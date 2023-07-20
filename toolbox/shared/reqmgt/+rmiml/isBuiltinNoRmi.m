function result=isBuiltinNoRmi(editorId)






    if isempty(editorId)
        result=true;

    elseif rmisl.isSidString(editorId)



        mdlName=strtok(editorId,':');
        result=rmiut.isBuiltinNoRmi(mdlName);

    else

        result=rmiut.RMExclusionMgr.getInstance.checkCached(editorId);
        if isempty(result)


            result=rmiut.RMExclusionMgr.getInstance.check(editorId);
        end
    end
end
