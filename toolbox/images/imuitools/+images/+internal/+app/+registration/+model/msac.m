function[isFound,bestModelParams,inliers,reachedMaxSkipTrials]=msac(...
    allPoints,params,funcs,varargin)

























%#codegen

    confidence=params.confidence;
    sampleSize=params.sampleSize;
    maxDistance=params.maxDistance;

    threshold=cast(maxDistance,'like',allPoints);
    numPts=size(allPoints,1);
    idxTrial=1;
    numTrials=int32(params.maxNumTrials);
    maxDis=cast(threshold*numPts,'like',allPoints);
    bestDis=maxDis;

    if isfield(params,'defaultModel')
        bestModelParams=params.defaultModel;
    else
        bestModelParams=zeros(0,'like',allPoints);
    end

    if isfield(params,'maxSkipTrials')
        maxSkipTrials=params.maxSkipTrials;
    else
        maxSkipTrials=params.maxNumTrials*10;
    end
    skipTrials=0;

    bestInliers=false(numPts,1);



    rng('default');


    while idxTrial<=numTrials&&skipTrials<maxSkipTrials

        indices=randperm(numPts,sampleSize);


        samplePoints=allPoints(indices,:,:);
        modelParams=funcs.fitFunc(samplePoints,varargin{:});


        isValidModel=funcs.checkFunc(modelParams,varargin{:});

        if isValidModel

            [model,dis,accDis]=evaluateModel(funcs.evalFunc,modelParams,...
            allPoints,threshold,varargin{:});


            if accDis<bestDis
                bestDis=accDis;
                bestInliers=dis<threshold;
                bestModelParams=model;
                inlierNum=cast(sum(dis<threshold),'like',allPoints);
                num=computeLoopNumber(sampleSize,...
                confidence,numPts,inlierNum);
                numTrials=min(numTrials,num);
            end

            idxTrial=idxTrial+1;
        else
            skipTrials=skipTrials+1;
        end
    end

    isFound=funcs.checkFunc(bestModelParams,varargin{:})&&...
    ~isempty(bestInliers)&&sum(bestInliers(:))>=sampleSize;
    if isFound
        if isfield(params,'recomputeModelFromInliers')&&...
            params.recomputeModelFromInliers
            modelParams=funcs.fitFunc(allPoints(bestInliers,:,:),varargin{:});
            [bestModelParams,dis]=evaluateModel(funcs.evalFunc,modelParams,...
            allPoints,threshold,varargin{:});
            isValidModel=funcs.checkFunc(bestModelParams,varargin{:});
            inliers=(dis<threshold);
            if~isValidModel||~any(inliers)
                isFound=false;
                inliers=false(size(allPoints,1),1);
                return;
            end
        else
            inliers=bestInliers;
        end

        if isempty(coder.target)&&numTrials>=int32(params.maxNumTrials)
            warning(message('vision:ransac:maxTrialsReached'));
        end
    else
        inliers=false(size(allPoints,1),1);
    end

    reachedMaxSkipTrials=skipTrials>=maxSkipTrials;


    function[modelOut,distances,sumDistances]=evaluateModel(evalFunc,modelIn,...
        allPoints,threshold,varargin)
        dis=evalFunc(modelIn,allPoints,varargin{:});
        dis(dis>threshold)=threshold;
        accDis=sum(dis);
        if iscell(modelIn)
            [sumDistances,minIdx]=min(accDis);
            distances=dis(:,minIdx);
            modelOut=modelIn{minIdx(1)};
        else
            distances=dis;
            modelOut=modelIn;
            sumDistances=accDis;
        end




        function N=computeLoopNumber(sampleSize,confidence,pointNum,inlierNum)
%#codegen
            pointNum=cast(pointNum,'like',inlierNum);
            inlierProbability=(inlierNum/pointNum)^sampleSize;

            if inlierProbability<eps(class(inlierNum))
                N=intmax('int32');
            else
                conf=cast(0.01,'like',inlierNum)*confidence;
                one=ones(1,'like',inlierNum);
                num=log10(one-conf);
                den=log10(one-inlierProbability);
                N=int32(ceil(num/den));
            end


