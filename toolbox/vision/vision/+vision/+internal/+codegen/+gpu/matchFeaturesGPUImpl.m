









%#codegen
function[matchMetric_final,indexPairs_final]=...
    matchFeaturesGPUImpl(ref_featureSet_inp,qry_featureSet_inp,metric,matchThreshold,maxRatio,uniqueness)%#codegen

    coder.allowpcode('plain');


    coder.gpu.internal.kernelfunImpl(false);


    if(maxRatio>1)
        maxRatio=1;
    end




    if strcmpi(metric,'SAD')
        compareMethod=2;
    elseif strcmpi(metric,'SSD')
        compareMethod=1;
    else
        compareMethod=0;
    end


    if(isa(ref_featureSet_inp,'double'))
        outputClass='double';
    else
        outputClass='single';
    end


    ref_featureSet=cast(ref_featureSet_inp,outputClass);
    qry_featureSet=cast(qry_featureSet_inp,outputClass);


    coder.internal.errorIf(size(ref_featureSet,2)~=size(qry_featureSet,2),...
    'gpucoder:common:MatchFeaturesDimensionMisMatchError');



    ref_featureSet=transpose(ref_featureSet);
    qry_featureSet=transpose(qry_featureSet);





    refFeatures_num=size(ref_featureSet,2);
    qryFeatures_num=size(qry_featureSet,2);
    featureLength=size(ref_featureSet,1);



    if compareMethod


        ref_sqMat=bsxfun(@times,ref_featureSet,ref_featureSet);
        ref_sumMat=sum(ref_sqMat);
        ref_sqrtMat=sqrt(ref_sumMat);
        ref_sqrtMat(ref_sqrtMat<1e-5)=1;
        ref_featureSet=bsxfun(@rdivide,ref_featureSet,ref_sqrtMat);

        qry_sqMat=bsxfun(@times,qry_featureSet,qry_featureSet);
        qry_sumMat=sum(qry_sqMat);
        qry_sqrtMat=sqrt(qry_sumMat);
        qry_sqrtMat(qry_sqrtMat<1e-5)=1;
        qry_featureSet=bsxfun(@rdivide,qry_featureSet,qry_sqrtMat);
    end


    ssdFunc=@(qD,rD)(rD-qD).*(rD-qD);
    sadFunc=@(qD,rD)abs(rD-qD);

    if coder.internal.isConst(size(ref_featureSet_inp))||coder.internal.isConst(size(qry_featureSet_inp))



        if compareMethod==1
            distanceScoreMat=gpucoder.matrixMatrixKernel(ssdFunc,qry_featureSet,ref_featureSet,'tn');
        elseif compareMethod==2
            distanceScoreMat=gpucoder.matrixMatrixKernel(sadFunc,qry_featureSet,ref_featureSet,'tn');
        else
            distanceScoreMat=gpucoder.matrixMatrixKernel(@hamFunc,qry_featureSet,ref_featureSet,'tn');
        end
    else


        coder.internal.compileWarning('gpucoder:common:MatchFeaturesVarDims');

        numThreads=32;
        numBlocks=ceil((refFeatures_num*qryFeatures_num)/numThreads);
        distanceScoreMat=zeros(qryFeatures_num,refFeatures_num,outputClass);
        coder.gpu.internal.kernelImpl(false,numBlocks,numThreads,-1,'distMatComputation');
        for rowIter=1:qryFeatures_num
            for colIter=1:refFeatures_num
                if compareMethod==1
                    distanceScoreMat(rowIter,colIter)=sum(bsxfun(ssdFunc,qry_featureSet(:,rowIter),ref_featureSet(:,colIter)));
                elseif compareMethod==2
                    distanceScoreMat(rowIter,colIter)=sum(bsxfun(sadFunc,qry_featureSet(:,rowIter),ref_featureSet(:,colIter)));
                else
                    sumVal=0;
                    for i=1:length(qry_featureSet(:,rowIter))
                        sumVal=sumVal+hamFunc(qry_featureSet(i,rowIter),ref_featureSet(i,colIter));
                    end
                    distanceScoreMat(rowIter,colIter)=sumVal;
                end
            end
        end
    end




    if compareMethod==1
        matchThreshold=matchThreshold*0.01*4.0;
    elseif compareMethod==2
        matchThreshold=matchThreshold*0.01*2.0*sqrt(featureLength);
    else
        matchThreshold=round(matchThreshold*0.01*8.0*featureLength);
    end
    matchThreshold=cast(matchThreshold,outputClass);


    indexPairs_nn=zeros(refFeatures_num,2,'uint32');
    matchMetric_nn=zeros(refFeatures_num,2,outputClass);



    numThreads=32;
    numBlocks=ceil(refFeatures_num/numThreads);
    coder.gpu.internal.kernelImpl(false,numBlocks,numThreads,-1,'distSortKernel');
    for colIter=1:refFeatures_num
        min_1st=cast(Inf,outputClass);min_2nd=cast(Inf,outputClass);
        minIdx=uint32(Inf);
        for rowIter=1:qryFeatures_num
            if(distanceScoreMat(rowIter,colIter)<min_2nd)
                tmpVal=distanceScoreMat(rowIter,colIter);
                min_2nd=tmpVal;
                if(min_2nd<min_1st)
                    min_2nd=min_1st;
                    min_1st=tmpVal;
                    minIdx=uint32(rowIter);
                end
            end
        end
        indexPairs_nn(colIter,:)=[colIter,minIdx];
        matchMetric_nn(colIter,:)=[min_1st,min_2nd];
    end






    indexPairs_postFiltering=zeros(refFeatures_num,2,'uint32');
    matchMetric_postFiltering=zeros(refFeatures_num,1,outputClass);


    numThreads=32;
    numBlocks=ceil(refFeatures_num/numThreads);
    coder.gpu.internal.kernelImpl(false,numBlocks,numThreads,-1,'filterKernel');
    for colIter=1:refFeatures_num


        if(matchMetric_nn(colIter,1)<=matchThreshold)

            tempDistPair=matchMetric_nn(colIter,:);
            if tempDistPair(2)<cast(1e-6,outputClass)
                tempDistPair(:)=1;
            end
            ratioVal=tempDistPair(1)/tempDistPair(2);


            if(ratioVal<=maxRatio)
                indexPairs_postFiltering(colIter,:)=indexPairs_nn(colIter,:);
                matchMetric_postFiltering(colIter)=matchMetric_nn(colIter,1);
            end
        end
    end


    distanceScoreMat_t=transpose(distanceScoreMat);
    if uniqueness
        numPairs=length(indexPairs_postFiltering(:,1));
        uniqueIdx=zeros(numPairs,1,'logical');


        numThreads=32;
        numBlocks=ceil(numPairs/numThreads);
        coder.gpu.internal.kernelImpl(false,numBlocks,numThreads,-1,'uniqueFlagKernel');
        for pairIter=1:numPairs
            tmpIdx=indexPairs_postFiltering(pairIter,:);
            minVal=cast(Inf,outputClass);
            minIdx=uint32(Inf);
            if(tmpIdx(1)~=0&&tmpIdx(2)~=0)
                for rowIter=1:refFeatures_num
                    tmpDistVal=distanceScoreMat_t(rowIter,tmpIdx(2));
                    if(tmpDistVal<=minVal)
                        if(tmpDistVal==minVal)
                            minIdx=min(uint32(rowIter),minIdx);
                        else
                            minIdx=uint32(rowIter);
                        end
                        minVal=distanceScoreMat_t(rowIter,tmpIdx(2));
                    end
                end
                if(minIdx==tmpIdx(1))
                    uniqueIdx(pairIter)=1;
                else
                    uniqueIdx(pairIter)=0;
                end
            else
                uniqueIdx(pairIter)=0;
            end
        end

        indexPairs_final=indexPairs_postFiltering(uniqueIdx,:);
        matchMetric_final=cast(matchMetric_postFiltering(uniqueIdx,:),outputClass);
    else
        indexPairs_final=indexPairs_postFiltering(indexPairs_postFiltering(:,1)>0,:);
        matchMetric_final=cast(matchMetric_postFiltering(indexPairs_postFiltering(:,1)>0,:),outputClass);
    end
end


function hamOut=hamFunc(qD,rD)
    xorVals=single(bitxor(uint8(rD),uint8(qD)));
    tmpVals=floor(xorVals.*pow2(-7:0));
    rem_tmpVal=(tmpVals/2-floor(tmpVals/2))*2;
    hamOut=double(sum(rem_tmpVal));
end
