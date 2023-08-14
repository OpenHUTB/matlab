classdef Grid<handle





    properties(SetAccess=private)
        Domains={}
GridSize
GridCreator
RangeObject
SingleDimensionDomains
    end

    methods
        function this=Grid(singleDimensionDomains,gridingCreator)


            minRanges=cellfun(@(x)min(x),singleDimensionDomains);
            maxRanges=cellfun(@(x)max(x),singleDimensionDomains);
            this.GridSize=cellfun(@(x)numel(x),singleDimensionDomains);
            this.GridCreator=gridingCreator;
            this.RangeObject=FunctionApproximation.internal.Range(minRanges,maxRanges);
            this.SingleDimensionDomains=singleDimensionDomains;
        end

        function domains=getDomains(this)
            if isempty(this.Domains)
                this.Domains=FunctionApproximation.internal.DomainCreator(this.SingleDimensionDomains).Domains;
            end
            domains=this.Domains;
        end

        function newObject=times(this,factor)




            factor=max(ceil(factor),1);
            singleDimensionDomains=this.SingleDimensionDomains;
            for ii=1:numel(singleDimensionDomains)
                vectorValue=[];
                for jj=1:numel(singleDimensionDomains{ii})-1
                    singleDomainMin=singleDimensionDomains{ii}(jj);
                    singleDomainMax=singleDimensionDomains{ii}(jj+1);
                    rangeObject=FunctionApproximation.internal.Range(...
                    singleDomainMin,singleDomainMax);
                    localVector=getGrid(this.GridCreator,...
                    rangeObject,factor+1);
                    maxIndex=max(numel(localVector{1})-1,1);
                    vectorValue=[vectorValue,localVector{1}(1:maxIndex)];%#ok<AGROW>
                end
                vectorValue=[vectorValue,singleDimensionDomains{ii}(end)];%#ok<AGROW>
                singleDimensionDomains{ii}=vectorValue;
            end
            newObject=FunctionApproximation.internal.Grid(singleDimensionDomains,this.GridCreator);
        end

        function sets=getSets(this,dimensions)
            if nargin<2


                dimensions=1:numel(this.GridSize);
            end
            sets=FunctionApproximation.internal.CoordinateSetCreator(this.SingleDimensionDomains(dimensions)).CoordinateSets;
        end
    end
end
