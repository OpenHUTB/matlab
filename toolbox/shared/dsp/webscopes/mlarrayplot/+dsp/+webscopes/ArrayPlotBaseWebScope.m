classdef(Hidden=true)ArrayPlotBaseWebScope<dsp.webscopes.internal.BaseWebScope




    properties(Dependent)








        XDataMode;





        SampleIncrement;










        CustomXData;







        XOffset;





        XScale;



        YScale;



        PlotType;












        AxesScaling;








        MaximizeAxes;



        PlotAsMagnitudePhase;



        Title;



        XLabel;



        YLabel;



        YLimits;





        ShowLegend;








        ChannelNames;



        ShowGrid;
    end

    properties(Dependent,Hidden,AbortSet)





        EnablePlotMagPhase;





        EnableGenerateScript;
    end

    properties(Constant,Hidden)
        XDataModeSet={'Sample increment and X-offset','Custom'};
        XScaleSet={'Linear','Log'};
        YScaleSet={'Linear','Log'};
        PlotTypeSet={'Stem','Line','Stairs'};
        AxesScalingSet={'Auto','Updates','Manual','OnceAtStop'};
        MaximizeAxesSet={'Auto','On','Off'};
        MaskStatusSet={'Pass','Fail','None'};
    end



    methods


        function this=ArrayPlotBaseWebScope(varargin)


            this@dsp.webscopes.internal.BaseWebScope(...
            'TimeBased',false,...
            'Name','Array Plot',...
            'Position',utils.getDefaultWebWindowPosition([800,500]),...
            'PlotType','Stem',...
            'Tag','ArrayPlot',...
            varargin{:});
        end


        function set.XDataMode(this,value)
            import dsp.webscopes.*;
            this.validatePropertiesOnSet('XDataMode');
            value=validateEnum(this,'XDataMode',value);

            if strcmp(this.XScale,'Log')
                if strcmp(value,'Sample increment and X-offset')&&this.XOffset<0
                    ArrayPlotBaseWebScope.localError('invalidXScaleXOffsetCombinationProperty');
                elseif strcmp(value,'Custom')&&~isempty(this.CustomXData)&&any(this.CustomXData<0)
                    ArrayPlotBaseWebScope.localError('invalidXScaleCustomXDataCombinationProperty');
                end
            end
            setPropertyValueAndNotify(this,'XDataMode',value);
        end
        function value=get.XDataMode(this)
            value=getPropertyValue(this,'XDataMode');
        end


        function set.SampleIncrement(this,value)
            this.validatePropertiesOnSet('SampleIncrement');
            validateattributes(value,...
            {'numeric'},{'positive','finite','scalar'},'','SampleIncrement');
            this.SampleTime=value.*ones(1,this.NumInputPorts);
            setPropertyValueAndNotify(this,'SampleIncrement',value);
        end
        function value=get.SampleIncrement(this)
            value=getPropertyValue(this,'SampleIncrement');
        end


        function set.XOffset(this,value)
            import dsp.webscopes.*;
            this.validatePropertiesOnSet('XOffset');
            validateattributes(value,...
            {'numeric'},{'real','finite','scalar'},'','XOffset');
            if strcmp(this.XScale,'Log')&&value<0
                ArrayPlotBaseWebScope.localError('invalidXOffset');
            end
            this.Offset=value.*ones(1,this.NumInputPorts);
            setPropertyValueAndNotify(this,'XOffset',value);
        end
        function value=get.XOffset(this)
            value=getPropertyValue(this,'XOffset');
        end


        function set.CustomXData(this,value)
            import dsp.webscopes.*;
            this.validatePropertiesOnSet('CustomXData');
            if~isempty(value)
                validateattributes(value,{'numeric'},...
                {'vector','real','finite','increasing'},'','CustomXData');
                if strcmp(this.XScale,'Log')&&any(value<0)
                    ArrayPlotBaseWebScope.localError('invalidCustomXDataWithLogScale');
                end
            end
            setPropertyValueAndNotify(this,'CustomXData',value);
        end
        function value=get.CustomXData(this)
            value=getPropertyValue(this,'CustomXData');
        end


        function set.XScale(this,value)
            import dsp.webscopes.*;
            value=validateEnum(this,'XScale',value);
            if strcmp(value,'Log')
                if strcmp(this.XDataMode,'Sample increment and X-offset')&&this.XOffset<0
                    ArrayPlotBaseWebScope.localError('invalidXScale');
                elseif strcmp(this.XDataMode,'Custom')&&~isempty(this.CustomXData)&&any(this.CustomXData<0)
                    ArrayPlotBaseWebScope.localError('invalidXScaleWithCustomXData');
                end
            end
            setPropertyValueAndNotify(this,'XScale',value);
        end
        function value=get.XScale(this)
            value=getPropertyValue(this,'XScale');
        end


        function set.YScale(this,value)
            value=validateEnum(this,'YScale',value);
            setPropertyValueAndNotify(this,'YScale',value);
        end
        function value=get.YScale(this)
            value=getPropertyValue(this,'YScale');
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


        function set.MaximizeAxes(this,value)
            value=validateEnum(this,'MaximizeAxes',value);
            setPropertyValueAndNotify(this,'MaximizeAxes',value);
        end
        function value=get.MaximizeAxes(this)
            value=getPropertyValue(this,'MaximizeAxes');
        end


        function set.PlotAsMagnitudePhase(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','PlotAsMagnitudePhase');
            setPropertyValueAndNotify(this,'PlotAsMagnitudePhase',logical(value));
        end
        function value=get.PlotAsMagnitudePhase(this)
            value=getPropertyValue(this,'PlotAsMagnitudePhase');
        end


        function set.Title(this,value)

            value=convertStringsToChars(value);

            validateattributes(value,{'string','char'},{'2d'},'','Title');
            setPropertyValueAndNotify(this,'Title',value);
        end
        function value=get.Title(this)
            value=getPropertyValue(this,'Title');
        end


        function set.XLabel(this,value)

            value=convertStringsToChars(value);

            validateattributes(value,{'string','char'},{'2d'},'','XLabel');
            setPropertyValueAndNotify(this,'XLabel',value);
        end
        function value=get.XLabel(this)
            value=getPropertyValue(this,'XLabel');
        end


        function set.YLabel(this,value)
            this.validatePropertiesOnSet('YLabel');

            value=convertStringsToChars(value);

            validateattributes(value,{'string','char'},{'2d'},'','YLabel');
            setPropertyValueAndNotify(this,'YLabel',value);
        end
        function value=get.YLabel(this)
            value=getPropertyValue(this,'YLabel');
        end


        function set.YLimits(this,value)
            import dsp.webscopes.*;
            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)
                ArrayPlotBaseWebScope.localError('invalidYLimits');
            end
            setPropertyValue(this,'AxesScaling','Manual');
            setPropertyValueAndNotify(this,'YLimits',value);
        end
        function value=get.YLimits(this)
            value=getPropertyValue(this,'YLimits');
        end


        function set.ShowGrid(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowGrid');
            setPropertyValueAndNotify(this,'ShowGrid',logical(value));
        end
        function value=get.ShowGrid(this)
            value=getPropertyValue(this,'ShowGrid');
        end


        function set.ShowLegend(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowLegend');
            setPropertyValueAndNotify(this,'ShowLegend',logical(value));
        end
        function value=get.ShowLegend(this)
            value=getPropertyValue(this,'ShowLegend');
        end


        function set.ChannelNames(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'string','cell'},{'vector'},'','ChannelNames');

            if(~isempty(value)&&(~isvector(value)||~iscellstr(cellstr(value))))
                ArrayPlotBaseWebScope.localError('invalidChannelNames');
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


        function set.EnablePlotMagPhase(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','EnablePlotMagPhase');
            setPropertyValue(this,'EnablePlotMagPhase',logical(value));
        end
        function value=get.EnablePlotMagPhase(this)
            value=getPropertyValue(this,'EnablePlotMagPhase');
        end


        function set.EnableGenerateScript(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','EnableGenerateScript');
            setPropertyValue(this,'EnableGenerateScript',logical(value));
        end
        function value=get.EnableGenerateScript(this)
            value=getPropertyValue(this,'EnableGenerateScript');
        end
    end



    methods(Access=protected)


        function h=getMessageHandler(~)
            h=dsp.webscopes.internal.ArrayPlotWebScopeMessageHandler;
        end


        function validatePropertiesOnSet(this,propName)
            import dsp.webscopes.*;
            validatePropertiesOnSet@dsp.webscopes.internal.BaseWebScope(this,propName);
            switch propName
            case 'XDataMode'
                if(this.isLocked)
                    ArrayPlotBaseWebScope.localError('propertySetWhenLocked',propName);
                end
            otherwise
                if isInactiveProperty(this,propName)&&this.WarnOnInactivePropertySet
                    ArrayPlotBaseWebScope.localWarning('nonRelevantProperty',propName);
                end
            end
        end


        function value=getDataProcessingStrategy(~)
            value='dsp_webscope_frame_data_strategy';
        end

        function optionList=addFilterProperties(this,optionList)
            optionList.magPhaseData=logical(...
            this.PlotAsMagnitudePhase.*ones(1,this.NumInputPorts));
            optionList.autoSpan=~strcmpi(this.XDataMode,'Custom');
            customSpan=10;
            if(~isempty(this.CustomXData))
                customSpan=this.CustomXData(end);
            end
            optionList.customSpan=customSpan;


        end

        function optionList=addStreamingOptions(~,optionList)


            optionList.bufferLength=Inf;
        end

        function groups=getPropertyGroups(this)

            mainProps=getValidDisplayProperties(this,{'NumInputPorts',...
            'XDataMode',...
            'CustomXData',...
            'SampleIncrement',...
            'XOffset',...
            'XScale',...
            'YScale',...
            'PlotType',...
            'AxesScaling',...
            'AxesScalingNumUpdates'});
            groups=matlab.mixin.util.PropertyGroup(mainProps,'');

            if(this.ShowAllProperties)


                measurementsProps={'MeasurementChannel',...
                'CursorMeasurements',...
                'PeakFinder',...
                'SignalStatistics'};

                visualizationProps=getValidDisplayProperties(this,{'Name',...
                'Position',...
                'MaximizeAxes',...
                'PlotAsMagnitudePhase',...
                'Title',...
                'XLabel',...
                'YLabel',...
                'YLimits',...
                'ShowLegend',...
                'ChannelNames',...
                'ShowGrid'});
                groups=[groups,...
                matlab.mixin.util.PropertyGroup(measurementsProps,...
                getString(message('shared_dspwebscopes:dspwebscopes:measurementsProperties'))),...
                matlab.mixin.util.PropertyGroup(visualizationProps,...
                getString(message('shared_dspwebscopes:dspwebscopes:visualizationProperties')))];
            end
        end

        function updateSampleTimeAndOffset(this)


            this.SampleTime=this.SampleIncrement.*ones(1,this.NumInputPorts);
            this.Offset=this.XOffset.*ones(1,this.NumInputPorts);
        end

        function S=saveobj(this)
            S=saveobj@dsp.webscopes.internal.BaseWebScope(this);
            S.CursorMeasurements=this.Specification.CursorMeasurements.toStruct();
            S.PeakFinder=this.Specification.PeakFinder.toStruct();
            S.SignalStatistics=this.Specification.SignalStatistics.toStruct();
        end
    end



    methods(Static,Hidden)


        function this=loadobj(S_load)
            import dsp.webscopes.internal.*;
            if(BaseWebScope.isSavedAsUnifiedScope(S_load))



                S.class=BaseWebScope.getUnifiedScopeClassName(S_load);
                cfg=BaseWebScope.getUnifiedScopeConfiguration(S_load);
                scopeCfg=cfg.ScopeConfig;
                propNames=intersect(cfg.ScopeConfig.PropertyNames,...
                dsp.webscopes.ArrayPlotBaseWebScope.getValidPropertyNames);


                for idx=1:numel(propNames)
                    propName=propNames{idx};
                    if any(strcmpi(propName,{'SampleIncrement','XOffset','CustomXData'}))
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
            if isfield(S,'CursorMeasurements')
                this.Specification.CursorMeasurements.fromStruct(S.CursorMeasurements);
            end
            if isfield(S,'PeakFinder')
                this.Specification.PeakFinder.fromStruct(S.PeakFinder);
            end
            if isfield(S,'SignalStatistics')
                this.Specification.SignalStatistics.fromStruct(S.SignalStatistics);
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
                mapFileLocation=fullfile(docroot,'toolbox','dsp','dsp.map');
                helpview(mapFileLocation,varargin{1});
            end
        end

        function propNames=getValidPropertyNames(~)


            propNames=properties('dsp.webscopes.ArrayPlotBaseWebScope');


            propNames(ismember(propNames,{'CursorMeasurements','PeakFinder','SignalStatistics'}))=[];
        end

        function a=getAlternateBlock
            a='dspsnks4/Array Plot';
        end

        function localError(ID,varargin)
            id=['shared_dspwebscopes:arrayplot:',ID];
            ME=MException(message(id,varargin{:}));
            throwAsCaller(ME);
        end

        function localWarning(ID,varargin)
            id=['shared_dspwebscopes:arrayplot:',ID];
            warning(message(id,varargin{:}));
        end
    end



    methods(Access=public,Hidden)

        function tabs=createToolstripTabs(~,container)
            tabs=container.getTab('matlabshared.scopes.toolstrip.MeasurementsTab');
        end

        function str=getQueryString(this,varargin)


            str=getQueryString@dsp.webscopes.internal.BaseWebScope(this,...
            'EnablePlotMagPhase',utils.logicalToOnOff(this.EnablePlotMagPhase),...
            'EnableGenerateScript',utils.logicalToOnOff(this.EnableGenerateScript),...
            varargin{:});
        end


        function spec=getScopeSpecification(this)
            spec=this.Specification;
            if isempty(spec)
                spec=dsp.webscopes.internal.ArrayPlotWebScopeSpecification();
            end
        end
    end
end
