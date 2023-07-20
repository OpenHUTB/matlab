

function updateDiagram(widgetID,mdl,widgetType)
    try
        set_param(mdl,'SimulationCommand','update');
    catch me
        Simulink.output.Stage(...
        message('Simulink:SLMsgViewer:Update_Diagram_Stage_Name').getString(),...
        'ModelName',mdl);
        Simulink.output.error(me);
    end
    currSelectedBlks=gsb(mdl);


    dialogSourceBlock={};
    bCoreBlock=false;


    filtered_blocks=[];
    for index=1:length(currSelectedBlks)
        block=currSelectedBlks(index);
        isCoreWebBlock=get_param(block,'isCoreWebBlock');
        if~strcmp(isCoreWebBlock,'on')
            filtered_blocks=[filtered_blocks,block];
        else
            dialogSourceBlock=block;
            bCoreBlock=true;
        end
    end

    if bCoreBlock
        binding=get_param(dialogSourceBlock,'Binding');
        if~isempty(binding{1})
            boundElem=binding{1};
        else
            boundElem={};
        end
    else
        boundElem=utils.getBoundElement(mdl,widgetID);
    end

    rowInfo=utils.getParameterRows(mdl,widgetID,filtered_blocks,boundElem,widgetType);
    channel=hmiblockdlg.ParameterDlg.getChannel();
    message.publish([channel,'repopulateParametersInModelSelection'],...
    rowInfo);
end

