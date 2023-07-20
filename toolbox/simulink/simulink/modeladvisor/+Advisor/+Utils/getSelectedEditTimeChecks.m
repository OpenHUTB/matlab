function selectedChecks=getSelectedEditTimeChecks(model)
    selectedChecks=[];
    am=Advisor.Manager.getInstance;
    applicationObj=am.getApplication('advisor','_modeladvisor_',...
    'Root',model,'RootType',Advisor.components.ComponentTypes.Model,...
    'Legacy',true,'MultiMode',false,'token','MWAdvi3orAPICa11');

    if~isempty(applicationObj)
        mdladvObj=applicationObj.getRootMAObj();
        edittimeChecks=modeladvisorprivate('modeladvisorutil2','GetEdittimeChecks');
        for i=1:length(edittimeChecks)
            taskObj=mdladvObj.getTaskObj(edittimeChecks{i});
            if taskObj.Selected
                selectedChecks{end+1}=taskObj.MAC;%#ok<AGROW>
            end
        end
    end
