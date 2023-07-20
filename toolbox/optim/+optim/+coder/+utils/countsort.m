function[x,workspace]=countsort(x,xLen,workspace,xMin,xMax)

























%#codegen

    coder.allowpcode('plain');


    validateattributes(x,{coder.internal.indexIntClass},{'vector'});
    validateattributes(xLen,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(workspace,{coder.internal.indexIntClass},{'vector'});
    validateattributes(xMin,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(xMax,{coder.internal.indexIntClass},{'scalar'});

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);


    if(xLen<=INT_ONE||xMax<=xMin)
        return;
    end


    for idx=1:(xMax-xMin+1)
        workspace(idx)=INT_ZERO;
    end

    minOffset=xMin-1;
    maxOffset=xMax-minOffset;


    for idx=1:xLen
        workspace(x(idx)-minOffset)=workspace(x(idx)-minOffset)+1;
    end



    for idx=2:maxOffset
        workspace(idx)=workspace(idx)+workspace(idx-1);
    end


    idxStart=coder.internal.indexInt(1);
    idxEnd=workspace(1);
    for idxW=1:maxOffset-1
        for idxFill=idxStart:idxEnd
            x(idxFill)=idxW+minOffset;
        end
        idxStart=workspace(idxW)+1;
        idxEnd=workspace(idxW+1);
    end

    for idx=idxStart:idxEnd
        x(idx)=xMax;
    end

end
