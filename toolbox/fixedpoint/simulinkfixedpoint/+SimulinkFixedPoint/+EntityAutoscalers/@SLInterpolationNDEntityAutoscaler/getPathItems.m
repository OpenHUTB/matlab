function pathItems=getPathItems(h,blkObj)%#ok




    pathItems={'1'};
    if strcmp(blkObj.InterpMethod,'Linear point-slope')


        pathItems=[pathItems,{'Intermediate Results'}];
    end
    if~strcmp(blkObj.TableSpecification,'Lookup table object')...
        &&(strcmp(blkObj.TableSpecification,'Explicit values')&&strcmp(blkObj.TableSource,'Dialog'))

        pathItems=[pathItems,{'Table'}];
    end
end
