function retVal=disableimplicitsignalresolution(model,displayOnly)

































    if nargin==1
        displayOnly=false;
    end

    if nargout==1
        retVal=struct('Signals',[],'States',[]);
    end

    modelName=get_param(model,'Name');
    model=get_param(model,'Handle');

    if~strncmp(get_param(model,'SignalResolutionControl'),'TryResolve',10)
        MSLDiagnostic('Simulink:tools:ImplicitSignalResolutionAlreadyDisabled',modelName).reportAsWarning;
        return;
    end





    ports=find_system(model,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'Regexp','on',...
    'FindAll','on',...
    'Type','port',...
    'PortType','outport',...
    'MustResolveToSignalObject','off',...
    'Name','\S+');

    hPorts=get_param(ports,'Object');
    if iscell(hPorts)
        hPorts=[hPorts{:}]';
    end


    disp(DAStudio.message('Simulink:tools:TurnOnResolutionForSignals'));
    for idx=length(hPorts):-1:1
        thisPort=hPorts(idx);


        if(l_IsSignalObjectResolved(modelName,thisPort.Parent,thisPort.Name))
            if l_IsPortInsideStateflowChart(thisPort);

                sfChart=get_param(thisPort.Parent,'Parent');
                usedByStr=l_FullName(sfChart);
            else

                usedByStr=l_FullName(thisPort.Parent,num2str(thisPort.PortNumber));
            end

            disp(['- ',strtrim(thisPort.Name),'  (used by: ',usedByStr,')']);
        else
            ports(idx)=[];
            hPorts(idx)=[];
        end
    end

    if isempty(hPorts)
        disp('... none found ...');
    end
    disp(' ');





    blks=find_system(model,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'Type','block',...
    'StateMustResolveToSignalObject','off');

    hBlks=get_param(blks,'Object');
    if iscell(hBlks)
        hBlks=[hBlks{:}]';
    end


    disp(DAStudio.message('Simulink:tools:TurnOnResolutionForStates'));
    for idx=length(hBlks):-1:1
        thisBlk=hBlks(idx);


        if strcmp(thisBlk.BlockType,'DataStoreMemory')
            stateName=strtrim(thisBlk.DataStoreName);
        else
            stateName=strtrim(thisBlk.StateIdentifier);
        end

        if l_IsSignalObjectResolved(modelName,thisBlk.Handle,stateName)
            disp(['- ',stateName,'  (used by: ',...
            l_FullName(thisBlk.Parent,thisBlk.Name),')']);
        else

            blks(idx)=[];
            hBlks(idx)=[];
        end
    end

    if isempty(hBlks)
        disp('... none found ...');
    end
    disp(' ');


    if(~displayOnly)

        for idx=1:length(hPorts)
            thisPort=hPorts(idx);
            if l_IsPortInsideStateflowChart(thisPort)

                sfChart=get_param(thisPort.Parent,'Parent');
                sigLabel=thisPort.Name;


                outportBlk=find_system(sfChart,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','on',...
                'Name',sigLabel,...
                'BlockType','Outport');

                if(iscell(outportBlk)&&(length(outportBlk)==1))
                    outportBlk=outportBlk{1};
                else
                    assert(false,DAStudio.message('Simulink:tools:ExpectedOneStateflowOutputWithSignalName'));
                end


                sfPorts=get_param(sfChart,'PortHandles');
                sfPortNo=str2double(get_param(outportBlk,'Port'));
                thisPort=get_param(sfPorts.Outport(sfPortNo),'Object');
                if~strcmp(thisPort.Name,sigLabel)
                    if~isempty(thisPort.Name)
                        MSLDiagnostic('Simulink:tools:RenameStateflowOutputSignal',...
                        thisPort.Name,sigLabel,sfChart).reportAsWarning;
                    end
                    thisPort.Name=sigLabel;
                end


                set_param(sfChart,'PermitHierarchicalResolution','ExplicitOnly');
            end
            thisPort.MustResolveToSignalObject=false;
            thisPort.RTWStorageClass='ExportedGlobal';
            thisPort.RTWStorageTypeQualifier='';
            thisPort.RTWStorageClass='Auto';
            thisPort.MustResolveToSignalObject=true;
        end


        for idx=1:length(hBlks)
            thisBlk=hBlks(idx);
            thisBlk.RTWStateStorageClass='ExportedGlobal';
            thisBlk.RTWStateStorageTypeQualifier='';
            thisBlk.RTWStateStorageClass='Auto';
            thisBlk.StateMustResolveToSignalObject=true;
        end


        configSet=getActiveConfigSet(model);
        if(isa(configSet,'Simulink.ConfigSet'))
            set_param(model,'SignalResolutionControl','UseLocalSettings');
        else
            assert(isa(configSet,'Simulink.ConfigSetRef'));
            MSLDiagnostic('Simulink:tools:CannotDisableImplicitSignalResolution',...
            configSet.WSVarName).reportAsWarning;
        end
    end

    if nargout==1
        if~isempty(ports)
            retVal.Signals=ports;
        end
        if~isempty(blks)
            retVal.States=blks;
        end
    end






    function name=l_FullName(name,suffix)

        if nargin==2
            name=[name,'/',suffix];
        end

        name=strrep(name,sprintf('\n'),' ');




        function isStateflow=l_IsPortInsideStateflowChart(thisPort)

            parentBlk=thisPort.Parent;
            parentSys=get_param(parentBlk,'Parent');


            if strcmp(get_param(parentSys,'Type'),'block')&&...
                slprivate('is_stateflow_based_block',parentSys)
                isStateflow=true;
            else
                isStateflow=false;
            end




            function doesResolve=l_IsSignalObjectResolved(modelName,hSrc,name)


                doesResolve=false;

                if iscvar(name)

                    parent=get_param(hSrc,'Parent');
                    while strcmp(get_param(parent,'Type'),'block')
                        if strcmp(get_param(parent,'PermitHierarchicalResolution'),'All')
                            parent=get_param(parent,'Parent');
                        else


                            return;
                        end
                    end


                    varExists=existsInGlobalScope(modelName,name);
                    if((varExists)&&...
                        (evalinGlobalScope(modelName,['isa(',name,', ''Simulink.Signal'');'])))
                        doesResolve=true;
                    end
                end




