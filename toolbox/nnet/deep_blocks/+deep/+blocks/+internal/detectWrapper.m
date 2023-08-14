function[bboxes,scores,labels_idxs]=detectWrapper(...
    detector,...
    image,...
    detectArgs,...
    ssbmArgs)%#codegen




    coder.inline('always');
    coder.allowpcode('plain');


    [bboxes_temp,scores_temp,labels_categorical_temp]=detector.detect(image,detectArgs{:});
    labels_idxs_temp=single(labels_categorical_temp);


    [bboxes,scores,labels_idxs]=selectStrongestBboxMulticlass(bboxes_temp,scores_temp,labels_idxs_temp,ssbmArgs{:});

end
