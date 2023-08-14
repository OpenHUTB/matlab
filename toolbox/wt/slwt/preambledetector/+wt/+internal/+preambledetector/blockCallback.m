function varargout=blockCallback(varargin)




    if nargout==0
        feval(varargin{:});
    else
        [varargout{1:nargout}]=feval(varargin{:});
    end
end


function simulationSetupCb(blkH)
    blkP=i_getDialogParams(blkH);
    me=get_param(blkH,'MaskEnables');
    if isequal(blkP.simulationSetup,'Custom')
        me(logical([0,1,1,1,1,1,1,1,1,1,1]))={'on'};
        set_param(blkH,'MaskEnables',me);
    else
        me(logical([0,1,1,1,1,1,1,1,1,1,1]))={'off'};
        set_param(blkH,'MaskEnables',me);
    end




    simParams=i_getSimParams(blkH,blkP.simulationSetup);
    i_setSimParams(blkH,simParams);
end

function thresholdMethodCb(blkH)

    blkP=i_getDialogParams(blkH);
    if isequal(blkP.thresholdMethod,'adaptive')
        set_param(blkH,'MaskVisibilities',{'on';'on';'on';'on';'off';'on';'off';'on';'on';'on';'on'});
    else
        set_param(blkH,'MaskVisibilities',{'on';'on';'on';'on';'off';'off';'on';'off';'on';'on';'on'});
    end
end

function InitFcn(blkH)

    blkP=i_getDialogParams(blkH);
    if~isequal(blkP.simulationSetup,'Custom')

        cfg=wt.internal.preambledetector.Config(blkP.simulationSetup);
        [varData,constData,busInfo]=cfg.getDataForSimulation;
    else

        cfg=wt.internal.preambledetector.Config('Custom');
        preamble=blkP.workspaceNamePreamble;
        filterCoefficients=flipud(conj(preamble));
        inputSignal=blkP.workspaceSignalName;

        ParameterValidations(blkP,filterCoefficients);

        cfg.FilterCoefficients=filterCoefficients;
        cfg.generateHWCoefficients(filterCoefficients,1);


        cfg.ThresholdMethod=blkP.thresholdMethod;
        cfg.AdaptiveThresholdWindowLength=length(cfg.FilterCoefficients);
        cfg.AdaptiveThresholdScaler=blkP.adaptiveThresholdScaler;
        cfg.FixedThreshold=blkP.fixedThresholdValue;
        cfg.MinThreshold=blkP.minimumThresholdValue;
        cfg.RecordNum=blkP.recordLength;
        cfg.SampleRate=blkP.sampleRate;
        cfg.Ts=1/blkP.sampleRate;
        cfg.FilterArchitecture='serial';
        [cfg.WaitNum,cfg.DelayNum]=getTriggerDelay(blkP.triggerDelay);

        [varData,constData,busInfo]=cfg.getDataForSimulation(inputSignal);
    end
    assignin('base','Ts',cfg.Ts);
    assignin('base','VariableData',varData);
    assignin('base','ConstantData',constData);
    assignin('base','BusInfo',busInfo);
end

function ParameterValidations(blkParam,filterCoefficients)

    try
        mustBeInRange(blkParam.adaptiveThresholdScaler,0,64);
        mustBeNumeric(blkParam.adaptiveThresholdScaler);
    catch
        error(message('wt:preambledetector:InvalidThresholdScaler',0,64));
    end

    try
        mustBeInRange(length(filterCoefficients),1,1536);
    catch
        error(message('wt:preambledetector:FilterTooLong',1,1536));
    end
    try
        mustBeVector(filterCoefficients);
        validateattributes(filterCoefficients,{'double','single','embedded.fi'},{'column','>=',-1,'<',1});
    catch
        error(message('wt:preambledetector:InvalidPreambleValue'));
    end

    try
        mustBeVector(blkParam.workspaceSignalName)
        validateattributes(blkParam.workspaceSignalName,{'double','single','embedded.fi'},{'column','>=',-1,'<',1});
    catch
        error(message('wt:preambledetector:InvalidInputSignal'));
    end

    if(strcmp(blkParam.thresholdMethod,"Fixed"))
        try
            mustBeInRange(blkParam.fixedThresholdValue,0,4095);
            mustBeNumeric(blkParam.fixedThresholdValue);
        catch
            error(message('wt:preambledetector:InvalidFixedThresholdValue',0,4095));
        end
    else

        try
            mustBeInRange(blkParam.minimumThresholdValue,0,2);
            mustBeNumeric(blkParam.minimumThresholdValue);
        catch
            error(message('wt:preambledetector:InvalidMinimumThreshold',0,2));
        end
    end

    try
        mustBeInteger(blkParam.recordLength);
        mustBePositive(blkParam.recordLength);
    catch
        error(message('wt:preambledetector:InvalidRecordLength'));
    end

    try
        mustBeInteger(blkParam.triggerDelay);
        mustBeInRange(blkParam.triggerDelay,-3096,4096);
    catch
        error(message('wt:preambledetector:InvalidTriggerOffset',-3096,4096));
    end
end


function MaskInitFcn(blkH)


    if i_IsLibContext(blkH)
        return;
    end


    blkP=i_getDialogParams(blkH);
    if isequal(blkP.simulationSetup,'Custom')

        blkP=i_getDialogParams(blkH);
        blkP.workspaceNamePreamble=get_param(blkH,'workspaceNamePreamble');
        blkP.workspaceSignalName=get_param(blkH,'workspaceSignalName');
        set_param(blkH,'UserData',blkP);
    end
end


function[waitNum,delayNum]=getTriggerDelay(delay)


    delay=delay-1;
    if(delay>0)
        delayNum=1;
        waitNum=delay;
    elseif(delay<0)
        delayNum=-delay+1;
        waitNum=1;
    else
        delayNum=2;
        waitNum=2;
    end
end

function blkPath=i_getBlkPath(blkH)
    blkPath=[get(blkH,'Path'),'/',strrep(get(blkH,'Name'),'/','//')];
end

function[p,idxMap]=i_getDialogParams(blkH,varargin)
...
...
...
...

    if nargin==2
        evalFunc={varargin{1}};%#ok<CCAT1>
    else
        evalFunc={'evalin','base'};
    end

    dpnames=fieldnames(get_param(blkH,'DialogParameters'));
    dpstrvalues=cellfun(@(x)(get_param(blkH,x)),dpnames,'UniformOutput',false);
    dpvalues={};
    for v=dpstrvalues'
        try
            val=feval(evalFunc{:},v{1},blkH);
        catch ME %#ok<NASGU>
            val=v{1};
        end
        dpvalues{end+1}=val;%#ok<AGROW>
    end
    p=cell2struct(dpvalues,dpnames',2);


    pnames=get_param(blkH,'MaskNames');
    idxMap=containers.Map;
    for ii=1:length(pnames)
        idxMap(pnames{ii})=ii;
    end
end

function simParams=i_getSimParams(blkH,simulationSetup)

    switch simulationSetup
    case{'WLAN 20MHz','5GNR PSS'}
        simParams=i_getSimParamsFromConfig(simulationSetup);

    case{'Custom'}
        simParams=get_param(blkH,'UserData');
        if isempty(simParams)

            simParams=i_getSimParamsFromConfig('WLAN 20MHz');
        end


        fnames=fieldnames(simParams);
        for k=1:numel(fnames)
            f=fnames{k};
            if~ischar(simParams.(f))||~isstring(simParams.(f))
                simParams.(f)=string(simParams.(f));
            end
        end
        simParams.adaptiveThresholdWindowLength=string(length(get_param(blkH,'workspaceNamePreamble')));
    end
    simParams.workspaceNamePreamble=get_param(blkH,'workspaceNamePreamble');
    simParams.workspaceSignalName=get_param(blkH,'workspaceSignalName');
end

function simParams=i_getSimParamsFromConfig(waveformName)


    cfg=wt.internal.preambledetector.Config(waveformName);
    simParams.thresholdMethod='adaptive';
    simParams.adaptiveThresholdWindowLength=string(cfg.AdaptiveThresholdWindowLength);
    simParams.adaptiveThresholdScaler=string(cfg.AdaptiveThresholdScaler);
    simParams.fixedThresholdValue=string(cfg.FixedThreshold);
    simParams.minimumThresholdValue=string(cfg.MinThreshold);
    simParams.recordLength=string(cfg.RecordNum);
    simParams.sampleRate=string(cfg.SampleRate);
    simParams.triggerDelay=string(-cfg.DelayNum-1);
end

function i_setSimParams(blkH,simParams)

    set_param(blkH,...
    'workspaceNamePreamble',simParams.workspaceNamePreamble,...
    'workspaceSignalName',simParams.workspaceSignalName,...
    'thresholdMethod',simParams.thresholdMethod,...
    'adaptiveThresholdWindowLength',simParams.adaptiveThresholdWindowLength,...
    'adaptiveThresholdScaler',simParams.adaptiveThresholdScaler,...
    'minimumThresholdValue',simParams.minimumThresholdValue,...
    'fixedThresholdValue',simParams.fixedThresholdValue,...
    'triggerDelay',simParams.triggerDelay,...
    'sampleRate',simParams.sampleRate,...
    'recordLength',simParams.recordLength);
end

function tf=i_IsLibContext(blkH)
    tf=any(strcmp(get(bdroot(blkH),'Name'),{'wtlib'}));
end


