function retVal=rtwcustomtfl(rtwCtx,RecForTfl)





    if RecForTfl.NumArgs==1
        args{2}=RecForTfl.ArgList.TypeId;
        args{1}=RecForTfl.ArgList.Name;
    else
        args=cell(2*RecForTfl.NumArgs);
        argIdx=1;
        for k=1:RecForTfl.NumArgs
            args{argIdx}=RecForTfl.ArgList{1,k}.Name;
            args{argIdx+1}=RecForTfl.ArgList{1,k}.TypeId;
            argIdx=argIdx+2;
        end
    end

    retVal=rtwcgtlc('Intrinsics',rtwCtx,RecForTfl.Key,RecForTfl.InlineFcn,...
    RecForTfl.NumArgs,RecForTfl.RetName,RecForTfl.RetTypeId,...
    args{1:end});


