classdef BaseWebScopeMessageHandler<matlabshared.scopes.WebScopeMessageHandler




    properties(Transient,Hidden)

        Specification;
    end

    properties
        PropertyChangedComplete=true;
        PropertyChangedAction='';
        LocalUpdateComplete=false;
    end

    methods

        function release(~)

        end

        function reset(this)
            this.ClientSettingsStale=true;
            this.publish('onReset',[]);
            matlabshared.application.waitfor(this,'ClientSettingsStale',false,'Timeout',10);
        end

        function publishPropertyValue(this,event,source,propName,propValue)
            if strcmpi(event,'PropertyChanged')

                eventName=['set',propName];
            else


                eventName=['set',source,'ParameterValue'];
                propValue=struct('parameter',propName,'value',propValue);
            end

            this.publish(eventName,propValue);

        end


        function requestSerializedSettings(this,varargin)
            if this.NumChannels~=-1
                addAllSignals(this);
            end
            this.publish('setSerializedSettings',...
            struct('Parameters',getParametersSettings(this),...
            'GraphicalSettings',getGraphicalSettings(this)));
        end

        function parameters=getParametersSettings(this)

            parameters=this.Specification.getSettings();
        end

        function graphicalSettings=getGraphicalSettings(this)

            styleSettings=this.Specification.Style.getSettings();
            graphicalSettings=struct('Style',styleSettings);

            if this.Specification.isMeasurementSupported('cursors')
                cursorsSettings=this.Specification.CursorMeasurements.getSettings();
                graphicalSettings.Cursors=cursorsSettings;
            end

            if this.Specification.isMeasurementSupported('peaks')
                peaksSettings=this.Specification.PeakFinder.getSettings();
                graphicalSettings.Peaks=peaksSettings;
            end
        end


        function updateSettings(this,params)
            this.GraphicalSettingsStale=false;

            if isfield(params,'Parameters')
                this.setParameterSettings(params.Parameters);
            end

            if isfield(params,'GraphicalSettings')
                this.setGraphicalSettings(params.GraphicalSettings);
            end
        end

        function setParameterSettings(this,params)
            if(~isempty(params))
                this.Specification.setSettings(params);
            end
        end

        function setGraphicalSettings(this,graphical)

            if isfield(graphical,'Style')
                styleSettings=graphical.Style;
                if(~isempty(styleSettings))
                    this.Specification.Style.setSettings(styleSettings);
                end
            end

            if isfield(graphical,'Cursors')
                cursorsSettings=graphical.Cursors;
                if~isempty(cursorsSettings)
                    this.Specification.CursorMeasurements.setSettings(cursorsSettings);
                end
            end

            if isfield(graphical,'Peaks')
                peaksSettings=graphical.Peaks;
                if~isempty(peaksSettings)
                    this.Specification.PeakFinder.setSettings(peaksSettings);
                end
            end
        end


        function generateScript(this,~)
            this.Specification.generateScript();
        end


        function S=toStruct(this)
            S=toStruct@matlabshared.scopes.WebMessageHandler(this);
        end


        function fromStruct(this,S)
            fromStruct@matlabshared.scopes.WebMessageHandler(this,S);
        end

        function propertyChangedRequested(this,action)
            this.PropertyChangedComplete=false;
            this.PropertyChangedAction=action;
        end

        function setVisible(this,value)
            this.Specification.Visible=value{2};
        end

        function localUpdateRequested(this)
            matlabshared.application.waitfor(this,'LocalUpdateComplete',true,'Timeout',10);
            this.LocalUpdateComplete=false;
        end

        function localUpdateComplete(this,value)
            this.LocalUpdateComplete=value;
        end
    end
end