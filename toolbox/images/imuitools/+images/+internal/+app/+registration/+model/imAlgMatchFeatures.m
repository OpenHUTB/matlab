function[indexPairs,matchMetric]=imAlgMatchFeatures(features1in,...
    features2in,metric,...
    matchPercentage,method,...
    maxRatioThreshold,isPrenormalized,...
    uniqueMatches)





%#codegen


    if(isa(features1in,'double'))
        outputClass='double';
    else
        outputClass='single';
    end

    if isempty(features1in)||isempty(features2in)
        indexPairs=zeros(2,0,'uint32');
        matchMetric=zeros(1,0,outputClass);
        return;
    end


    [features1,features2]=castFeatures(features1in,features2in,metric,outputClass);


    if~isPrenormalized&&~strcmpi(metric,'hamming')
        [features1,features2]=normalizeFeatures(features1,features2,method,metric);
    end


    matchThreshold=percentToLevel(matchPercentage,size(features1,1),...
    metric,outputClass);


    [indexPairs,matchMetric]=findMatchesExhaustive(features1,features2,...
    metric,maxRatioThreshold,matchThreshold,uniqueMatches,outputClass);




    function[indexPairs,matchMetric]=findMatchesExhaustive(features1,features2,...
        metric,maxRatioThreshold,matchThreshold,uniqueMatches,outputClass)




        N1=uint32(size(features1,2));
        N2=uint32(size(features2,2));

        scores=exhaustiveDistanceMetrics(features1,features2,N1,N2,outputClass,metric);

        [indexPairs,matchMetric]=findNearestNeighbors(scores,metric);

        [indexPairs,matchMetric]=removeWeakMatches(indexPairs,...
        matchMetric,matchThreshold,metric);

        [indexPairs,matchMetric]=removeAmbiguousMatches(indexPairs,...
        matchMetric,maxRatioThreshold,N2,metric);

        if uniqueMatches
            uniqueIndices=findUniqueIndices(scores,metric,indexPairs);
        else

            uniqueIndices=true(1,size(indexPairs,2));
        end
        indexPairs=indexPairs(:,uniqueIndices);
        matchMetric=matchMetric(1,uniqueIndices);






        function[indexPairs,topTwoMetrics]=findNearestNeighbors(scores,metric)

            if strcmp(metric,'normxcorr')
                [topTwoMetrics,topTwoIndices]=partialSort(scores,2,'descend');
            else
                [topTwoMetrics,topTwoIndices]=partialSort(scores,2,'ascend');
            end

            indexPairs=vertcat(uint32(1:size(scores,1)),topTwoIndices(1,:));




            function scores=exhaustiveDistanceMetrics(features1,features2,...
                N1,N2,outputClass,metric)

                switch metric
                case 'sad'

                    scores=metricSAD(features1,features2,N1,N2,outputClass);
                case 'normxcorr'

                    scores=metricNormXCorr(features1,features2);
                case 'ssd'

                    scores=metricSSD(features1,features2,N1,N2,outputClass);
                otherwise

                    scores=metricHamming(features1,features2,N1,N2,outputClass);
                end




                function[indexPairs,matchMetric]=removeAmbiguousMatches(indexPairs,...
                    matchMetric,maxRatio,N2,metric)

                    if N2>1

                        unambiguousIndices=findUnambiguousMatches(matchMetric,maxRatio,metric);
                    else
                        unambiguousIndices=true(1,size(matchMetric,2));
                    end

                    indexPairs=indexPairs(:,unambiguousIndices);
                    matchMetric=matchMetric(1,unambiguousIndices);




                    function uniqueIndices=findUniqueIndices(scores,metric,...
                        indexPairs)

                        if strcmpi(metric,'normxcorr')
                            [~,idx]=max(scores(:,indexPairs(2,:)));
                        else
                            [~,idx]=min(scores(:,indexPairs(2,:)));
                        end

                        uniqueIndices=idx==indexPairs(1,:);




                        function[features1,features2]=normalizeFeatures(features1,features2,...
                            method,metric)



                            if strcmp(method,'nearestneighbor_old')&&...
                                strcmp(metric,'normxcorr')

                                f1Mean=mean(features1);
                                features1=bsxfun(@minus,features1,f1Mean);
                                f2Mean=mean(features2);
                                features2=bsxfun(@minus,features2,f2Mean);
                            end


                            features1=normalizeX(features1);
                            features2=normalizeX(features2);




                            function matchThreshold=percentToLevel(matchPercentage,...
                                vector_length,metric,outputClass)

                                matchPercentage=cast(matchPercentage,outputClass);
                                vector_length=cast(vector_length,outputClass);

                                if(strcmp(metric,'normxcorr'))
                                    matchThreshold=cast(0.01,outputClass)*(cast(100,outputClass)...
                                    -matchPercentage);
                                else
                                    if(strcmp(metric,'sad'))
                                        max_val=cast(2,outputClass)*sqrt(vector_length);
                                    elseif(strcmp(metric,'ssd'))
                                        max_val=cast(4,outputClass);
                                    else


                                        max_val=cast(8*vector_length,outputClass);
                                    end

                                    matchThreshold=(matchPercentage*cast(0.01,outputClass))*max_val;

                                    if strcmp(metric,'hamming')

                                        matchThreshold=round(matchThreshold);
                                    end
                                end




                                function[features1,features2]=castFeatures(features1in,features2in,...
                                    metric,outputClass)

                                    if~strcmp(metric,'hamming')
                                        features1=cast(features1in,outputClass);
                                        features2=cast(features2in,outputClass);
                                    else

                                        features1=features1in;
                                        features2=features2in;
                                    end




                                    function unambiguousIndices=findUnambiguousMatches(topTwoScores,maxRatioThreshold,metric)

                                        if strcmpi(metric,'normxcorr')





                                            topTwoScores(topTwoScores>1)=1;
                                            topTwoScores=acos(topTwoScores);
                                        end


                                        zeroInds=topTwoScores(2,:)<cast(1e-6,'like',topTwoScores);
                                        topTwoScores(:,zeroInds)=1;
                                        ratios=topTwoScores(1,:)./topTwoScores(2,:);

                                        unambiguousIndices=ratios<=maxRatioThreshold;




                                        function scores=metricSAD(features1,features2,N1,N2,outputClass)





                                            scores=images.internal.builtins.SADMetric(features1,features2);




                                            function scores=metricSSD(features1,features2,N1,N2,outputClass)





                                                scores=images.internal.builtins.SSDMetric(features1,features2);




                                                function scores=metricHamming(features1,features2,N1,N2,outputClass)




                                                    scores=images.internal.builtins.hammingMetric(features1,features2);




                                                    function scores=metricNormXCorr(features1,features2)
                                                        scores=features1'*features2;




                                                        function[indices,matchMetric]=removeWeakMatches(indices,...
                                                            matchMetric,matchThreshold,metric)

                                                            if(strcmp(metric,'normxcorr'))
                                                                inds=matchMetric(1,:)>=matchThreshold;
                                                            else
                                                                inds=matchMetric(1,:)<=matchThreshold;
                                                            end

                                                            indices=indices(:,inds);
                                                            matchMetric=matchMetric(:,inds);




                                                            function X=normalizeX(X)
                                                                Xnorm=sqrt(sum(X.^2,1));
                                                                X=bsxfun(@rdivide,X,Xnorm);


                                                                X(:,(Xnorm<=eps(single(1))))=0;





                                                                function[values,indices]=partialSort(x,n,mode)





                                                                    if n>size(x,2),n=size(x,2);end
                                                                    if nargin<3,mode='ascend';end

                                                                    values=zeros(n,size(x,1),'like',x);
                                                                    indices=zeros(n,size(x,1));

                                                                    if isempty(x)
                                                                        indices=cast(indices,'uint32');
                                                                        return;
                                                                    end

                                                                    if n<log2(size(x,2))

                                                                        if strcmp(mode,'ascend')
                                                                            for i=1:n
                                                                                [values(i,:),indices(i,:)]=min(x,[],2);
                                                                                inds=sub2ind(size(x),1:size(x,1),indices(i,:));
                                                                                x(inds)=inf;
                                                                            end
                                                                        else
                                                                            for i=1:n
                                                                                [values(i,:),indices(i,:)]=max(x,[],2);
                                                                                inds=sub2ind(size(x),1:size(x,1),indices(i,:));
                                                                                x(inds)=-inf;
                                                                            end
                                                                        end
                                                                    else
                                                                        [xSorted,inds]=sort(x,2,mode);
                                                                        values=xSorted(:,1:n)';
                                                                        indices=inds(:,1:n)';
                                                                    end

                                                                    indices=cast(indices,'uint32');
