

function[inference,mexFile,messages,success,callerCalleeList,errorMessage]=fpBuildFloatingPointCode(dataAdapter)
    try

        epCell=dataAdapter.getEntryPoints().toArray().cell();
        for i=1:length(epCell)
            epCell{i}=char(epCell{i}.getAbsolutePath());
        end

        [inference,mexFile,messages,success,callerCalleeList,errorMessage]=...
        coderprivate.Float2FixedManager.instance.buildFloatingPointCode(dataAdapter,epCell);

        manager=coder.internal.F2FGuiCallbackManager.getInstance();
        manager.init(dataAdapter.getConfiguration());

        if success
            manager.MexBuildOutput={inference,mexFile,messages,success,callerCalleeList,errorMessage};
        else
            manager.MexBuildOutput=[];
        end
    catch ex
        throwAsCaller(ex);
    end
end
