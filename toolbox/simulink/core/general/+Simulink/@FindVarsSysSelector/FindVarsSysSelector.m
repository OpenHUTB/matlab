classdef FindVarsSysSelector<ModelAdvisor.SystemSelector




    properties(SetObservable=true)

        SearchRefMdls(1,1)logical=false;


        RefreshVarUsage(1,1)logical=false;


        ForRenameAll(1,1)logical=false;

        userData;
    end

    methods
        closeCB(obj,closeAction)
    end
end
