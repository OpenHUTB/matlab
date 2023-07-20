function slciadvisor(system,varargin)


    if nargin>0
        system=convertStringsToChars(system);
    end

    if~ismac()


        if(nargin>1&&strcmpi(varargin{1},'SystemSelector'))
            system=modeladvisorprivate('systemselector',system);
            if isempty(system)
                return
            end
        end
        if ishandle(system)
            system=get_param(system,'handle');
        else
            open_system(system);
            system=get_param(system,'handle');
        end

        modelName=get_param(bdroot(system),'Name');
        if Simulink.harness.isHarnessBD(modelName)
            DAStudio.error('Simulink:Harness:SLCINotSupported');
        end

        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(...
        system,...
        'new',...
        '_SYSTEM_By Product_Simulink Code Inspector');

        mdladvObj.TaskAdvisorRoot.disconnect;
        mdladvObj.TaskAdvisorRoot.select;
        mdladvObj.TaskAdvisorRoot.changeSelectionStatus(true);
        mdladvObj.displayExplorer;
        mdladvObj.MAExplorer.title=...
        [DAStudio.message('Slci:compatibility:MASLCITaskGroupName')...
        ,' - '...
        ,regexprep(mdladvObj.SystemName,sprintf('\n'),' ')];
    end