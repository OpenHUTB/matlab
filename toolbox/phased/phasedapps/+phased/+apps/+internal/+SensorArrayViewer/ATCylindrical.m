


classdef ATCylindrical<phased.apps.internal.SensorArrayViewer.ArrayType

    properties(SetObservable)
        Radius=1
        RadiusUnitsIndex=1
        ElemOnRing=10
        NumRings=10
        RingSpacing=0.5
        RingSpacingUnitsIndex=1
        CustomTaper=1
    end

    properties(SetAccess=private)
        TranslatedName=getString(message('phased:apps:arrayapp:Cylindrical'));
        ShortName='Cyl'
    end

    methods
        function obj=ATCylindrical(dlg)

            obj.ArrayObj=phased.ConformalArray();
            obj.CanPlotGratingLobe=false;

            if nargin<1
                return
            end

            obj.Application=dlg.Application;

        end
    end

    methods(Access=protected)

        function updateArrayObj(obj)

            radiusRatio=1;
            ringRatio=1;
            if obj.RadiusUnitsIndex~=1
                radiusRatio=obj.PropSpeed/obj.SignalFreqs(1);
            end
            if obj.RingSpacingUnitsIndex~=1
                ringRatio=obj.PropSpeed/obj.SignalFreqs(1);
            end

            R=obj.Radius*radiusRatio;
            N=obj.ElemOnRing;
            RS=obj.RingSpacing*ringRatio;
            NR=obj.NumRings;
            angles=(0:N-1)/N*360-180;
            xy=[R*cosd(angles);R*sind(angles)];
            Height=RS*NR;
            z=-Height/2:RS:Height/2;
            xy=kron(ones(1,NR),xy);
            xy=[xy;zeros(1,size(xy,2))];
            angles=kron(ones(1,NR),angles);
            for idx=1:NR
                xy(3,(idx-1)*N+1:idx*N)=z(idx);
            end
            nDir=[angles;zeros(size(angles))];

            set(obj.ArrayObj,'ElementPosition',xy);
            set(obj.ArrayObj,'ElementNormal',nDir);

            obj.expandRangeForFreq();
            el=obj.getCurElementType();
            obj.ArrayObj.Element=el.getElement(obj);

        end

        function as=getArraySizeWithoutSave(~,pending)
            as=pending.ElemOnRing*pending.NumRings;
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


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:ElementsRing')),':']);
            c.Tag=[obj.ShortName,'_ElemOnRingTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ElementsRingCylTT'));
            c.ValidAttributes={'real','scalar','>=',4,'integer','finite','nonempty','nonnan'};
            connectPropertyAndControl(obj,'ElemOnRing',c);
            obj.newrow


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:NumRings')),':']);
            c.Tag=[obj.ShortName,'_NumRingsTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:NumRingsTT'));
            c.ValidAttributes={'real','scalar','>=',2,'integer','finite','nonempty','nonnan'};
            connectPropertyAndControl(obj,'NumRings',c);
            obj.newrow


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:RingSpacing')),':']);
            c.Tag=[obj.ShortName,'_RingSpacingTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:RingSpacingTT'));
            c.ValidAttributes={'real','scalar','positive','finite','nonempty','nonnan'};
            connectPropertyAndControl(obj,'RingSpacing',c);

            c=uipopup(obj,{getString(message('phased:apps:arrayapp:meter')),...
            getString(message('phased:apps:arrayapp:Lambda'))});
            c.Tag=[obj.ShortName,'_RingSpacingUnitsTag'];
            connectPropertyAndControl(obj,'RingSpacingUnitsIndex',c,'value');
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

            usingLambda=pending.RadiusUnitsIndex~=1||pending.RingSpacingUnitsIndex~=1;

            if~isscalar(SigFreqs)&&usingLambda
                e=MException('SensorArray:InvalidWavelength','Signal Frequencies must be scalar when using wavelength units');
                throwAsCaller(e);
            end

        end

    end

    methods
        function genCode(obj,mcode)

            radiusRatio=1;
            ringRatio=1;
            if obj.RadiusUnitsIndex~=1
                radiusRatio=obj.PropSpeed/obj.SignalFreqs(1);
            end
            if obj.RingSpacingUnitsIndex~=1
                ringRatio=obj.PropSpeed/obj.SignalFreqs(1);
            end

            mcode.addcr('% Create a cylindrical array');
            mcode.addcr(['R = ',num2str(obj.Radius*radiusRatio),';']);
            mcode.addcr(['N = ',num2str(obj.ElemOnRing),';']);
            mcode.addcr(['RS = ',num2str(obj.RingSpacing*ringRatio),';']);
            mcode.addcr(['NR = ',num2str(obj.NumRings),';']);
            mcode.addcr('angles = (0:N-1)/N*360-180;');
            mcode.addcr('xy = [R*cosd(angles); R*sind(angles)];');
            mcode.addcr('Height = RS * NR;');
            mcode.addcr('z = -Height/2:RS:Height/2;');
            mcode.addcr('xy = kron(ones(1, NR),xy);');
            mcode.addcr('xy = [xy;zeros(1,size(xy,2))];');
            mcode.addcr('angles = kron(ones(1,NR),angles);');
            mcode.addcr('for idx = 1:NR');
            mcode.addcr('    xy(3,(idx-1)*N+1:idx*N) = z(idx);');
            mcode.addcr('end');
            mcode.addcr('nDir = [angles;zeros(size(angles))];');
            mcode.addcr('h = phased.ConformalArray(''ElementPosition'', xy, ...');
            mcode.addcr('   ''ElementNormal'', nDir);');

        end
    end

end

