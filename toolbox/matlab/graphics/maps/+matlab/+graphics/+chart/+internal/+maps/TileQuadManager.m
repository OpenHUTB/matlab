classdef TileQuadManager








































































































    properties(SetAccess=private)


TileDisplayFcn




NewQuadFcn



SetToUnusedStateFcn


        XTileLimits=[]
        YTileLimits=[];



        QuadIndex=[];


        QuadInUse=false(1,0);
    end


    methods
        function obj=TileQuadManager(tileDisplayFcn,newQuadFcn,setToUnusedStateFcn)



            obj.TileDisplayFcn=tileDisplayFcn;
            obj.NewQuadFcn=newQuadFcn;
            obj.SetToUnusedStateFcn=setToUnusedStateFcn;
        end


        function[obj,quadObjects]=update(obj,xTileLimits,yTileLimits,quadObjects)


            attributes={'real','finite','integer','size',[1,2],'nondecreasing'};
            validateattributes(xTileLimits,{'double'},attributes,'','xTileLimits')
            validateattributes(yTileLimits,{'double'},attributes,'','yTileLimits')
            validateattributes(quadObjects,{'handle'},{},'','quadObjects')



            numQuads=numel(quadObjects);
            if numel(obj.QuadInUse)~=numQuads
                obj=reset(obj,numQuads);
            end

            xTileLimitsOld=obj.XTileLimits;
            yTileLimitsOld=obj.YTileLimits;
            if~isequal(xTileLimits,xTileLimitsOld)||~isequal(yTileLimits,yTileLimitsOld)
                if isempty(xTileLimitsOld)||isempty(yTileLimitsOld)
                    obj.QuadIndex=zeros(diff(yTileLimits),diff(xTileLimits));
                else
                    obj=updateIndices(obj,xTileLimits,yTileLimits);
                end
                obj.XTileLimits=xTileLimits;
                obj.YTileLimits=yTileLimits;
                [obj,quadObjects]=displayTiles(obj,quadObjects);
            end
        end


        function obj=reset(obj,numQuads)
            obj.XTileLimits=[];
            obj.YTileLimits=[];
            obj.QuadIndex=[];
            obj.QuadInUse=false(1,numQuads);
        end
    end


    methods(Access=private)
        function obj=updateIndices(obj,xLimitsNew,yLimitsNew)


            xLimitsOld=obj.XTileLimits;
            yLimitsOld=obj.YTileLimits;

            quadIndexOld=obj.QuadIndex;
            quadIndexNew=zeros(diff(yLimitsNew),diff(xLimitsNew));

            if overlap(xLimitsNew,xLimitsOld)&&overlap(yLimitsNew,yLimitsOld)


                xOverlap=[...
                max(xLimitsOld(1),xLimitsNew(1)),...
                min(xLimitsOld(2),xLimitsNew(2))];

                yOverlap=[...
                max(yLimitsOld(1),yLimitsNew(1)),...
                min(yLimitsOld(2),yLimitsNew(2))];

                relativeRows=((1+yOverlap(1)):yOverlap(2));
                relativeCols=((1+xOverlap(1)):xOverlap(2));

                quadIndexNew(...
                relativeRows-yLimitsNew(1),...
                relativeCols-xLimitsNew(1))...
                =quadIndexOld(...
                relativeRows-yLimitsOld(1),...
                relativeCols-xLimitsOld(1));



                quadsNotInOverlap=setdiff(quadIndexOld(:),quadIndexNew(:));
            else

                quadsNotInOverlap=quadIndexOld(:);
            end
            obj.QuadInUse(quadsNotInOverlap)=false;
            obj.QuadIndex=quadIndexNew;
        end


        function[obj,quadObjects]=displayTiles(obj,quadObjects)


            index=obj.QuadIndex;
            inuse=obj.QuadInUse;




            displayUpdateNeeded=any(index(:)==0)...
            ||~isequal(sort(index(:)),sort(find(inuse(:))));

            if displayUpdateNeeded

                xTileIndices=(obj.XTileLimits(1):(obj.XTileLimits(2)-1));
                yTileIndices=(obj.YTileLimits(1):(obj.YTileLimits(2)-1));



                numQuads=numel(quadObjects);
                for c=1:length(xTileIndices)
                    for r=1:length(yTileIndices)
                        tileNotDisplayed=(index(r,c)==0);
                        if tileNotDisplayed

                            k=find(~inuse,1,'first');
                            if isempty(k)

                                quad=obj.NewQuadFcn();
                                quadObjects(end+1)=quad;%#ok<AGROW>
                                numQuads=numQuads+1;
                                k=numQuads;
                            else

                                quad=quadObjects(k);
                            end



                            xTileIndex=xTileIndices(c);
                            yTileIndex=yTileIndices(r);
                            obj.TileDisplayFcn(quad,xTileIndex,yTileIndex);
                            inuse(k)=true;
                            index(r,c)=k;
                        end
                    end
                end


                obj.QuadIndex=index;
                obj.QuadInUse=inuse;
            end
            arrayfun(obj.SetToUnusedStateFcn,quadObjects(~inuse))
        end
    end
end


function tf=overlap(limitsA,limitsB)


    tf=~isempty(limitsA)&&~isempty(limitsB)...
    &&~(limitsA(2)<=limitsB(1)||limitsB(2)<=limitsA(1));
end
