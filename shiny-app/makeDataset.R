#' @title A function to build cancer dataset using BE1 sparse matrices.
#' @description This function extract from BE1 experiment a set of cells on the basis of the user requirement
#' @param cell.lines, a vector indicating the cell lines to be included in the dataset. Seven options:
#' @param n.cells, a vector indicating the number of cell for each cell line. If the number of cell exceed the number of available cell in a data set the full dataset is used.
#' @param output.folder, a character string indicating the path where to save the data.
#' @param input.folder, a character string indicating the path where BE1run12.zip from figshare https://figshare.com/articles/dataset/BE1_10XGenomics_count_matrices/23939481 has been downloaded.
#' @author Raffaele Calogero, raffaele.calogero [at] unito [dot] it, University of Torino, Italy
#' @return  A 10XGenomics sparse matrix
#'
#' @examples
#' \dontrun{
#'
#' #download https://figshare.com/articles/dataset/BE1_10XGenomics_count_matrices/23939481
#' #the downloade file is named BE1run12.zip
#' unzip("BE1run12.zip")
#' makeDataset(input.folder="/Users/raffaelecalogero/Desktop/BE1run12", output.folder="/Users/raffaelecalogero/Desktop/tmp", cell.lines = c("A549", "CCL-185-IG", "CRL5868", "DV90", "HCC78", "HTB178", "PC9", "PBMCs"), n.cells=c(100,100,100,100,100,100,100,10))
#'
#' }
#'
#' @export

library(Matrix)
library(MatrixExtra)
library("R.utils")


#cell.lines=list.dirs(input.folder, full.names = FALSE, recursive = FALSE)
#n.cells=c(100,10)
makeDataset <- function(input.folder, output.folder,n.cells,cell.lines,seed,nDataset){
n.cells=n.cells*nDataset
set.seed(seed)
for(i in 1:length(cell.lines)){
if(!is.numeric(n.cells[i])){
n.cells[i]=0
}
}
  matrix_dir = paste(input.folder, cell.lines[1], sep="/")
  barcode.path <- paste(matrix_dir, "barcodes.tsv.gz", sep="/")
  features.path <- paste(matrix_dir, "features.tsv.gz", sep="/")
  matrix.path <- paste(matrix_dir, "matrix.mtx.gz", sep="/")
  mat <- readMM(file = matrix.path)
  feature.names = read.delim(features.path, header = FALSE, stringsAsFactors = FALSE)
  col.mat.out =  vector(mode='list', length=nDataset)
mat.out=list()
  for(i in seq(nDataset)){
  mat.out[[i]] = emptySparse(nrow=dim(mat)[1], format="C")
  rownames(mat.out[[i]]) = feature.names$V1

  }
  start=1
  end=NULL
  for (i in 1:length(cell.lines)){
  if(n.cells[i]!=0){
    matrix_dir = paste(input.folder, cell.lines[i], sep="/")
    barcode.path <- paste(matrix_dir, "barcodes.tsv.gz", sep="/")
    features.path <- paste(matrix_dir, "features.tsv.gz", sep="/")
    matrix.path <- paste(matrix_dir, "matrix.mtx.gz", sep="/")
    mat <- readMM(file = matrix.path)
    feature.names = read.delim(features.path,
                             header = FALSE,
                             stringsAsFactors = FALSE)
    barcode.names = read.delim(barcode.path,
                             header = FALSE,
                             stringsAsFactors = FALSE)
    colnames(mat) = barcode.names$V1
    rownames(mat) = feature.names$V1
        if(n.cells[i]>ncol(mat)){
        n.cells[i]=ncol(mat)
        }

    #subsetting
    n.tmp = sample(x=seq(1,dim(mat)[2]), size=n.cells[i])
    vettori_divisi <- split(n.tmp, cut(seq_along(n.tmp), breaks = nDataset, labels = FALSE))
    for(jj in seq(nDataset)){

        col.mat.out[[jj]] = append(col.mat.out[[jj]], barcode.names$V1[vettori_divisi[[jj]]])
        tmp.mat.s = mat[,vettori_divisi[[jj]]]
        mat.out[[jj]]=cbind(mat.out[[jj]],tmp.mat.s)
    }

  }
}
finalName=c()
for(jj in seq(nDataset)){
  colnames(mat.out[[jj]]) = col.mat.out[[jj]]
  writeMM(mat.out[[jj]], file=file.path(output.folder, "matrix.mtx"))
  write(as.character(col.mat.out[[jj]]), file=file.path(output.folder, "barcodes.tsv"))
  write.table(feature.names, file=file.path(output.folder, "features.tsv"), row.names=FALSE, col.names=FALSE, quote=FALSE, sep="\t")
  sampling_info <- paste("For the dataset", cell.lines, "you sampled", n.cells/nDataset, "cells.")
  cat(sampling_info, file = file.path(output.folder, "sampling_info.txt"), sep = "\n")

  gzip(file.path(output.folder, "matrix.mtx"),overwrite=TRUE)
  gzip(file.path(output.folder, "barcodes.tsv"),overwrite=TRUE)
  gzip(file.path(output.folder, "features.tsv"),overwrite=TRUE)
  system(paste("cd ",output.folder,";tar -czvf output_",jj,".tar.gz matrix.mtx.gz barcodes.tsv.gz features.tsv.gz sampling_info.txt",sep=""))
  finalName=append(finalName,paste("output_",jj,".tar.gz ",sep=""))
}
  system(paste("cd ",output.folder,";tar -czvf output.tar.gz ",paste(finalName,collapse=" "),sep=""))


# writing borrowd from Write count data in the 10x format Aaron Lun



  return(TRUE)

}
