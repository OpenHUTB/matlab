function initModelForTBGen(this,hcLoggingName,outLogNamePrefix,inLogNamePrefix)







    this.SignalLoggingName=this.Model.SignalLoggingName;
    this.LoggingToFile=get_param(this.Model.handle,'LoggingToFile');
    this.ReturnWorkspaceOutputs=get_param(this.Model.handle,'ReturnWorkspaceOutputs');

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
    hcLoggingToFile='off';
    hcTestPoint='on';
    hcDataLogging='on';
    hcDataLoggingNameMode='Custom';
    hcReturnWorkspaceOutputs='off';


    set_param(this.Model.handle,'SignalLogging',hcSignalLogging);
    this.Model.SignalLoggingName=hcLoggingName;

    set_param(this.Model.handle,'LoggingToFile',hcLoggingToFile);
    set_param(this.Model.handle,'ReturnWorkspaceOutputs',hcReturnWorkspaceOutputs);

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

