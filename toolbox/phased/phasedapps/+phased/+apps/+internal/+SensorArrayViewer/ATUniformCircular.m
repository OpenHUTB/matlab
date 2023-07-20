


classdef ATUniformCircular<phased.apps.internal.SensorArrayViewer.ArrayType

    properties(SetObservable)
        NumElements=16
        Radius=1
        RadiusUnitsIndex=1
        ArrayNormal='z'
        CustomTaper=1

    end

    properties(SetAccess=private)
        TranslatedName=getString(message('phased:apps:arrayapp:uca'));
        ShortName='UCA';
    end

    methods
        function obj=ATUniformCircular(dlg)

            obj.ArrayObj=phased.UCA();
            obj.CanPlotGratingLobe=false;

            if nargin<1
                return
            end

            obj.Application=dlg.Application;

        end
        function updateWithArrayObj(obj,sysObj)
            sensorArray=sysObj.Sensor;
            pvPair={'NumElements',sensorArray.NumElements,...
            'Radius',sensorArray.Radius,...
            'ArrayNormal',sensorArray.ArrayNormal,...
            'RadiusUnitsIndex',1};
            updateWithArrayObj@phased.apps.internal.SensorArrayViewer.ArrayType(obj,sysObj,pvPair);
        end

    end

    methods(Access=protected)

        function updateArrayObj(obj)

            ratio=1;
            if obj.RadiusUnitsIndex~=1
                ratio=obj.PropSpeed/obj.SignalFreqs(1);
            end
            radius=obj.Radius*ratio;

            set(obj.ArrayObj,'NumElements',obj.NumElements);
            set(obj.ArrayObj,'Radius',radius);
            set(obj.ArrayObj,'ArrayNormal',obj.ArrayNormal);

            obj.expandRangeForFreq();
            el=obj.getCurElementType();
            obj.ArrayObj.Element=el.getElement(obj);

        end

        function as=getArraySizeWithoutSave(~,pending)
            as=pending.NumElements;
        end

    end

    methods(Access=protected)

        function initTable(obj)


            initTable@phased.apps.internal.SensorArrayViewer.ArrayType(obj);


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:NumElements')),':']);
            c.Tag=[obj.ShortName,'_NumElementsTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:NumElementsTT'));
            c.ValidAttributes={'real','scalar','>=',2,'finite','integer','nonempty','nonnan'};
            connectPropertyAndControl(obj,'NumElements',c);
            obj.newrow;


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:Radius')),':']);
            c.Tag=[obj.ShortName,'_RadiusTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:RadiusTT'));
            c.ValidAttributes={'real','scalar','positive','finite','nonempty','nonnan'};
            connectPropertyAndControl(obj,'Radius',c);

            c=uipopup(obj,{getString(message('phased:apps:arrayapp:meter')),...
            getString(message('phased:apps:arrayapp:Lambda'))});
            c.Tag=[obj.ShortName,'_RadiusUnitsTag'];
            connectPropertyAndControl(obj,'RadiusUnitsIndex',c,'value');
            obj.newrow;


            c=uipopup(obj,{getString(message('phased:apps:arrayapp:xaxis')),...
            getString(message('phased:apps:arrayapp:yaxis')),...
            getString(message('phased:apps:arrayapp:zaxis'))},...
            'label',[getString(message('phased:apps:arrayapp:ArrayNormal')),':']);
            c.Tag=[obj.ShortName,'_ArrayNormalTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ArrayNormalTT'));
            connectPropertyAndControl(obj,'ArrayNormal',c);
            obj.newrow;

            obj.addSignalFrequenciesControl();
            obj.addPropSpeedControl();
            obj.addSteeringControl();
            obj.addTaperCustomEdit();

        end
    end

    methods

        function verifyParameters(obj,pending,~)

            verifyParameters@phased.apps.internal.SensorArrayViewer.ArrayType(obj,pending);


            SigFreqs=pending.SignalFreqs;
            usingLambda=pending.RadiusUnitsIndex~=1;

            if~isscalar(SigFreqs)&&usingLambda
                e=MException('SensorArray:InvalidWavelength','Signal Frequencies must be scalar when using wavelength units');
                throwAsCaller(e);
            end

        end

    end

    methods
        function genCode(obj,mcode)

            ratio=1;
            if obj.RadiusUnitsIndex~=1
                ratio=obj.PropSpeed/obj.SignalFreqs(1);
            end
            radius=obj.Radius*ratio;

            mcode.addcr('% Create a uniform circular array');
            mcode.addcr('h = phased.UCA;');
            mcode.addcr(['h.NumElements = ',num2str(obj.NumElements),';']);
            mcode.addcr(['h.Radius = ',num2str(radius),';']);
            mcode.addcr(['h.ArrayNormal = ''',obj.ArrayNormal,''';']);

        end
    end

end

