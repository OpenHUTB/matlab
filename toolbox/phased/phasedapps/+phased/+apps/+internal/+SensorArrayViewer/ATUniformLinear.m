


classdef ATUniformLinear<phased.apps.internal.SensorArrayViewer.ArrayType

    properties(SetObservable)
        NumElements=4
        ElemSpacing=0.5
        ElemSpacingUnitsIndex=1
        TaperTypeIndex=1
        SidelobeAttenuation=30
        Nbar=4
        Beta=0.5
        CustomTaper=1
        ArrayAxis='y'
    end

    properties(SetAccess=private)
        TranslatedName=getString(message('phased:apps:arrayapp:ula'));
        ShortName='ULA'
        pElRatio=1
    end

    methods
        function obj=ATUniformLinear(dlg)

            obj.ArrayObj=phased.ULA();
            obj.CanPlotGratingLobe=true;

            if nargin<1
                return
            end

            obj.Application=dlg.Application;

        end

        function tt=getCurTaperType(obj)
            tt=phased.apps.internal.SensorArrayViewer.TaperType.getTaperAtPos(obj.TaperTypeIndex);
        end
        function updateWithArrayObj(obj,sysObj)
            sensorArray=sysObj.Sensor;
            pvPair={'NumElements',sensorArray.NumElements,...
            'ElemSpacing',sensorArray.ElementSpacing,...
            'ArrayAxis',sensorArray.ArrayAxis};
            updateWithArrayObj@phased.apps.internal.SensorArrayViewer.ArrayType(obj,sysObj,pvPair);
        end
    end

    methods(Access=protected)

        function updateArrayObj(obj)

            ratio=1;
            if obj.ElemSpacingUnitsIndex~=1
                ratio=obj.PropSpeed/obj.SignalFreqs(1);
            end
            obj.pElRatio=ratio;
            set(obj.ArrayObj,'NumElements',obj.NumElements);
            set(obj.ArrayObj,'ElementSpacing',obj.ElemSpacing*ratio);
            set(obj.ArrayObj,'ArrayAxis',obj.ArrayAxis);

            obj.expandRangeForFreq();
            el=obj.getCurElementType();
            obj.ArrayObj.Element=el.getElement(obj);
        end

        function as=getArraySizeWithoutSave(~,pending)
            as=pending.NumElements;
        end

        function taperPV=getPVTapers(~,sensorArray)
            taper=sensorArray.Taper;
            taperPV={};
            if~isscalar(taper)||taper~=1
                taperPV={'TaperTypeIndex',7,'CustomTaper',taper};
            end
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


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:ElementSpacing')),':']);
            c.Tag=[obj.ShortName,'_ElemSpacingTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ElementSpacingTT'));
            c.ValidAttributes={'real','scalar','positive','finite','nonempty','nonnan'};
            connectPropertyAndControl(obj,'ElemSpacing',c);

            c=uipopup(obj,{getString(message('phased:apps:arrayapp:meter')),...
            getString(message('phased:apps:arrayapp:Lambda'))});
            c.Tag=[obj.ShortName,'_ElemSpacingUnitsTag'];
            connectPropertyAndControl(obj,'ElemSpacingUnitsIndex',c,'value');
            obj.newrow;


            c=uipopup(obj,{getString(message('phased:apps:arrayapp:xaxis')),...
            getString(message('phased:apps:arrayapp:yaxis')),...
            getString(message('phased:apps:arrayapp:zaxis'))},...
            'label',[getString(message('phased:apps:arrayapp:ArrayAxis')),':']);
            c.Tag=[obj.ShortName,'_ArrayAxisTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ArrayAxisTT'));

            connectPropertyAndControl(obj,'ArrayAxis',c);
            obj.newrow;

            obj.addSignalFrequenciesControl();
            obj.addPropSpeedControl();
            obj.addSteeringControl();
            obj.addTaperDropdown();

        end
    end

    methods
        function verifyParameters(obj,pending,~)

            verifyParameters@phased.apps.internal.SensorArrayViewer.ArrayType(obj,pending);


            SigFreqs=pending.SignalFreqs;
            usingLambda=pending.ElemSpacingUnitsIndex~=1;

            if~isscalar(SigFreqs)&&usingLambda
                e=MException('SensorArray:InvalidWavelength','Signal Frequencies must be scalar when using wavelength units');
                throwAsCaller(e);
            end


        end

        function verifyCustomTaper(obj,pending,~)
            curTT=phased.apps.internal.SensorArrayViewer.TaperType.getTaperAtPos(pending.TaperTypeIndex);
            isCustomTaper=curTT==phased.apps.internal.SensorArrayViewer.TaperType.Custom;
            customTaper=pending.CustomTaper;
            nE=obj.getArraySizeWithoutSave(pending);
            if isCustomTaper&&~isscalar(customTaper)&&length(customTaper)~=nE
                e=MException('SensorArray:InvalidDimensions','Expected Custom Taper to be scalar or have one entry for each element');
                throwAsCaller(e);
            end
        end

    end

    methods
        function genCode(obj,mcode)

            mcode.addcr('% Create a uniform linear array');
            mcode.addcr('h = phased.ULA;');
            mcode.addcr(['h.NumElements = ',num2str(obj.NumElements),';']);
            mcode.addcr(['h.ElementSpacing = ',num2str(obj.ElemSpacing*obj.pElRatio),';']);
            mcode.addcr(['h.ArrayAxis = ''',obj.ArrayAxis,''';']);

        end
    end

end

