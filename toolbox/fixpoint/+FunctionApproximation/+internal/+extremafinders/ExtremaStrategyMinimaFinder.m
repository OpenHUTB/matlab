classdef(Sealed)ExtremaStrategyMinimaFinder<FunctionApproximation.internal.extremafinders.MinimaFinder






    properties(Constant,Hidden)
        MaxPointsForEvaluation=2^22;
    end

    properties(SetAccess=private)
        ExtremaStrategy;
    end

    methods
        function this=ExtremaStrategyMinimaFinder(extremaStrategy)
            this.ExtremaStrategy=extremaStrategy;
        end
    end

    methods(Hidden)
        function maxSets=getMaxEvaluationSets(this,wls)
            maxSets=2^min(sum(wls),log2(this.MaxPointsForEvaluation));
        end
    end

    methods(Access=?FunctionApproximation.internal.extremafinders.ExtremaFinder)
        function[value,functionValue]=execute(this,functionWrapper,gridObject,varargin)
            log2NumPoints=18;
            if nargin>3
                log2NumPoints=min(varargin{1},log2NumPoints);
            end










            maxNumCoordinateSets=2^log2NumPoints;
            nD=numel(gridObject.SingleDimensionDomains);
            pointsPerDomain=this.ExtremaStrategy.Factor^nD;
            numDomains=maxNumCoordinateSets/pointsPerDomain;
            this.ExtremaStrategy.DomainCount=ceil(numDomains^(1/nD));
            stepCount=this.ExtremaStrategy.DomainCount-1;
            singleDimensionGrid=gridObject.SingleDimensionDomains;
            for j=1:numel(singleDimensionGrid)
                if stepCount==0
                    singleDimensionGrid{j}=singleDimensionGrid{j}([1,end]);
                else
                    singleDimensionGrid{j}=singleDimensionGrid{j}([1:stepCount:end-1,end]);
                end
            end
            searchDomains=FunctionApproximation.internal.DomainCreator(singleDimensionGrid).Domains;


            nDomains=numel(searchDomains);
            value=[];
            functionValue=Inf;

            wls=arrayfun(@(x)x.WordLength,gridObject.GridCreator.DataTypes);
            numMaxSets=getMaxEvaluationSets(this,wls);

            coordinates=zeros(numMaxSets,nD);
            start=1;
            gridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(gridObject.GridCreator.DataTypes);

            for ii=1:nDomains
                currentCoordinates=this.ExtremaStrategy.getCoordinateSet(searchDomains{ii}(:,1),searchDomains{ii}(:,2),gridCreator);
                stop=start+size(currentCoordinates,1)-1;
                coordinates(start:stop,:)=currentCoordinates;


                if(stop>numMaxSets)||(ii==nDomains)
                    functionValues=functionWrapper.evaluate(coordinates(1:stop,:));



                    [fval,location]=min(functionValues(~isinf(functionValues)&~isnan(functionValues)));
                    xValue=coordinates(location,:);


                    if fval<functionValue
                        value=xValue;
                        functionValue=fval;
                    end


                    coordinates=zeros(numMaxSets,nD);
                    start=1;
                else
                    start=stop+1;
                end
            end
        end
    end
end


