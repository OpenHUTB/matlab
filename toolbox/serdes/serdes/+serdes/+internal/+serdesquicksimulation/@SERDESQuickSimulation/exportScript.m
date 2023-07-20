function hDoc=exportScript(obj)




    if~isempty(obj)

        if~obj.refreshValuesFromWorkspaceVariables()
            return;
        end
    end

    [sys,~,mismatchedValuesBlocksCTLE,mismatchedValuesBlocksDFECDR]=computeQuickSimulation(obj);
    if~isempty(mismatchedValuesBlocksCTLE)||~isempty(mismatchedValuesBlocksDFECDR)
        serdes.internal.apps.serdesdesigner.Model.showMismatchedValuesDialog(mismatchedValuesBlocksCTLE,mismatchedValuesBlocksDFECDR);
        return;
    end

    sw=StringWriter;

    addcr(sw,'% ------------------------------------')
    addcr(sw,'% MATLAB script to build SerDes System')
    addcr(sw,'% ------------------------------------')


    txElementCount=0;
    rxElementCount=0;
    isTx=true;
    for i=1:length(obj.Elements)
        elem=obj.Elements{i};
        if isa(elem,'serdes.internal.apps.serdesdesigner.agc')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.ffe')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.vga')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.satAmp')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.dfeCdr')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.cdr')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.ctle')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.transparent')
            if isTx
                txElementCount=txElementCount+1;
            else
                rxElementCount=rxElementCount+1;
            end
        elseif isa(elem,'serdes.internal.apps.serdesdesigner.channel')
            isTx=false;
        end
    end


    if txElementCount>0
        addcr(sw,'');
        addcr(sw,'% Build cell array of Tx blocks:')
    end

    txCount=0;
    rxCount=0;
    isTx=true;
    for i=1:length(obj.Elements)
        elem=obj.Elements{i};
        if isa(elem,'serdes.internal.apps.serdesdesigner.agc')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.ffe')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.vga')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.satAmp')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.dfeCdr')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.cdr')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.ctle')||...
            isa(elem,'serdes.internal.apps.serdesdesigner.transparent')
            if isTx
                txCount=txCount+1;
                vn=sprintf('txBlocks{%d}',txCount);
                exportScript(elem,sw,vn,true);
            else
                rxCount=rxCount+1;
                vn=sprintf('rxBlocks{%d}',rxCount);
                exportScript(elem,sw,vn,true);
            end
        elseif isa(elem,'serdes.internal.apps.serdesdesigner.channel')
            isTx=false;
            if rxElementCount>0
                addcr(sw,'');
                addcr(sw,'% Build cell array of Rx blocks:')
            end
        end
    end

    if~isempty(sys)
        sysProps=getSetableProperties(sys);
        if~isempty(sysProps)&&numel(sysProps)>0
            for i=1:numel(sysProps)
                switch sysProps{i}
                case 'TxModel'
                    txModelName=buildTxRxModel(sw,sys,sysProps{i},'tx','Transmitter',txCount);
                case 'RxModel'
                    rxModelName=buildTxRxModel(sw,sys,sysProps{i},'rx','Receiver',rxCount);
                case 'ChannelData'
                    channelModelName=buildChannelModel(sw,sys,sysProps{i},'channel','ChannelData');
                case 'JitterAndNoise'
                    jitterAndNoiseName=buildJitterAndNoise(sw,sys);
                case 'dt'
                    dtName='dt';
                case 'SymbolTime'
                    symbolTimeName='SymbolTime';
                case 'ImpulseDelay'
                    impulseDelayName='ImpulseDelay';
                case 'ImpulseResponse'
                    impulseResponseName='ImpulseResponse';


                end
            end
            sysPropsCount=0;
            addcr(sw,'');
            addcr(sw,'% Build SerDes System:');

            addcr(sw,sprintf('SymbolTime = %g;',sys.SymbolTime));
            addcr(sw,sprintf('SamplesPerSymbol = %g;',sys.SamplesPerSymbol));
            addcr(sw,sprintf('ModulationLevels = %g;',sys.Modulation));
            addcr(sw,sprintf('BERtarget = %g;',sys.BERtarget));

            addcr(sw,'sys = SerdesSystem(...');
            if~isempty(txModelName)
                sysPropsCount=sysPropsCount+1;
                addcr(sw,sprintf('\t''TxModel'',%s,...',txModelName));
            end
            if~isempty(rxModelName)
                sysPropsCount=sysPropsCount+1;
                addcr(sw,sprintf('\t''RxModel'',%s,...',rxModelName));
            end
            if~isempty(channelModelName)
                sysPropsCount=sysPropsCount+1;
                addcr(sw,sprintf('\t''ChannelData'',%s,...',channelModelName));
            end
            if~isempty(jitterAndNoiseName)
                sysPropsCount=sysPropsCount+1;
                addcr(sw,sprintf('\t''JitterAndNoise'',%s,...',jitterAndNoiseName));
            end



















            for i=1:numel(sysProps)
                switch sysProps{i}
                case 'TxModel'
                case 'RxModel'
                case 'ChannelData'
                case 'JitterAndNoise'
                case 'dt'
                case 'ImpulseDelay'
                case 'ImpulseResponse'
                case 'ChannelDataSet'
                otherwise
                    sysPropsCount=sysPropsCount+1;
                    switch sysProps{i}
                    case 'SymbolTime'
                        addcr(sw,getParamString(sysProps{i},'SymbolTime',sysPropsCount==numel(sysProps),true));
                    case 'SamplesPerSymbol'
                        addcr(sw,getParamString(sysProps{i},'SamplesPerSymbol',sysPropsCount==numel(sysProps),true));
                    case 'Modulation'
                        addcr(sw,getParamString(sysProps{i},'ModulationLevels',sysPropsCount==numel(sysProps),true));
                    case 'BERtarget'
                        addcr(sw,getParamString(sysProps{i},'BERtarget',sysPropsCount==numel(sysProps),true));
                    otherwise
                        if~isempty(sys.(sysProps{i}))
                            addcr(sw,getParamString(sysProps{i},sys.(sysProps{i}),sysPropsCount==numel(sysProps)));
                        end
                    end
                end
            end

        end
    end

    addcr(sw,sprintf('\n%%Visualize Pulse Response'));
    addcr(sw,sprintf('figure'));
    addcr(sw,sprintf('plotPulse(sys)'));

    addcr(sw,sprintf('\n%%Visualize PRBS Waveform Response'));
    addcr(sw,sprintf('figure'));
    addcr(sw,sprintf('plotWavePattern(sys)'));

    addcr(sw,sprintf('\n%%Plot bathtubs, Statistical Eye and contours'));
    addcr(sw,sprintf('figure'));
    addcr(sw,sprintf('plotStatEye(sys)'))

    addcr(sw,sprintf('\n%%Display Report'));
    addcr(sw,sprintf('analysisReport(sys)'));


    addcr(sw,sprintf('\n%% To export Serdes System to Simulink execute the following command:'));
    addcr(sw,sprintf('%% exportToSimulink(sys);'));

    if sys.ChannelData.OptionSel==1
        addcr(sw,newline);
        addcr(sw,sprintf('function impulse = getimpulse()'));
        addcr(sw,sprintf('\t%%Return the impulse response referenced in the SerDes Designer App.'));
        localImpulse=sys.ChannelData.Impulse;
        addcr(sw,sprintf('\timpulse = zeros(%i,%i);',size(localImpulse)));
        for ii=1:size(localImpulse,2)
            localstr=sprintf('%g, ',localImpulse(:,ii));
            addcr(sw,sprintf('\t\timpulse(:,%i) = [%s];',ii,localstr));
        end
        addcr(sw,sprintf('end\n'));
    end



    if nargout<1
        matlab.desktop.editor.newDocument(sw.string);
    else
        hDoc=matlab.desktop.editor.newDocument(sw.string);
    end

end

function modelName=buildChannelModel(sw,sys,sysProp,modelType,modelClass)
    modelProps=properties(sys.(sysProp));
    if isempty(modelProps)||numel(modelProps)<=0
        modelName=[];
        return;
    end
    modelName=modelType;
    modelPropsCount=0;
    addcr(sw,'');
    addcr(sw,sprintf('%% Build %s:',modelClass));
    addcr(sw,sprintf('channel = %s( ...',modelClass));

    if sys.ChannelData.OptionSel==1

        addcr(sw,'    ''Impulse'',getimpulse(),...',false);
        addcr(sw,getParamString('dt',sys.(sysProp).dt,true));
    elseif sys.ChannelData.OptionSel==3

        addcr(sw,getParamString('ChannelLossdB',sys.(sysProp).ChannelLossdB,false));
        addcr(sw,getParamString('ChannelLossFreq',sys.(sysProp).ChannelLossFreq,false));

        if sys.(sysProp).EnableCrosstalk
            addcr(sw,getParamString('ChannelDifferentialImpedance',sys.(sysProp).ChannelDifferentialImpedance,false));
            addcr(sw,getParamString('EnableCrosstalk',sys.(sysProp).EnableCrosstalk,false));
            addcr(sw,getParamString('CrosstalkSpecification',sys.(sysProp).CrosstalkSpecification,false));
            if strcmpi(sys.(sysProp).CrosstalkSpecification,'Custom')
                addcr(sw,getParamString('FEXTICN',sys.(sysProp).FEXTICN,false));
                addcr(sw,getParamString('NEXTICN',sys.(sysProp).NEXTICN,false));
            end
            addcr(sw,getParamString('fb',sys.(sysProp).fb,true));
        else
            addcr(sw,getParamString('ChannelDifferentialImpedance',sys.(sysProp).ChannelDifferentialImpedance,true));
        end
    else

    end



















end

function modelName=buildTxRxModel(sw,sys,sysProp,modelType,modelClass,blockCount)
    modelProps=properties(sys.(sysProp));
    if isempty(modelProps)||numel(modelProps)<=0
        modelName=[];
        return;
    end
    modelName=modelType;
    addcr(sw,'');
    addcr(sw,sprintf('%% Build %sModel:',modelType));
    analogModelPropsCount=0;
    if isprop(sys.(sysProp),'AnalogModel')
        analogProps=properties(sys.(sysProp).('AnalogModel'));
        if~isempty(analogProps)&&numel(analogProps)>0
            addcr(sw,sprintf('%sAnalogModel = AnalogModel( ...',modelType));
            for i=1:numel(analogProps)
                analogModelPropsCount=analogModelPropsCount+1;
                addcr(sw,getParamString(analogProps{i},sys.(sysProp).('AnalogModel').(analogProps{i}),i==numel(analogProps)));
            end
        end
    end
    addcr(sw,sprintf('%s = %s( ...',modelType,modelClass));
    if blockCount>0
        addcr(sw,sprintf('\t''Blocks'',%sBlocks, ...',modelType));
    end
    modelPropsCount=1;
    if analogModelPropsCount>0
        modelPropsCount=modelPropsCount+1;
        addcr(sw,sprintf('\t''AnalogModel'',%sAnalogModel, ...',modelType));
    end
    for i=1:numel(modelProps)
        switch modelProps{i}
        case 'Blocks'
        case 'AnalogModel'
        otherwise
            modelPropsCount=modelPropsCount+1;
            addcr(sw,getParamString(modelProps{i},sys.(sysProp).(modelProps{i}),modelPropsCount==numel(modelProps)));
        end
    end
end

function str=getParamString(name,value,isEnd,varargin)
    if nargin==4
        isVariable=varargin{1};
    else
        isVariable=false;
    end
    if isEnd
        ending=');';
    else
        ending=', ...';
    end
    if isempty(value)
        str=sprintf('\t''%s'',[]%s',name,ending);
    elseif isnumeric(value)||islogical(value)
        str=sprintf('\t''%s'',%d%s',name,value,ending);
    else
        if isVariable
            str=sprintf('\t''%s'',%s%s',name,value,ending);
        else
            str=sprintf('\t''%s'',''%s''%s',name,value,ending);
        end
    end
end

function propnames=getSetableProperties(sys)









    mc=metaclass(sys);


    test1=strcmp({mc.PropertyList(:).SetAccess},'public');
    test2=~[mc.PropertyList(:).Hidden];
    test3=~[mc.PropertyList(:).Dependent];


    propnames={mc.PropertyList(test1&test2&test3).Name};
end

function modelName=buildJitterAndNoise(sw,sys)
    jitterProps=properties(sys.JitterAndNoise);
    modelName='jitter';



    isUI=zeros(size(jitterProps));
    isIncluded=zeros(size(jitterProps));
    firstUI=1;
    for ii=1:length(isUI)
        if isa(sys.JitterAndNoise.(jitterProps{ii}),'SimpleJitter')&&...
            sys.JitterAndNoise.(jitterProps{ii}).Include==1

            isIncluded(ii)=1;

            if strcmp(sys.JitterAndNoise.(jitterProps{ii}).Type,'UI')
                if firstUI==1
                    addcr(sw,'');
                    addcr(sw,'% Build jitter parameters defined as Type UI:');
                    firstUI=0;
                end

                addcr(sw,'%s = SimpleJitter(''Value'',%s,''Include'',true,''Type'',''UI'');',...
                jitterProps{ii},...
                sprintf('%.15f',sys.JitterAndNoise.(jitterProps{ii}).Value));


                isUI(ii)=1;
            end
        end
    end

    addcr(sw,'');
    addcr(sw,'% Build Jitter And Noise Object:');
    addcr(sw,'%s = JitterAndNoise( ...',modelName);
    for ii=1:length(isIncluded)
        if isIncluded(ii)
            if isUI(ii)
                addcr(sw,sprintf('\t''%s'',%s,...',jitterProps{ii},jitterProps{ii}));
            else
                addcr(sw,getParamString(jitterProps{ii},sys.JitterAndNoise.(jitterProps{ii}).Value,false));
            end
        end
    end
    addcr(sw,getParamString('RxClockMode',sys.JitterAndNoise.RxClockMode,true));
end