function nonDegenerate=isNonDegenerate(obj,tol)













%#codegen

    coder.allowpcode('plain');


    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(tol,{'double'},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);

    nonDegenerate=(obj.mrows>0&&obj.ncols>0);

    if~nonDegenerate
        return;
    end

    idx=obj.ncols;

    if(obj.mrows<obj.ncols)




        idxQR=obj.mrows+obj.ldq*(idx-INT_ONE);
        while(idx>obj.mrows&&abs(obj.QR(idxQR))>=tol)
            idx=idx-1;
            idxQR=idxQR-obj.ldq;
        end
        nonDegenerate=(idx==obj.mrows);


        if~nonDegenerate
            return;
        end
    end








    idxQR=idx+obj.ldq*(idx-INT_ONE);
    while(idx>=INT_ONE&&abs(obj.QR(idxQR))>=tol)
        idx=idx-1;
        idxQR=idxQR-obj.ldq-INT_ONE;
    end
    nonDegenerate=(idx==0);

end

