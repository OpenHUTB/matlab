function initModelForTBGen(this,hcLoggingName,outLogNamePrefix,inLogNamePrefix)







    cfg=this.getModel.getActiveConfigSet;
    this.SignalLogging=cfg.getProp('SignalLogging');
    this.ReturnWorkspaceOutputs=cfg.getProp('ReturnWorkspaceOutputs');
    this.LoggingToFile=cfg.getProp('LoggingToFile');
    this.SignalLoggingName=cfg.getProp('SignalLoggingName');
    this.SignalLoggingSaveFormat=cfg.getProp('SignalLoggingSaveFormat');
    this.SimulationMode=get_param(this.getModel.handle,'SimulationMode');

    inportHandles=this.getInportSrcHandles;
    outportHandles=this.getOutportHandles;








    for m=1:length(outportHandles)

        hOutport=outportHandles(m);

        this.OutportTestPoint{m}=get_param(hOutport,'TestPoint');
        this.OutportDataLogging{m}=get_param(hOutport,'DataLogging');
        this.OutportDataLoggingNameMode{m}=get_param(hOutport,'DataLoggingNameMode');
        this.OutportDataLoggingName{m}=get_param(hOutport,'DataLoggingName');

        set_param(hOutport,'TestPoint','off');
        set_param(hOutport,'DataLogging','off');

    end

    for m=1:length(inportHandles)

        hInport=inportHandles(m);

        this.InportTestPoint{m}=get_param(hInport,'TestPoint');
        this.InportDataLogging{m}=get_param(hInport,'DataLogging');
        this.InportDataLoggingNameMode{m}=get_param(hInport,'DataLoggingNameMode');
        this.InportDataLoggingName{m}=get_param(hInport,'DataLoggingName');

        set_param(hInport,'TestPoint','off');
        set_param(hInport,'DataLogging','off');


    end





    hcSignalLogging='on';
    hcReturnWorkspaceOutputs='off';
    hcLoggingToFile='off';
    hcTestPoint='on';
    hcDataLogging='on';
    hcDataLoggingNameMode='Custom';
    hcSimulationMode='normal';







    if strcmp(get_param(this.System,'Name'),bdroot)



        ParameterThatNeedToChange='';

        if~strcmp(get_param(this.Model.handle,'SignalLogging'),hcSignalLogging)
            temp_msg=message('HDLLink:DPITestbench:DataLoggingWrongPropertyValue','SignalLogging',hcSignalLogging);
            ParameterThatNeedToChange=sprintf('%s%s\n',ParameterThatNeedToChange,temp_msg.getString);
        end

        if~strcmp(get_param(this.Model.handle,'ReturnWorkspaceOutputs'),hcReturnWorkspaceOutputs)
            temp_msg=message('HDLLink:DPITestbench:DataLoggingWrongPropertyValue','ReturnWorkspaceOutputs',hcReturnWorkspaceOutputs);
            ParameterThatNeedToChange=sprintf('%s%s\n',ParameterThatNeedToChange,temp_msg.getString);
        end

        if~strcmp(get_param(this.Model.handle,'LoggingToFile'),hcLoggingToFile)
            temp_msg=message('HDLLink:DPITestbench:DataLoggingWrongPropertyValue','LoggingToFile',hcLoggingToFile);
            ParameterThatNeedToChange=sprintf('%s%s\n',ParameterThatNeedToChange,temp_msg.getString);
        end

        if~strcmp(get_param(this.Model.handle,'SignalLoggingSaveFormat'),'Dataset')
            temp_msg=message('HDLLink:DPITestbench:DataLoggingWrongPropertyValue','SignalLoggingSaveFormat','Dataset');
            ParameterThatNeedToChange=sprintf('%s%s\n',ParameterThatNeedToChange,temp_msg.getString);
        end

        if~strcmpi(get_param(this.Model.handle,'SimulationMode'),'normal')
            temp_msg=message('HDLLink:DPITestbench:DataLoggingWrongPropertyValue','SimulationMode','normal');
            ParameterThatNeedToChange=sprintf('%s%s\n',ParameterThatNeedToChange,temp_msg.getString);
        end



        assert(isempty(ParameterThatNeedToChange),message('HDLLink:DPITestbench:DataLoggingPropertiesValuesNeedToChange',ParameterThatNeedToChange));
    end

    set_param(this.Model.handle,'SignalLogging',hcSignalLogging);




    set_param(this.Model.handle,'ReturnWorkspaceOutputs',hcReturnWorkspaceOutputs);
    set_param(this.Model.handle,'LoggingToFile',hcLoggingToFile);
    cfg.setProp('SignalLoggingSaveFormat','Dataset');

    if~strcmpi(get_param(this.Model.handle,'SimulationMode'),'normal')

        warning(message('HDLLink:DPITestbench:ModelWillRunInNormalModeForVectorLogging'));
        set_param(this.Model.handle,'SimulationMode',hcSimulationMode);
    end


    this.Model.SignalLoggingName=hcLoggingName;

    for m=1:length(outportHandles)

        hOutport=outportHandles(m);

        signalLoggingStatus=get_param(hOutport,'DataLogging');

        if~strcmpi(signalLoggingStatus,'on')
            set_param(hOutport,'TestPoint',hcTestPoint);
            set_param(hOutport,'DataLogging',hcDataLogging);
            set_param(hOutport,'DataLoggingNameMode',hcDataLoggingNameMode);
            set_param(hOutport,'DataLoggingname',[outLogNamePrefix,num2str(m)]);
        end
    end

    for m=1:length(inportHandles)

        hInport=inportHandles(m);

        signalLoggingStatus=get_param(hInport,'DataLogging');

        if~strcmpi(signalLoggingStatus,'on')
            set_param(hInport,'TestPoint',hcTestPoint);
            set_param(hInport,'DataLogging',hcDataLogging);
            set_param(hInport,'DataLoggingNameMode',hcDataLoggingNameMode);
            set_param(hInport,'DataLoggingName',[inLogNamePrefix,num2str(m)]);
        end
    end

