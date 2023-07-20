classdef(Hidden=true)ConstellationDiagramScopeSpecification<dsp.webscopes.internal.BaseWebScopeSpecification





    properties(AbortSet)


        Title='';
        XLimits=[-1.375,1.375];
        YLimits=[-1.375,1.375];
        XLabel='In-phase Amplitude';
        YLabel='Quadrature Amplitude';
        SamplesPerSymbol=1;
        SampleOffset=0;
        SymbolsToDisplaySource=true;
        SymbolsToDisplay=256;
        ReferenceConstellation={[0.7071+0.7071i,-0.7071+0.7071i,-0.7071-0.7071i,0.7070-0.7071i]};
        ReferenceMarker='+';
        ReferenceColor=[1,0,0];
        ShowReferenceConstellation=true;
        ShowGrid=true;
        ShowLegend=false;
        ChannelNames={''};
        ShowTicks=true;
        ShowTrajectory=false;
        EnableMeasurements=false;
        MeasurementInterval='Current display';
        EVMNormalization='Average constellation power';
        ColorFading=false;
        MaximizeAxes='Auto';
        PlotType='Line';
        AveragePower=1;
        PhaseOffset=pi/8;
        ConstellationNormalization='AveragePower';
        MinDistance=2;
        PeakPower=1;
    end
    properties(Hidden)

        hEVM;
        hMER;
        ActualData={};
        UpdatedData={};
        MaxDimensions=[];
        currentSelectedChannel=1;
        xRefData={[0.707100000000000,-0.707100000000000,-0.707100000000000,0.707000000000000]};
        yRefData={[0.707100000000000,0.707100000000000,-0.707100000000000,-0.707100000000000]};
        refNumRows={4};
        Product='comm';
        DataDomain='time';
        MaxNumChannels=100;
        inputDataInfo=[];
    end
    methods(Access=protected)
        function style=getStyleSpecification(this)
            style=comm.webscopes.style.ConstellationWebScopesStyleSpecification(this);
        end
    end



    methods

        function value=get.SymbolsToDisplaySource(this)
            if this.SymbolsToDisplaySource
                value='Input frame length';
            else
                value='Property';
            end
        end

        function set.SymbolsToDisplaySource(this,value)
            if strcmp(value,'Input frame length')||(islogical(value)&&value==1)
                this.SymbolsToDisplaySource=true;
            else
                this.SymbolsToDisplaySource=false;
            end
        end

        function value=get.ReferenceConstellation(this)
            value=this.ReferenceConstellation;
        end
    end




    methods



        function settings=getScopeSettings(this)
            this.updateReferenceConstelaltionValues();
            settings=struct(...
            'NumInputPorts',this.NumInputPorts,...
            'Name',this.Name,...
            'Position',this.Position,...
            'ExpandToolstrip',this.ExpandToolstrip,...
            'PlotType',this.PlotType,...
            'MaximizeAxes',this.MaximizeAxes,...
            'Title',this.Title,...
            'XLabel',this.XLabel,...
            'YLabel',this.YLabel,...
            'XLimits',this.XLimits,...
            'YLimits',this.YLimits,...
            'SamplesPerSymbol',this.SamplesPerSymbol,...
            'SampleOffset',this.SampleOffset,...
            'SymbolsToDisplaySource',this.getUISymbolsToDisplaySourceValue(),...
            'SymbolsToDisplay',this.SymbolsToDisplay,...
            'ReferenceConstellation',struct('referenceConstellation',this.getRefStringValue(),...
            'xRefData',this.xRefData,'yRefData',this.yRefData),...
            'ReferenceMarker',struct('referenceMarker',this.ReferenceMarker),...
            'ReferenceColor',struct('referenceColor',this.ReferenceColor),...
            'ShowReferenceConstellation',this.ShowReferenceConstellation,...
            'ShowTicks',this.ShowTicks,...
            'ShowGrid',this.ShowGrid,...
            'ShowTrajectory',this.ShowTrajectory,...
            'ShowLegend',this.ShowLegend,...
            'EnableMeasurements',this.EnableMeasurements,...
            'MeasurementInterval',this.MeasurementInterval,...
            'EVMNormalization',this.EVMNormalization,...
            'ColorFading',this.ColorFading,...
            'ChannelNames',string(this.ChannelNames),...
            'LogDiagnostic',enable_webscopes_diagnostics(),...
            'DefaultLegendLabel',this.DefaultLegendLabel);
        end


        function S=toStruct(this)
            propNames=comm.webscopes.ConstellationDiagram.getValidPropNames;
            for idx=1:numel(propNames)
                S.(propNames{idx})=this.(propNames{idx});
            end
        end


        function fromStruct(this,S)

            propNames=intersect(fieldnames(S),comm.webscopes.ConstellationDiagram.getValidPropNames);
            for idx=1:numel(propNames)
                this.(propNames{idx})=S.(propNames{idx});
            end
        end



        function setScopeSettings(this,S)
            fields=fieldnames(S);
            for idx=1:numel(fields)
                value=S.(fields{idx});
                if ischar(value)
                    this.(fields{idx})=S.(fields{idx});
                else
                    this.(fields{idx})=S.(fields{idx}).';
                end
            end
        end


        function setPropertyValue(this,propName,propValue)
            if(~isequal(this.(propName),propValue))
                this.(propName)=propValue;
                this.MessageHandler.GraphicalSettingsStale=true;
                this.MessageHandler.(['set',propName])(propValue);
            end
        end


        function propValue=getPropertyValue(this,propName)
            propValue=this.(propName);
        end


        function n=getNumChannels(this)
            n=sum(this.NumChannels);
        end
    end

    methods

        function updateReferenceConstelaltionValues(this)
            refValue=this.ReferenceConstellation;
            if~iscell(refValue)
                refValue={refValue};
            end
            this.xRefData=cell(size(refValue));
            this.yRefData=cell(size(refValue));
            this.refNumRows=cell(size(refValue));
            for idx=1:numel(refValue)
                this.xRefData{idx}=real(refValue{idx});
                this.refNumRows{idx}=numel(this.xRefData{idx});
                this.yRefData{idx}=imag(refValue{idx});
            end
        end

        function refValue=getRefStringValue(this)

            refValue=this.ReferenceConstellation;
            if iscell(refValue)
                for idx=1:numel(refValue)
                    refValue{idx}=mat2str(refValue{idx});
                end
            else
                refValue=mat2str(refValue);
            end
        end

        function symToDisplaySourceValue=getUISymbolsToDisplaySourceValue(this)
            symToDisplaySourceValue=true;
            if strcmp(this.SymbolsToDisplaySource,'Input frame length')~=1
                symToDisplaySourceValue=false;
            end
        end

        function UpdateReferenceConstellation(this)
            refConValue=this.ReferenceConstellation;
            numInputPorts=this.NumInputPorts;
            if~iscell(refConValue)
                refConValue={refConValue};
            end
            currentRefValue=numel(refConValue);
            if numInputPorts>currentRefValue
                for idx=1:numInputPorts-currentRefValue
                    if numel(refConValue)==1
                        refConValue{idx+currentRefValue}=refConValue{1};
                    else
                        defaultRefValue=[0.7071+0.7071i,-0.7071+0.7071i,-0.7071-0.7071i,0.7070-0.7071i];
                        refConValue{idx+currentRefValue}=defaultRefValue;
                    end
                end
                this.ReferenceConstellation=refConValue;
            else
                temp=cell(size(numInputPorts));
                for idx=1:numInputPorts
                    temp{idx}=refConValue{idx};
                end
                this.ReferenceConstellation=temp;
            end
        end

        function[updateReferenceConstelaltion,updateRefNumRows]=getReferenceConstellation(this)
            referenceConstelaltion=[];
            tempRefNumRows=[];
            for id=1:numel(this.xRefData)
                for idx=1:numel(this.xRefData{id})
                    referenceConstelaltion(end+1)=this.xRefData{id}(idx);
                end
                for idx=1:numel(this.yRefData{id})
                    referenceConstelaltion(end+1)=this.yRefData{id}(idx);
                end
                tempRefNumRows=vertcat(tempRefNumRows,numel(this.xRefData{id}));
            end
            updateReferenceConstelaltion=referenceConstelaltion;
            updateRefNumRows=tempRefNumRows;
        end

        function propValue=visualToEVMPropValue(~,strProp)
            switch strProp
            case{'PeakPower','Peak constellation power'}
                propValue='Peak constellation power';
            otherwise
                propValue='Average constellation power';
            end
        end
        function updateInputDataInfo(this,varargin)
            nInputs=numel(varargin);
            this.inputDataInfo.complex=zeros(1,nInputs);
            for idx=1:nInputs
                this.inputDataInfo.complex(1,idx)=~isreal(varargin{idx});
            end
        end

        function isTypeChanged=IsDataTypeChanged(this,varargin)
            isTypeChanged=false;
            nInputs=numel(varargin);
            for idx=1:nInputs
                if this.inputDataInfo.complex(1,idx)~=~isreal(varargin{idx})
                    isTypeChanged=true;
                    return;
                end
            end
        end
    end



    methods(Hidden)


        function name=getScopeName(~)
            name='Constellation Diagram';
        end


        function className=getClassName(~)
            className='comm.ConstellationDiagram';
        end
        function props=getIrrelevantConstructorProperties(~)
            props='';
        end
        function measurers=getSupportedMeasurements(~)
            measurers={};
        end
        function impls=getSupportedFiltersImpls(~)
            impls={};
        end
    end
end

