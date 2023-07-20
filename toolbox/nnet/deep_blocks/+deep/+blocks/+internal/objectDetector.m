function[varargout]=objectDetector(...
    image,...
    detectorToLoad,...
    useExtrinsic,...
    detectArgs,...
    ssbmArgs,...
    maxDetections,...
    bboxesEnabled,...
    labelsEnabled,...
    scoresEnabled)%#codegen





    coder.inline('always');
    coder.allowpcode('plain');
    coder.extrinsic('coder.internal.getFileInfo');


    fileName=coder.const(@coder.internal.getFileInfo,detectorToLoad);
    coder.internal.addDependentFile(fileName);
    persistent detector;
    if isempty(detector)
        if coder.const(useExtrinsic)
            detector=feval('deep.blocks.internal.loadObjectDetector',coder.const(detectorToLoad));
        else
            detector=coder.loadDeepLearningNetwork(coder.const(detectorToLoad));
        end
    end


    dims=ndims(image);
    coder.internal.assert(any(dims==[2,3]),'vision:ObjectDetectorBlock:InvalidImage');

    if coder.const(useExtrinsic)
        detectorClass=coder.const(feval('deep.blocks.internal.loadObjectDetector',coder.const(detectorToLoad),'ReturnDetectorClassName',true));



        if coder.const(any(strcmp(detectorClass,{'yolov2ObjectDetector','ssdObjectDetector',...
            'rcnnObjectDetector','fastRCNNObjectDetector','fasterRCNNObjectDetector'})))
            bboxes=coder.nullcopy(zeros(maxDetections,4,'double'));%#ok
        elseif coder.const(any(strcmp(detectorClass,{'yolov3ObjectDetector','yolov4ObjectDetector'})))
            bboxes=coder.nullcopy(zeros(maxDetections,4,'single'));%#ok
        end



        scores=coder.nullcopy(zeros(maxDetections,1,'single'));%#ok
        labelsIdxs=coder.nullcopy(zeros(maxDetections,1,'single'));%#ok

        coder.varsize('bboxes','scores','labelsIdxs');

        [bboxes,scores,labelsIdxs]=feval('deep.blocks.internal.detectWrapper',detector,image,detectArgs,ssbmArgs);
    else
        [bboxes,scores,labelsIdxs]=deep.blocks.internal.detectWrapper(detector,image,detectArgs,ssbmArgs);
    end


    startIndex=0;
    if coder.const(bboxesEnabled)
        startIndex=startIndex+1;
        varargout{coder.const(startIndex)}=bboxes;
    end

    if coder.const(labelsEnabled)
        startIndex=startIndex+1;
        varargout{coder.const(startIndex)}=labelsIdxs;
    end

    if coder.const(scoresEnabled)
        startIndex=startIndex+1;
        varargout{coder.const(startIndex)}=scores;
    end

end
