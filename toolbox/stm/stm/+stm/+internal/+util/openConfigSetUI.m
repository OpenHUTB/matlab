function openConfigSetUI(topModel,harnessModel,harnessOwner,pathList,varargin)





    open_system(topModel);
    isFcnInterface=false;

    if nargin>4
        isFcnInterface=varargin{1};
    end
    modelToUse=topModel;
    if~isempty(harnessModel)
        modelToUse=harnessModel;

        if~contains(harnessOwner,'/')
            harnessOwner=[topModel,'/',harnessOwner];
        end
        if isFcnInterface
            Simulink.libcodegen.internal.openCodeContext(harnessOwner,harnessModel);
        else
            Simulink.harness.open(harnessOwner,harnessModel);
        end
    end
    modelH=get_param(modelToUse,'Handle');
    sldvprivate('configcomp_open',modelH);
    configset.showParameterGroup(modelToUse,pathList);
end
