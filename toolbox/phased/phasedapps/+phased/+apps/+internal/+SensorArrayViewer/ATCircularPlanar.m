


classdef ATCircularPlanar<phased.apps.internal.SensorArrayViewer.ArrayType

    properties(SetObservable)
        Radius=1
        RadiusUnitsIndex=1
        ElemSpacing=0.5
        ElemSpacingUnitsIndex=1
        LatticeIndex=1
        CustomTaper=1
    end

    properties(SetAccess=private)
        TranslatedName=getString(message('phased:apps:arrayapp:CircularPlanar'));
        ShortName='CircPlanar'
    end

    properties
LatticeNames
    end

    properties(Access=private)
MsgLatticeNames
    end

    methods
        function obj=ATCircularPlanar(dlg)

            obj.ArrayObj=phased.ConformalArray();
            obj.CanPlotGratingLobe=true;

            if nargin<1
                return
            end

            obj.Application=dlg.Application;

            obj.LatticeNames={'Rectangular','Triangular'};
            obj.MsgLatticeNames={getString(message('phased:apps:arrayapp:Rectangular')),...
            getString(message('phased:apps:arrayapp:Triangular'))};
        end

    end

    methods(Access=protected)

        function updateArrayObj(obj)

            radiusRatio=1;
            elemSpacingRatio=1;
            if obj.RadiusUnitsIndex~=1
                radiusRatio=obj.PropSpeed/obj.SignalFreqs(1);
            end
            if obj.ElemSpacingUnitsIndex~=1
                elemSpacingRatio=obj.PropSpeed/obj.SignalFreqs(1);
            end

            radius=obj.Radius*radiusRatio;
            delta=obj.ElemSpacing*elemSpacingRatio;
            n=round(radius/delta*2);
            htemp=phased.URA(n,delta,...
            'Lattice',obj.LatticeNames{obj.LatticeIndex});
            pos=getElementPosition(htemp);
            elemToRemove=sum(pos.^2)>radius^2;
            pos(:,elemToRemove)=[];

            set(obj.ArrayObj,'ElementPosition',pos);
            set(obj.ArrayObj,'ElementNormal',[1;0]*ones(1,size(pos,2)));

            obj.expandRangeForFreq();
            el=obj.getCurElementType();
            obj.ArrayObj.Element=el.getElement(obj);

        end

        function as=getArraySizeWithoutSave(obj,pending)



            radiusRatio=1;
            elemSpacingRatio=1;
            if pending.RadiusUnitsIndex~=1
                radiusRatio=pending.PropSpeed/pending.SignalFreqs;
            end
            if pending.ElemSpacingUnitsIndex~=1
                elemSpacingRatio=pending.PropSpeed/pending.SignalFreqs;
            end

            radius=pending.Radius*radiusRatio;
            delta=pending.ElemSpacing*elemSpacingRatio;
            n=round(radius/delta*2);
            if n<2
                e=MException('SensorArray:InvalidNumElements',getString(message('phased:apps:arrayapp:NumElementsSmall')));
                throwAsCaller(e);
            end

            htemp=phased.URA(n,delta,...
            'Lattice',obj.LatticeNames{pending.LatticeIndex});
            pos=getElementPosition(htemp);
            elemToRemove=sum(pos.^2)>radius^2;
            pos(:,elemToRemove)=[];


            as=size(pos,2);
        end

    end

    methods(Access=protected)

        function initTable(obj)

            initTable@phased.apps.internal.SensorArrayViewer.ArrayType(obj);


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


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:ElementSpacing')),':']);
            c.Tag=[obj.ShortName,'_ElemSpacingTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ElementSpacingRTT'));
            c.ValidAttributes={'real','scalar','positive','finite','nonempty','nonnan'};
            connectPropertyAndControl(obj,'ElemSpacing',c);

            c=uipopup(obj,{getString(message('phased:apps:arrayapp:meter')),getString(message('phased:apps:arrayapp:Lambda'))});
            c.Tag=[obj.ShortName,'_ElemSpacingUnitsTag'];
            connectPropertyAndControl(obj,'ElemSpacingUnitsIndex',c,'value');
            obj.newrow;


            obj.addSignalFrequenciesControl();


            c=uipopup(obj,obj.MsgLatticeNames,'label',[getString(message('phased:apps:arrayapp:Lattice')),':']);
            c.TooltipString=getString(message('phased:apps:arrayapp:LatticeTT'));
            c.Tag=[obj.ShortName,'_LatticeDDTag'];
            connectPropertyAndControl(obj,'LatticeIndex',c,'value');
            obj.newrow;


            obj.addPropSpeedControl();
            obj.addSteeringControl();
            obj.addTaperCustomEdit();
        end
    end

    methods

        function verifyParameters(obj,pending,~)

            verifyParameters@phased.apps.internal.SensorArrayViewer.ArrayType(obj,pending);


            SigFreqs=pending.SignalFreqs;

            usingLambda=pending.ElemSpacingUnitsIndex~=1||pending.RadiusUnitsIndex~=1;

            if~isscalar(SigFreqs)&&usingLambda
                e=MException('SensorArray:InvalidWavelength','Signal Frequencies must be scalar when using wavelength units');
                throwAsCaller(e);
            end

        end
    end
    methods
        function genCode(obj,mcode)

            radiusRatio=1;
            elemSpacingRatio=1;
            if obj.RadiusUnitsIndex~=1
                radiusRatio=obj.PropSpeed./obj.SignalFreqs(1);
            end
            if obj.ElemSpacingUnitsIndex~=1
                elemSpacingRatio=obj.PropSpeed/obj.SignalFreqs(1);
            end

            mcode.addcr('% Create a circular planar array');

            mcode.addcr(['radius = ',num2str(obj.Radius*radiusRatio),';']);
            mcode.addcr(['delta = ',num2str(obj.ElemSpacing*elemSpacingRatio),';']);
            mcode.addcr('n = round(radius/delta*2);');
            mcode.addcr('htemp = phased.URA(n, delta, ...');
            mcode.addcr(['   ''Lattice'', ''',obj.LatticeNames{obj.LatticeIndex},''');']);
            mcode.addcr('pos = getElementPosition(htemp);');
            mcode.addcr('elemToRemove = sum(pos.^2)>radius^2;');
            mcode.addcr('pos(:,elemToRemove) = [];');
            mcode.addcr('h = phased.ConformalArray(''ElementPosition'', pos, ...');
            mcode.addcr('   ''ElementNormal'', [1;0]*ones(1,size(pos,2)));');

        end
    end

end

