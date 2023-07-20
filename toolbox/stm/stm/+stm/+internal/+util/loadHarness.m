function loadHarness(owner,harnessName,varargin)

    harnessInfo=Simulink.harness.find(owner,'Name',harnessName);
    initialSetting=false;
    model='';
    dirtyFlag='';


    if(isempty(harnessInfo))
        stm.internal.MRT.share.error('stm:general:HarnessDoesNotFound',harnessName,owner);

    end


    if(harnessInfo.isOpen)
        return;
    end



    if length(harnessInfo)==1&&isfield(harnessInfo,'saveExternally')&&...
        ~harnessInfo.saveExternally
        model=harnessInfo.model;
        initialSetting=harnessInfo.rebuildOnOpen;
        dirtyFlag=get_param(model,'Dirty');

        if(initialSetting)
            Simulink.harness.set(owner,harnessName,'RebuildOnOpen',false);
        end
    end

    if nargin>=3&&varargin{1}==true
        Simulink.harness.open(owner,harnessName);
    else
        Simulink.harness.load(owner,harnessName);
    end


    if(initialSetting)
        Simulink.harness.set(owner,harnessName,'RebuildOnOpen',initialSetting);
        if~isempty(model)&&~isempty(dirtyFlag)
            isModelLocked=strcmp('on',get_param(model,'lock'));

            if(isModelLocked)
                Simulink.harness.internal.setBDLock(model,false);
            end

            set_param(model,'Dirty',dirtyFlag);


            if(isModelLocked)
                Simulink.harness.internal.setBDLock(model,true);
            end
        end
    end
end

