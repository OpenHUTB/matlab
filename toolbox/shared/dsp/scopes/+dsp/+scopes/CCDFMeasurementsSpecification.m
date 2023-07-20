classdef CCDFMeasurementsSpecification<dsp.scopes.AbstractMeasurementsSpecification


















































    properties(AbortSet,Dependent)




        PlotGaussianReference;
    end

    events(Hidden)
CCDFMeasurementsUpdated
    end

    properties(Access=protected)
        MeasurerName='ccdf';
    end

    methods

        function obj=CCDFMeasurementsSpecification(hApp)


            if nargin>0
                obj.setupMeasurementObject(hApp);

                obj.pMeasurementUpdatedListener=event.listener(obj.pMeasurementObject,...
                'CCDFMeasurementsSettingsUpdated',makeCallback(obj.hVisual,@updateCCDFMeasurements));
            else
                obj.pMeasurementLocalObject=struct('PlotGaussianReference',false,...
                'Enable',false);
            end
        end

        function set.PlotGaussianReference(obj,val)
            validateattributes(val,{'logical'},{'scalar'},'','PlotGaussianReference');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.PlotGaussianReference=val;
            else
                obj.pMeasurementLocalObject.PlotGaussianReference=val;
            end
            notify(obj,'CCDFMeasurementsUpdated');
        end
        function val=get.PlotGaussianReference(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.PlotGaussianReference;
            else
                val=obj.pMeasurementLocalObject.PlotGaussianReference;
            end
        end
    end

    methods(Access=protected)

        function groups=getPropertyGroups(this)


            if~isscalar(this)
                groups=getPropertyGroups@matlab.mixin.CustomDisplay(this);
            else

                propList={'PlotGaussianReference',...
                'Enable'};
                groups=matlab.mixin.util.PropertyGroup(propList);
            end
        end

        function eventName=getMeasurementUpdatedEventName(~)
            eventName='CCDFMeasurementsUpdated';
        end

        function setupMeasurementObject(obj,hApp)
            obj.Application=hApp;
            obj.hVisual=obj.Application.Visual;
            obj.pMeasurementObject=matlabshared.scopes.measurements.CCDFMeasurements(hApp);

            allMeasurementsMap=getExtension(obj.Application.ExtDriver,'Tools:Measurements');
            allMeasurementsMap.ListenerMap(obj.MeasurerName)=event.proplistener(obj,...
            obj.findprop('Enable'),'PostSet',...
            enableMeasurementsCallback(allMeasurementsMap,obj.MeasurerName));
        end

        function spec=getDefaultMeasurementsSpec(~)
            spec=dsp.scopes.CCDFMeasurementsSpecification;
        end
    end

    methods(Hidden)

        function name=getMeasurementName(~)
            name='CCDF Measurements';
        end

        function name=getMeasurementObjectName(~)
            name='CCDFMeasurements';
        end
    end
end
