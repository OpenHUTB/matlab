function checkTopModel(this)



    model=this.TopModel;
    status=this.verifyLoaded(model);

    logging=get_param(model,'SignalLogging');
    output=get_param(model,'SaveOutput');
    wasDirty=get_param(model,'dirty');
    if strcmpi(logging,'off')&&strcmpi(output,'off')
        DAStudio.error('RTW:cgv:LoggingAndSavingBothOff',model);
    end
    tempOutport=find_system(model,'SearchDepth',1,'BlockType','Outport');

    orgLock=get_param(model,'Lock');
    set_param(model,'Lock','off');

    function cleanUpFcn(model,status,orgLock,wasDirty,this)


        if strcmpi(get_param(model,'SimulationStatus'),'paused')
            eval([model,'([], [], [], ''term'')']);
        end


        set_param(model,'Lock',orgLock);

        set_param(model,'dirty',wasDirty);
        this.restoreLoaded(model,status);
    end

    tidyUp=onCleanup(@()cleanUpFcn(model,status,orgLock,wasDirty,this));
    compile_cmd=[model,'([],[],[],','''compile'')'];
    eval(compile_cmd);
    if strcmpi(logging,'on')
        countValidSignals=0;
        InvalidSignals={};
        BusObjError=false;
        busObjErrStr='';
        VirtBusError=false;
        VirtBusErrStr='';
        for i=1:length(tempOutport);
            handles=get_param(char(tempOutport(i)),'PortHandles');
            isBus=get_param(handles.Inport,'CompiledPortBusMode');
            line=get_param(handles.Inport(1),'Line');
            src=get_param(line,'SrcPortHandle');
            loggingOn=get_param(src,'DataLogging');
            signalName=get_param(src,'Name');
            if strcmp(loggingOn,'on')&&~isempty(signalName)
                valid=true;

                if isBus
                    if strcmp(this.ComponentType,'modelblock')
                        useBus=get_param(tempOutport(i),'UseBusObject');
                        busObjName=get_param(tempOutport(i),'BusObject');
                        if~strcmp(useBus,'on')||isempty(busObjName)
                            busObjErrStr=[busObjErrStr,'''',char(tempOutport(i)),''' '];%#ok<AGROW>
                            BusObjError=true;
                            continue;
                        end
                    else
                        isNonVirtual=get_param(tempOutport(i),'BusOutputAsStruct');
                        if strcmp(isNonVirtual,'off')
                            VirtBusError=true;
                            VirtBusErrStr=[VirtBusErrStr,'''',char(tempOutport(i)),''' '];%#ok<AGROW>
                            continue;
                        end
                    end
                end
            else
                valid=false;
            end
            if valid
                countValidSignals=countValidSignals+1;
                this.OutPortSignalNames{end+1}=signalName;
            else
                InvalidSignals{end+1}=tempOutport(i);%#ok<AGROW>
            end
        end



        if countValidSignals==0
            if BusObjError
                DAStudio.error('RTW:cgv:BusObjectError',busObjErrStr);
            elseif VirtBusError
                DAStudio.error('RTW:cgv:VirtBusError',VirtBusErrStr);
            else
                DAStudio.error('RTW:cgv:NoNamedLoggedSignals',model);
            end
        elseif~isempty(InvalidSignals)
            msg=DAStudio.message('RTW:cgv:WarnSomeInvalidSignals',model);
            disp(msg);
            for i=1:length(InvalidSignals)
                disp(char(InvalidSignals{i}));
            end
            disp(DAStudio.message('RTW:cgv:WarnSomeInvalidSignals2'));
        end
        if BusObjError
            disp(DAStudio.message('RTW:cgv:BusObjectError',busObjErrStr));
        end
    end

    if strcmpi(output,'on')
        countBuses=0;
        countSignals=0;
        BusPorts={};
        for i=1:length(tempOutport);
            handles=get_param(char(tempOutport(i)),'porthandles');
            isBus=get_param(handles.Inport,'CompiledPortBusMode');
            portName=get_param(handles.Inport,'Name');
            if isBus
                countBuses=countBuses+1;
                BusPorts{end+1}=portName;%#ok<AGROW>
            else
                countSignals=countSignals+1;
            end
        end

        if countSignals==0
            DAStudio.error('RTW:cgv:OnlyBuses',model);
        elseif countBuses>0
            msg=DAStudio.message('RTW:cgv:SomeBuses',model);
            disp(msg);
            for i=1:length(BusPorts)
                disp(char(BusPorts{i}));
            end
            disp(DAStudio.message('RTW:cgv:UseSignalLogging'));
        end
    end
end
