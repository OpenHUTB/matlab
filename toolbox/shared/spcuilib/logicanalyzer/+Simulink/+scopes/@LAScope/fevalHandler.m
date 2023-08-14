function fevalHandler(action,clientId,varargin)




    hModel=str2double(clientId);




    if slfeature('slPbcModelRefEditorReuse')
        getLAScopeInstance=@()Simulink.scopes.LAScope.GetInstanceForModel(hModel,get_param(hModel,'Name'));

        hModel=Simulink.scopes.getTopLevelMdl(hModel,getLAScopeInstance);
    end



    if~ishandle(hModel)
        return;
    end

    switch action
    case 'HiliteSource'
        uuid=varargin{1};
        portHandle=Simulink.scopes.LAScope.getPortHandleFromUUID(clientId,uuid);
        if isequal(portHandle,-1)
            CheckAndHiliteIfSFinModel(hModel,uuid);
            return;
        else
            model=bdroot(portHandle);
            fullPath=get(portHandle,'Parent');

            lines=accumulateLineChildren(get_param(portHandle,'Line'));
            containingParent=get_param(fullPath,'Parent');


            open_system(containingParent,'force');


            hEditor=GLUE2.Util.findAllEditors(get(model,'name'));
            if isempty(hEditor)
                hEditor=GLUE2.Util.findAllEditors(containingParent);
            end
            hStudio=hEditor.getStudio();

            hStudio.App.hiliteAndFadeObject(diagram.resolver.resolve(get_param(fullPath,'Handle')),1200);
            for jndx=1:length(lines)
                hStudio.App.hiliteAndFadeObject(diagram.resolver.resolve(lines(jndx)),1200);
            end

        end


    case 'HelpRequested'
        switch varargin{1}
        case 'aboutDST'
            aboutdspsystbx;
        otherwise
            helpview(fullfile(docroot,'toolbox','dsp','dsp.map'),varargin{1});
        end
    case 'AddWave'

    case 'SimulationCommand'
        Simulink.scopes.simulationCommand(varargin{1},varargin{2},hModel);
    case 'MakeModelDirty'
        set_param(hModel,'Dirty','on');
    case 'ThrowSignalLoggingMessage'
        loggingOn=strcmp(get_param(hModel,'SignalLogging'),'on');
        loggingMessage.params=[];
        if(loggingOn)
            actionStr=strcat('updateForSignalLoggingOn',clientId);
        else
            actionStr=strcat('updateForSignalLoggingOff',clientId);
        end
        loggingMessage.action=actionStr;
        message.publish('/logicanalyzer',loggingMessage);

    case 'ThrowLoggingOverrideMessage'
        modelLogInfoObj=get_param(hModel,'DataLoggingOverride');
        overrideOn=~modelLogInfoObj.getLogAsSpecifiedInModel(modelLogInfoObj.Model);
        loggingOn=strcmp(get_param(hModel,'SignalLogging'),'on');
        loggingMessage.params=[];
        if(loggingOn&&overrideOn)
            actionStr=strcat('updateForLoggingOverrideOn',clientId);
        else
            actionStr=strcat('updateForLoggingOverrideOff',clientId);
        end
        loggingMessage.action=actionStr;
        message.publish('/logicanalyzer',loggingMessage);
    end

    function CheckAndHiliteIfSFinModel(hModel,sigUUID)
        instr_signals=get_param(hModel,'InstrumentedSignals');
        if~isempty(instr_signals)
            num_signals=instr_signals.Count;
            for kndx=1:num_signals
                k_signal=instr_signals.get(num_signals-kndx+1,true);
                if(sigUUID==k_signal.UUID)
                    sfSig=k_signal;
                    break;
                end
            end
        end
        if~isempty(sfSig)





            rt=sfroot;
            m=rt.find('-isa','Simulink.BlockDiagram','name',get_param(hModel,'name'));
            sfChartObj=m.find('Path',sfSig.BlockPath_,...
            '-isa','Stateflow.Chart',...
            '-or','-isa','Stateflow.TruthTableChart',...
            '-or','-isa','Stateflow.StateTransitionTableChart',...
            '-or','-isa','Stateflow.LinkChart');
            if length(sfChartObj)~=1
                sfChartObj=sfSubSys.find('-isa','Stateflow.Chart','Path',sfSig.BlockPath_);
            elseif~isempty(sfChartObj)
                chartId1=sfprivate('block2chart',get_param(sfChartObj.Path,'handle'));
                sfChartObj=idToHandle(sfroot,chartId1);
            end
            Simulink.ID.hilite(sfSig.SID_);
            sfChartObj.view;
            sf('Select',sfChartObj.Id,[]);
            if(sfSig.DomainType_=="sf_state")
                sfState=sfChartObj.find('-isa','Stateflow.State','SSIDNumber',str2double(sfSig.DomainParams_.SSID));
                sf('Select',sfChartObj.Id,sfState.Id);
            end
        end


        function hLine=accumulateLineChildren(hLine)

            children=get_param(hLine,'LineChildren');
            for indx=1:numel(children)
                hLine=[hLine;accumulateLineChildren(children(indx))];%#ok<AGROW>
            end


