classdef SpectrumAnalyzerViewController<handle








    methods


        function processSectionEventImpl(this,ev)
            switch ev.EventName
            case 'PropertyChanged'
                spec=this.MessageHandler.Specification;
                propName=ev.PropertyName;
                switch propName
                case{'RBW','FullScale','TimeResolution','TimeSpan'}
                    propValue=getProperty(ev.Source,propName);
                    inactiveControlProp=[propName,'Source'];
                    if strcmpi(propValue,getString(message('shared_dspwebscopes:spectrumanalyzer:RBWAutoText')))||isempty(propValue)||strcmpi(propValue,'auto')
                        spec.(inactiveControlProp)='auto';
                        propValue=spec.(propName);
                    else
                        spec.(inactiveControlProp)='property';
                        propValue=str2num(propValue);%#ok<ST2NM>
                    end
                case{'SpectrumType','SpectrogramType'}
                    spectrumTypeValues={'power','power-density','rms'};
                    powerValue=getProperty(ev.Source,[propName,'Power']);
                    powerDensityValue=getProperty(ev.Source,[propName,'PowerDensity']);
                    rmsValue=getProperty(ev.Source,[propName,'RMS']);
                    propValue=spectrumTypeValues([powerValue,powerDensityValue,rmsValue]);
                    propValue=propValue{1};
                    propName='SpectrumType';
                case 'StartFrequency'
                    propValue=getProperty(ev.Source,propName);
                    if strcmpi(spec.FrequencySpan,'span-and-center-frequency')
                        propName='Span';
                    end
                case 'StopFrequency'
                    propValue=getProperty(ev.Source,propName);
                    if strcmpi(spec.FrequencySpan,'span-and-center-frequency')
                        propName='CenterFrequency';
                    end
                otherwise
                    propValue=getProperty(ev.Source,propName);
                end

                if isempty(propValue)
                    return;
                end
                if isprop(spec,propName)

                    if ischar(propValue)&&ischar(spec.(propName))
                        setPropertyValue(spec,propName,lower(propValue));
                    elseif ischar(propValue)&&isnumeric(spec.(propName))
                        setPropertyValue(spec,propName,str2double(propValue));
                    else
                        setPropertyValue(spec,propName,propValue);
                    end
                else

                    tag=ev.Source.Tag;
                    measObj=[];
                    switch(tag)
                    case 'DataCursors'
                        measObj='CursorMeasurements';
                        if strcmpi(propName,'ShowDataCursors')
                            propName='Enabled';
                        end
                    case 'Distortion'
                        measObj='DistortionMeasurements';
                        if strcmpi(propName,'ShowDistortion')
                            propName='Enabled';
                        end
                        if strcmpi(propName,'DistortionType')
                            propName='Type';
                        end
                        if strcmpi(propName,'LabelHarmonics')
                            propName='LabelValues';
                        end
                    case 'Peaks'
                        measObj='PeakFinder';
                        if strcmpi(propName,'ShowPeaks')
                            propName='Enabled';
                        end
                    end
                    if~isempty(measObj)
                        spec=spec.(measObj);
                        if ischar(propValue)&&ischar(spec.(propName))
                            setPropertyValue(spec,propName,lower(propValue));
                        elseif ischar(propValue)&&isnumeric(spec.(propName))
                            setPropertyValue(spec,propName,str2double(propValue));
                        else
                            setPropertyValue(spec,propName,propValue);
                        end
                    end
                end


                updateToolstripImpl(this,this.Application.CurrentDynamicTabs);
            end
        end




        function updateToolstripImpl(this,tabs)
            msg=getScopeMessageHandler(this);
            if isempty(msg)



                return;
            end
            updateToolstripTabs(this,tabs);
        end


        function updateToolstripTabs(this,tabs)
            for tabIndex=1:numel(tabs)
                tab=tabs(tabIndex);
                sections=tab.Sections;
                sectionNames=fieldnames(sections);

                for sectionIndex=1:numel(sectionNames)
                    section=sections.(sectionNames{sectionIndex});


                    switch(section.Tag)
                    case 'DataCursors'
                        updateDataCursorsWidgets(this,tab,section);
                    case 'Distortion'
                        updateDistortionWidgets(this,tab,section);
                    case 'Peaks'
                        updatePeakFinderWidgets(this,tab,section);
                    otherwise
                        updateToolstripWidgets(this,tab,section);
                    end
                end
            end
        end


        function updateToolstripWidgets(this,~,section)
            widgets=section.Widgets;
            widgetsNames=fieldnames(widgets);
            spec=getScopeMessageHandler(this).Specification;
            for widgetIndex=1:numel(widgetsNames)
                widget=widgets.(widgetsNames{widgetIndex});
                propName=widget.Tag;


                if isprop(spec,propName)

                    inactiveControlProp=propName;
                    switch class(widget)
                    case 'matlab.ui.internal.toolstrip.DropDown'
                        switch propName

                        case{'RBW','FullScale','TimeResolution','TimeSpan'}
                            inactiveControlProp=[propName,'Source'];
                            if strcmpi(spec.(inactiveControlProp),'auto')
                                specValue=widget.Items{2};
                            else
                                specValue=num2str(spec.(propName));
                            end

                        case{'Method','Window','FrequencyScale','FrequencySpan'}
                            specValue=upper(spec.(propName));
                        case 'SpectrumUnits'
                            specValue=upper(spec.(propName));
                            updateWidgets(section,spec);
                        otherwise
                            specValue=num2str(spec.(propName));
                        end
                    case 'matlab.ui.internal.toolstrip.EditField'
                        switch(propName)
                        case 'StartFrequency'
                            if strcmpi(spec.FrequencySpan,'span-and-center-frequency')
                                inactiveControlProp='Span';
                            end
                            specValue=num2str(spec.(inactiveControlProp));
                            upateFrequencyOptionsWidgets(this,section);
                        case 'StopFrequency'
                            if strcmpi(spec.FrequencySpan,'span-and-center-frequency')
                                inactiveControlProp='CenterFrequency';
                            end
                            specValue=num2str(spec.(inactiveControlProp));
                            upateFrequencyOptionsWidgets(this,section);
                        otherwise
                            specValue=num2str(spec.(propName));
                        end
                    otherwise
                        specValue=spec.(propName);
                    end


                    widget.Enabled=~isInactiveProperty(spec,inactiveControlProp);
                    if~isequal(widget.Value,specValue)
                        section.setProperty(propName,specValue);
                    end

                    switch propName

                    case{'RBW','FullScale','TimeResolution','TimeSpan'}
                        if strcmpi(spec.(inactiveControlProp),'auto')
                            widget.SelectedIndex=1;
                        end
                    end
                end
            end
        end


        function upateFrequencyOptionsWidgets(this,section)

            spec=getScopeMessageHandler(this).Specification;
            if~strcmpi(spec.FrequencySpan,'full')
                updateWidgets(section,spec.FrequencySpan);
            end
        end


        function updateDataCursorsWidgets(this,~,section)
            widgets=section.Widgets;
            widgetsNames=fieldnames(widgets);
            spec=getScopeMessageHandler(this).Specification.CursorMeasurements;
            for widgetIndex=1:numel(widgetsNames)
                widget=widgets.(widgetsNames{widgetIndex});
                propName=widget.Tag;
                specPropName=propName;
                if strcmpi(propName,'ShowDataCursors')
                    specPropName='Enabled';
                end

                if isprop(spec,specPropName)
                    switch class(widget)
                    case 'matlab.ui.internal.toolstrip.EditField'
                        specValue=num2str(spec.(specPropName));
                    otherwise
                        specValue=spec.(specPropName);
                    end


                    widget.Enabled=~isInactiveProperty(spec,specPropName);
                    if~isequal(widget.Value,specValue)
                        section.setProperty(propName,specValue);
                    end
                end
            end
        end


        function updateDistortionWidgets(this,~,section)
            widgets=section.Widgets;
            widgetsNames=fieldnames(widgets);
            spec=getScopeMessageHandler(this).Specification.DistortionMeasurements;
            for widgetIndex=1:numel(widgetsNames)
                widget=widgets.(widgetsNames{widgetIndex});
                propName=widget.Tag;
                specPropName=propName;
                if strcmpi(propName,'ShowDistortion')
                    specPropName='Enabled';
                end
                if strcmpi(propName,'DistortionType')
                    specPropName='Type';
                end
                if strcmpi(propName,'LabelHarmonics')
                    specPropName='LabelValues';
                end
                if isprop(spec,specPropName)
                    switch class(widget)
                    case 'matlab.ui.internal.toolstrip.EditField'
                        specValue=num2str(spec.(specPropName));
                    case 'matlab.ui.internal.toolstrip.DropDown'
                        specValue=upper(spec.(specPropName));
                    otherwise
                        specValue=spec.(specPropName);
                    end
                    if~isequal(widget.Value,specValue)
                        section.setProperty(propName,specValue);
                    end
                end
            end
        end


        function updatePeakFinderWidgets(this,~,section)
            widgets=section.Widgets;
            widgetsNames=fieldnames(widgets);
            spec=getScopeMessageHandler(this).Specification.PeakFinder;
            for widgetIndex=1:numel(widgetsNames)
                widget=widgets.(widgetsNames{widgetIndex});
                propName=widget.Tag;
                specPropName=propName;
                if strcmpi(propName,'ShowPeaks')
                    specPropName='Enabled';
                end

                if isprop(spec,specPropName)
                    switch class(widget)
                    case 'matlab.ui.internal.toolstrip.EditField'
                        specValue=num2str(spec.(specPropName));
                    otherwise
                        specValue=spec.(specPropName);
                    end
                    if~isequal(widget.Value,specValue)
                        section.setProperty(propName,specValue);
                    end
                end
            end
        end
    end
end
