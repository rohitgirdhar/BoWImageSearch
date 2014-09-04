Bag of Words (BoW) based Image Search
-------------------------------------

Based on:   
[**Object Retrieval with Large Vocabularies and Fast Spatial Matching**](http://www.robots.ox.ac.uk/~vgg/publications/papers/philbin07.pdf)   
Philbin, J. and Chum, O. and Isard, M. and Sivic, J. and Zisserman, A.  *(CVPR 2007)*

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
Alternate option: Train only on subset of images from `imagesDir/`, given from a list
```matlab
>> model = bow_computeVocab('~/imagesDir', params, 'imgsListFpath', '/path/to/TrainSet.txt');
```
#### Learn Inverted Index over corpus
```matlab
>> iindex = bow_buildInvIndex('~/imagesDir', model);
```
Alternate option: Train only on subset of images from `imagesDir/`, given from a list
```matlab
>> iindex = bow_buildInvIndex('../../../datasets/hussain_hotels/corpus', model, 'imgsListFpath', '../eval/TrainSet.txt');
```
#### Test time: search for a query image
```matlab
>> I = imread('path/to/img.jpg');
>> config.topn = 10; % set the number of top matches to retrieve
>> config.geomRerank = 1; % set to have geometric reranking, ignore if not.
>> [imgPaths, scores] = bow_imageSearch(I, model, iindex, config);
>> imgPaths % prints the image paths (relative to base directory) of top matches
>> scores % prints the scores: tf-idf without geometric reranking, and #inliers with geometric reranking
```
Note: Geometric reranking done by fitting a fundamental matrix using RANSAC, and counting the number of inliers.

### Evaluation
The dataset should be arranged in a directory structure as follows:
```text
|-corpus/
    |--class1
    |   |--img1.jpg
    |   |--img2.jpg
    |--class2
    |   |--img1.jpg
```
#### Split test train set
This distribution already has `eval/TestSet.txt` and `eval/TrainSet.txt`. Use this only to recompute these sets.
```matlab
>> [train, test] = splitTestTrain('path/to/corpus/', 700); % 700 is the number of images in test set. remaining in train.
>> f = fopen('TrainSet.txt', 'w'); % write it out to this file
>> for i = 1 : numel(train)
     fprintf(f, '%s\n', train{i});
   end
>> % similarly for the test set
```
#### Running evaluation
```matlab
>> matlabpool open <ncores> % use parpool on newer matlab version
>> cd $PROJECT_ROOT/eval
>> runTests('/path/to/corpus/', model, iindex, '/path/to/output_dir', 'imgsListFpath', '/path/to/TestSet.txt')
```
----

**Copyright (C) 2014 by Rohit Girdhar**

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
