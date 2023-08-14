

function result=actionAddBus2Vec(taskobj)

    mdladvObj=taskobj.MAObj;


    model=mdladvObj.System;

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);
    ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:CommonMABusModifyAction'));
    try
        [~,BusToVectorBlocks]=Simulink.BlockDiagram.addBusToVector(model,true,false);
        ResultLinks=unique(strtok(BusToVectorBlocks,'/'));
        strictBusLevel='ErrorOnBusTreatedAsVector';

        if isempty(ResultLinks)
            ResultLinks={get_param(model,'Name')};
        end

        ft.setListObj(ResultLinks);
        result=ft;

        set_param(model,'StrictBusMsg',strictBusLevel);
        save_system(model);
    catch Ex
        result=DAStudio.message('ModelAdvisor:engine:CommonMABusModifyFail',Ex.message);
    end
