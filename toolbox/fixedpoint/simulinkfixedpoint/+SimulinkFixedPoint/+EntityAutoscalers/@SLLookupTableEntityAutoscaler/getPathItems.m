function[pathItems]=getPathItems(h,blkObj)





    pathItems=h.getPortMapping([],[],1);

    if~any(strcmp(blkObj.InterpMethod,{'Flat','Nearest','Linear Lagrange'}))
        pathItems=[pathItems,{'Intermediate Results'},{'Fraction'}];
    end

    if~strcmp(blkObj.DataSpecification,'Lookup table object')



        tableSourceFromPort=isprop(blkObj,'TableSource')&&strcmp(blkObj.TableSource,'Input port');


        if tableSourceFromPort
            tablePathItems='';
        else
            tablePathItems={'Table'};
        end


        numOfDim=slResolve(blkObj.NumberOfTableDimensions,blkObj.getFullName);


        breakPointPathItems=cell(1,numOfDim);
        for bpIdx=1:numOfDim
            sourceString=['BreakpointsForDimension',int2str(bpIdx),'Source'];
            bpSourceFromPort=isprop(blkObj,sourceString)&&strcmp(blkObj.(sourceString),'Input port');
            if bpSourceFromPort

                breakPointPathItems{1,bpIdx}='';
            else
                breakPointPathItems{1,bpIdx}=['BreakpointsForDimension',int2str(bpIdx)];
            end
        end
        pathItemsFull=[pathItems,tablePathItems,breakPointPathItems];
        pathItems=pathItemsFull(~cellfun('isempty',pathItemsFull));
    end
end