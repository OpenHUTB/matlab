classdef DistortionMeasurementsSpecification<dsp.scopes.AbstractMeasurementsSpecification



















































    properties(AbortSet,Dependent)



        Algorithm;




        NumHarmonics;
    end

    events(Hidden)
DistortionMeasurementsUpdated
    end

    properties(Constant,Hidden)

        AlgorithmSet={'Harmonic','Intermodulation'};
    end

    properties(Access=protected)
        MeasurerName='distortion';
    end

    methods

        function obj=DistortionMeasurementsSpecification(hApp)


            if nargin>0
                obj.setupMeasurementObject(hApp);

                obj.pMeasurementUpdatedListener=event.listener(obj.pMeasurementObject,...
                'DistortionMeasurementsSettingsUpdated',makeCallback(obj.hVisual,@updateDistortionMeasurements));
            else
                obj.pMeasurementLocalObject=struct('Algorithm',1,...
                'NumHarmonics',6,...
                'Enable',false);
            end
        end

        function set.Algorithm(obj,val)
            [~,ind]=validateEnum(obj,val,'Algorithm',obj.AlgorithmSet);
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.Algorithm=ind;
            else
                obj.pMeasurementLocalObject.Algorithm=ind;
            end
            notify(obj,'DistortionMeasurementsUpdated');
        end
        function val=get.Algorithm(obj)
            if~isempty(obj.hVisual)
                val=obj.AlgorithmSet{obj.pMeasurementObject.Algorithm};
            else
                val=obj.AlgorithmSet{obj.pMeasurementLocalObject.Algorithm};
            end
        end

        function set.NumHarmonics(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','real','scalar','integer','>=',1,'<=',99,'finite','nonnan'},'','NumHarmonics');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.NumHarmonics=val;
            else
                obj.pMeasurementLocalObject.NumHarmonics=val;
            end
            notify(obj,'DistortionMeasurementsUpdated');
        end
        function val=get.NumHarmonics(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.NumHarmonics;
            else
                val=obj.pMeasurementLocalObject.NumHarmonics;
            end
        end

        function varargout=set(obj,varargin)


            if nargin==2&&ischar(varargin{1})
                switch varargin{1}
                case 'Algorithm'
                    varargout{1}=obj.([varargin{1},'Set']);
                otherwise
                    varargout{1}=[];
                end
            else
                if nargout
                    varargout{1}=set@matlab.mixin.SetGet(obj,varargin{:});
                else
                    set@matlab.mixin.SetGet(obj,varargin{:});
                end
            end
        end
    end

    methods(Access=protected)

        function groups=getPropertyGroups(this)


            if~isscalar(this)
                groups=getPropertyGroups@matlab.mixin.CustomDisplay(this);
            else
                propList={'Algorithm'};
                if strcmp(this.Algorithm,'Harmonic')
                    propList=[propList,{'NumHarmonics'}];
                end
                propList=[propList,{'Enable'}];
                groups=matlab.mixin.util.PropertyGroup(propList);
            end
        end

        function eventName=getMeasurementUpdatedEventName(~)
            eventName='DistortionMeasurementsUpdated';
        end

        function setupMeasurementObject(obj,hApp)
            obj.Application=hApp;
            obj.hVisual=obj.Application.Visual;
            obj.pMeasurementObject=matlabshared.scopes.measurements.DistortionMeasurements(hApp);

            allMeasurementsMap=getExtension(obj.Application.ExtDriver,'Tools:Measurements');
            allMeasurementsMap.ListenerMap(obj.MeasurerName)=event.proplistener(obj,...
            obj.findprop('Enable'),'PostSet',...
            enableMeasurementsCallback(allMeasurementsMap,obj.MeasurerName));
        end

        function spec=getDefaultMeasurementsSpec(~)
            spec=dsp.scopes.DistortionMeasurementsSpecification;
        end
    end

    methods(Hidden)

        function name=getMeasurementName(~)
            name='Distortion Measurements';
        end

        function name=getMeasurementObjectName(~)
            name='DistortionMeasurements';
        end
    end
end
