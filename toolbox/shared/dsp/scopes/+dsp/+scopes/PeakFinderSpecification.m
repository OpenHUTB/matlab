classdef PeakFinderSpecification<dsp.scopes.AbstractMeasurementsSpecification























































    properties(AbortSet)



        MinHeight=-Inf;



        NumPeaks=3;



        MinDistance=1;




        Threshold=0;




        LabelFormat='X + Y';
    end

    events(Hidden)
PeakFinderUpdated
    end

    properties(Constant,Hidden)

        LabelFormatSet={'X + Y','X','Y'};
    end

    properties(Access=protected)
        MeasurerName='peaks';
    end

    methods

        function obj=PeakFinderSpecification(hApp)


            if nargin>0
                obj.setupMeasurementObject(hApp);

                obj.pMeasurementUpdatedListener=event.listener(obj.pMeasurementObject,...
                'PeakFinderSettingsUpdated',makeCallback(obj.hVisual,@updatePeakFinder));
            else
                obj.pMeasurementLocalObject=struct('MinHeight',-Inf,...
                'NumPeaks',3,...
                'MinDistance',1,...
                'Threshold',0,...
                'LabelFormat',1,...
                'Enable',false);
            end
        end

        function set.MinHeight(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','real'},'','MinHeight');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.MinPeakHeight=val;
            else
                obj.pMeasurementLocalObject.MinHeight=val;
            end
            notify(obj,'PeakFinderUpdated');
        end
        function val=get.MinHeight(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.MinPeakHeight;
            else
                val=obj.pMeasurementLocalObject.MinHeight;
            end
        end

        function set.NumPeaks(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','real','scalar','integer','>=',1,'<=',99,'finite','nonnan'},'','NumPeaks');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.NumPeaks=val;
            else
                obj.pMeasurementLocalObject.NumPeaks=val;
            end
            notify(obj,'PeakFinderUpdated');
        end
        function val=get.NumPeaks(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.NumPeaks;
            else
                val=obj.pMeasurementLocalObject.NumPeaks;
            end
        end

        function set.MinDistance(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','real','scalar','integer','finite','nonnan'},'','MinDistance');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.MinPeakDistance=val;
            else
                obj.pMeasurementLocalObject.MinDistance=val;
            end
            notify(obj,'PeakFinderUpdated');
        end
        function val=get.MinDistance(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.MinPeakDistance;
            else
                val=obj.pMeasurementLocalObject.MinDistance;
            end
        end

        function set.Threshold(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonnegative','real','scalar','finite','nonnan'},'','Threshold');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.Threshold=val;
            else
                obj.pMeasurementLocalObject.Threshold=val;
            end
            notify(obj,'PeakFinderUpdated');
        end
        function val=get.Threshold(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.Threshold;
            else
                val=obj.pMeasurementLocalObject.Threshold;
            end
        end

        function set.LabelFormat(obj,val)
            [~,ind]=validateEnum(obj,val,'LabelFormat',obj.LabelFormatSet);
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.LabelFormat=ind;
            else
                obj.pMeasurementLocalObject.LabelFormat=ind;
            end
            notify(obj,'PeakFinderUpdated');
        end
        function val=get.LabelFormat(obj)
            if~isempty(obj.hVisual)
                val=obj.LabelFormatSet{obj.pMeasurementObject.LabelFormat};
            else
                val=obj.LabelFormatSet{obj.pMeasurementLocalObject.LabelFormat};
            end
        end

        function varargout=set(obj,varargin)


            if nargin==2&&ischar(varargin{1})
                switch varargin{1}
                case 'LabelFormat'
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

                propList={'MinHeight',...
                'NumPeaks',...
                'MinDistance',...
                'Threshold',...
                'LabelFormat',...
                'Enable'};
                groups=matlab.mixin.util.PropertyGroup(propList);
            end
        end

        function eventName=getMeasurementUpdatedEventName(~)
            eventName='PeakFinderUpdated';
        end

        function setupMeasurementObject(obj,hApp)
            obj.Application=hApp;
            obj.hVisual=obj.Application.Visual;
            obj.pMeasurementObject=matlabshared.scopes.measurements.PeakFinder(hApp);

            allMeasurementsMap=getExtension(obj.Application.ExtDriver,'Tools:Measurements');
            allMeasurementsMap.ListenerMap(obj.MeasurerName)=event.proplistener(obj,...
            obj.findprop('Enable'),'PostSet',...
            enableMeasurementsCallback(allMeasurementsMap,obj.MeasurerName));
        end

        function spec=getDefaultMeasurementsSpec(~)
            spec=dsp.scopes.PeakFinderSpecification;
        end
    end

    methods(Hidden)

        function name=getMeasurementName(~)
            name='Peak Finder';
        end

        function name=getMeasurementObjectName(~)
            name='PeakFinder';
        end
    end
end
