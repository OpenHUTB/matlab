function fevalHandler(action,clientID,varargin)




    dsp.webscopes.internal.BaseWebScope.fevalHandler(action,clientID,varargin{:});
    Simulink.scopes.SLWebScopeUtils.fevalHandler(action,clientID,varargin{:});

    switch action
    case 'closeRequested'
        wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
        wsBlock.close();
        wsBlock.WebWindow.hide();
    case 'showHelp'
        mapFileLocation=fullfile(docroot,'toolbox','comm','comm.map');
        helpview(mapFileLocation,'constellation_diagram');
    case 'printPreviewDisplay'
        printPreviewDisplay(clientID);
    case 'setParameters'
        params=varargin{1};
        numParameters=numel(params);
        wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
        block=wsBlock.FullPath;

        for indx=1:numParameters
            paramName=params(indx).name;
            paramType=params(indx).type;
            paramValue=params(indx).value;
            if isequal(paramType,'bool')&&~strcmpi(paramName,'ExpandToolstrip')
                if isequal(paramValue,true)
                    paramValue='on';
                else
                    paramValue='off';
                end
            end
            try
                blockConfig=get_param(block,'ScopeConfiguration');
                if any(strcmpi(paramName,{'NumInputPorts','ExpandToolstrip'}))
                    blockConfig.(paramName)=paramValue;
                else
                    if strcmpi(paramName,'GraphicalSettings')
                        GRSettings=get_param(block,'GraphicalSettings');
                        if~strcmpi(GRSettings,paramValue)
                            set_param(bdroot(block),'Dirty','on');
                            blockConfig.IsCacheReferenceConstellation=true;
                        end
                    end
                    set_param(block,paramName,paramValue);
                end
            catch
            end
        end
    case 'setMeasurementParametersRequest'
        wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
        block=wsBlock.FullPath;
        params=varargin{1};
        paramNames=fieldnames(params);
        ValidParams=paramNames;
        for valIdx=1:numel(ValidParams)
            if any(strcmpi(ValidParams{valIdx},{'eventName'}))
                continue;
            end
            newVal=params.(ValidParams{valIdx});
            if islogical(newVal)
                newVal=utils.logicalToOnOff(newVal);
            elseif isnumeric(newVal)&&any(strcmpi(ValidParams{valIdx},{'MeasurementChannel','MeasurementPortChannel','MeasurementSignal'}))
                newVal=num2str(newVal);
            end
            oldVal=get_param(block,ValidParams{valIdx});
            if~strcmpi(oldVal,newVal)
                try
                    set_param(block,ValidParams{valIdx},newVal);
                catch
                end
            end
        end
    case 'referenceConstellationRequest'
        params=varargin{1};
        wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
        block=wsBlock.FullPath;

        blockConfig=get_param(block,'ScopeConfiguration');
        if~iscell(params.refConstellation)
            params.refConstellation=num2cell(params.refConstellation);
        end
        value=cellfun(@getActualRefCon,params.refConstellation,'un',0);
        referenceConstString=cell(size(params.refConstellation));
        if length(params.refConstellation)>1
            refConStr=[];
            for idx=1:length(params.refConstellation)
                delim='';
                if(idx==length(params.refConstellation))
                    delim=[];
                end
                blockConfig.currentReferenceConstellation{idx}=params.refConstellation{idx};
                refCon=params.refConstellation{idx}.ReferenceConstellation;
                if strcmpi(params.refConstellation{idx}.ReferenceConstellation,'Custom')
                    refCon=params.refConstellation{idx}.RefConstellationValue;
                end
                if contains(refCon,']')
                    refConStr=[refConStr,num2str(refCon),delim];%#ok<AGROW>
                else
                    refConStr=[refConStr,'[',num2str(refCon),']',delim];%#ok<AGROW>
                end
                referenceConstString{idx}=refCon;
            end
            refConStr=['{',refConStr,'}'];
        else
            refConStr=params.refConstellation{1}.ReferenceConstellation;
            if strcmpi(params.refConstellation{1}.ReferenceConstellation,'Custom')
                refConStr=params.refConstellation{1}.RefConstellationValue;
            end
            referenceConstString{1}=refConStr;
            blockConfig.currentReferenceConstellation{1}=params.refConstellation{1};
        end
        if isfield(params,'NeedtoPreserveDirty')

            preserveDirty=Simulink.PreserveDirtyFlag(bdroot(block),'blockDiagram');%#ok
            blockConfig.ShowReferenceConstellation=params.showReferenceConstellation;
            blockConfig.ReferenceConstellation=refConStr;
        else
            blockConfig.ShowReferenceConstellation=params.showReferenceConstellation;
            blockConfig.ReferenceConstellation=refConStr;
            blockConfig.IsCacheReferenceConstellation=true;
        end
        if~iscell(value)
            value={value};
        end
        xRefData=cell(size(value));
        yRefData=cell(size(value));
        for idx=1:numel(value)
            xRefData{idx}=real(value{idx});
            yRefData{idx}=imag(value{idx});
            value{idx}=mat2str(value{idx});
        end
        channel=['/webscope',clientID];
        msg.action=['updateParamSettings',clientID];
        ParamSettings=struct('ReferenceConstellation',struct('referenceConstellation',value,...
        'xRefData',xRefData,'yRefData',yRefData,'referenceConstellationString',referenceConstString),...
        "ReferenceConstellationDialog",struct('value',true));
        msg.params=ParamSettings;
        message.publish(channel,msg);
    case 'getNumInputPort'
        wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
        block=wsBlock.FullPath;
        num=get_param(block,'NumInputPorts');
        channel=['/webscope',clientID];
        msg.action=['setNumInputPorts',clientID];
        msg.params=num;
        message.publish(channel,msg);
    end
end
function refCon=getActualRefCon(currentInputRefCon)




    if refConIsPreset(currentInputRefCon.ReferenceConstellation)
        if ischar(currentInputRefCon.AverageReferencePower)
            [varargout{1:nargout}]=uiservices.evaluate(currentInputRefCon.AverageReferencePower);
            this.Specification.AveragePower=varargout{1};
        else
            this.Specification.AveragePower=currentInputRefCon.AverageReferencePower;
        end
        if ischar(currentInputRefCon.ReferencePhaseOffSet)
            [varargout{1:nargout}]=uiservices.evaluate(currentInputRefCon.ReferencePhaseOffSet);
            this.Specification.PhaseOffset=varargout{1};
        else
            this.Specification.PhaseOffset=currentInputRefCon.ReferencePhaseOffSet;
        end
        refConPower=this.Specification.AveragePower;
        refConOffset=this.Specification.PhaseOffset;
        if any(strcmp(currentInputRefCon.ReferenceConstellation,{'BPSK',getString(message('comm:ConstellationVisual:BPSK'))}))


            refCon={refConPower*constellation(comm.BPSKModulator('PhaseOffset',refConOffset)).'};

        elseif any(strcmp(currentInputRefCon.ReferenceConstellation,{'QPSK',getString(message('comm:ConstellationVisual:QPSK'))}))

            refCon={refConPower*constellation(comm.QPSKModulator('PhaseOffset',refConOffset)).'};

        elseif any(strcmp(currentInputRefCon.ReferenceConstellation,{'8-PSK',getString(message('comm:ConstellationVisual:PSK8'))}))

            refCon={refConPower*constellation(comm.PSKModulator('PhaseOffset',refConOffset)).'};

        else
            if any(strcmp(currentInputRefCon.ReferenceConstellation,{'16-QAM',getString(message('comm:ConstellationVisual:QAM16'))}))

                modulationOrder=16;
            elseif any(strcmp(currentInputRefCon.ReferenceConstellation,{'64-QAM',getString(message('comm:ConstellationVisual:QAM64'))}))

                modulationOrder=64;
            elseif any(strcmp(currentInputRefCon.ReferenceConstellation,{'256-QAM',getString(message('comm:ConstellationVisual:QAM256'))}))

                modulationOrder=256;
            end
            this.Specification.ConstellationNormalization=currentInputRefCon.ConstellationNormalization;
            normalizationMethod=this.Specification.ConstellationNormalization;
            if strcmp(normalizationMethod,'MinimumDistance')||strcmp(normalizationMethod,'MinDistance')
                this.Specification.MinDistance=refConPower;
            elseif strcmp(normalizationMethod,'AveragePower')
                this.Specification.MinDistance=comm.internal.qam.minDistanceForAvgPower(refConPower,modulationOrder);
            elseif strcmp(normalizationMethod,'PeakPower')
                this.Specification.MinDistance=comm.internal.qam.minDistanceForPeakPower(refConPower,modulationOrder);
            end
            refCon={(this.Specification.MinDistance/2).*exp(1i*refConOffset).*qammod((0:modulationOrder-1),modulationOrder,'bin')};
        end
        refCon=refCon{1};
    else
        [varargout{1:nargout}]=uiservices.evaluate(currentInputRefCon.RefConstellationValue);
        refCon=varargout{1};
    end
end
function isPreset=refConIsPreset(varargin)




    NonQAMpresets={'BPSK',getString(message('comm:ConstellationVisual:BPSK')),...
    'QPSK',getString(message('comm:ConstellationVisual:QPSK')),...
    '8-PSK',getString(message('comm:ConstellationVisual:PSK8'))};
    qamPresets={'16-QAM',getString(message('comm:ConstellationVisual:QAM16')),...
    '64-QAM',getString(message('comm:ConstellationVisual:QAM64')),...
    '256-QAM',getString(message('comm:ConstellationVisual:QAM256'))};
    mustBeQAM=false;
    refCon=varargin{1};
    if nargin==3&&strcmp(varargin{2},'QAM')
        mustBeQAM=true;
    end
    if isa(refCon,'double')
        refCon=mat2str(refCon);
    end
    if mustBeQAM&&ismember(refCon,qamPresets)
        isPreset=true;
    elseif~mustBeQAM&&(ismember(refCon,[qamPresets,NonQAMpresets]))
        isPreset=true;
    else
        isPreset=false;
    end
end


function printPreviewDisplay(clientId)
    import dsp.webscopes.internal.*;
    webWindow=BaseWebScope.getWebWindowFromClientID(clientId);
    if isempty(webWindow)
        return;
    end
    fig=prepareWebWindowForSharing(webWindow,'print');

    BaseWebScope.publishMessage(clientId,'onPrePrintPreview',true);
    if~isMATLABOnline()

        printpreview(fig);
    else

        desiredName='ConstellationDiagram';
        uniqueName=getUniqueFileName(desiredName);
        print(uniqueName,'-dpdf');
    end
    delete(fig);

    BaseWebScope.publishMessage(clientId,'onPostPrintPreview',true);
end



function fig=prepareWebWindowForSharing(webWindow,action)
    screenshot=flipud(getScreenshot(webWindow));
    pos=webWindow.Position;
    fig=figure(...
    'HandleVisibility',uiservices.logicalToOnOff(strcmpi(action,'copy')),...
    'Visible','off',...
    'Position',pos);
    a=axes(...
    'Parent',fig,...
    'Position',[0,0,1,1]);

    img=image(...
    'Parent',a,...
    'CData',screenshot);

    xLim=a.XLim;
    yLim=a.YLim;

    img.XData=[1,xLim(2)-1];
    img.YData=[1,yLim(2)-1];
end


function flag=isMATLABOnline(~)

    flag=matlab.internal.environment.context.isMATLABOnline||...
    matlab.ui.internal.desktop.isMOTW;
end

function uniqueName=getUniqueFileName(desiredName)


    dirPDFFiles=dir('./*.pdf');
    existingPDFNames={''};
    if~isempty(dirPDFFiles)
        existingPDFNames={dirPDFFiles.name};

        existingPDFNames=regexprep(existingPDFNames,'.pdf','');
    end
    uniqueName=matlab.lang.makeUniqueStrings(desiredName,existingPDFNames);
end
