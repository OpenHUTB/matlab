classdef CursorMeasurementsSpecification<dsp.scopes.AbstractMeasurementsSpecification



























































    properties(AbortSet,Dependent)



        Type;




        ShowHorizontal;




        ShowVertical;




        Cursor1TraceSource;




        Cursor2TraceSource;



        LockSpacing;



        SnapToData;



        XLocation;




        YLocation;
    end

    events(Hidden)
CursorMeasurementsUpdated
    end

    properties(Constant,Hidden)

        TypeSet={'Screen cursors','Waveform cursors'};
    end

    properties(Access=protected)
        MeasurerName='fcursors';
    end

    methods

        function obj=CursorMeasurementsSpecification(hApp)


            if nargin>0
                obj.setupMeasurementObject(hApp);

                obj.pMeasurementUpdatedListener=event.listener(obj.pMeasurementObject,...
                'CursorMeasurementsSettingsUpdated',makeCallback(obj.hVisual,@updateCursorMeasurements));
            else
                obj.pMeasurementLocalObject=struct('Type',2,...
                'ShowHorizontal',true,...
                'ShowVertical',true,...
                'Cursor1TraceSource',1,...
                'Cursor2TraceSource',1,...
                'LockSpacing',false,...
                'SnapToData',true,...
                'XLocation',[-2500,2500],...
                'YLocation',[-55,-5],...
                'Enable',false);

            end
        end

        function set.Type(obj,val)
            [~,ind]=validateEnum(obj,val,'Type',obj.TypeSet);
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.CursorType=ind;
            else
                obj.pMeasurementLocalObject.Type=ind;
            end
            notify(obj,'CursorMeasurementsUpdated');
        end
        function val=get.Type(obj)
            if~isempty(obj.hVisual)
                val=obj.TypeSet{obj.pMeasurementObject.CursorType};
            else
                val=obj.TypeSet{obj.pMeasurementLocalObject.Type};
            end
        end

        function set.ShowHorizontal(obj,val)
            validateattributes(val,{'logical'},{'scalar'},'','ShowHorizontal');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.ShowHorizontal=val;
            else
                obj.pMeasurementLocalObject.ShowHorizontal=val;
            end
            notify(obj,'CursorMeasurementsUpdated');
        end
        function val=get.ShowHorizontal(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.ShowHorizontal;
            else
                val=obj.pMeasurementLocalObject.ShowHorizontal;
            end
        end

        function set.ShowVertical(obj,val)
            validateattributes(val,{'logical'},{'scalar'},'','ShowHorizontal');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.ShowVertical=val;
            else
                obj.pMeasurementLocalObject.ShowVertical=val;
            end
            notify(obj,'CursorMeasurementsUpdated');
        end
        function val=get.ShowVertical(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.ShowVertical;
            else
                val=obj.pMeasurementLocalObject.ShowVertical;
            end
        end

        function set.Cursor1TraceSource(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','real','scalar','integer','>=',1,'<=',99,'finite','nonnan'},'','Cursor1TraceSource');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.CursorChannels=[val,obj.Cursor2TraceSource];
            else
                obj.pMeasurementLocalObject.Cursor1TraceSource=val;
            end
            notify(obj,'CursorMeasurementsUpdated');
        end
        function val=get.Cursor1TraceSource(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.CursorChannels(1);
            else
                val=obj.pMeasurementLocalObject.Cursor1TraceSource;
            end
        end

        function set.Cursor2TraceSource(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','real','scalar','integer','>=',1,'<=',99,'finite','nonnan'},'','Cursor2TraceSource');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.CursorChannels=[obj.Cursor1TraceSource,val];
            else
                obj.pMeasurementLocalObject.Cursor2TraceSource=val;
            end
            notify(obj,'CursorMeasurementsUpdated');
        end
        function val=get.Cursor2TraceSource(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.CursorChannels(2);
            else
                val=obj.pMeasurementLocalObject.Cursor2TraceSource;
            end
        end

        function set.LockSpacing(obj,val)
            validateattributes(val,{'logical'},{'scalar'},'','LockSpacing');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.LockCursorSpacing=val;
            else
                obj.pMeasurementLocalObject.LockSpacing=val;
            end
            notify(obj,'CursorMeasurementsUpdated');
        end
        function val=get.LockSpacing(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.LockCursorSpacing;
            else
                val=obj.pMeasurementLocalObject.LockSpacing;
            end
        end

        function set.SnapToData(obj,val)
            validateattributes(val,{'logical'},{'scalar'},'','SnapToData');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.SnapToData=val;
            else
                obj.pMeasurementLocalObject.SnapToData=val;
            end
            notify(obj,'CursorMeasurementsUpdated');
        end
        function val=get.SnapToData(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.SnapToData;
            else
                val=obj.pMeasurementLocalObject.SnapToData;
            end
        end

        function set.XLocation(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','vector','numel',2},'','XLocation');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.XCoordinates=val;
            else
                obj.pMeasurementLocalObject.XLocation=val;
            end
            notify(obj,'CursorMeasurementsUpdated');
        end
        function val=get.XLocation(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.XCoordinates;
            else
                val=obj.pMeasurementLocalObject.XLocation;
            end
        end

        function set.YLocation(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','vector','numel',2},'','YLocation');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.YCoordinates=val;
            else
                obj.pMeasurementLocalObject.YLocation=val;
            end
            notify(obj,'CursorMeasurementsUpdated');
        end
        function val=get.YLocation(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.YCoordinates;
            else
                val=obj.pMeasurementLocalObject.YLocation;
            end
        end

        function varargout=set(obj,varargin)


            if nargin==2&&ischar(varargin{1})
                switch varargin{1}
                case 'Type'
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

                propList={'Type'};
                if strcmp(this.Type,'Screen cursors')
                    propList=[propList,{'ShowHorizontal','ShowVertical'}];
                else
                    propList=[propList,{'Cursor1TraceSource','Cursor2TraceSource'}];
                end
                propList=[propList,{'LockSpacing','SnapToData'}];
                if strcmp(this.Type,'Screen cursors')
                    propList=[propList,{'XLocation','YLocation'}];
                else
                    propList=[propList,'XLocation'];
                end
                propList=[propList,'Enable'];
                groups=matlab.mixin.util.PropertyGroup(propList);
            end
        end

        function eventName=getMeasurementUpdatedEventName(~)
            eventName='CursorMeasurementsUpdated';
        end

        function setupMeasurementObject(obj,hApp)
            obj.Application=hApp;
            obj.hVisual=obj.Application.Visual;
            obj.pMeasurementObject=matlabshared.scopes.measurements.FrequencyCursors(hApp);

            allMeasurementsMap=getExtension(obj.Application.ExtDriver,'Tools:Measurements');
            allMeasurementsMap.ListenerMap(obj.MeasurerName)=event.proplistener(obj,...
            obj.findprop('Enable'),'PostSet',...
            enableMeasurementsCallback(allMeasurementsMap,obj.MeasurerName));
        end

        function spec=getDefaultMeasurementsSpec(~)
            spec=dsp.scopes.CursorMeasurementsSpecification;
        end
    end

    methods(Hidden)

        function name=getMeasurementName(~)
            name='Cursor Measurements';
        end

        function name=getMeasurementObjectName(~)
            name='CursorMeasurements';
        end
    end
end