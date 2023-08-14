classdef GridToSegmentMapperStrategy<FunctionApproximation.internal.gridcreator.GridMapperStrategy






















    methods
        function mapGrid(this,keyGrid,valueGrid)
            nKey=numel(keyGrid);
            nValue=numel(valueGrid);

            if nKey==2
                gridMap=[1;nValue];
            else
                gridMap=zeros(2,nKey-1);




                loc=find(valueGrid<=keyGrid(2),1,'last');
                if isempty(loc)
                    firstPoint=0;
                    lastPoint=0;
                else
                    firstPoint=1;
                    lastPoint=loc;
                end
                gridMap(:,1)=[firstPoint;lastPoint];




                iKey=3;
                iValue=max(lastPoint,1);
                while(iValue<=nValue)&&(iKey<nKey)
                    firstPoint=0;
                    lastPoint=0;
                    for jValue=iValue:nValue
                        if valueGrid(max(jValue-1,1))==keyGrid(iKey-1)
                            firstPoint=jValue-1;
                            lastPoint=firstPoint;
                        end
                        if(valueGrid(jValue)<=keyGrid(iKey))
                            if valueGrid(jValue)>=keyGrid(iKey-1)
                                if firstPoint==0
                                    firstPoint=jValue;
                                end
                                lastPoint=jValue;
                            end
                        else
                            iValue=jValue;
                            break;
                        end
                    end
                    gridMap(:,iKey-1)=[firstPoint;lastPoint];
                    iKey=iKey+1;
                end




                firstPoint=0;
                lastPoint=0;
                if(iValue>1)&&(valueGrid(iValue-1)==keyGrid(nKey-1))
                    firstPoint=iValue-1;
                elseif valueGrid(iValue)>=keyGrid(nKey-1)
                    firstPoint=iValue;
                end
                if firstPoint
                    lastPoint=nValue;
                end
                gridMap(:,iKey-1)=[firstPoint;lastPoint];
            end

            this.GridMap=gridMap;
        end

        function indices=getIndices(this,keyPair)
            key1=max(keyPair(1),1);
            nKey=size(this.GridMap,2);
            key2=min(keyPair(2)-1,nKey);
            start=[];
            stop=[];

            if(key1<=key2)
                for iKey=key1:key2
                    if this.GridMap(1,iKey)~=0
                        start=this.GridMap(1,iKey);
                        break;
                    end
                end

                for iKey=key2:-1:key1
                    if this.GridMap(2,iKey)~=0
                        stop=this.GridMap(2,iKey);
                        break;
                    end
                end
            end

            indices=start:stop;
        end
    end
end