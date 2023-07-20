classdef CoordinateSetCreator















    properties
        CoordinateSets;
    end

    methods
        function this=CoordinateSetCreator(singleDimensionDomains)




            nDimensions=numel(singleDimensionDomains);
            outputGrid=cell(1,nDimensions);
            [outputGrid{:}]=ndgrid(singleDimensionDomains{:});

            gridSize=cellfun(@(x)numel(x),singleDimensionDomains);
            nSets=prod(gridSize);
            this.CoordinateSets=zeros(nSets,nDimensions);

            for ii=1:nDimensions
                this.CoordinateSets(:,ii)=outputGrid{ii}(:);
            end
        end
    end
end
