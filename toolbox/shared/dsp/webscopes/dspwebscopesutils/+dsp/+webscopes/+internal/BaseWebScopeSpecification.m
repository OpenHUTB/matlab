classdef BaseWebScopeSpecification<handle&...
    dsp.webscopes.mixin.StyleSpecifiable&...
    dsp.webscopes.mixin.MeasurementsSpecifiable&...
    dsp.webscopes.mixin.ScriptGenerator&...
    matlab.mixin.SetGet






    properties(AbortSet)

        NumInputPorts=1;

        NumInputPortsSource='auto';

        Name='Scope';

        Position=utils.getDefaultWebWindowPosition([800,500]);

        AxesScalingNumUpdates=100;

        ExpandToolstrip=false;

        MeasurementChannel=1;

        DefaultLegendLabel='';

        NumChannels=-1;

        Annotation='';

        CounterMode='frames';

        ScopeLocked=false;

        IsInputComplex=false;
    end

    properties(Transient,Hidden)

        MessageHandler;
    end

    properties(Hidden)

        HasToolstrip=true;

        HasStatusbar=true;

        HasDockControls=false;

        Tag='';

        RenderInMATLAB=false;


        WarnOnInactivePropertySet=true;

        ReduceUpdates=true;
    end

    properties(Abstract)

        Product;

        DataDomain;

        MaxNumChannels;
    end

    properties(Hidden,SetObservable)

        Visible=false;
    end



    methods

        function this=BaseWebScopeSpecification()

            addStyleSpecification(this);

            addMeasurementsSpecification(this);
        end


        function value=get.Position(this)
            webWindow=this.getWebWindow();
            if(~isempty(webWindow)&&isvalid(webWindow))
                value=webWindow.Position;
            else
                value=this.Position;
            end
        end


        function S=toStruct(this)
            S.NumInputPorts=this.NumInputPorts;
            S.Name=this.Name;
            S.Position=this.Position;
            S.AxesScalingNumUpdates=this.AxesScalingNumUpdates;
        end


        function fromStruct(this,S)
            if(isfield(S,'NumInputPorts'))
                this.NumInputPorts=S.NumInputPorts;
            end
            if(isfield(S,'Name'))
                this.Name=S.Name;
            end
            if(isfield(S,'Position'))
                this.Position=S.Position;
            end
            if(isfield(S,'AxesScalingNumUpdates'))
                this.AxesScalingNumUpdates=S.AxesScalingNumUpdates;
            end
        end


        function setSettings(this,S)
            fields=fieldnames(S);
            for idx=1:numel(fields)
                prop=fields{idx};
                value=S.(prop);
                if ischar(value)
                    this.(prop)=value;
                else
                    this.(prop)=value.';
                end
            end
        end


        function setPropertyValue(this,propName,propValue)
            if(~isequal(this.(propName),propValue))
                this.(propName)=propValue;
                hMessage=this.MessageHandler;
                hMessage.GraphicalSettingsStale=true;
                hMessage.publishPropertyValue('PropertyChanged','Specification',propName,propValue);


                hMessage.notify('PropertyChanged');
            end
        end


        function propValue=getPropertyValue(this,propName)
            propValue=this.(propName);
        end


        function n=getNumChannels(this)
            n=sum(this.NumChannels);
        end

        function flag=isLocked(this)
            flag=this.ScopeLocked;
        end

        function release(this)
            this.ScopeLocked=false;
        end


        function flag=isMeasurementSupported(this,measurer)
            measurers=getSupportedMeasurements(this);
            flag=false;
            if~isempty(measurers)
                flag=isKey(measurers,measurer);
            end
        end

        function webWindow=getWebWindow(this)
            import dsp.webscopes.internal.*;
            webWindow=BaseWebScope.getWebWindowFromClientID(this.MessageHandler.ClientId);
        end

        function flag=isScopeVisible(this)
            webwindow=this.getWebWindow();
            flag=false;
            if isvalid(webwindow)&&~isempty(webwindow)&&(isVisible(webwindow)||webwindow.isWindowActive)
                flag=true;
            end
        end

        function flag=isInactiveProperty(this,propName)
            flag=false;
            switch propName
            case 'AxesScalingNumUpdates'
                flag=~strcmpi(this.AxesScaling,'updates');
            end
        end

        function validProps=getValidDisplayProperties(this,props)
            validProps={};
            for idx=1:numel(props)
                if~isInactiveProperty(this,props{idx})
                    validProps=[validProps,props{idx}];%#ok<AGROW>
                end
            end
        end
    end



    methods(Access=protected)

        function style=getStyleSpecification(this)
            style=dsp.webscopes.style.StyleSpecification(this);
        end
    end



    methods(Hidden)


        function props=getDisplaySpecificProperties(~)
            props='';
        end



        function props=getIrrelevantConstructorProperties(~)
            props={'CursorMeasurements','PeakFinder'};
        end
    end



    methods(Abstract)

        name=getScopeName(this)

        className=getClassName(this)

        measurers=getSupportedMeasurements(this)

        filterImpls=getSupportedFiltersImpls(this);
    end
end

