function vars=getVariantControlVarsForBlock(blkPath)










    vars=slvariants.internal.manager.core.getVariantControlVarsForBlockImpl(get_param(blkPath,'handle'));




    modelH=bdroot(blkPath);
    vars(cellfun(@(token)(~isVariable(modelH,token)),vars))=[];

    function flag=isVariable(modelH,token)
        ex=exist(token);%#ok<EXIST>


        flag=((ex==0)||(ex==7))||(existsInGlobalScope(modelH,token)==1);
    end
end
