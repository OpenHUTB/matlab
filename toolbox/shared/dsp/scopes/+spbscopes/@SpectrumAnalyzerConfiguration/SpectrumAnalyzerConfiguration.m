classdef SpectrumAnalyzerConfiguration<Simulink.scopes.BlockScopeConfiguration&...
    matlab.mixin.CustomDisplay









    properties

        NumInputPorts='1';
    end

    properties(Dependent)

        InputDomain;
        SpectrumType;
        ViewType;
        SampleRate;
        SampleRateSource;
        Method;
        PlotAsTwoSidedSpectrum;
        FrequencyScale;


        FrequencySpan;
        Span;
        CenterFrequency;
        StartFrequency;
        StopFrequency;
        FrequencyResolutionMethod;
        RBWSource;
        RBW;
        WindowLength;
        FFTLengthSource;
        FFTLength;
        NumTapsPerBand;
        FrequencyVectorSource;
        FrequencyVector;
        InputUnits;
        OverlapPercent;
        Window;
        CustomWindow;
        SidelobeAttenuation;
        SpectrumUnits;
        FullScaleSource;
        FullScale;
        AveragingMethod;
        SpectralAverages;
        ForgettingFactor;
        ReferenceLoad;
        FrequencyOffset;
        TreatMby1SignalsAsOneChannel;


        SpectrogramChannel;
        TimeResolutionSource;
        TimeResolution;
        TimeSpanSource;
        TimeSpan;


        MeasurementChannel;
        SpectralMask;
        PeakFinder;
        CursorMeasurements;
        ChannelMeasurements;
        DistortionMeasurements;
        CCDFMeasurements;


        PlotType;
        PlotNormalTrace;
        PlotMaxHoldTrace;
        PlotMinHoldTrace;
        ReducePlotRate;
        Title;
        YLabel;
        ShowLegend;
        ChannelNames;
        ShowGrid;
        YLimits;
        ColorLimits;
        AxesScaling;
        AxesScalingNumUpdates;
        AxesLayout;
    end


    properties(Hidden,Dependent)

        wintypeSpecScope;
        numAvg;
        XRange;
        YUnits;
        AxisGrid;
        AxisLegend;
        Memory;
        inpFftLenInherit;
        FFTlength;
        RsSpecScope;
        betaSpecScope;
        Overlap;
        UseBuffer;
        BufferSize;
        FigPos;
        XLimit;
        XMin;
        XMax;
        YMin;
        YMax;
        OpenScopeAtSimStart;
        OpenScopeImmediately;
        LineDisables;
        LineStyles;
        LineMarkers;
        LineColors;
        TreatMby1Signals;
        WinsampSpecScope;
        FrameNumber;
        AxisZoom;
        InheritXIncr;
        XIncr;
        XDisplay;
        SegLen;
        PowerUnits;

        IsSourceVectorScope;
    end

    properties(Hidden)
        wintypeSpecScopeLocal='unset';
        RsSpecScopeLocal='unset';
        betaSpecScopeLocal='unset';
        UseBufferLocal=-1;
        BufferSizeLocal=[];
        OverlapLocal=[];
        XLimitLocal='unset';
        XMinLocal='unset';
        XMaxLocal='unset';
        IsFstartFstopSettingDirty;
        LegacySetFlag=false;
        VectorScopeLegacyMode=false;
    end

    properties(Hidden,SetAccess=private)
        SimscapeMode=false;
    end

    properties(Access=protected)


pMaskSpecificationObject


pPeakFinderObject


pCursorMeasurementsObject


pChannelMeasurementsObject


pDistortionMeasurementsObject


pCCDFMeasurementsObject


pMaskListener


pPeakFinderListener


pCursorMeasurementsListener


pChannelMeasurementsListener


pDistortionMeasurementsListener


pCCDFMeasurementsListener


        SpectrumDataFieldNames={'SimulationTime',...
        'Spectrum',...
        'Spectrogram',...
        'MinHoldTrace',...
        'MaxHoldTrace',...
        'FrequencyVector'};
        MeasurementsDataFieldNames={'SimulationTime',...
        'PeakFinder',...
        'CursorMeasurements',...
        'ChannelMeasurements',...
        'DistortionMeasurements',...
        'CCDFMeasurements'};
        pCachedSpectrumData;
        pCachedMeasurementsData;
    end

    properties(Access=private,Constant)
        VisualName='Spectrum';
    end

    methods
        function obj=SpectrumAnalyzerConfiguration(varargin)

            obj@Simulink.scopes.BlockScopeConfiguration(varargin{:});


            framework=obj.Scope.Framework;
            if~isempty(framework)
                obj.SimscapeMode=framework.Visual.SimscapeMode;
            else
                [~,~,licenseType]=checkLicense(obj.Scope.ScopeCfg,false);
                obj.SimscapeMode=any(strcmpi(licenseType,{'simscape','rfblockset'}));
            end

            obj.pCachedSpectrumData=createEmptySpectrumDataTable(obj,1);

            obj.pCachedMeasurementsData=createEmptyMeasurementsDataTable(obj);

            obj.Validator=dsp.scopes.SpectrumAnalyzerValidator;
        end





        function s=getSpectralMaskStatus(obj)

            s=struct([]);
            framework=obj.Scope.Framework;
            if~isempty(framework)&&~isempty(framework.Visual)&&...
                ~isempty(framework.Visual.MaskTesterObject)
                s=getMaskStatus(framework.Visual.MaskTesterObject);
            end
        end

        function data=getSpectrumData(obj,allFlag)













            narginchk(1,2);
            if nargin==2

                allFlag=convertStringsToChars(allFlag);

                validatestring(allFlag,{'all'});
                allFlag=true;
            else
                allFlag=false;
            end
            allData=obj.pCachedSpectrumData;
            framework=obj.Scope.Framework;
            if isempty(framework)
                data=allData;
                return;
            end
            hVisual=framework.Visual;
            data=getSpectrumData(hVisual,allFlag);
        end

        function data=getMeasurementsData(obj,allFlag)

















            narginchk(1,2);
            if nargin==2

                allFlag=convertStringsToChars(allFlag);

                validatestring(allFlag,{'all'});
                allFlag=true;
            else
                allFlag=false;
            end
            allData=obj.pCachedMeasurementsData;
            framework=obj.Scope.Framework;
            if isempty(framework)
                data=allData;
                return;
            end
            hVisual=framework.Visual;
            data=getMeasurementsData(hVisual,allFlag);
        end

        function flag=isNewDataReady(obj)




            flag=false;
            framework=obj.Scope.Framework;
            if~isempty(framework)&&~isempty(framework.Visual)
                flag=framework.Visual.IsNewDataReady;
            end
        end






        function set.NumInputPorts(this,value)
            if isSimulationRunning(this)

                msgObj=message('Spcuilib:configuration:PropertyNotTunable',...
                'NumInputPorts',getBlockName(this));
                throwAsCaller(MException(msgObj));
            end

            [rvalue,errorID,errorStr]=evaluateVariable(this,value);
            if~isempty(errorID)
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'NumInputPorts',getBlockName(this),errorStr);
                throwAsCaller(MException(msgObj));
            elseif~isnumeric(rvalue)
                errorStr=getString(message('dspshared:SpectrumAnalyzer:invalidVariableForNumberOfInputPorts',value));
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'NumInputPorts',getBlockName(this),errorStr);
                throwAsCaller(MException(msgObj));
            end



            if~(~isscalar(rvalue)||isinf(rvalue)||isnan(rvalue)||...
                rvalue<0||rvalue~=round(rvalue)||rvalue>96||rvalue<1)
                Simulink.scopes.setBlockParam(this.Scope.Block,'NumInputPorts',num2str(rvalue));
            else
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'NumInputPorts',getBlockName(this),getString(...
                message('Spcuilib:scopes:InvalidNumInputPorts')));
                throwAsCaller(MException(msgObj));
            end
        end
        function value=get.NumInputPorts(this)
            value=get_param(this.Scope.Block.Handle,'NumInputPorts');
        end


        function set.InputDomain(obj,strValue)
            validatePropertyAccess(obj,'InputDomain');
            if isSimulationRunning(obj)
                msgObj=message('Spcuilib:configuration:PropertyNotTunable',...
                'InputDomain',getBlockName(obj));
                throwAsCaller(MException(msgObj));
            end
            strValue=convertStringsToChars(strValue);
            validEnums={'Time','Frequency'};
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'InputDomain',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'InputDomain',strValue);
        end
        function value=get.InputDomain(obj)
            value=getParameter(obj,'InputDomain');
        end


        function set.SpectrumType(obj,strValue)
            validEnums={'Power','Power density','RMS','Spectrogram'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'SpectrumType',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'SpectrumType',strValue);
        end
        function value=get.SpectrumType(obj)
            value=getParameter(obj,'SpectrumType');
        end


        function set.ViewType(obj,strValue)
            validatePropertyAccess(obj,'ViewType');
            validEnums={'Spectrum','Spectrogram','Spectrum and spectrogram'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'ViewType',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'ViewType',strValue);
        end
        function value=get.ViewType(obj)
            value=getParameter(obj,'ViewType');
        end


        function set.SampleRateSource(obj,strValue)
            if isSimulationRunning(obj)
                msgObj=message('Spcuilib:configuration:PropertyNotTunable',...
                'SampleRateSource',getBlockName(obj));
                throwAsCaller(MException(msgObj));
            end
            strValue=convertStringsToChars(strValue);
            validEnums={'Inherited','Property'};
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'SampleRateSource',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            if strcmp(strValue,'Inherited')
                strValue='Auto';
            end
            setScopeParameter(obj,'SampleRateSource',strValue);
        end
        function value=get.SampleRateSource(obj)
            value=getParameter(obj,'SampleRateSource');
            if strcmp(value,'Auto')
                value='Inherited';
            end
        end


        function set.SampleRate(obj,strValue)
            if isSimulationRunning(obj)
                msgObj=message('Spcuilib:configuration:PropertyNotTunable',...
                'SampleRate',getBlockName(obj));
                throwAsCaller(MException(msgObj));
            end
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'SampleRate');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'SampleRate',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                if strcmp(obj.InputDomain,'Frequency')
                    setScopeParam(obj.Scope,'Visuals','Spectrum',...
                    'FrequencyInputSampleRate',strValue);
                else
                    setScopeParam(obj.Scope,'Visuals','Spectrum',...
                    'SampleRate',strValue);
                end
            else
                if strcmp(obj.InputDomain,'Frequency')
                    setScopeParamOnConfig(obj.Scope,'Visuals',...
                    'Spectrum','FrequencyInputSampleRate','string',strValue)
                else
                    setScopeParamOnConfig(obj.Scope,'Visuals',...
                    'Spectrum','SampleRate','string',strValue)
                end
            end
        end
        function value=get.SampleRate(obj)
            if strcmp(obj.InputDomain,'Frequency')
                value=getScopeParam(obj.Scope,'Visuals','Spectrum','FrequencyInputSampleRate');
            else
                value=getScopeParam(obj.Scope,'Visuals','Spectrum','SampleRate');
            end
        end


        function set.Method(obj,strValue)
            validatePropertyAccess(obj,'Method');
            if isSimulationRunning(obj)
                msgObj=message('Spcuilib:configuration:PropertyNotTunable',...
                'Method',getBlockName(obj));
                throwAsCaller(MException(msgObj));
            end
            strValue=convertStringsToChars(strValue);
            validEnums={'Welch','Filter bank'};
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'Method',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'Method',strValue);
        end
        function value=get.Method(obj)
            value=getParameter(obj,'Method');
        end


        function set.PlotAsTwoSidedSpectrum(obj,value)
            if isSimulationRunning(obj)
                msgObj=message('Spcuilib:configuration:PropertyNotTunable',...
                'PlotAsTwoSidedSpectrum',getBlockName(obj));
                throwAsCaller(MException(msgObj));
            end
            if islogical(value)&&isscalar(value)
                setScopeParameter(obj,'TwoSidedSpectrum',value);
            else
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'PlotAsTwoSidedSpectrum',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidLogical')));
                throwAsCaller(MException(msgObj));
            end
        end
        function value=get.PlotAsTwoSidedSpectrum(obj)
            value=getParameter(obj,'TwoSidedSpectrum');
        end


        function set.FrequencyScale(obj,strValue)
            validEnums={'Linear','Log'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'FrequencyScale',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            if obj.PlotAsTwoSidedSpectrum&&strcmp(strValue,'Log')
                throwAsCaller(MException(message('dspshared:SpectrumAnalyzer:InvalidFreqScale')));
            end
            setScopeParameter(obj,'FrequencyScale',strValue);
        end
        function value=get.FrequencyScale(obj)
            value=getParameter(obj,'FrequencyScale');
        end






        function set.FrequencySpan(obj,strValue)
            validatePropertyAccess(obj,'FrequencySpan');
            validEnums={'Full','Start and stop frequencies','Span and center frequency'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'FrequencySpan',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            if strcmp(obj.InputDomain,'Frequency')
                setScopeParameter(obj,'FrequencyInputSpan',strValue);
            else
                setScopeParameter(obj,'FrequencySpan',strValue);
            end
        end
        function value=get.FrequencySpan(obj)
            if strcmp(obj.InputDomain,'Frequency')
                value=getParameter(obj,'FrequencyInputSpan');
            else
                value=getParameter(obj,'FrequencySpan');
            end
        end


        function set.Span(obj,strValue)
            validatePropertyAccess(obj,'Span');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'Span');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'Span',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'Span',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','Span','string',strValue)
            end
            setScopeParameter(obj,'IsSpanCFSettingDirty',true);
        end
        function value=get.Span(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','Span');
        end


        function set.CenterFrequency(obj,strValue)
            validatePropertyAccess(obj,'CenterFrequency');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'CenterFrequency');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'CenterFrequency',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidRealNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'CenterFrequency',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','CenterFrequency','string',strValue)
            end
            setScopeParameter(obj,'IsSpanCFSettingDirty',true);
        end
        function value=get.CenterFrequency(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','CenterFrequency');
        end


        function set.StartFrequency(obj,strValue)
            validatePropertyAccess(obj,'StartFrequency');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'StartFrequency');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'StartFrequency',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidRealNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'StartFrequency',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','StartFrequency','string',strValue);
            end
            setScopeParameter(obj,'IsFstartFstopSettingDirty',true);
        end
        function value=get.StartFrequency(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','StartFrequency');
        end


        function set.StopFrequency(obj,strValue)
            validatePropertyAccess(obj,'StopFrequency');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'StopFrequency');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'StopFrequency',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidRealNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'StopFrequency',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','StopFrequency','string',strValue);
            end
            setScopeParameter(obj,'IsFstartFstopSettingDirty',true);
        end
        function value=get.StopFrequency(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','StopFrequency');
        end


        function set.FrequencyResolutionMethod(obj,strValue)
            validatePropertyAccess(obj,'FrequencyResolutionMethod');
            if strcmp(obj.Method,'Welch')

                validEnums={'RBW','WindowLength'};
            else

                validEnums={'RBW','NumFrequencyBands'};
            end
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'FrequencyResolutionMethod',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'FrequencyResolutionMethod',strValue);
            if strcmp(strValue,'RBW')

                obj.LegacySetFlag=false;
            end
        end
        function value=get.FrequencyResolutionMethod(obj)
            value=getParameter(obj,'FrequencyResolutionMethod');
        end


        function set.RBWSource(obj,strValue)
            if strcmp(obj.InputDomain,'Frequency')
                validEnums={'Auto','Property','InputPort'};
            else
                validEnums={'Auto','Property'};
            end
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'RBWSource',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            if strcmp(obj.InputDomain,'Frequency')
                setScopeParameter(obj,'FrequencyInputRBWSource',strValue);
            else
                setScopeParameter(obj,'RBWSource',strValue);
            end
        end
        function value=get.RBWSource(obj)
            if strcmp(obj.InputDomain,'Frequency')
                value=getParameter(obj,'FrequencyInputRBWSource');
            else
                value=getParameter(obj,'RBWSource');
            end
        end


        function set.RBW(obj,strValue)
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'RBW');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'RBW',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'RBW',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','RBW','string',strValue)
            end
        end
        function value=get.RBW(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','RBW');
        end


        function set.WindowLength(obj,strValue)
            validatePropertyAccess(obj,'WindowLength');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'WindowLength');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'WindowLength',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveIntegerGreaterThan','2')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'WindowLength',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','WindowLength','string',strValue)
            end
        end
        function value=get.WindowLength(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','WindowLength');
        end


        function set.FFTLengthSource(obj,strValue)
            validatePropertyAccess(obj,'FFTLengthSource');
            validEnums={'Auto','Property'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'FFTLengthSource',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'FFTLengthSource',strValue);
        end
        function value=get.FFTLengthSource(obj)
            value=getParameter(obj,'FFTLengthSource');
        end


        function set.FFTLength(obj,strValue)
            validatePropertyAccess(obj,'FFTLength');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'FFTLength');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'FullScale',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveInteger')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'FFTLength',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','FFTLength','string',strValue)
            end

        end
        function value=get.FFTLength(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','FFTLength');
        end


        function set.NumTapsPerBand(obj,strValue)
            validatePropertyAccess(obj,'NumTapsPerBand');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'NumTapsPerBand');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'NumTapsPerBand',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveIntegerGreaterThan','0')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'NumTapsPerBand',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','NumTapsPerBand','string',strValue)
            end
        end
        function value=get.NumTapsPerBand(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','NumTapsPerBand');
        end


        function set.FrequencyVectorSource(obj,strValue)
            strValue=convertStringsToChars(strValue);
            validEnums={'Auto','Property','InputPort'};
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'FrequencyVectorSource',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'FrequencyVectorSource',strValue);
        end
        function value=get.FrequencyVectorSource(obj)
            value=getParameter(obj,'FrequencyVectorSource');
        end


        function set.FrequencyVector(obj,strValue)
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'FrequencyVector');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'FrequencyVector',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'FrequencyVector',strValue);

            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','FrequencyVector','string',strValue)
            end
        end
        function value=get.FrequencyVector(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','FrequencyVector');
        end


        function set.InputUnits(obj,strValue)
            validatePropertyAccess(obj,'InputUnits');
            if isSimulationRunning(obj)
                msgObj=message('Spcuilib:configuration:PropertyNotTunable',...
                'InputDomain',getBlockName(obj));
                throwAsCaller(MException(msgObj));
            end
            strValue=convertStringsToChars(strValue);
            validEnums={'dBm','dBV','dBW','Vrms','Watts'};
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'InputUnits',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'InputUnits',strValue);
        end
        function value=get.InputUnits(obj)
            value=getParameter(obj,'InputUnits');
        end


        function set.OverlapPercent(obj,strValue)
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'OverlapPercent');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'OverlapPercent',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveNumberGreaterThanOrEqualAndLessThan','0','100')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'OverlapPercent',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','OverlapPercent','string',strValue)
            end
        end
        function value=get.OverlapPercent(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','OverlapPercent');
        end


        function set.Window(obj,strValue)
            validEnums={'Hann',...
            'Hamming',...
            'Kaiser',...
            'Chebyshev',...
            'Rectangular',...
            'Flat Top',...
            'Blackman-Harris',...
            'Custom'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'Window',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end

            indx=find(ismember(lower(validEnums),lower(strValue))==1,1);
            strValue=validEnums{indx};
            if obj.SimscapeMode&&~any(strcmp(strValue,{'Hann','Rectangular'}))
                error(message('dspshared:SpectrumAnalyzer:PropertyValueRequiresDSTLicense','Window',strValue));
            end
            setScopeParameter(obj,'Window',strValue);
        end
        function value=get.Window(obj)
            value=getParameter(obj,'Window');
        end


        function set.CustomWindow(obj,strValue)
            validatePropertyAccess(obj,'CustomWindow');

            strValue=convertStringsToChars(strValue);

            if~obj.Validator.isValid('CustomWindow',strValue)
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'CustomWindow',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidName')));
                throwAsCaller(MException(msgObj));
            end


            switch strValue
            case{'blackman','blackmanharris','flattopwin','hamming','hann','nuttallwin'}



                try
                    feval(strValue,100,'periodic');
                catch







                    msgObj=message('Spcuilib:configuration:InvalidSetting',...
                    'CustomWindow',getBlockName(obj),getString(...
                    message('dspshared:SpectrumAnalyzer:InvalidCustomWindowShadowing',strValue)));
                    throwAsCaller(MException(msgObj));
                end
            otherwise
                try



                    feval_value=feval(strValue,100);
                    if~isa(feval_value,'double')&&numel(feval_value)~=100
                        msgObj=message('Spcuilib:configuration:InvalidSetting',...
                        'CustomWindow',getBlockName(obj),getString(...
                        message('dspshared:SpectrumAnalyzer:InvalidCustomWindowName',strValue)));
                        throwAsCaller(MException(msgObj));
                    end

                    if numel(feval_value)~=100||isrow(feval_value)
                        msgObj=message('Spcuilib:configuration:InvalidSetting',...
                        'CustomWindow',getBlockName(obj),getString(...
                        message('dspshared:SpectrumAnalyzer:InvalidCustomWindowDimensions',strValue)));
                        throwAsCaller(MException(msgObj));
                    end
                catch ME
                    switch ME.identifier
                    case 'MATLAB:UndefinedFunction'

                        msgObj=message('Spcuilib:configuration:InvalidSetting',...
                        'CustomWindow',getBlockName(obj),getString(...
                        message('dspshared:SpectrumAnalyzer:UndefinedCustomWindowName',strValue)));
                        throwAsCaller(MException(msgObj));
                    case{'MATLAB:minrhs','MATLAB:TooManyInputs'}


                        msgObj=message('Spcuilib:configuration:InvalidSetting',...
                        'CustomWindow',getBlockName(obj),getString(...
                        message('dspshared:SpectrumAnalyzer:InvalidCustomWindowNotEnoughArgs',strValue)));
                        throwAsCaller(MException(msgObj));
                    case 'dspshared:SpectrumAnalyzer:InvalidCustomWindowDimensions'



                        msgObj=message('Spcuilib:configuration:InvalidSetting',...
                        'CustomWindow',getBlockName(obj),getString(...
                        message('dspshared:SpectrumAnalyzer:InvalidCustomWindowDimensions',strValue)));
                        throwAsCaller(MException(msgObj));
                    otherwise


                        msgObj=message('Spcuilib:configuration:InvalidSetting',...
                        'CustomWindow',getBlockName(obj),getString(...
                        message('dspshared:SpectrumAnalyzer:InvalidCustomWindowName',strValue)));
                        throwAsCaller(MException(msgObj));
                    end
                end
            end
            setScopeParameter(obj,'CustomWindow',strValue);
        end
        function value=get.CustomWindow(obj)
            value=getParameter(obj,'CustomWindow');
        end


        function set.SidelobeAttenuation(obj,strValue)
            validatePropertyAccess(obj,'SidelobeAttenuation');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'SidelobeAttenuation');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'SidelobeAttenuation',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveNumberGreaterThanOrEqual','45')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'SidelobeAttenuation',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','SidelobeAttenuation','string',strValue)
            end
        end
        function value=get.SidelobeAttenuation(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','SidelobeAttenuation');
        end


        function set.SpectrumUnits(obj,strValue)
            if obj.SimscapeMode&&~strcmp(obj.SpectrumType,'RMS')

                error(message('dspshared:SpectrumAnalyzer:PropertyAccessedWithoutLicense','SpectrumUnits'));
            end
            strValue=convertStringsToChars(strValue);
            if strcmp(obj.InputDomain,'Time')
                if strcmp(obj.SpectrumType,'RMS')
                    validEnums={'Vrms','dBV'};
                    if~any(strcmpi(strValue,validEnums))
                        msgObj=message('Spcuilib:configuration:InvalidSetting',...
                        'SpectrumUnits',getBlockName(obj),getString(...
                        message('Spcuilib:configuration:InvalidEnums',...
                        strjoin(validEnums,', '))));
                        throwAsCaller(MException(msgObj));
                    end
                    setScopeParameter(obj,'RMSUnits',strValue);
                else
                    validEnums={'Watts','dBm','dBW','dBFS'};
                    if~any(strcmpi(strValue,validEnums))
                        msgObj=message('Spcuilib:configuration:InvalidSetting',...
                        'SpectrumUnits',getBlockName(obj),getString(...
                        message('Spcuilib:configuration:InvalidEnums',...
                        strjoin(validEnums,', '))));
                        throwAsCaller(MException(msgObj));
                    end
                    setScopeParameter(obj,'PowerUnits',strValue);
                end
            else
                validEnums={'Auto','dBm','dBV','dBW','Vrms','Watts'};
                if~any(strcmpi(strValue,validEnums))
                    msgObj=message('Spcuilib:configuration:InvalidSetting',...
                    'SpectrumUnits',getBlockName(obj),getString(...
                    message('Spcuilib:configuration:InvalidEnums',...
                    strjoin(validEnums,', '))));
                    throwAsCaller(MException(msgObj));
                end
                setScopeParameter(obj,'FrequencyInputSpectrumUnits',strValue);
            end
        end
        function value=get.SpectrumUnits(obj)
            if~strcmp(obj.InputDomain,'Frequency')
                if strcmp(obj.SpectrumType,'RMS')
                    value=getParameter(obj,'RMSUnits');
                else
                    value=getParameter(obj,'PowerUnits');
                end
            else
                value=getParameter(obj,'FrequencyInputSpectrumUnits');
            end
        end


        function set.PowerUnits(obj,strValue)
            if obj.SimscapeMode

                error(message('dspshared:SpectrumAnalyzer:PropertyAccessedWithoutLicense','PowerUnits'));
            end
            validEnums={'Watts','dBm','dBW','dBFS'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'PowerUnits',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'PowerUnits',strValue);
        end
        function value=get.PowerUnits(obj)
            value=getParameter(obj,'PowerUnits');
        end


        function set.FullScaleSource(obj,strValue)
            validatePropertyAccess(obj,'FullScaleSource');
            validEnums={'Auto','Property'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'FullScaleSource',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'FullScaleSource',strValue);
        end
        function value=get.FullScaleSource(obj)
            value=getParameter(obj,'FullScaleSource');
        end


        function set.FullScale(obj,strValue)
            validatePropertyAccess(obj,'FullScale');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'FullScale');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'FullScale',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'FullScale',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','FullScale','string',strValue)
            end
        end
        function value=get.FullScale(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','FullScale');
        end


        function set.AveragingMethod(obj,strValue)
            strValue=convertStringsToChars(strValue);
            validEnums={'Running','Exponential'};
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'AveragingMethod',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'AveragingMethod',strValue);
        end
        function value=get.AveragingMethod(obj)
            value=getParameter(obj,'AveragingMethod');
        end


        function set.SpectralAverages(obj,strValue)
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'SpectralAverages');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'SpectralAverages',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveInteger')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'SpectralAverages',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','SpectralAverages','string',strValue)
            end
        end
        function value=get.SpectralAverages(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','SpectralAverages');
        end


        function set.ForgettingFactor(obj,strValue)
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'ForgettingFactor');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'ForgettingFactor',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveNumberGreaterThanAndLessThanOrEqual','0','1')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'ForgettingFactor',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','ForgettingFactor','string',strValue)
            end
        end
        function value=get.ForgettingFactor(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','ForgettingFactor');
        end


        function set.ReferenceLoad(obj,strValue)
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'ReferenceLoad');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'ReferenceLoad',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'ReferenceLoad',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','ReferenceLoad','string',strValue)
            end
        end
        function value=get.ReferenceLoad(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','ReferenceLoad');
        end


        function set.FrequencyOffset(obj,strValue)
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'FrequencyOffset');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'FrequencyOffset',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidRealNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'FrequencyOffset',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','FrequencyOffset','string',strValue)
            end
        end
        function value=get.FrequencyOffset(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','FrequencyOffset');
        end


        function set.TreatMby1SignalsAsOneChannel(obj,value)
            if isSimulationRunning(obj)
                msgObj=message('Spcuilib:configuration:PropertyNotTunable',...
                'TreatMby1SignalsAsOneChannel',getBlockName(obj));
                throwAsCaller(MException(msgObj));
            end
            if islogical(value)&&isscalar(value)
                setScopeParameter(obj,'TreatMby1SignalsAsOneChannel',value);
            else
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'TreatMby1SignalsAsOneChannel',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidLogical')));
                throwAsCaller(MException(msgObj));
            end
        end
        function value=get.TreatMby1SignalsAsOneChannel(obj)
            value=getParameter(obj,'TreatMby1SignalsAsOneChannel');
        end






        function set.SpectrogramChannel(obj,strValue)
            validatePropertyAccess(obj,'SpectrogramChannel');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'SpectrogramChannel');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'SpectrogramChannel',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveIntegerGreaterThanAndLessThanOrEqual','0','100')));
                throwAsCaller(MException(msgObj))
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'ChannelNumber',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','ChannelNumber','string',strValue)
            end
        end
        function value=get.SpectrogramChannel(obj)
            value=getParameter(obj,'ChannelNumber');
        end


        function set.TimeResolutionSource(obj,strValue)
            validatePropertyAccess(obj,'TimeResolutionSource');
            validEnums={'Auto','Property'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'TimeResolutionSource',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'TimeResolutionSource',strValue);
        end
        function value=get.TimeResolutionSource(obj)
            value=getParameter(obj,'TimeResolutionSource');
        end


        function set.TimeResolution(obj,strValue)
            validatePropertyAccess(obj,'TimeResolution');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'TimeResolution');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'TimeResolution',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'TimeResolution',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','TimeResolution','string',strValue)
            end
        end
        function value=get.TimeResolution(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','TimeResolution');
        end


        function set.TimeSpanSource(obj,strValue)
            validatePropertyAccess(obj,'TimeSpanSource');
            validEnums={'Auto','Property'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'TimeSpanSource',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'TimeSpanSource',strValue);
        end
        function value=get.TimeSpanSource(obj)
            value=getParameter(obj,'TimeSpanSource');
        end


        function set.TimeSpan(obj,strValue)
            validatePropertyAccess(obj,'TimeSpan');
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'TimeSpan');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'TimeSpan',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveNumber')));
                throwAsCaller(MException(msgObj));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'TimeSpan',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','TimeSpan','string',strValue)
            end
        end
        function value=get.TimeSpan(obj)
            value=getScopeParam(obj.Scope,'Visuals','Spectrum','TimeSpan');
        end






        function set.MeasurementChannel(obj,strValue)
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'MeasurementChannel');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'MeasurementChannel',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveIntegerGreaterThanAndLessThanOrEqual','0','100')));
                throwAsCaller(MException(msgObj))
            end
            if isLaunched(obj.Scope.ScopeCfg)
                if~isempty(errorID)
                    throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
                end
                setScopeParam(obj.Scope,'Visuals','Spectrum',...
                'MeasurementChannelNumber',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Visuals',...
                'Spectrum','MeasurementChannelNumber','string',strValue)
            end
        end
        function value=get.MeasurementChannel(obj)
            value=getParameter(obj,'MeasurementChannelNumber');
        end


        function set.SpectralMask(obj,value)
            validatePropertyAccess(obj,'SpectralMask');
            if isa(value,'dsp.scopes.SpectralMaskSpecification')&&isvalid(value)
                if isLaunched(obj.Scope)
                    setSpectralMask(obj.Scope.Framework.Visual,value);
                else

                    obj.pMaskSpecificationObject=value;
                    obj.pMaskListener=event.listener(value,...
                    'MaskUpdated',@(~,~)updateSpectralMask(obj));
                    updateSpectralMask(obj);
                end
            else
                error(message('dspshared:SpectrumAnalyzer:invalidMaskSpecification','SpectralMask'));
            end
        end
        function value=get.SpectralMask(obj)
            framework=obj.Scope.Framework;
            if~isempty(framework)
                value=getSpectralMask(framework.Visual);
            else
                if isempty(obj.pMaskSpecificationObject)

                    obj.pMaskSpecificationObject=dsp.scopes.SpectralMaskSpecification;
                end
                maskProps=getParameter(obj,'SpectralMaskProperties');
                if~isempty(maskProps)
                    set(obj.pMaskSpecificationObject,maskProps);
                end
                value=obj.pMaskSpecificationObject;
                obj.pMaskListener=event.listener(value,...
                'MaskUpdated',@(~,~)updateSpectralMask(obj));
            end
        end


        function value=get.PeakFinder(obj)
            framework=obj.Scope.Framework;
            if~isempty(framework)
                value=getPeakFinder(framework.Visual);
            else
                if isempty(obj.pPeakFinderObject)

                    obj.pPeakFinderObject=dsp.scopes.PeakFinderSpecification;
                end
                peakFinderProps=getParameter(obj,'PeakFinderProperties');
                if~isempty(peakFinderProps)
                    set(obj.pPeakFinderObject,peakFinderProps);
                end
                value=obj.pPeakFinderObject;
                obj.pPeakFinderListener=event.listener(value,...
                'PeakFinderUpdated',@(~,~)updatePeakFinder(obj));
            end
        end


        function value=get.CursorMeasurements(obj)
            framework=obj.Scope.Framework;
            if~isempty(framework)
                value=getCursorMeasurements(framework.Visual);
            else
                if isempty(obj.pCursorMeasurementsObject)


                    obj.pCursorMeasurementsObject=dsp.scopes.CursorMeasurementsSpecification;
                end
                cursorProps=getParameter(obj,'CursorMeasurementsProperties');
                if~isempty(cursorProps)
                    set(obj.pCursorMeasurementsObject,cursorProps);
                end
                value=obj.pCursorMeasurementsObject;
                obj.pCursorMeasurementsListener=event.listener(value,...
                'CursorMeasurementsUpdated',@(~,~)updateCursorMeasurements(obj));
            end
        end


        function value=get.ChannelMeasurements(obj)
            validatePropertyAccess(obj,'ChannelMeasurements');
            framework=obj.Scope.Framework;
            if~isempty(framework)
                value=getChannelMeasurements(framework.Visual);
            else
                if isempty(obj.pChannelMeasurementsObject)


                    obj.pChannelMeasurementsObject=dsp.scopes.ChannelMeasurementsSpecification;
                end
                channelProps=getParameter(obj,'ChannelMeasurementsProperties');
                if~isempty(channelProps)
                    set(obj.pChannelMeasurementsObject,channelProps);
                end
                value=obj.pChannelMeasurementsObject;
                obj.pChannelMeasurementsListener=event.listener(value,...
                'ChannelMeasurementsUpdated',@(~,~)updateChannelMeasurements(obj));
            end
        end


        function value=get.DistortionMeasurements(obj)
            framework=obj.Scope.Framework;
            if~isempty(framework)
                value=getDistortionMeasurements(framework.Visual);
            else
                if isempty(obj.pDistortionMeasurementsObject)


                    obj.pDistortionMeasurementsObject=dsp.scopes.DistortionMeasurementsSpecification;
                end
                distortionProps=getParameter(obj,'DistortionMeasurementsProperties');
                if~isempty(distortionProps)
                    set(obj.pDistortionMeasurementsObject,distortionProps);
                end
                value=obj.pDistortionMeasurementsObject;
                obj.pDistortionMeasurementsListener=event.listener(value,...
                'DistortionMeasurementsUpdated',@(~,~)updateDistortionMeasurements(obj));
            end
        end


        function value=get.CCDFMeasurements(obj)
            validatePropertyAccess(obj,'CCDFMeasurements');
            framework=obj.Scope.Framework;
            if~isempty(framework)
                value=getCCDFMeasurements(framework.Visual);
            else
                if isempty(obj.pCCDFMeasurementsObject)

                    obj.pCCDFMeasurementsObject=dsp.scopes.CCDFMeasurementsSpecification;
                end
                ccdfProps=getParameter(obj,'CCDFMeasurementsProperties');
                if~isempty(ccdfProps)
                    set(obj.pCCDFMeasurementsObject,ccdfProps);
                end
                value=obj.pCCDFMeasurementsObject;
                obj.pCCDFMeasurementsListener=event.listener(value,...
                'CCDFMeasurementsUpdated',@(~,~)updateCCDFMeasurements(obj));
            end
        end






        function set.PlotType(obj,strValue)
            validEnums={'Line','Stem'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'PlotType',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'PlotType',strValue);
        end
        function value=get.PlotType(obj)
            value=getParameter(obj,'PlotType');
        end


        function set.PlotNormalTrace(obj,value)
            validatePropertyAccess(obj,'PlotNormalTrace');
            if islogical(value)&&isscalar(value)
                setScopeParameter(obj,'NormalTrace',value);
            else
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'PlotNormalTrace',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidLogical')));
                throwAsCaller(MException(msgObj));
            end
        end
        function value=get.PlotNormalTrace(obj)
            value=getParameter(obj,'NormalTrace');
        end


        function set.PlotMaxHoldTrace(obj,value)
            validatePropertyAccess(obj,'PlotMaxHoldTrace');
            if islogical(value)&&isscalar(value)
                setScopeParameter(obj,'MaxHoldTrace',value);
            else
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'PlotMaxHoldTrace',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidLogical')));
                throwAsCaller(MException(msgObj));
            end
        end
        function value=get.PlotMaxHoldTrace(obj)
            value=getParameter(obj,'MaxHoldTrace');
        end


        function set.PlotMinHoldTrace(obj,value)
            validatePropertyAccess(obj,'PlotMinHoldTrace');
            if islogical(value)&&isscalar(value)
                setScopeParameter(obj,'MinHoldTrace',value);
            else
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'PlotMinHoldTrace',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidLogical')));
                throwAsCaller(MException(msgObj));
            end
        end
        function value=get.PlotMinHoldTrace(obj)
            value=getParameter(obj,'MinHoldTrace');
        end


        function set.ReducePlotRate(obj,value)
            if islogical(value)&&isscalar(value)
                setScopeParameter(obj,'ReduceUpdates',value);
            else
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'ReducePlotRate',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidLogical')));
                throwAsCaller(MException(msgObj));
            end
        end
        function value=get.ReducePlotRate(obj)
            value=getParameter(obj,'ReduceUpdates');
        end


        function set.Title(obj,value)

            value=convertStringsToChars(value);

            if~ischar(value)
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'Title',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidString')));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'Title',value);
        end
        function value=get.Title(obj)
            value=getParameter(obj,'Title');
        end


        function set.YLabel(obj,value)

            value=convertStringsToChars(value);
            if~ischar(value)
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'YLabel',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidString')));
                throwAsCaller(MException(msgObj));
            end




            if~obj.VectorScopeLegacyMode
                value=removeLegacyUnits(value);
            end
            setScopeParameter(obj,'YLabel',value);
        end
        function value=get.YLabel(obj)
            value=getParameter(obj,'YLabel');
        end


        function set.ShowLegend(obj,value)
            if islogical(value)&&isscalar(value)
                setScopeParameter(obj,'Legend',value);
            else
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'ShowLegend',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidLogical')));
                throwAsCaller(MException(msgObj));
            end
        end
        function value=get.ShowLegend(obj)
            value=getParameter(obj,'Legend');
        end


        function set.ChannelNames(obj,strValue)
            valid=obj.Validator.isValid('ChannelNames',strValue);
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'ChannelNames',getBlockName(obj),getString(...
                message('dspshared:SpectrumAnalyzer:InvalidChannelNames','ChannelNames')));
                throwAsCaller(MException(msgObj));
            end
            strValue=cellstr(strValue);
            setScopeParameter(obj,'UserDefinedChannelNames',strValue);
        end
        function value=get.ChannelNames(obj)
            value=getParameter(obj,'UserDefinedChannelNames');
        end


        function set.ShowGrid(obj,value)
            if islogical(value)&&isscalar(value)
                setScopeParameter(obj,'Grid',value);
            else
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'ShowGrid',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidLogical')));
                throwAsCaller(MException(msgObj));
            end
        end
        function value=get.ShowGrid(obj)
            value=getParameter(obj,'Grid');
        end


        function set.YLimits(obj,value)
            if~obj.Validator.isValid('Limits',value)
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'YLimits',getBlockName(obj),getString(...
                message('dspshared:SpectrumAnalyzer:InvalidLimits','')));
                throwAsCaller(MException(msgObj));
            end

            if value>obj.YLimits(1)

                setScopeParameter(obj,'MaxYLim',num2str(value(2)));
                setScopeParameter(obj,'MinYLim',num2str(value(1)));
            else

                setScopeParameter(obj,'MinYLim',num2str(value(1)));
                setScopeParameter(obj,'MaxYLim',num2str(value(2)));
            end



            disableAutoscale(obj);

        end
        function value=get.YLimits(obj)
            value=[obj.evaluateVariable(getParameter(obj,'MinYLim')),obj.evaluateVariable(getParameter(obj,'MaxYLim'))];
        end


        function set.ColorLimits(obj,value)
            validatePropertyAccess(obj,'ColorLimits');
            if~obj.Validator.isValid('Limits',value)
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'ColorLimits',getBlockName(obj),getString(...
                message('dspshared:SpectrumAnalyzer:InvalidLimits','')));
                throwAsCaller(MException(msgObj));
            end

            if value(1)>obj.ColorLimits(1)

                setScopeParameter(obj,'MaxColorLim',num2str(value(2)));
                setScopeParameter(obj,'MinColorLim',num2str(value(1)));
            else

                setScopeParameter(obj,'MinColorLim',num2str(value(1)));
                setScopeParameter(obj,'MaxColorLim',num2str(value(2)));
            end



            disableAutoscale(obj);
        end
        function value=get.ColorLimits(obj)
            value=[obj.evaluateVariable(getParameter(obj,'MinColorLim')),obj.evaluateVariable(getParameter(obj,'MaxColorLim'))];
        end


        function set.AxesScaling(obj,value)
            value=convertStringsToChars(value);
            if any(strcmpi(value,{'Manual','Auto','Updates'}))
                if isLaunched(obj.Scope)
                    setScopeParam(obj.Scope,'Tools','Plot Navigation',...
                    'AutoscaleMode',value);
                else
                    setScopeParamOnConfig(obj.Scope,'Tools',...
                    'Plot Navigation','AutoscaleMode','string',value);
                end
            else
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'AxesScaling',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                'Manual, Auto, Updates')));
                throwAsCaller(MException(msgObj));
            end
        end
        function value=get.AxesScaling(obj)
            value=getScopeParam(obj.Scope,'Tools','Plot Navigation',...
            'AutoscaleMode');
        end


        function set.AxesScalingNumUpdates(obj,strValue)
            [eval_value,errorID]=evaluateVariable(obj,strValue);
            valid=validateVariable(obj,eval_value,errorID,'AxesScalingNumUpdates');
            if~valid
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'AxesScalingNumUpdates',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidPositiveInteger')));
                throwAsCaller(MException(msgObj));
            end
            if~isempty(errorID)
                throwAsCaller(MException(message('Spcuilib:uiservices:EvaluateUndefinedVariable',strValue)));
            end
            if isLaunched(obj.Scope.ScopeCfg)
                setScopeParam(obj.Scope,'Tools','Plot Navigation',...
                'UpdatesBeforeAutoscale',strValue);
            else
                setScopeParamOnConfig(obj.Scope,'Tools',...
                'Plot Navigation','UpdatesBeforeAutoscale','string',strValue);
            end
        end
        function value=get.AxesScalingNumUpdates(obj)
            value=getScopeParam(obj.Scope,'Tools','Plot Navigation',...
            'UpdatesBeforeAutoscale');
        end


        function set.AxesLayout(obj,strValue)
            validatePropertyAccess(obj,'AxesLayout');
            validEnums={'Vertical','Horizontal'};
            strValue=convertStringsToChars(strValue);
            if~any(strcmpi(strValue,validEnums))
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'AxesLayout',getBlockName(obj),getString(...
                message('Spcuilib:configuration:InvalidEnums',...
                strjoin(validEnums,', '))));
                throwAsCaller(MException(msgObj));
            end
            setScopeParameter(obj,'AxesLayout',strValue);
        end
        function value=get.AxesLayout(obj)
            value=getParameter(obj,'AxesLayout');
        end


        function set.OpenScopeAtSimStart(obj,strValue)
            if strcmp(strValue,'on')
                obj.OpenAtSimulationStart=true;
            else
                obj.OpenAtSimulationStart=false;
            end
        end
        function value=get.OpenScopeAtSimStart(obj)
            if obj.OpenAtSimulationStart
                value='on';
            else
                value='off';
            end
        end





        function set.LegacySetFlag(obj,value)
            setScopeParameter(obj,'MapLegacyBlock',value);
        end
        function value=get.LegacySetFlag(obj)
            value=getParameter(obj,'MapLegacyBlock');
        end

        function set.wintypeSpecScope(obj,strValue)

            strValue_lower=lower(strValue);
            switch strValue_lower
            case{'boxcar'}
                obj.Window='Rectangular';
            case{'chebyshev','hann','hamming','kaiser'}
                obj.Window=strValue;
            otherwise
                obj.Window='Hann';
            end


            obj.wintypeSpecScopeLocal=strValue;
            setLegacyAttenation(obj);
        end
        function value=get.wintypeSpecScope(obj)
            value=obj.Window;
        end

        function set.RsSpecScope(obj,strValue)
            obj.RsSpecScopeLocal=strValue;


            setLegacyAttenation(obj);
        end
        function value=get.RsSpecScope(obj)
            value=obj.SidelobeAttenuation;
        end

        function set.betaSpecScope(obj,strValue)
            obj.betaSpecScopeLocal=strValue;


            setLegacyAttenation(obj);
        end
        function value=get.betaSpecScope(obj)
            value=obj.SidelobeAttenuation;
        end

        function set.numAvg(obj,strValue)
            obj.SpectralAverages=strValue;
        end
        function value=get.numAvg(obj)
            value=obj.SpectralAverages;
        end

        function set.XRange(obj,strValue)





            if contains(lower(strValue),'-fs/2...fs/2')||contains(lower(strValue),'[0...fs]')
                obj.PlotAsTwoSidedSpectrum=true;
            else
                obj.PlotAsTwoSidedSpectrum=false;
            end
        end
        function value=get.XRange(obj)
            if obj.PlotAsTwoSidedSpectrum
                value='Two-sided ((-Fs/2...Fs/2])';
            else
                value='One-sided ([0...Fs/2])';
            end
        end

        function set.AxisGrid(obj,strValue)
            if strcmp(strValue,'on')
                obj.ShowGrid=true;
            else
                obj.ShowGrid=false;
            end
        end
        function value=get.AxisGrid(obj)
            if obj.ShowGrid
                value='on';
            else
                value='off';
            end
        end

        function set.AxisLegend(obj,strValue)
            if strcmp(strValue,'on')
                obj.ShowLegend=true;
            else
                obj.ShowLegend=false;
            end
        end
        function value=get.AxisLegend(obj)
            if obj.ShowLegend
                value='on';
            else
                value='off';
            end
        end

        function set.Memory(obj,strValue)
            if strcmp(strValue,'on')
                obj.PlotMaxHoldTrace=true;
            else
                obj.PlotMaxHoldTrace=false;
            end
        end
        function value=get.Memory(obj)
            if obj.PlotMaxHoldTrace
                value='on';
            else
                value='off';
            end
        end

        function set.inpFftLenInherit(obj,strValue)
            if strcmp(strValue,'on')
                obj.FFTLengthSource='Property';
            else
                obj.FFTLengthSource='Auto';
            end
        end
        function value=get.inpFftLenInherit(obj)
            if strcmp(obj.FFTLengthSource,'Property')
                value='on';
            else
                value='off';
            end
        end

        function set.XDisplay(obj,strValue)
            obj.FrequencyOffset=strValue;
        end
        function value=get.XDisplay(obj)
            value=obj.FrequencyOffset;
        end

        function set.FFTlength(obj,strValue)
            obj.FFTLength=strValue;
        end
        function value=get.FFTlength(obj)
            value=obj.FFTLength;
        end

        function set.FigPos(obj,strValue)

            ind=strfind(strValue,'%');
            if~isempty(ind)
                strValue=strValue(1:ind-1);
            end
            obj.Position=obj.evaluateVariable(strValue);
        end
        function value=get.FigPos(obj)
            value=sprintf('[%s]',num2str(obj.Position));
            value=strrep(value,'  ',' ');
        end

        function set.XLimit(obj,strValue)
            if strcmpi(strValue,'Auto')
                obj.FrequencySpan='Full';
                return
            end
            obj.XLimitLocal=strValue;


            setStartStopFrq(obj);
        end
        function value=get.XLimit(obj)
            if strcmp(obj.FrequencySpan,'Full')
                value='Auto';
            else
                value='User-defined';
            end
        end

        function set.XMin(obj,strValue)
            obj.XMinLocal=strValue;


            setStartStopFrq(obj);
        end
        function value=get.XMin(obj)
            if strcmp(obj.FrequencySpan,'Start and stop frequencies')
                value=obj.StartFrequency;
            elseif strcmp(obj.FrequencySpan,'Span and center frequency')
                value=sprintf('%s - %s/2',obj.CenterFrequency,obj.Span);
            else
                if obj.PlotAsTwoSidedSpectrum
                    value=sprintf('-%s/2',obj.SampleRate);
                else
                    value='0';
                end
            end
        end

        function set.XMax(obj,strValue)
            obj.XMaxLocal=strValue;


            setStartStopFrq(obj);
        end
        function value=get.XMax(obj)
            if strcmp(obj.FrequencySpan,'Start and stop frequencies')
                value=obj.StopFrequency;
            elseif strcmp(obj.FrequencySpan,'Span and center frequency')
                value=sprintf('%s + %s/2',obj.CenterFrequency,obj.Span);
            else
                value=sprintf('%s/2',obj.SampleRate);
            end
        end

        function set.IsFstartFstopSettingDirty(obj,val)
            setScopeParameter(obj,'IsFstartFstopSettingDirty',val);
        end

        function set.YMin(obj,strValue)


            [val,errId,errStr]=obj.evaluateVariable(strValue);
            if isempty(errId)&&isempty(errStr)
                if isLaunched(obj.Scope)
                    obj.validateLimits([val,obj.YLimits(2)],'YLimits');
                end
                setScopeParameter(obj,'MinYLim',strValue);




                if~strcmp(strValue,'-10')
                    disableAutoscale(obj);
                end
            end
        end
        function value=get.YMin(obj)
            value=num2str(obj.YLimits(1));
        end

        function set.YMax(obj,strValue)


            [val,errId,errStr]=obj.evaluateVariable(strValue);
            if isempty(errId)&&isempty(errStr)
                if isLaunched(obj.Scope)
                    obj.validateLimits([obj.YLimits(1),val],'YLimits');
                end
                setScopeParameter(obj,'MaxYLim',strValue);




                if~strcmp(strValue,'10')
                    disableAutoscale(obj);
                end
            end
        end
        function value=get.YMax(obj)
            value=num2str(obj.YLimits(2));
        end

        function set.OpenScopeImmediately(~,~)

        end
        function value=get.OpenScopeImmediately(~)
            value='off';
        end

        function set.SegLen(obj,value)
            setScopeParameter(obj,'SegLen',value);
        end
        function value=get.SegLen(obj)
            value=getParameter(obj,'SegLen');
        end

        function set.UseBuffer(obj,strValue)
            if obj.Scope.ScopeCfg.executedStartFcn


                return
            end
            if strcmp(strValue,'on')
                obj.UseBufferLocal=true;
            else
                obj.UseBufferLocal=false;
            end


            obj.LegacySetFlag=true;
            setSegmentLengthInfo(obj);
            setLegacyOverlap(obj);
        end
        function value=get.UseBuffer(~)
            value='on';
        end

        function set.BufferSize(obj,strValue)
            if obj.Scope.ScopeCfg.executedStartFcn


                return
            end
            obj.BufferSizeLocal=strValue;
            obj.Method='Welch';
            obj.AveragingMethod='Running';
            obj.FrequencyResolutionMethod='WindowLength';


            obj.LegacySetFlag=true;
            setSegmentLengthInfo(obj);
            setLegacyOverlap(obj);
        end
        function value=get.BufferSize(obj)
            framework=obj.Scope.ScopeCfg.Scope.Framework;
            if~isempty(framework)
                value=framework.Visual.DataBuffer.SegmentLength;
                value=num2str(value);
            else
                val=obj.BufferSizeLocal;
                if isempty(val)
                    val='';
                end
                value=val;
            end
        end

        function set.Overlap(obj,strValue)
            if obj.Scope.ScopeCfg.executedStartFcn


                return
            end
            obj.OverlapLocal=strValue;

            setLegacyOverlap(obj);
        end
        function value=get.Overlap(obj)
            if~isempty(obj.BufferSize)
                value=sprintf('round(%s * %s / 100)',obj.OverlapPercent,obj.BufferSize);
                value=simplifyString(obj,value);
            else
                value='';
            end
        end

        function set.YUnits(obj,strValue)
            strValue_lower=lower(strValue);


            if~obj.VectorScopeLegacyMode
                if contains(strValue_lower,'hertz')||...
                    contains(strValue_lower,'magnitude-squared')||...
                    (~contains(strValue_lower,'dbw')&&~contains(strValue_lower,'dbm')&&...
                    contains(strValue_lower,'db'))
                    obj.SpectrumType='Power density';
                else
                    obj.SpectrumType='Power';
                end
                if contains(strValue_lower,'dbw')
                    obj.PowerUnits='dBW';
                elseif contains(strValue_lower,'dbm')
                    obj.PowerUnits='dBm';
                elseif contains(strValue_lower,'db')
                    obj.PowerUnits='dBW';
                else
                    obj.PowerUnits='Watts';
                end
            else


                if strcmp(strValue,'dB')

                    obj.SpectrumUnits='dBW';
                    obj.InputUnits='Watts';
                else

                    obj.SpectrumUnits='Watts';
                    obj.InputUnits='Watts';
                end

            end
        end
        function value=get.YUnits(obj)
            if~obj.VectorScopeLegacyMode
                value=obj.PowerUnits;
                if strcmp(obj.SpectrumType,'Power density')
                    value=sprintf('%s/Hertz',value);
                end
            else
                if strcmp(obj.SpectrumUnits,'dBW')
                    value='dB';
                else
                    value='Magnitude';
                end
            end
        end

        function set.TreatMby1Signals(obj,val)
            if strcmp(val,'One channel')
                obj.TreatMby1SignalsAsOneChannel=true;
            else
                obj.TreatMby1SignalsAsOneChannel=false;
            end
        end
        function value=get.TreatMby1Signals(obj)
            if obj.TreatMby1SignalsAsOneChannel
                value='One channel';
            else
                value='M channels';
            end
        end

        function set.LineDisables(~,~)

        end
        function value=get.LineDisables(~)

            value='';
        end

        function set.LineStyles(obj,val)
            if obj.VectorScopeLegacyMode

                lineStyles=strsplit(val,'|');

                lineStyles=strtrim(lineStyles);

                success=launchScope(obj);
                if success
                    hVisual=obj.Scope.Framework.Visual;
                    hPlotter=hVisual.Plotter;
                    for idx=1:numel(lineStyles)
                        lp=getLineProperties(hPlotter,idx);
                        lp.LineStyle=lineStyles{idx};
                        hPlotter.setLineProperties(idx,lp);
                    end
                end
            end
        end
        function value=get.LineStyles(obj)
            if~obj.VectorScopeLegacyMode
                value='';
            else
                hVisual=obj.Scope.Framework.Visual;
                hPlotter=hVisual.Plotter;
                lp=getStyle(hPlotter);
                lineStyles=lp.LineStyles;
                value=strjoin(lineStyles,' | ');
            end
        end

        function set.LineMarkers(obj,val)
            if obj.VectorScopeLegacyMode

                lineMarkers=strsplit(val,'|');

                lineMarkers=strtrim(lineMarkers);

                success=launchScope(obj);
                if success
                    hVisual=obj.Scope.Framework.Visual;
                    hPlotter=hVisual.Plotter;
                    for idx=1:numel(lineMarkers)
                        lp=getLineProperties(hPlotter,idx);
                        lp.Marker=lineMarkers{idx};
                        hPlotter.setLineProperties(idx,lp);
                    end
                end
            end
        end
        function value=get.LineMarkers(obj)
            if~obj.VectorScopeLegacyMode
                value='';
            else
                hVisual=obj.Scope.Framework.Visual;
                hPlotter=hVisual.Plotter;
                lp=getStyle(hPlotter);
                markerStyles=lp.MarkerStyles;
                value=strjoin(markerStyles,' | ');
            end
        end

        function set.LineColors(~,~)

        end
        function value=get.LineColors(~)

            value='';
        end

        function set.WinsampSpecScope(~,~)

        end
        function value=get.WinsampSpecScope(~)
            value='Symmetric';
        end

        function set.FrameNumber(~,~)

        end
        function value=get.FrameNumber(~)
            value='on';
        end

        function set.AxisZoom(~,~)

        end
        function value=get.AxisZoom(~)
            value='off';
        end

        function set.InheritXIncr(obj,val)
            if obj.VectorScopeLegacyMode
                if strcmpi(val,'off')
                    obj.SampleRateSource='Property';
                else
                    obj.SampleRateSource='Inherited';
                end
            end
        end
        function value=get.InheritXIncr(obj)
            value='on';
            if obj.VectorScopeLegacyMode
                if strcmpi(obj.SampleRateSource,'Property')
                    value='off';
                else
                    value='on';
                end
            end
        end

        function set.XIncr(obj,val)
            if obj.VectorScopeLegacyMode
                if strcmp(obj.SampleRateSource,'Property')
                    [value,variableUndefined]=evaluateString(obj,val,'XIncr');
                    if~variableUndefined
                        obj.SampleRate=num2str(1/value);
                    end
                end
            end
        end
        function value=get.XIncr(obj)
            if obj.VectorScopeLegacyMode
                value=['1/',obj.SampleRate];
            else
                value='';
            end
        end

        function set.IsSourceVectorScope(obj,val)
            if strcmpi(val,'on')
                obj.VectorScopeLegacyMode=true;
                obj.InputDomain='Frequency';
            else
                obj.VectorScopeLegacyMode=false;
            end
        end
        function val=get.IsSourceVectorScope(obj)
            if obj.VectorScopeLegacyMode
                val='on';
            else
                val='off';
            end
        end

        function set.VectorScopeLegacyMode(obj,value)
            setScopeParameter(obj,'VectorScopeLegacyMode',value);
        end
        function value=get.VectorScopeLegacyMode(obj)
            value=getParameter(obj,'VectorScopeLegacyMode');
        end
    end

    methods(Access=protected)
        [value,errorOccured]=evaluateString(obj,strValue,propName)
        errorForNonTunableProperty(obj,propertyName)
        newStrVal=simplifyString(obj,strVal)
        disableAutoscale(obj)
        updateSpectralMask(obj)
        groups=getPropertyGroups(obj);
    end

    methods(Access=protected)
        function validatePropertyAccess(obj,propName)


            if obj.SimscapeMode
                dstOnlyProps=getDSTOnlyProperties(obj);
                if ismember(propName,dstOnlyProps)
                    msgObj=message('dspshared:SpectrumAnalyzer:PropertyAccessedWithoutLicense',propName);
                    throwAsCaller(MException(msgObj));
                end
            end
        end
        function props=getDSTOnlyProperties(~)



            props={...
            'InputDomain',...
            'ViewType',...
            'Method',...
            'FrequencySpan',...
            'Span',...
            'CenterFrequency',...
            'StartFrequency',...
            'StopFrequency',...
            'FrequencyResolutionMethod',...
            'WindowLength',...
            'FFTLengthSource',...
            'FFTLength',...
            'NumTapsPerBand',...
            'FrequencyVector',...
            'FrequencyVectorSource',...
            'CustomWindow',...
            'SidelobeAttenuation',...
            'InputUnits',...
            'FullScaleSource',...
            'FullScale',...
'SpectrogramChannel'...
            ,'TimeResolutionSource',...
            'TimeResolution',...
            'TimeSpanSource',...
            'TimeSpan',...
            'ChannelMeasurements',...
            'CCDFMeasurements',...
            'SpectralMask',...
            'PlotNormalTrace',...
            'PlotMaxHoldTrace',...
            'PlotMinHoldTrace',...
            'ColorLimits',...
            'AxesLayout'};
        end
        function inactiveProps=getInactiveProperties(obj)
            inactiveProps={};
            if strcmpi(obj.InputDomain,'Time')

                if strcmpi(obj.SampleRateSource,'Inherited')

                    inactiveProps={'SampleRate'};
                end
                if strcmpi(obj.FrequencySpan,'Full')

                    inactiveProps=[inactiveProps,{'Span',...
                    'CenterFrequency',...
                    'StartFrequency',...
                    'StopFrequency'}];
                elseif strcmpi(obj.FrequencySpan,'Span and center frequency')

                    inactiveProps=[inactiveProps,{'StartFrequency',...
                    'StopFrequency'}];
                else

                    inactiveProps=[inactiveProps,{'Span',...
                    'CenterFrequency'}];
                end
                if strcmpi('Method','Filter bank')

                    inactiveProps=[inactiveProps,{'WindowLength',...
                    'OverlapPercent',...
                    'Window',...
                    'CustomWindow',...
                    'SidelobeAttenuation'}];
                else

                    inactiveProps=[inactiveProps,{'NumTapsPerBand'}];
                end
                if strcmpi(obj.FrequencyResolutionMethod,'RBW')

                    inactiveProps=[inactiveProps,{'WindowLength',...
                    'FFTLengthSource',...
                    'FFTLength',...
                    'NumTapsPerBand'}];
                    if strcmpi(obj.RBWSource,'Auto')
                        inactiveProps=[inactiveProps,{'RBW'}];
                    end
                elseif strcmpi(obj.FrequencyResolutionMethod,'WindowLength')

                    inactiveProps=[inactiveProps,{'RBWSource',...
                    'RBW',...
                    'NumTapsPerBand'}];
                    if strcmpi(obj.FFTLengthSource,'Auto')
                        inactiveProps=[inactiveProps,{'FFTLength'}];
                    end
                else

                    inactiveProps=[inactiveProps,{'WindowLength',...
                    'RBWSource',...
                    'RBW'}];
                    if strcmpi(obj.FFTLengthSource,'Auto')
                        inactiveProps=[inactiveProps,{'FFTLength'}];
                    end
                end
                inactiveProps=[inactiveProps,{'FrequencyVectorSource',...
                'FrequencyVector',...
                'InputUnits'}];

                if~strcmpi('Window','Custom')

                    inactiveProps=[inactiveProps,{'CustomWindow'}];
                end

                if~any(strcmpi('Window',{'Chebyshev','Kaiser'}))

                    inactiveProps=[inactiveProps,{'SidelobeAttenuation'}];
                end

                if~strcmpi(obj.SpectrumUnits,'dBFS')

                    inactiveProps=[inactiveProps,{'FullScaleSource',...
                    'FullScale'}];
                else

                    if~strcmpi(obj.FullScaleSource,'Auto')
                        inactiveProps=[inactiveProps,{'FullScale'}];
                    end
                end

                if strcmpi(obj.AveragingMethod,'Running')
                    inactiveProps=[inactiveProps,{'ForgettingFactor'}];
                else
                    inactiveProps=[inactiveProps,{'SpectralAverages'}];
                end

            else

                inactiveProps=[inactiveProps,{'SpectrumType',...
                'SampleRateSource',...
                'Method',...
                'FrequencySpan',...
                'Span',...
                'CenterFrequency',...
                'StartFrequency',...
                'StopFrequency',...
                'FrequencyResolutionMethod',...
                'WindowLength',...
                'FFTLengthSource',...
                'FFTLength',...
                'NumTapsPerBand',...
                'OverlapPercent',...
                'Window',...
                'CustomWindow',...
                'SidelobeAttenuation',...
                'FullScaleSource',...
                'FullScale',...
                'AveragingMethod',...
                'SpectralAverages',...
                'ForgettingFactor',...
                'TreatMby1SignalsAsOneChannel',...
                'TimeResolutionSource',...
                'TimeResolution',...
                'CCDFMeasurements'}];
                if strcmpi(obj.TimeSpanSource,'Auto')
                    inactiveProps=[inactiveProps,{'TimeSpan'}];
                end
            end

            if strcmpi(obj.ViewType,'Spectrum')

                inactiveProps=[inactiveProps,{'SpectrogramChannel',...
                'TimeResolutionSource',...
                'TimeResolution',...
                'TimeSpanSource',...
                'TimeSpan',...
                'ColorLimits',...
                'AxesLayout'}];
            elseif strcmpi(obj.ViewType,'Spectrogram')

                inactiveProps=[inactiveProps,{'SpectralMask',...
                'PeakFinder',...
                'ChannelMeasurements',...
                'DistortionMeasurements',...
                'AveragingMethod',...
                'SpectralAverages',...
                'ForgettingFactor',...
                'PlotType',...
                'PlotNormalTrace',...
                'PlotMaxHoldTrace',...
                'PlotMinHoldTrace',...
                'YLimits',...
                'ColorLimits',...
                'AxesLayout'}];
                if strcmpi(obj.TimeResolutionSource,'Auto')
                    inactiveProps=[inactiveProps,{'TimeResolution'}];
                end

                if strcmpi(obj.TimeSpanSource,'Auto')
                    inactiveProps=[inactiveProps,{'TimeSpan'}];
                end
            else

                inactiveProps=[inactiveProps,{'AveragingMethod',...
                'SpectralAverages',...
                'ForgettingFactor'}];
                if strcmpi(obj.TimeResolutionSource,'Auto')
                    inactiveProps=[inactiveProps,{'TimeResolution'}];
                end

                if strcmpi(obj.TimeSpanSource,'Auto')
                    inactiveProps=[inactiveProps,{'TimeSpan'}];
                end
            end

            if~strcmpi(obj.AxesScaling,'Updates')
                inactiveProps=[inactiveProps,{'AxesScalingNumUpdates'}];
            end
        end
    end

    methods(Static)
        function validateLimits(value,prop)
            if~all(isnumeric(value))||~all(isfinite(value))||numel(value)~=2||value(1)>=value(2)
                throwAsCaller(MException(message('dspshared:SpectrumAnalyzer:InvalidLimits',prop)));
            end
        end
    end

    methods(Hidden)
        function props=getDisplayProperties(this)
            props=getPropertyGroups(this);
        end
    end

end



function spectrumData=createEmptySpectrumDataTable(obj,numSegments)
    if numSegments==1
        spectrumData=table({[]},{[]},{[]},{[]},{[]},{[]},'VariableNames',obj.SpectrumDataFieldNames);
    else
        data=cell(numSegments,numel(obj.SpectrumDataFieldNames));
        spectrumData=cell2table(data);
        spectrumData.Properties.VariableNames=obj.SpectrumDataFieldNames;
    end
end

function measurementsData=createEmptyMeasurementsDataTable(obj,~)
    measurementsData=table({[]},{[]},{[]},{[]},{[]},{[]},'VariableNames',obj.MeasurementsDataFieldNames);
end

