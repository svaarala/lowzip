#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "lowzip.h"

typedef struct {
	FILE *input;
	unsigned int input_length;
	unsigned char input_chunk[256];
	unsigned int input_chunk_start;
	unsigned int input_chunk_end;
} read_state;

/* Read callback which uses a single cached chunk to minimize file I/O. */
unsigned int my_read(void *udata, unsigned int offset) {
	read_state *st;
	size_t got;
	int chunk_start;

	st = (read_state *) udata;

	/* Most reads should be cached here with no file I/O. */
	if (offset >= st->input_chunk_start && offset < st->input_chunk_end) {
		return (unsigned int) st->input_chunk[offset - st->input_chunk_start];
	}

	/* Out-of-bounds read, no file I/O. */
	if (offset >= st->input_length) {
		fprintf(stderr, "OOB read (offset %ld)\n", (long) offset);
		return 0x100U;
	}

	/* Load in new chunk so that desired offset is in the middle.
	 * This makes backwards and forwards scanning reasonably
	 * efficient.
	 */
	chunk_start = offset - sizeof(st->input_chunk) / 2;
	if (chunk_start < 0) {
		chunk_start = 0;
	}
	if (fseek(st->input, (size_t) chunk_start, SEEK_SET) != 0) {
		return 0x100U;
	}
	got = fread((void *) st->input_chunk, 1, sizeof(st->input_chunk), st->input);
	st->input_chunk_start = chunk_start;
	st->input_chunk_end = chunk_start + got;

	/* Recheck original request. */
	if (offset >= st->input_chunk_start && offset < st->input_chunk_end) {
		return (unsigned int) st->input_chunk[offset - st->input_chunk_start];
	}
	return 0x100U;
}

static int extract_located_file(lowzip_state *st, lowzip_file *fileinfo, int ignore_errors) {
	void *buf = NULL;
	int retcode = 1;

	fprintf(stderr, "Extracting %s (%ld bytes -> %ld bytes)\n",
	        fileinfo->filename, (long) fileinfo->compressed_size,
	        (long) fileinfo->uncompressed_size);

	buf = malloc(fileinfo->uncompressed_size);
	if (!buf) {
		fprintf(stderr, "Failed to allocate\n");
		return 1;
	}

	st->output_start = buf;
	st->output_end = buf + fileinfo->uncompressed_size;
	st->output_next = st->output_start;

	lowzip_get_data(st);

	if (st->have_error) {
		if (ignore_errors) {
			fprintf(stderr, "Failed to extract (ignoring as requested)\n");
			retcode = 0;
		} else {
			fprintf(stderr, "Failed to extract\n");
		}
	} else {
		fwrite((void *) st->output_start, 1, (size_t) (st->output_next - st->output_start), stdout);
		retcode = 0;
	}

	free(buf);

	return retcode;
}

static int extract_raw_inflate(lowzip_state *st, int ignore_errors) {
	size_t buf_size = 256L * 1024L * 1024L;  /* 256MB just for testing; don't know size beforehand. */
	void *buf = NULL;
	int retcode = 1;

	buf = malloc(buf_size);
	if (!buf) {
		fprintf(stderr, "Failed to allocate\n");
		return 1;
	}

	st->read_offset = 0;
	st->output_start = buf;
	st->output_end = buf + buf_size;
	st->output_next = st->output_start;

	lowzip_inflate_raw(st);

	if (st->have_error) {
		if (ignore_errors) {
			fprintf(stderr, "Failed to inflate (ignoring as requested)\n");
			retcode = 0;
		} else {
			fprintf(stderr, "Failed to inflate\n");
		}
	} else {
		fwrite((void *) st->output_start, 1, (size_t) (st->output_next - st->output_start), stdout);
		retcode = 0;
	}

	return retcode;
}

/* Main program. */
int main(int argc, char *argv[]) {
	lowzip_state st;
	read_state read_st;
	lowzip_file *fileinfo;
	const char *zip_filename = NULL;
	const char *file_filename = NULL;
	int ignore_errors = 0;
	int raw_inflate = 0;
	int file_index = -1;
	int retcode = 1;
	FILE *input = NULL;
	void *buf = NULL;
	int i;

	memset((void *) &st, 0, sizeof(st));
	memset((void *) &read_st, 0, sizeof(read_st));

	for (i = 1; i < argc; i++) {
		if (strcmp(argv[i], "--ignore-errors") == 0) {
			ignore_errors = 1;
		} else if (strcmp(argv[i], "--raw-inflate") == 0) {
			raw_inflate = 1;
		} else {
			if (zip_filename == NULL) {
				zip_filename = argv[i];
			} else {
				if (file_filename || file_index >= 0) {
					goto invalid_args;
				}
				if (sscanf(argv[i], "%d", &file_index) == 1) {
					/* Use file index to find file. */
				} else {
					/* Use filename to find file. */
					file_filename = argv[i];
				}
			}
		}
	}
	if (zip_filename == NULL) {
		goto invalid_args;
	}

	input = fopen(zip_filename, "rb");
	if (!input) {
		goto invalid_zip;
	}
	if (fseek(input, 0, SEEK_END) != 0) {
		goto invalid_zip;
	}
	read_st.input = input;
	read_st.input_length = (unsigned int) ftell(input);
	fprintf(stderr, "ZIP input is %s, %ld bytes\n", zip_filename, (long) read_st.input_length);
#if 0
	fprintf(stderr, "sizeof(lowzip_state) = %ld bytes\n", (long) sizeof(lowzip_state));
#endif

	st.udata = (void *) &read_st;
	st.read_callback = my_read;
	st.zip_length = read_st.input_length;

	if (raw_inflate) {
		/* This is just for testing, the lowzip_inflate_raw() call
		 * is not part of the actual API.
		 */

		fprintf(stderr, "Inflating (raw inflate) %s\n", zip_filename);

		if (extract_raw_inflate(&st, ignore_errors) == 0) {
			retcode = 0;
		}
	} else {
		lowzip_init_archive(&st);
		if (st.have_error) {
			fprintf(stderr, "Lowzip archive init failed\n");
			goto done;
		}

		if (file_filename) {
			fileinfo = lowzip_locate_file(&st, 0, file_filename);
			if (!fileinfo) {
				fprintf(stderr, "File %s not found in archive\n", file_filename);
				goto done;
			}

			if (extract_located_file(&st, fileinfo, ignore_errors) == 0) {
				retcode = 0;
			}
		} else if (file_index >= 0) {
			fileinfo = lowzip_locate_file(&st, file_index, NULL);
			if (!fileinfo) {
				fprintf(stderr, "File at index %ld not found in archive\n", (long) file_index);
				goto done;
			}

			if (extract_located_file(&st, fileinfo, ignore_errors) == 0) {
				retcode = 0;
			}
		} else {
			/* Without a file name/index, scan all files. */
			for (i = 0; ; i++) {
				fileinfo = lowzip_locate_file(&st, i, NULL);
				if (!fileinfo) {
					break;
				}
				fprintf(stdout, "%s\n", fileinfo->filename);
			}
			retcode = 0;
		}
	}

 done:
	if (buf) {
		free(buf);
		buf = NULL;
	}
	if (input) {
		(void) fclose(input);
		input = NULL;
	}
	return retcode;

 invalid_zip:
	fprintf(stderr, "Failed to open input file %s\n", zip_filename);
	goto done;

 invalid_args:
	fprintf(stderr, "Usage: ./test_lowzip [--ignore-errors] foo.zip test.txt           # extract file to stdout\n"
	                "       ./test_lowzip [--ignore-errors] foo.zip 3                  # extract Nth file to stdout\n"
	                "       ./test_lowzip [--ignore-errors] foo.zip                    # list files to stdout\n"
	                "       ./test_lowzip [--ignore-errors] --raw-inflate foo.deflate  # inflate raw deflate input to stdout\n");
	goto done;
}
