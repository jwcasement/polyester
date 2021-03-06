% Generated by roxygen2 (4.0.2): do not edit by hand
\name{simulate_experiment_multi}
\alias{simulate_experiment_multi}
\title{simulate RNA-seq experiment with multiple groups with negative binomial model}
\usage{
simulate_experiment_multi(fasta = NULL, gtf = NULL, seqpath = NULL,
  num_reps = c(5, 5, 5), fraglen = 250, fragsd = 25, readlen = 100,
  lib_sizes = NULL, error_rate = 0.005, error_model = "uniform",
  model_path = NULL, model_prefix = NULL, paired = TRUE,
  reads_per_transcript = 300, fold_changes, size = NULL, outdir = ".",
  write_info = TRUE, transcriptid = NULL, seed = NULL, ...)
}
\arguments{
\item{fasta}{path to FASTA file containing transcripts from which to simulate
reads. See details.}

\item{gtf}{path to GTF file containing transcript structures from which reads
should be simulated. See details.}

\item{seqpath}{path to folder containing one FASTA file (\code{.fa}
extension) for each chromosome in \code{gtf}. See details.}

\item{num_reps}{How many biological replicates should be in each group? The
length \code{num_reps} determines how many groups are in the experiment.
For example, \code{num_reps = c(5,6,5)} specifies a 3-group experiment with
5 samples in group 1, 6 samples in group 2, and 5 samples in group 3.
Defaults to a 3-group experiment with 5 reps per group (i.e.,
\code{c(5,5,5)}).}

\item{fraglen}{Mean RNA fragment length. Sequences will be read off the
end(s) of these fragments. Default 250.}

\item{fragsd}{Standard deviation of fragment lengths. Default 25.}

\item{readlen}{Read length. Default 100.}

\item{lib_sizes}{Library size factors for the biological replicates.
\code{lib_sizes} should have length equal to the total number of
replicates in the experiment, i.e., \code{sum(num_reps)}. For each
replicate, once the number of reads to simulate from each transcript for
that replicate is known, all read numbers across all transcripts from that
replicate are multiplied by the corresponding entry in \code{lib_sizes}.}

\item{error_rate}{Sequencing error rate. Must be between 0 and 1. Only used
if error_model is \code{'uniform'}.}

\item{error_model}{one of \code{'uniform'}, \code{'custom'},
\code{'illumina4'}, \code{'illumina5'}, or \code{'roche454'} specifying
which sequencing error model to use while generating reads. See
\code{?add_platform_error} for more information.}

\item{model_path}{If using a custom error model, the output folder you
provided to \code{build_error_model.py}. Should contain either two files
suffixed _mate1 and _mate2, or a file suffixed _single.}

\item{model_prefix}{If using a custom error model, the prefix argument you
provided to \code{build_error_model.py}. This is whatever comes before
_mate1 and _mate2 or _single files in \code{model_path}.}

\item{paired}{If \code{TRUE}, paired-end reads are simulated; else
single-end reads are simulated.}

\item{reads_per_transcript}{baseline mean number of reads to simulate
from each transcript. Can be an integer, in which case this many reads
are simulated from each transcript, or an integer vector whose length
matches the number of transcripts in \code{fasta}.}

\item{fold_changes}{Matrix specifying multiplicative fold changes between
groups, with the same number of rows as there are transcripts in
\code{fasta} and the same number of columns as there are groups (i.e.,
entries in \code{num_reps}). A fold change of X in matrix entry i,j means
that for replicate j, the baseline mean number of reads
(reads_per_transcript[i]) will be multiplied by X. Note that the
multiplication happens before the negative binomial value
(for the number of reads that *actually will* be
drawn from transcript i, for replicate j) is drawn.}

\item{size}{the negative binomial \code{size} parameter (see
\code{\link{NegBinomial}}) for the number of reads drawn per transcript.
It can be a matrix (where the user can specify the size parameter per
transcript, per group), a vector (where the user can specify the size per
transcript, perhaps relating to reads_per_transcript), or a single number,
specifying the size for all transcripts and groups.
If left NULL, defaults to \code{reads_per_transcript * fold_changes / 3}.
Negative binomial variance is mean + mean^2 / size.}

\item{outdir}{character, path to folder where simulated reads should be
written, with *no* slash at the end. By default, reads are
written to current working directory.}

\item{write_info}{If \code{TRUE}, write a file matching transcript IDs to
differential expression status into the file \code{outdir/sim_tx_info.txt}
and a file matching biological replicate IDs to group membership and
library size into the file \code{outdir/sim_rep_info.txt}.}

\item{transcriptid}{optional vector of transcript IDs to be written into
\code{sim_info.txt} and used as transcript identifiers in the fasta files.
Defaults to \code{names(readDNAStringSet(fasta))}. This option is useful
if default names are very long or contain special characters.}

\item{seed}{Optional seed to set before simulating reads, for
reproducibility.}

\item{...}{additional arguments to pass to \code{seq_gtf} if using
\code{gtf} and \code{seqpath}}
}
\value{
No return, but simulated reads and optional simulation info files
  are written to \code{outdir}.
}
\description{
create FASTA files containing RNA-seq reads simulated from provided
  transcripts, with optional differential expression between many groups
}
\details{
Reads can either be simulated from a FASTA file of transcripts
  (provided with the \code{fasta} argument) or from a GTF file plus DNA
  sequences (provided with the \code{gtf} and \code{seqpath} arguments).
  Simulating from a GTF file and DNA sequences may be a bit slower: it took
  about 6 minutes to parse the GTF/sequence files for chromosomes 1-22, X,
  and Y in hg19.

  Simulation information is written out into files. Briefly, samples 1
  through \code{num_reps[1]} are in group 1, samples \code{num_reps[1]+1)}
  through \code{num_reps[1]+num_reps[2]} are in group 2, etc.
}
\examples{
## simulate a few reads from chromosome 22, for a 3-group experiment

  fastapath = system.file("extdata", "chr22.fa", package="polyester")
  numtx = count_transcripts(fastapath)
  set.seed(4)
  fold_changes = matrix(1, nrow=numtx, ncol=3)
  fold_changes[1:20, 2] = 3
  fold_changes[199:220, 3] = 0.8
  fold_changes[407:422, 1] = 2
  ## these fold changes imply that transcripts 1-20 are overexpressed in
  ## group 2 (fc=3x), transcripts 199-220 are underexpressed in group 3
  ## (fc=0.8), and transcripts 407-422 are overexpressed in group 1 (fc=2).

  library(Biostrings)
  # remove quotes from transcript IDs:
  tNames = gsub("'", "", names(readDNAStringSet(fastapath)))

  simulate_experiment_multi(fastapath, reads_per_transcript=10,
     num_reps=c(5,6,4), fold_changes=fold_changes, outdir='simulated_reads',
     transcriptid=tNames, seed=12)
}

