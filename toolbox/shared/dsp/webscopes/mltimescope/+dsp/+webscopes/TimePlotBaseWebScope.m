classdef TimePlotBaseWebScope<dsp.webscopes.internal.BaseWebScope&...
    dsp.webscopes.mixin.TimeMeasurementsConfigurable




    properties(Dependent)









        SampleRate{mustBeNumeric,mustBeFinite,mustBePositive};



















        TimeSpanSource;












        TimeSpan;








        TimeSpanOverrunAction;




        PlotType;












        AxesScaling;





        LayoutDimensions;





        TimeUnits;














        TimeDisplayOffset;








        TimeAxisLabels;








        MaximizeAxes;



BufferLength








ChannelNames








        ActiveDisplay;




        PlotAsMagnitudePhase;




        Title;









        YLabel;








        YLimits;










        ShowLegend;




        ShowGrid;
    end

    properties(Constant,Hidden)
        TimeSpanSourceSet={'auto','property'};
        TimeSpanOverrunActionSet={'wrap','scroll'};
        PlotTypeSet={'line','stairs','stem'};
        TimeAxisLabelsSet={'all','none','bottom'};
        MaximizeAxesSet={'auto','on','off'};
        TimeUnitsSet={'none','seconds','metric'};
        AxesScalingSet={'auto','updates','manual','onceatstop'};
    end



    methods

        function this=TimePlotBaseWebScope(varargin)



            this@dsp.webscopes.internal.BaseWebScope(...
            'TimeBased',true,...
            'Name','Time Scope',...
            'Tag','TimeScope',...
            'Position',utils.getDefaultWebWindowPosition([800,500]));

            this.setProperties(varargin{:});

            this.NeedsTimedBuffer=false;

            addTimeMeasurementsConfiguration(this);
        end


        function set.SampleRate(this,value)
            this.validatePropertiesOnSet('SampleRate');
            validateattributes(value,...
            {'numeric'},{'positive','finite'},'','SampleRate');
            this.SampleTime=1./value;
            setPropertyValue(this,'SampleRate',value);
        end
        function value=get.SampleRate(this)
            value=getPropertyValue(this,'SampleRate');
        end


        function set.TimeSpanSource(this,value)
            this.validatePropertiesOnSet('TimeSpanSource');
            value=validateEnum(this,'TimeSpanSource',value);
            setPropertyValueAndNotify(this,'TimeSpanSource',value);
        end
        function value=get.TimeSpanSource(this)
            value=getPropertyValue(this,'TimeSpanSource');
        end


        function set.TimeSpan(this,value)

            this.TimeSpanSource='property';
            this.validatePropertiesOnSet('TimeSpan');
            validateattributes(value,...
            {'numeric'},{'real','finite','positive','scalar'},'','TimeSpan');
            setPropertyValueAndNotify(this,'TimeSpan',value);
        end
        function value=get.TimeSpan(this)
            value=getPropertyValue(this,'TimeSpan');
        end


        function set.TimeSpanOverrunAction(this,value)
            value=validateEnum(this,'TimeSpanOverrunAction',value);
            setPropertyValueAndNotify(this,'TimeSpanOverrunAction',value);
        end
        function value=get.TimeSpanOverrunAction(this)
            value=getPropertyValue(this,'TimeSpanOverrunAction');
        end


        function set.PlotType(this,value)
            value=validateEnum(this,'PlotType',value);
            setPropertyValueAndNotify(this,'PlotType',value);
        end
        function value=get.PlotType(this)
            value=getPropertyValue(this,'PlotType');
        end


        function set.AxesScaling(this,value)
            value=validateEnum(this,'AxesScaling',value);
            setPropertyValue(this,'AxesScaling',value);
        end
        function value=get.AxesScaling(this)
            value=getPropertyValue(this,'AxesScaling');
        end


        function set.LayoutDimensions(this,value)
            import dsp.webscopes.*;
            if(~all(isnumeric(value))||numel(value)~=2||~all(floor(value)>0)||~all(floor(value)<=4))
                TimePlotBaseWebScope.localError('invalidLayoutDimensions');
            end
            setPropertyValueAndNotify(this,'LayoutDimensions',value);
        end
        function value=get.LayoutDimensions(this)
            value=getPropertyValue(this,'LayoutDimensions');
        end


        function set.BufferLength(this,value)
            this.validatePropertiesOnSet('BufferLength');
            validateattributes(value,...
            {'numeric'},{'integer','positive','real','finite','scalar'},'','BufferLength');
            setPropertyValue(this,'BufferLength',value);
        end
        function value=get.BufferLength(this)
            value=getPropertyValue(this,'BufferLength');
        end


        function set.TimeUnits(this,value)
            value=validateEnum(this,'TimeUnits',value);
            setPropertyValueAndNotify(this,'TimeUnits',value);
        end
        function value=get.TimeUnits(this)
            value=getPropertyValue(this,'TimeUnits');
        end


        function set.TimeDisplayOffset(this,value)
            validateattributes(value,...
            {'numeric'},{'real','finite'},'','TimeDisplayOffset');
            this.Offset=value;
            setPropertyValueAndNotify(this,'TimeDisplayOffset',value);
        end
        function value=get.TimeDisplayOffset(this)
            value=getPropertyValue(this,'TimeDisplayOffset');
        end


        function set.TimeAxisLabels(this,value)
            value=validateEnum(this,'TimeAxisLabels',value);
            setPropertyValueAndNotify(this,'TimeAxisLabels',value);
        end
        function value=get.TimeAxisLabels(this)
            value=getPropertyValue(this,'TimeAxisLabels');
        end


        function set.MaximizeAxes(this,value)
            value=validateEnum(this,'MaximizeAxes',value);
            setPropertyValueAndNotify(this,'MaximizeAxes',value);
        end
        function value=get.MaximizeAxes(this)
            value=getPropertyValue(this,'MaximizeAxes');
        end


        function set.ActiveDisplay(this,value)
            import dsp.webscopes.*;
            if(~isnumeric(value)||~isscalar(value)||isnan(value)||(floor(value)<=0))||...
                (floor(value)>prod(this.LayoutDimensions))
                TimePlotBaseWebScope.localError('invalidActiveDisplay')
            end
            setPropertyValueAndNotify(this,'ActiveDisplay',value);
        end
        function value=get.ActiveDisplay(this)
            value=getPropertyValue(this,'ActiveDisplay');
        end


        function set.Title(this,value)
            import dsp.webscopes.*;

            value=convertStringsToChars(value);

            if~ischar(value)
                TimePlotBaseWebScope.localError('invalidTitle');
            end
            setPropertyValueAndNotify(this,'Title',value);
        end
        function value=get.Title(this)
            value=getPropertyValue(this,'Title');
            value=convertStringsToChars(value(1,this.ActiveDisplay));
        end


        function set.YLabel(this,value)
            import dsp.webscopes.*;
            this.validatePropertiesOnSet('YLabel');

            value=convertStringsToChars(value);

            if~ischar(value)
                TimePlotBaseWebScope.localError('invalidYLabel');
            end
            setPropertyValueAndNotify(this,'YLabel',value);
        end
        function value=get.YLabel(this)
            value=getPropertyValue(this,'YLabel');
            value=convertStringsToChars(value(1,this.ActiveDisplay));
        end


        function set.YLimits(this,value)
            import dsp.webscopes.*;
            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)
                TimePlotBaseWebScope.localError('invalidYLimits');
            end
            setPropertyValue(this,'AxesScaling','manual');
            setPropertyValueAndNotify(this,'YLimits',value);
        end
        function value=get.YLimits(this)
            value=getPropertyValue(this,'YLimits');
            value=value(this.ActiveDisplay,:);
        end


        function set.ShowLegend(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowLegend');
            setPropertyValueAndNotify(this,'ShowLegend',logical(value));
        end
        function value=get.ShowLegend(this)
            value=getPropertyValue(this,'ShowLegend');
            value=value(1,this.ActiveDisplay);
        end


        function set.ChannelNames(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'string','cell'},{'vector'},'','ChannelNames');

            if(~isempty(value)&&(~isvector(value)||~iscellstr(cellstr(value))))
                TimePlotBaseWebScope.localError('invalidChannelNames');
            end
            value=cellstr(value);
            if this.ShowLegend
                setPropertyValueAndNotify(this,'ChannelNames',value);
            else
                setPropertyValue(this,'ChannelNames',value);
            end
        end
        function value=get.ChannelNames(this)
            value=getPropertyValue(this,'ChannelNames');
        end


        function set.ShowGrid(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowGrid');
            setPropertyValueAndNotify(this,'ShowGrid',logical(value));
        end
        function value=get.ShowGrid(this)
            value=getPropertyValue(this,'ShowGrid');
            value=value(1,this.ActiveDisplay);
        end


        function set.PlotAsMagnitudePhase(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','PlotAsMagnitudePhase');
            setPropertyValueAndNotify(this,'PlotAsMagnitudePhase',logical(value));
        end
        function value=get.PlotAsMagnitudePhase(this)
            value=getPropertyValue(this,'PlotAsMagnitudePhase');
            value=value(1,this.ActiveDisplay);
        end
    end



    methods(Access=protected)


        function validatePropertiesOnSet(this,propName)
            import dsp.webscopes.*;
            validatePropertiesOnSet@dsp.webscopes.internal.BaseWebScope(this,propName);
            switch propName
            case{'SampleRate','BufferLength'}
                if(this.isLocked)
                    TimePlotBaseWebScope.localError('propertySetWhenLocked',propName);
                end
            otherwise
                if isInactiveProperty(this,propName)&&~strcmpi(propName,'TimeSpan')&&this.WarnOnInactivePropertySet

                    TimePlotBaseWebScope.localWarning('nonRelevantProperty',propName);
                end
            end
        end


        function validatePropertiesOnSetup(this)
            import dsp.webscopes.*;
            validatePropertiesOnSetup@dsp.webscopes.internal.BaseWebScope(this);


            numInputPorts=this.NumInputs;
            if numel(this.SampleRate)~=1&&...
                numel(this.SampleRate)~=numInputPorts
                TimePlotBaseWebScope.localError('invalidNumOfSampleRates');
            end


            if numel(this.TimeDisplayOffset)~=1&&...
                numel(this.TimeDisplayOffset)~=numInputPorts
                TimePlotBaseWebScope.localError('invalidNumOfTimeDisplayOffsets');
            end
        end

        function isTimeBased=isTimeBased(~)
            isTimeBased=true;
        end


        function h=getMessageHandler(~)
            h=dsp.webscopes.internal.TimePlotWebScopeMessageHandler;
        end


        function value=getDataProcessingStrategy(~)
            value='dsp_webscope_time_data_strategy';
        end

        function optionList=addFilterProperties(this,optionList)
            magPhaseData=false(1,this.NumInputPorts);
            flag=getPropertyValue(this.Specification,'PlotAsMagnitudePhase');
            for sigIdx=1:this.NumInputPorts
                magPhaseData(1,sigIdx)=flag(1,this.Specification.signalIdxToDisplayIdx(sigIdx));
            end

            optionList.magPhaseData=magPhaseData;



            optionList.autoSpan=strcmpi(this.TimeSpanSource,'Auto');
            optionList.customSpan=this.TimeSpan;
        end

        function optionList=addStreamingOptions(~,optionList)


            optionList.bufferLength=Inf;
        end

        function groups=getPropertyGroups(this)

            mainProps=getValidDisplayProperties(this,{'SampleRate',...
            'TimeSpanSource',...
            'TimeSpan',...
            'TimeSpanOverrunAction',...
            'PlotType',...
            'AxesScaling',...
            'AxesScalingNumUpdates'});

            groups=matlab.mixin.util.PropertyGroup(mainProps,'');

            if(this.ShowAllProperties)


                advancedProps=getValidDisplayProperties(this,{...
                'LayoutDimensions',...
                'TimeUnits',...
                'TimeDisplayOffset',...
                'TimeAxisLabels',...
                'MaximizeAxes',...
                'BufferLength'});

                measurementsProps={'MeasurementChannel',...
                'BilevelMeasurements',...
                'CursorMeasurements',...
                'PeakFinder',...
                'SignalStatistics',...
                'Trigger'};

                visualizationProps=getValidDisplayProperties(this,{...
                'Name',...
                'Position',...
                'ChannelNames',...
                'ActiveDisplay',...
                'PlotAsMagnitudePhase',...
                'Title',...
                'YLabel',...
                'YLimits',...
                'ShowLegend',...
                'ShowGrid'});

                advancedGroupTitle=getString(message('shared_dspwebscopes:dspwebscopes:advancedProperties'));
                measurementsGroupTitle=getString(message('shared_dspwebscopes:dspwebscopes:measurementsProperties'));
                visualizationGroupTitle=getString(message('shared_dspwebscopes:dspwebscopes:visualizationProperties'));

                groups=[groups,...
                matlab.mixin.util.PropertyGroup(advancedProps,advancedGroupTitle),...
                matlab.mixin.util.PropertyGroup(measurementsProps,measurementsGroupTitle),...
                matlab.mixin.util.PropertyGroup(visualizationProps,visualizationGroupTitle)];
            end
        end

        function updateSampleTimeAndOffset(this)



            if numel(this.SampleRate)==1&&this.NumInputPorts>1
                this.SampleTime=ones(1,this.NumInputPorts).*(1/this.SampleRate);
            else
                this.SampleTime=1./this.SampleRate;
            end

            if numel(this.TimeDisplayOffset)==1&&this.NumInputPorts>1
                this.Offset=ones(1,this.NumInputPorts).*this.TimeDisplayOffset;
            else
                this.Offset=this.TimeDisplayOffset;
            end
        end

        function S=saveobj(this)
            S=saveobj@dsp.webscopes.internal.BaseWebScope(this);
            S.BilevelMeasurements=this.Specification.BilevelMeasurements.toStruct();
            S.CursorMeasurements=this.Specification.CursorMeasurements.toStruct();
            S.PeakFinder=this.Specification.PeakFinder.toStruct();
            S.SignalStatistics=this.Specification.SignalStatistics.toStruct();
            S.Trigger=this.Specification.Trigger.toStruct();
        end
    end



    methods(Access=public,Hidden)

        function p=getValueOnlyProperties(~)
            p={'NumInputPorts','SampleRate'};
        end

        function sac=constructScopeApplicationComponent(this,container)
            sac=matlabshared.scopes.container.TimeScopeComponent(container,this);
        end


        function spec=getScopeSpecification(this)
            spec=this.Specification;
            if isempty(spec)
                spec=dsp.webscopes.internal.TimePlotWebScopeSpecification();
            end
        end
    end



    methods(Static,Hidden)

        function this=loadobj(S_load)

            dsp.webscopes.TimePlotBaseWebScope.licenseCheckout(true);
            import dsp.webscopes.internal.*;
            if(BaseWebScope.isSavedAsUnifiedScope(S_load))



                S.class=BaseWebScope.getUnifiedScopeClassName(S_load);
                cfg=BaseWebScope.getUnifiedScopeConfiguration(S_load);
                scopeCfg=cfg.ScopeConfig;
                propNames=intersect(cfg.ScopeConfig.PropertyNames,...
                dsp.webscopes.TimePlotBaseWebScope.getValidPropertyNames);


                for idx=1:numel(propNames)
                    propName=propNames{idx};
                    if any(strcmpi(propName,{'SampleRate','TimeDisplayOffset'}))
                        S.Specification.(propNames{idx})=str2double(scopeCfg.getValue(propNames{idx}));
                    else
                        S.Specification.(propNames{idx})=scopeCfg.getValue(propNames{idx});
                    end
                end

                S.Specification.NumInputPorts=cfg.NumInputPorts;

                S.Visible=utils.onOffToLogical(cfg.Visible);

                dispCfg=cfg.DispConfig{1};
                if(isfield(dispCfg,'XLabel'))
                    S.Specification.XLabel=dispCfg.XLabel;
                end
                if(isfield(dispCfg,'YLabelReal'))
                    S.Specification.YLabel=dispCfg.YLabelReal;
                end
                if(isfield(dispCfg,'Title'))
                    S.Specification.Title=dispCfg.Title;
                end
                if(isfield(dispCfg,'LegendVisibility'))
                    S.Specification.ShowLegend=utils.onOffToLogical(dispCfg.LegendVisibility);
                end
                if(isfield(dispCfg,'PlotMagPhase'))
                    S.Specification.PlotAsMagnitudePhase=dispCfg.PlotMagPhase;
                end
                if(isfield(dispCfg,'LineNames'))
                    S.Specification.ChannelNames=dispCfg.LineNames;
                end
                if(isfield(dispCfg,'XGrid')&&isfield(dispCfg,'YGrid'))
                    S.Specification.ShowGrid=dispCfg.XGrid&&dispCfg.YGrid;
                end
                if(isfield(dispCfg,'MinYLimReal')&&isfield(dispCfg,'MaxYLimReal'))
                    S.Specification.YLimits=[str2double(dispCfg.MinYLimReal),str2double(dispCfg.MaxYLimReal)];
                end

                S.MessageHandler.GraphicalSettings=[];
                S.MessageHandler.ClientSettings=[];
                S.MessageHandler.CallMethodCache={};
                S.MessageHandler.InputIds=cellstr(matlab.lang.internal.uuid(1,S.Specification.NumInputPorts));
                S.MessageHandler.GraphicalSettingsStale=false;
                S.MessageHandler.ClientSettingsStale=false;
            else

                S=S_load;
            end

            this=loadobj@dsp.webscopes.internal.BaseWebScope(S);
            if(isfield(S,'BilevelMeasurements'))
                this.Specification.BilevelMeasurements.fromStruct(S.BilevelMeasurements);
            end
            if(isfield(S,'CursorMeasurements'))
                this.Specification.CursorMeasurements.fromStruct(S.CursorMeasurements);
            end
            if(isfield(S,'PeakFinder'))
                this.Specification.PeakFinder.fromStruct(S.PeakFinder);
            end
            if(isfield(S,'SignalStatistics'))
                this.Specification.SignalStatistics.fromStruct(S.SignalStatistics);
            end
            if(isfield(S,'Trigger'))
                this.Specification.Trigger.fromStruct(S.Trigger);
            end
            if isfield(S,'ScopeLocked')
                this.ScopeLocked=S.ScopeLocked;
            end

            if(S.Visible)
                this.show();
            end
        end

        function fevalHandler(action,clientID,varargin)
            import dsp.webscopes.internal.*;
            BaseWebScope.fevalHandler(action,clientID,varargin{:});
            switch action
            case 'showHelp'
                productName=dsp.webscopes.TimePlotBaseWebScope.licenseCheckout(false);
                mapFileLocation=fullfile(docroot,productName,'helptargets.map');
                helpview(mapFileLocation,varargin{1});
            end
        end

        function propNames=getValidPropertyNames(~)


            propNames=properties('dsp.webscopes.TimePlotBaseWebScope');


            propNames(ismember(propNames,{'BilevelMeasurements','CursorMeasurements',...
            'PeakFinder','SignalStatistics','Trigger'}))=[];
        end

        function a=getAlternateBlock
            a='dspsnks4/Time Scope';
        end

        function localError(ID,varargin)
            id=['shared_dspwebscopes:timescope:',ID];
            ME=MException(message(id,varargin{:}));
            throwAsCaller(ME);
        end

        function localWarning(ID,varargin)
            id=['shared_dspwebscopes:timescope:',ID];
            warning(message(id,varargin{:}));
        end

        function varargout=licenseCheckout(checkoutFlag)






            import dsp.webscopes.*;

            errMessageID='licenseFailed';

            products={'Signal_Blocks','Navigation_Toolbox',...
            'Sensor_Fusion_and_Tracking'};


            productNames={'dsp','nav','fusion'};

            [success,productName]=...
            TimePlotBaseWebScope.checkoutFirstAvailableLicense(...
            products,productNames,checkoutFlag);

            if~success
                TimePlotBaseWebScope.localError(errMessageID,'timescope');
            end
            if nargout==1
                varargout{1}=productName;
            end
        end

        function[success,productName]=checkoutFirstAvailableLicense(productLicenses,productNames,checkout)

            success=true;
            productName='';

            for index=1:numel(productLicenses)

                productLicense=productLicenses{index};

                productName=productNames{index};


                if builtin('license','test',productLicense)&&...
                    ~isempty(builtin('license','inuse',productLicense))&&...
                    ~isempty(ver(productName))


                    if(checkout)
                        [avail,~]=builtin('license','checkout',productLicense);
                        if avail


                            return;
                        end
                    end
                    return;
                end
            end

            for index=1:numel(productLicenses)

                productLicense=productLicenses{index};

                productName=productNames{index};

                if builtin('license','test',productLicense)&&~isempty(ver(productName))
                    if(checkout)

                        [checkAvail,~]=builtin('license','checkout',productLicense);
                        if checkAvail
                            return;
                        end
                    end
                end
            end
            success=false;
        end
    end
end
