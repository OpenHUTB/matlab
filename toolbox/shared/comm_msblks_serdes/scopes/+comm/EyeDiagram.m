classdef(StrictDefaults,TunablesDetermineInactiveStatus)EyeDiagram<matlabshared.scopes.UnifiedSystemScope&dynamicprops















































































































    properties




        Name='Eye Diagram';
    end

    properties(Dependent,Nontunable)



SampleRate




MeasurementDelay
    end

    properties(Dependent)



SamplesPerSymbol




SampleOffset




SymbolsPerTrace




TracesToDisplay







DisplayMode







ShowBathtub







OverlayHistogram







BathtubBER






EnableMeasurements




ShowImaginaryEye





ColorFading



ShowGrid




YLimits





OversamplingMethod







ColorScale






DecisionBoundary






EyeLevelBoundaries




RiseFallThresholds






Hysteresis





BERThreshold
    end

    properties(Constant,Hidden)
        DisplayModeSet=matlab.system.StringSet({'Line plot','2D color histogram'});
        OversamplingMethodSet=matlab.system.StringSet({'None','Input interpolation','Histogram interpolation'});
        ColorScaleSet=matlab.system.StringSet({'Linear','Logarithmic'});
        OverlayHistogramSet=matlab.system.StringSet({'None','Jitter','Noise'});
        ShowBathtubSet=matlab.system.StringSet({'None','Horizontal','Vertical','Both'});
    end

    properties(Access=private)
        pSampleCount=0;



        pMeasDelaySamples=0;
    end

    methods

        function this=EyeDiagram(varargin)

            error(message('shared_comm_msblks_serdes:EyeDiagramSystemObject:isRemoved','comm.EyeDiagram','eyediagram'));

            this@matlabshared.scopes.UnifiedSystemScope();%#ok<*UNRCH> 


            [success,errMsg]=checkLicense(this,true);
            if~success
                error(errMsg);
            end

            this.ShowImaginaryEye=false;

            this.Position=uiscopes.getDefaultPosition([640,460]);
            enableExtension(this.pFramework.ExtDriver,'Tools','Measurements');

            setProperties(this,nargin,varargin{:});


            this.pFramework.Visual.HistogramBuffer=shared_commutil.EyeHistogramBuffer();
        end

        function set.Name(this,value)
            setScopeName(this,value);
            this.Name=value;
        end

        function set.SampleRate(this,value)
            validateattributes(value,{'numeric'},{'scalar','real','positive','finite'},'','SampleRate');
            setVisualProperty(this,'SampleRate',value,true);
        end
        function value=get.SampleRate(this)
            value=this.getWithThrowAsCaller('SampleRate');
        end

        function set.SamplesPerSymbol(this,value)


            validateattributes(value,{'numeric'},{'integer','scalar','real','positive'},'','SamplesPerSymbol');

            if isLocked(this)&&(value<this.SampleOffset)
                error(message('comm:ConstellationVisual:InvalidSamplesPerSymbol'));
            end
            setVisualProperty(this,'SamplesPerSymbol',value,true);
        end
        function value=get.SamplesPerSymbol(this)
            value=this.getWithThrowAsCaller('SamplesPerSymbol');
        end

        function set.SymbolsPerTrace(this,value)


            validateattributes(value,{'numeric'},{'integer','scalar','>',0},'','SymbolsPerTrace');

            setVisualProperty(this,'SymbolsPerTrace',value,true);
        end
        function value=get.SymbolsPerTrace(this)
            value=this.getWithThrowAsCaller('SymbolsPerTrace');
        end

        function set.SampleOffset(this,value)
            validateattributes(value,{'numeric'},{'integer','scalar','real','nonnegative'},'','SampleOffset');
            setVisualProperty(this,'SampleOffset',value,true);
        end
        function value=get.SampleOffset(this)
            value=this.getWithThrowAsCaller('SampleOffset');
        end

        function set.TracesToDisplay(this,value)
            validateattributes(value,{'numeric'},{'integer','scalar','real','positive'},'','TracesToDisplay');
            setVisualProperty(this,'TracesToDisplay',value,true);
        end
        function value=get.TracesToDisplay(this)
            value=this.getWithThrowAsCaller('TracesToDisplay');
        end

        function set.DisplayMode(this,value)
            if strcmp(value,'2D color histogram')
                value='DisplayModeHistogram';
            else
                value='DisplayModeLine';
            end
            setVisualProperty(this,'DisplayMode',value,false);
        end
        function value=get.DisplayMode(this)
            value=getVisualProperty(this,'DisplayMode');
            if strcmp(value,'DisplayModeHistogram')
                value='2D color histogram';
            else
                value='Line plot';
            end
        end

        function set.ShowGrid(this,value)
            validateattributes(value,{'logical','double'},{'scalar','real'},'','ShowGrid');
            if isnumeric(value)
                value=value>0;
            end
            setVisualProperty(this,'Grid',value,false);
        end
        function value=get.ShowGrid(this)
            value=getVisualProperty(this,'Grid',false);
        end

        function set.ShowBathtub(this,value)
            showHor=any(strcmp(value,{'Horizontal','Both'}));
            showVer=any(strcmp(value,{'Vertical','Both'}));
            setVisualProperty(this,'ShowHorBathtub',showHor,false);
            setVisualProperty(this,'ShowVerBathtub',showVer,false);
        end
        function value=get.ShowBathtub(this)
            showHor=getVisualProperty(this,'ShowHorBathtub',false);
            showVer=getVisualProperty(this,'ShowVerBathtub',false);
            if~showHor&&~showVer
                value='None';
            elseif showHor&&~showVer
                value='Horizontal';
            elseif~showHor&&showVer
                value='Vertical';
            else
                value='Both';
            end
        end

        function set.OverlayHistogram(this,value)
            if strcmp(value,'None')
                strID='ShowNoHist';
            elseif strcmp(value,'Jitter')
                strID='ShowHorHist';
            else
                strID='ShowVerHist';
            end
            setVisualProperty(this,'ShowAuxHist',strID,false);
        end
        function value=get.OverlayHistogram(this)
            propValue=getVisualProperty(this,'ShowAuxHist',false);
            if strcmp('ShowNoHist',propValue)
                value='None';
            elseif strcmp('ShowHorHist',propValue)
                value='Jitter';
            else
                value='Noise';
            end
        end

        function set.EnableMeasurements(this,value)
            validateattributes(value,{'logical','double'},{'scalar','real'},'','EnableMeasurements');
            if isnumeric(value)
                value=value>0;
            end
            setVisualProperty(this,'EnableMeasurements',value,false);
        end
        function value=get.EnableMeasurements(this)
            value=getVisualProperty(this,'EnableMeasurements',false);
        end

        function set.ShowImaginaryEye(this,value)
            validateattributes(value,{'logical','double'},{'scalar','real'},'','ShowImaginaryEye');
            if isnumeric(value)
                value=value>0;
            end
            if value
                value='Eye_Display_two';
            else
                value='Eye_Display_one';
            end
            setVisualProperty(this,'EyeDisplay',value,false);
        end
        function value=get.ShowImaginaryEye(this)
            str='Eye_Display_two';
            value=strcmp(getVisualProperty(this,'EyeDisplay'),str);
        end

        function set.ColorFading(this,value)
            validateattributes(value,{'logical','double'},{'scalar','real'},'','ColorFading');
            if isnumeric(value)
                value=value>0;
            end
            setVisualProperty(this,'ColorFading',value,false);
        end
        function value=get.ColorFading(this)
            value=getVisualProperty(this,'ColorFading',false);
        end

        function set.YLimits(this,value)

            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)
                error(message('shared_comm_msblks_serdes:EyeDiagramVisual:InvalidXYLimits','YLimits'));
            end
            setVisualProperty(this,'MinYLim',value(1),true);
            setVisualProperty(this,'MaxYLim',value(2),true);
        end
        function value=get.YLimits(this)
            value=[getVisualProperty(this,'MinYLim',true)...
            ,getVisualProperty(this,'MaxYLim',true)];
        end

        function set.OversamplingMethod(this,value)
            if strcmp(value,'None')
                value='NoOversampling';

            elseif strcmp(value,'Input interpolation')
                value='InputInterpolation';

            else
                value='Histogramnterpolation';
            end
            setVisualProperty(this,'OversamplingMethod',value,false);
        end
        function value=get.OversamplingMethod(this)
            value=getVisualProperty(this,'OversamplingMethod');
            if strcmp(value,'NoOversampling')
                value='None';
            elseif strcmp(value,'InputInterpolation')
                value='Input interpolation';
            else
                value='Histogram interpolation';
            end
        end

        function set.ColorScale(this,value)
            if strcmp(value,'Linear')
                value='ColorScaleLinear';
            else
                value='ColorScaleLogarithmic';
            end
            setVisualProperty(this,'ColorScale',value,false);
        end
        function value=get.ColorScale(this)
            value=getVisualProperty(this,'ColorScale');
            if strcmp(value,'ColorScaleLinear')
                value='Linear';
            else
                value='Logarithmic';
            end
        end

        function set.DecisionBoundary(this,value)
            validateattributes(value,{'numeric'},{'scalar','real','finite'},'','DecisionBoundary');
            setMeasurementProperty(this,'DecisionBoundary',value);
        end
        function value=get.DecisionBoundary(this)
            value=this.getWithThrowAsCaller('DecisionBoundary');
        end

        function set.EyeLevelBoundaries(this,value)
            validateattributes(value,{'numeric'},{'real','numel',2,'>=',0,'<=',100},'','EyeLevelBoundaries');
            setMeasurementProperty(this,'EyeLevelBoundaries',value);
        end
        function value=get.EyeLevelBoundaries(this)
            value=this.getWithThrowAsCaller('EyeLevelBoundaries');
        end

        function set.RiseFallThresholds(this,value)
            validateattributes(value,{'numeric'},{'real','numel',2,'>=',0,'<=',100},'','RiseFallThresholds');
            setMeasurementProperty(this,'RiseFallThresholds',value);
        end
        function value=get.RiseFallThresholds(this)
            value=this.getWithThrowAsCaller('RiseFallThresholds');
        end

        function set.Hysteresis(this,value)
            validateattributes(value,{'numeric'},{'scalar','real','nonnegative'},'','Hysteresis');
            setMeasurementProperty(this,'Hysteresis',value);
        end
        function value=get.Hysteresis(this)
            value=this.getWithThrowAsCaller('Hysteresis');
        end

        function set.BERThreshold(this,value)
            validateattributes(value,{'numeric'},{'scalar','real','nonnegative','<=',0.5},'','BERThreshold');
            setMeasurementProperty(this,'BERThreshold',value);
        end
        function value=get.BERThreshold(this)
            value=this.getWithThrowAsCaller('BERThreshold');
        end

        function set.BathtubBER(this,value)
            validateattributes(value,{'numeric'},{'real','nonnegative','<=',0.5},'','BathtubBER');
            if length(value)<2
                error(message('shared_comm_msblks_serdes:EyeDiagramVisual:BathtubBERLessThan2'));
            end
            setMeasurementProperty(this,'BathtubBER',value);
        end
        function value=get.BathtubBER(this)
            value=this.getWithThrowAsCaller('BathtubBER');
        end

        function set.MeasurementDelay(this,value)
            validateattributes(value,{'numeric'},{'scalar','real','nonnegative','finite'},'','MeasurementDelay');
            setMeasurementProperty(this,'MeasurementDelay',value);
        end
        function value=get.MeasurementDelay(this)
            value=this.getWithThrowAsCaller('MeasurementDelay');
        end

        function measurements=measurements(this)



            visual=this.pFramework.Visual;
            if~this.EnableMeasurements||isempty(visual.MeasurementDialog.Measurer.measVals)
                error(message('shared_comm_msblks_serdes:EyeDiagramVisual:MeasurementsMethod'));
            end

            measStruct=visual.getMeasurements();
            measurements=measStruct.Measurements;
        end

        function horHist=jitterHistogram(this)



            visual=this.pFramework.Visual;
            if~this.EnableMeasurements||isempty(visual.HistogramBuffer.getHorHistogramReal())
                error(message('shared_comm_msblks_serdes:EyeDiagramVisual:JitterHistogramMethod'));
            end

            horHist=visual.getHorHistogram();
        end

        function verHist=noiseHistogram(this)



            visual=this.pFramework.Visual;
            if~this.EnableMeasurements||~strcmp(this.DisplayMode,'2D color histogram')||...
                isempty(visual.MeasurementDialog.Measurer.measVals)
                error(message('shared_comm_msblks_serdes:EyeDiagramVisual:NoiseHistogramMethod'));
            end

            verHist=visual.getVerHistogram();
        end

        function horBtub=horizontalBathtub(this)





            visual=this.pFramework.Visual;
            if~any(strcmp(this.ShowBathtub,{'Horizontal','Both'}))||length(get(visual.Plotter.Lines(3),'YData'))<2
                error(message('shared_comm_msblks_serdes:EyeDiagramVisual:HorizontalBathtubMethod'));
            end
            horBtub=visual.getHorBathtub();
        end

        function verBtub=verticalBathtub(this)





            visual=this.pFramework.Visual;
            if~any(strcmp(this.ShowBathtub,{'Vertical','Both'}))||length(get(visual.Plotter.Lines(3),'XData'))<2
                error(message('shared_comm_msblks_serdes:EyeDiagramVisual:VerticalBathtubMethod'));
            end
            verBtub=this.pFramework.Visual.getVerBathtub();
        end
    end

    methods(Access=protected)

        function setMeasurementProperty(obj,property,value)


            set=false;
            dialog=obj.pFramework.Visual.MeasurementDialog;
            if~isempty(dialog)


                edit=findobj(dialog.hSettingsDialog.hEdits,'Tag',property);
                if~isempty(edit)
                    set=true;
                    edit.String=mat2str(value);
                end
            end
            if~set


                setVisualProperty(obj,property,value,true);
            end
        end

        function setupImpl(obj,varargin)

            [success,errMsg]=checkLicense(obj,true);
            if~success
                error(errMsg);
            end

            validateInputs(obj,varargin{1});
            setupImpl@matlabshared.scopes.UnifiedSystemScope(obj,varargin{:});


            obj.pMeasDelaySamples=round(obj.MeasurementDelay*obj.SampleRate);

            onSourceRun(obj.pFramework.Visual);
        end

        function validateInputsImpl(~,varargin)
            if size(varargin{1},2)>1
                error(message('comm:system:inputNot1D2DColVec'));
            end
        end

        function updateImpl(obj,varargin)

            if isempty(obj.pFramework)
                launchScope(obj);
            end

            inData=double(varargin{1});
            if(obj.EnableMeasurements||strcmp(obj.DisplayMode,'2D color histogram'))&&...
                (any(inData<obj.YLimits(1))||any(inData>obj.YLimits(2)))
                warning(message('shared_comm_msblks_serdes:EyeDiagramVisual:InputOutsideYLims'));
            end



            offset=max(0,obj.pMeasDelaySamples-obj.pSampleCount);



            obj.pFramework.Visual.HistogramBuffer.updateHistograms(obj.pMeasDelaySamples,inData(1+offset:end));


            obj.pSampleCount=obj.pSampleCount+length(inData);


            update(obj.pSource,inData);
        end

        function resetImpl(this)
            resetImpl@matlabshared.scopes.UnifiedSystemScope(this);

            this.pFramework.Visual.resetHistograms();
        end

        function S=saveObjectImpl(obj)
            S=saveObjectImpl@matlabshared.scopes.UnifiedSystemScope(obj);
            S.ShowImaginaryEye=obj.ShowImaginaryEye;
        end

        function c=cloneImpl(obj)
            c=cloneImpl@matlabshared.scopes.UnifiedSystemScope(obj);
            c.ShowImaginaryEye=obj.ShowImaginaryEye;
        end

        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlabshared.scopes.UnifiedSystemScope(obj,s,wasLocked);
            obj.ShowImaginaryEye=s.ShowImaginaryEye;
            setupDisplay(obj.pFramework.Visual.Plotter);
            loadLineProperties(obj.pFramework.Visual);
        end

        function hScopeCfg=getScopeCfg(~)
            hScopeCfg=comm.scopes.EyeDiagramSystemObjectCfg;
        end

        function num=getNumInputsImpl(this)%#ok<MANU>
            num=1;
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case{'TracesToDisplay','ColorFading'}
                flag=~strcmp(obj.DisplayMode,'Line plot');
            case{'OversamplingMethod','ColorScale'}
                flag=~strcmp(obj.DisplayMode,'2D color histogram');
            case{'ShowBathtub','DecisionBoundary','EyeLevelBoundaries',...
                'RiseFallThresholds','Hysteresis','BERThreshold','MeasurementDelay'}
                flag=~obj.EnableMeasurements;
            case 'ShowImaginaryEye'
                flag=obj.EnableMeasurements;
            case 'BathtubBER'
                flag=~(obj.EnableMeasurements&&(~strcmp(obj.ShowBathtub,'None')));
            case{'OverlayHistogram'}
                flag=~(obj.EnableMeasurements&&strcmp(obj.DisplayMode,'2D color histogram'));
            end
        end
    end

    methods(Static,Hidden,Access=protected)

        function groups=getPropertyGroupsImpl()

            main=matlab.system.display.Section(...
            'TitleSource','Auto',...
            'PropertyList',{'Name'});

            mainGroup=matlab.system.display.SectionGroup(...
            'TitleSource','Auto',...
            'Sections',main);

            traceSection=matlab.system.display.Section(...
            'PropertyList',{'SampleRate','SamplesPerSymbol','SampleOffset','SymbolsPerTrace','TracesToDisplay'});

            traceGroup=matlab.system.display.SectionGroup(...
            'Title',getMsgString('TraceTitle'),...
            'Sections',traceSection);
            traceGroup.IncludeInShortDisplay=true;

            displaySection=matlab.system.display.Section(...
            'PropertyList',{'DisplayMode','EnableMeasurements','ShowBathtub','OverlayHistogram','ColorFading','ShowImaginaryEye','YLimits','ShowGrid','Position'});

            displayGroup=matlab.system.display.SectionGroup(...
            'Title',getMsgString('DisplayTitle'),...
            'Sections',displaySection);
            displayGroup.IncludeInShortDisplay=true;

            measSettingsSection=matlab.system.display.Section(...
            'PropertyList',{'DecisionBoundary','EyeLevelBoundaries','RiseFallThresholds','Hysteresis','BERThreshold','BathtubBER','MeasurementDelay'});

            measSettingsGroup=matlab.system.display.SectionGroup(...
            'Title',getMsgString('MeasurementTitle'),...
            'Sections',measSettingsSection);

            hist2DSection=matlab.system.display.Section(...
            'PropertyList',{'OversamplingMethod','ColorScale'});

            hist2DGroup=matlab.system.display.SectionGroup(...
            'Title',getMsgString('DisplayModeHistogram'),...
            'Sections',hist2DSection);

            groups=[mainGroup,traceGroup,displayGroup,hist2DGroup,measSettingsGroup];
        end

    end

    methods(Hidden)
        function st=getInputSampleTime(obj)


            dims=obj.pSource.getMaxDimensions();
            st=dims(1)/obj.SampleRate;
        end

        function value=getWithThrowAsCaller(this,propname)
            try
                value=getVisualProperty(this,propname,true);
            catch
                me.throwAsCaller;
            end
        end
        function[success,errMessage,licenseType]=checkLicense(~,checkoutFlag)









            success=false;
            licenseType='';

            productCOMM='Communications Toolbox';
            productSERDES='SerDes Toolbox';

            failedLicenseTypeCount=0;
            failedLicenseTypes=[];

            if~isempty(ver('comm'))&&builtin('license','test','Communication_Toolbox')

                licenseType='Communication_Toolbox';
                success=true;
                errMessage=[];
                if~checkoutFlag
                    return;
                end
                [success,~]=builtin('license','checkout',licenseType);
                if success
                    return;
                end
                failedLicenseTypeCount=failedLicenseTypeCount+1;
                failedLicenseTypes{failedLicenseTypeCount}=productCOMM;
            end

            if~isempty(ver('serdes'))&&builtin('license','test','SerDes_Toolbox')

                licenseType='SerDes_Toolbox';
                success=true;
                errMessage=[];
                if~checkoutFlag
                    return;
                end
                [success,~]=builtin('license','checkout',licenseType);
                if success
                    return;
                end
                failedLicenseTypeCount=failedLicenseTypeCount+1;
                failedLicenseTypes{failedLicenseTypeCount}=productSERDES;
            end

            switch failedLicenseTypeCount
            case 1
                errMessage=message('shared_comm_msblks_serdes:EyeDiagramBlock:LicenseFailed1',...
                failedLicenseTypes{1});
            case 2
                errMessage=message('shared_comm_msblks_serdes:EyeDiagramBlock:LicenseFailed2',...
                failedLicenseTypes{1},failedLicenseTypes{2});
            otherwise
                errMessage=message('shared_comm_msblks_serdes:EyeDiagramBlock:LicenseFailed2',...
                productCOMM,productSERDES);
            end

        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commsink2/Eye Diagram';
        end
    end

end

function str=getMsgString(strID)
    str=getString(message(['shared_comm_msblks_serdes:EyeDiagramVisual:',strID]));
end



