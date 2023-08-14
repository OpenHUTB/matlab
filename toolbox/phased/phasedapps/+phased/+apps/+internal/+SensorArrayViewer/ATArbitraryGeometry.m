


classdef ATArbitraryGeometry<phased.apps.internal.SensorArrayViewer.ArrayType

    properties(SetObservable)
        ElemPos=[0,0;0.1,0.15;0.15,0.17]
        ElemPosUnitsIndex=1
        ElemNormal=[0,10;10,20]
        CustomTaper=1
    end

    properties(SetAccess=private)
        TranslatedName=getString(message('phased:apps:arrayapp:Arbitrary'));
        ShortName='AGA'
    end


    methods
        function obj=ATArbitraryGeometry(dlg)

            obj.ArrayObj=phased.ConformalArray();
            obj.CanPlotGratingLobe=false;

            if nargin<1
                return
            end

            obj.Application=dlg.Application;

        end
        function updateWithArrayObj(obj,sysObj)
            sensorArray=sysObj.Sensor;
            pvPair={'ElemPos',sensorArray.ElementPosition,...
            'ElemNormal',sensorArray.ElementNormal,...
            'ElemPosUnitsIndex',1};
            updateWithArrayObj@phased.apps.internal.SensorArrayViewer.ArrayType(obj,sysObj,pvPair);
        end

    end

    methods(Access=protected)

        function updateArrayObj(obj)

            ratio=1;
            if obj.ElemPosUnitsIndex~=1
                ratio=obj.PropSpeed/obj.SignalFreqs(1);
            end

            set(obj.ArrayObj,'ElementPosition',obj.ElemPos*ratio);
            set(obj.ArrayObj,'ElementNormal',obj.ElemNormal);

            obj.expandRangeForFreq();
            el=obj.getCurElementType();
            obj.ArrayObj.Element=el.getElement(obj);

        end

        function as=getArraySizeWithoutSave(~,pending)
            as=size(pending.ElemPos,2);
        end
    end

    methods(Access=protected)

        function initTable(obj)

            initTable@phased.apps.internal.SensorArrayViewer.ArrayType(obj);


            c=uieditv(obj,'[0, 0;0.1, 0.15; 0.15, 0.17]','label',[getString(message('phased:apps:arrayapp:ElementPosition')),':']);
            c.Tag=[obj.ShortName,'_ElemPosTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ElementPositionTT'));
            c.ValidAttributes={'real','nrows',3,'finite','nonempty','nonnan'};
            connectPropertyAndControl(obj,'ElemPos',c);

            c=uipopup(obj,{getString(message('phased:apps:arrayapp:meter')),...
            getString(message('phased:apps:arrayapp:Lambda'))});
            c.Tag=[obj.ShortName,'_ElemPosUnitsTag'];
            connectPropertyAndControl(obj,'ElemPosUnitsIndex',c,'value');
            obj.newrow;


            c=uieditv(obj,'[0, 10; 10, 20]','label',[getString(message('phased:apps:arrayapp:ElementNormal')),':']);
            c.Tag=[obj.ShortName,'_ElemNormalTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ElementNormalTT'));
            c.ValidAttributes={'real','nrows',2,'finite','nonempty','nonnan'};
            uitext(obj,getString(message('phased:apps:arrayapp:degrees')));
            connectPropertyAndControl(obj,'ElemNormal',c);
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


            pos=pending.ElemPos;
            normal=pending.ElemNormal;

            if size(pos,2)~=size(normal,2)
                e=MException('SensorArray:LengthMismatch',['Expected Element Normal to have ',num2str(size(pos,2)),' columns']);
                throwAsCaller(e);
            end


            SigFreqs=pending.SignalFreqs;
            usingLambda=pending.ElemPosUnitsIndex~=1;

            if~isscalar(SigFreqs)&&usingLambda
                e=MException('SensorArray:InvalidWavelength','Signal Frequencies must be scalar when using wavelength units');
                throwAsCaller(e);
            end


        end
    end

    methods
        function genCode(obj,mcode)

            ratio=1;
            if obj.ElemPosUnitsIndex~=1
                ratio=obj.PropSpeed/obj.SignalFreqs(1);
            end

            mcode.addcr('% Create an arbitrary geometry array');
            mcode.addcr('h = phased.ConformalArray();');
            mcode.addcr(['h.ElementPosition = ',mat2str(obj.ElemPos*ratio),';']);
            mcode.addcr(['h.ElementNormal = ',mat2str(obj.ElemNormal),';']);

        end
    end

end

