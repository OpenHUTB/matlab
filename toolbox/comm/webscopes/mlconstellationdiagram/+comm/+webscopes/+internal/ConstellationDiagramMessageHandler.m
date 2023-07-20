classdef(Hidden=true)ConstellationDiagramMessageHandler<matlabshared.scopes.WebScopeMessageHandler



    properties(Hidden)

        Specification;

        TargetLines;
        success;
        NonQAMpresets={'BPSK',getString(message('comm:ConstellationVisual:BPSK')),...
        'QPSK',getString(message('comm:ConstellationVisual:QPSK')),...
        '8-PSK',getString(message('comm:ConstellationVisual:PSK8'))};
        QAMpresets={'16-QAM',getString(message('comm:ConstellationVisual:QAM16')),...
        '64-QAM',getString(message('comm:ConstellationVisual:QAM64')),...
        '256-QAM',getString(message('comm:ConstellationVisual:QAM256'))};
    end
    methods


        function url=getUrl(~)
            url='toolbox/comm/webscopes/mlconstellationdiagram/web/constellationdiagram-systemobject';
        end

        function release(~)
        end

        function reset(this)
            this.ClientSettingsStale=true;
            this.publish('onReset',[]);

            for indx=1:100
                if~this.ClientSettingsStale
                    return;
                end
                pause(.1);
            end
        end


        function S=toStruct(this)
            S=toStruct@matlabshared.scopes.WebMessageHandler(this);
        end


        function fromStruct(this,S)
            fromStruct@matlabshared.scopes.WebMessageHandler(this,S);
        end

        function setExpandToolstrip(this,value)
            this.publish('setExpandToolstrip',value);
        end

        function setDefaultLegendLabel(this,value)
            this.publish('setDefaultLegendLabel',value);
        end


        function setTitle(this,value)
            if~isempty(value)
                this.publish('setTitle',value);
            end
        end


        function setXLimits(this,value)
            if~isempty(value)
                this.publish('setXLimits',value);
            end
        end


        function setYLimits(this,value)
            if~isempty(value)
                this.publish('setYLimits',value);
            end
        end


        function setXLabel(this,value)
            if~isempty(value)
                this.publish('setXLabel',value);
            end
        end


        function setYLabel(this,value)
            if~isempty(value)
                this.publish('setYLabel',value);
            end
        end


        function setSamplesPerSymbol(this,value)
            if~isempty(value)
                this.publish('setSamplesPerSymbol',value);
            end
        end


        function setSampleOffset(this,value)
            if~isempty(value)
                this.publish('setSampleOffset',value);
            end
        end


        function setSymbolsToDisplaySource(this,value)
            if~isempty(value)
                this.publish('setSymbolsToDisplaySource',this.Specification.getUISymbolsToDisplaySourceValue());
            end
        end


        function setSymbolsToDisplay(this,value)
            if~isempty(value)
                this.publish('setSymbolsToDisplay',value);
            end
        end


        function setReferenceConstellation(this,value)
            if~isempty(value)
                this.Specification.UpdateReferenceConstellation();
                this.Specification.updateReferenceConstelaltionValues();
                this.publish('setReferenceConstellation',struct('referenceConstellation',this.Specification.getRefStringValue(),...
                'xRefData',this.Specification.xRefData,...
                'yRefData',this.Specification.yRefData));
            end
        end

        function setReferenceMarker(this,value)
            if~isempty(value)
                this.publish('setReferenceMarker',struct('referenceMarker',value));
            end
        end


        function setReferenceColor(this,value)
            if~isempty(value)
                this.publish('setReferenceColor',struct('referenceColor',value));
            end
        end


        function setShowReferenceConstellation(this,value)
            if~isempty(value)
                this.publish('setShowReferenceConstellation',value);
            end
        end


        function setColorFading(this,value)
            if~isempty(value)
                this.publish('setColorFading',value);
            end
        end


        function setShowGrid(this,value)
            if~isempty(value)
                this.publish('setShowGrid',value);
            end
        end


        function setNumInputPorts(this,value)
            if~isempty(value)
                this.publish('setNumInputPorts',value);
            end
        end


        function setShowLegend(this,value)
            if~isempty(value)
                this.publish('setShowLegend',value);
            end
        end


        function setChannelNames(this,value)
            if~isempty(value)
                this.publish('setChannelNames',value);
            end
        end


        function setShowTrajectory(this,value)
            if~isempty(value)
                this.publish('setShowTrajectory',value);
            end
        end


        function setEnableMeasurements(this,value)
            if~isempty(value)
                this.publish('setEnableMeasurements',value);
            end
        end


        function setMeasurementInterval(this,value)
            if~isempty(value)
                this.publish('setMeasurementInterval',value);
            end
        end


        function setEVMNormalization(this,value)
            if~isempty(value)
                this.publish('setEVMNormalization',value);
            end
        end


        function setShowTicks(this,value)
            if~isempty(value)
                this.publish('setShowTicks',value);
            end
        end


        function ReferenceConstellationRequest(this,refparams)

            refValues=refparams.refConstellation;

            this.Specification.ShowReferenceConstellation=refparams.showReferenceConstellation;
            for idx=1:numel(refValues)
                if iscell(refValues)
                    currentRefValue=refValues{idx};
                else
                    currentRefValue=refValues(idx);
                end
                if(isfield(currentRefValue,'ReferenceConstellation'))
                    ref=this.getActualRefCon(currentRefValue);
                    if iscell(ref)
                        ref=cell2mat(ref);
                    end
                    this.Specification.ReferenceConstellation{idx}=ref;
                end
            end
            this.Specification.updateReferenceConstelaltionValues();
            this.publish('updateReferenceConstellation',struct('referenceConstellation',this.Specification.getRefStringValue(),...
            'xRefData',this.Specification.xRefData,'yRefData',this.Specification.yRefData));
        end


        function requestSerializedSettings(this,varargin)
            serializedScopeSettings=this.Specification.getScopeSettings();
            serializedStyleSettings=this.Specification.Style.getSettings();
            this.publish('setSerializedSettings',struct('Parameters',serializedScopeSettings,...
            'GraphicalSettings',struct('Style',serializedStyleSettings)));
        end


        function MeasurementRequested(this,varargin)
            this.Specification.EnableMeasurements=varargin{1}{2}.EnableMeasurements;
            this.Specification.MeasurementInterval=varargin{1}{2}.MeasurementInterval;
            this.Specification.EVMNormalization=varargin{1}{2}.EVMNormalization;
        end


        function updateSettings(this,params)
            this.GraphicalSettingsStale=false;

            paramSettings=params.Parameters;
            currentNumInputPort=this.Specification.NumInputPorts;
            if(~isempty(paramSettings))
                this.Specification.setScopeSettings(paramSettings);
            end

            if~isempty(paramSettings)&&isfield(paramSettings,'NumInputPorts')&&currentNumInputPort~=paramSettings.NumInputPorts

                this.setReferenceConstellation(this.Specification.ReferenceConstellation);
            end

            styleSettings=params.GraphicalSettings.Style;
            if(~isempty(styleSettings)&&~isempty(styleSettings.Marker))
                this.Specification.Style.setSettings(styleSettings);

                refMarker=cell(this.Specification.NumInputPorts,1);
                refColor=cell(this.Specification.NumInputPorts,1);
                refIdx=1;
                for idx=1:numel(styleSettings.IsRefLine)
                    if styleSettings.IsRefLine(idx)
                        refMarker{refIdx}=styleSettings.Marker{idx};
                        refColor{refIdx}=styleSettings.LineColor(idx,1:end);
                        refIdx=refIdx+1;
                    end
                end
                if~isempty(refMarker{1})
                    if numel(refMarker)>1
                        this.Specification.ReferenceMarker=refMarker;
                        this.Specification.ReferenceColor=refColor;
                    else
                        this.Specification.ReferenceMarker=refMarker{1};
                        this.Specification.ReferenceColor=refColor{1};
                    end
                end
            end
        end

        function generateScript(this,~)
            this.Specification.generateScript();
        end


        function helplinkopen(this,~)
            this.Specification.helplinkopen();
        end

    end

    methods(Access=private)

        function refCon=getActualRefCon(this,currentInputRefCon)



            cdMessageHandler=comm.webscopes.internal.ConstellationDiagramMessageHandler;
            if cdMessageHandler.refConIsPreset(cdMessageHandler,currentInputRefCon.ReferenceConstellation)
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
                    if strcmp(normalizationMethod,'MinimumDistance')
                        this.Specification.MinDistance=refConPower;
                    elseif strcmp(normalizationMethod,'AveragePower')
                        this.Specification.MinDistance=comm.internal.qam.minDistanceForAvgPower(refConPower,modulationOrder);
                    elseif strcmp(normalizationMethod,'PeakPower')
                        this.Specification.MinDistance=comm.internal.qam.minDistanceForPeakPower(refConPower,modulationOrder);
                    end
                    refCon={(this.Specification.MinDistance/2).*exp(1i*refConOffset).*qammod((0:modulationOrder-1),modulationOrder,'bin')};
                end
            else
                [varargout{1:nargout}]=uiservices.evaluate(currentInputRefCon.RefConstellationValue);
                refCon=varargout{1};
            end
        end
    end
    methods(Static,Hidden)
        function isPreset=refConIsPreset(this,varargin)


            mustBeQAM=false;
            refCon=varargin{1};
            if nargin==3&&strcmp(varargin{2},'QAM')
                mustBeQAM=true;
            end
            if isa(refCon,'double')
                refCon=mat2str(refCon);
            end
            qamPresets=this.QAMpresets;
            if mustBeQAM&&ismember(refCon,qamPresets)
                isPreset=true;
            elseif~mustBeQAM&&(ismember(refCon,[qamPresets,this.NonQAMpresets]))
                isPreset=true;
            else
                isPreset=false;
            end
        end
    end
end
