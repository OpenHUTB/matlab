function[minV,maxV]=gatherDesignMinMax(h,blkObj,PathItems)%#ok<INUSL>





    minV=[];
    maxV=[];
    if(strcmp(PathItems,'Table'))


        if(strcmp(blkObj.TableIsInput,'off'))



            if~strcmpi(blkObj.('TableMax'),'[]')
                maxV=slResolve(blkObj.('TableMax'),blkObj.getFullName);
            end



            if~strcmpi(blkObj.('TableMin'),'[]')
                minV=slResolve(blkObj.('TableMin'),blkObj.getFullName);
            end
        end
    end



