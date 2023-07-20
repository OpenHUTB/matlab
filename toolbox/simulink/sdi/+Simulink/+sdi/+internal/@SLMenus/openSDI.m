function schema=openSDI(cbinfo,varargin)



    if~isempty(varargin)&&strcmpi(varargin,'openSDI_CB')
        schema=[];
        openSDI_CB(cbinfo);
    else
        schema=openSDIv2(cbinfo,varargin{:});
    end
end


function schema=openSDIv2(cbinfo,varargin)
    schema=sl_action_schema;
    schema.tag='Simulink:OpenSDI';
    schema.callback=@openSDI_CB;
    schema.autoDisableWhen='Never';
    schema.refreshCategories={'interval#4','SimulinkEvent:Simulation'};


    newData=Simulink.sdi.internal.SLMenus.getSetNewDataAvailable(cbinfo.model.Name);

    if~SLStudio.Utils.showInToolStrip(cbinfo)
        if newData&&isempty(varargin)
            schema.label=DAStudio.message('SDI:sdi:SLMenuNewData');
        else
            schema.label=DAStudio.message('SDI:sdi:SLMenuOpenSDI');
        end
    else
        schema.label='simulink_ui:studio:resources:openSDIActionLabel';
    end


    recOutput=SLStudio.Utils.getConfigSetParam(cbinfo.model.Handle,'InspectSignalLogs','off');
    showRecord=strcmpi(recOutput,'on');

    if showRecord&&newData

        schema.icon='resultSimDataInspectorActive';
    elseif showRecord

        schema.icon='resultSimDataInspector';
    elseif~showRecord&&newData

        schema.icon='resultSimDataInspectorOffActive';
    else

        schema.icon='resultSimDataInspector';
    end
end


function openSDI_CB(cbinfo)

    if strcmpi(SLStudio.Utils.getSimStatus(cbinfo),'running')
        SLM3I.SLDomain.updateBlockLogVars(cbinfo.model.handle);
    end
    modelName=cbinfo.model.Name;
    Simulink.sdi.internal.SLMenus.getSetNewDataAvailable(modelName,false);
    bWasRunning=Simulink.sdi.Instance.isSDIRunning();
    if~bWasRunning
        set_param(modelName,'StatusString',DAStudio.message('SDI:sdi:StartingSDI'));
    end
    Simulink.sdi.view;

    set_param(0,'LastVisualizer','SDI');
    gui=Simulink.sdi.Instance.getMainGUI();
    if gui.UsingSystemBrowser||bWasRunning
        onReadyHandler(modelName);
    elseif~bWasRunning
        gui.setOnReadyToShow(@()onReadyHandler(modelName));
    end
end


function onReadyHandler(modelName)
    try
        set_param(modelName,'StatusString','');
    catch me %#ok<NASGU>

    end
end