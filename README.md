Bag of Words (BoW) based Image Search
-------------------------------------

Based on:   
[**Object Retrieval with Large Vocabularies and Fast Spatial Matching**](http://www.robots.ox.ac.uk/~vgg/publications/papers/philbin07.pdf)   
Philbin, J. and Chum, O. and Isard, M. and Sivic, J. and Zisserman, A.  *(CVPR 2007)*

(c) Rohit Girdhar

### Requirements
+ MATLAB
+ VLFeat (MATLAB API)

### Usage Instructions
Clone, cd into the project and run matlab
```bash
$ git clone https://github.com/rohitgirdhar/BoWImageMatching.git
$ cd BoWImageMatching
$ matlab
```
In MATLAB:
```matlab
>> cd src
>> edit bow_getDefaultParams.m % change the path to vlfeat's vl_setup script
>> bow_getDefaultParams; % get the params variable with default settings
```
#### Learn Vocabulary
```matlab
>> model = bow_computeVocab('~/imagesDir', params);
```
#### Learn Inverted Index over corpus
```matlab
>> iindex = bow_buildInvIndex('~/imagesDir', model);
```
#### Test time: search for a query image
```matlab
>> I = imread('path/to/img.jpg');
>> config.topn = 10; % set the number of top matches to retrieve
>> config.geomRerank = 1; % set to have geometric reranking, ignore if not.
>> res = bow_imageSearch(I, model, iindex, config);
>> res{1} % prints the image paths (relative to base directory) of top matches
>> res{2} % prints the scores: tf-idf without geometric reranking, and #inliers with geometric reranking
```
Note: Geometric reranking done by fitting a fundamental matrix using RANSAC, and counting the number of inliers.

