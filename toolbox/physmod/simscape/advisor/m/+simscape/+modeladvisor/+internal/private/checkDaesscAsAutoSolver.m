function obj=checkDaesscAsAutoSolver(objType)





    checkId='checkDaesscAsAutoSolver';


    obj=simscape.modeladvisor.internal.create_basic_check(...
    objType,checkId,...
    @checkCallback,@actionCallback);
end



function result=checkCallback(model)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(model);
    mdladvObj.setCheckResultStatus(false);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');

    if strcmpi(get_param(model,'SimscapeDaeAutoSolver'),'daessc')
        ft.setSubResultStatus('Pass');
        ft.setCheckText(lGetMsg('CheckResultPass'));
        mdladvObj.setCheckResultStatus(true);
    else
        ft.setSubResultStatus('Warn');
        ft.setCheckText(lGetMsg('CheckResultWarn'));
        mdladvObj.setCheckResultStatus(false);
    end

    result={ft};
end

function result=actionCallback(taskObj)

    system=get_param(taskObj.MAObj.System,'Name');
    set_param(system,'SimscapeDaeAutoSolver','daessc');
    result=lGetMsg('CheckResultAction');
end

function msg=lGetMsg(id)

    messageCatalog=...
    'physmod:simscape:advisor:modeladvisor:checkDaesscAsAutoSolver';
    msg=DAStudio.message([messageCatalog,':',id]);
end
