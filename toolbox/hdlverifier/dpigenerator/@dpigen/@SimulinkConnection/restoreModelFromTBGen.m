function restoreModelFromTBGen(this)





    outportHandles=this.getOutportHandles;

    for m=1:length(outportHandles)

        hOutport=outportHandles(m);

        if~isempty(hOutport)

            if~isempty(this.OutportTestPoint)&&~isempty(this.OutportTestPoint{m})
                set_param(hOutport,'TestPoint',this.OutportTestPoint{m});
            end
            if~isempty(this.OutportDataLogging)&&~isempty(this.OutportDataLogging{m})
                set_param(hOutport,'DataLogging',this.OutportDataLogging{m});
            end
            if~isempty(this.OutportDataLoggingNameMode)&&~isempty(this.OutportDataLoggingNameMode{m})
                set_param(hOutport,'DataLoggingNameMode',this.OutportDataLoggingNameMode{m});
            end
            if~isempty(this.OutportDataLoggingName)&&~isempty(this.OutportDataLoggingName{m})
                set_param(hOutport,'DataLoggingName',this.OutportDataLoggingName{m});
            end
        end

    end


    inportHandles=this.getInportSrcHandles;

    for m=1:length(inportHandles)

        hInport=inportHandles(m);

        if~isempty(hInport)

            if~isempty(this.InportTestPoint)&&~isempty(this.InportTestPoint{m})
                set_param(hInport,'TestPoint',this.InportTestPoint{m});
            end
            if~isempty(this.InportDataLogging)&&~isempty(this.InportDataLogging{m})
                set_param(hInport,'DataLogging',this.InportDataLogging{m});
            end
            if~isempty(this.InportDataLoggingNameMode)&&~isempty(this.InportDataLoggingNameMode{m})
                set_param(hInport,'DataLoggingNameMode',this.InportDataLoggingNameMode{m});
            end
            if~isempty(this.InportDataLoggingname)&&~isempty(this.InportDataLoggingname{m})
                set_param(hInport,'DataLoggingname',this.InportDataLoggingname{m});
            end
        end
    end


    if~isempty(this.SignalLogging)
        cfg=this.getModel.getActiveConfigSet;
        cfg.setProp('SignalLogging',this.SignalLogging);
    end



    if~isempty(this.ReturnWorkspaceOutputs)
        cfg=this.getModel.getActiveConfigSet;
        cfg.setProp('ReturnWorkspaceOutputs',this.ReturnWorkspaceOutputs);
    end

    if~isempty(this.LoggingToFile)
        cfg=this.getModel.getActiveConfigSet;
        cfg.setProp('LoggingToFile',this.LoggingToFile);
    end

    if~isempty(this.SignalLoggingName)
        cfg=this.getModel.getActiveConfigSet;
        cfg.setProp('SignalLoggingName',this.SignalLoggingName);
    end


    if~isempty(this.SignalLoggingSaveFormat)
        cfg=this.getModel.getActiveConfigSet;
        cfg.setProp('SignalLoggingSaveFormat',this.SignalLoggingSaveFormat);
    end

    if~isempty(this.SimulationMode)&&~strcmpi(this.SimulationMode,'normal')
        set_param(this.getModel.handle,'SimulationMode',this.SimulationMode);
    end



