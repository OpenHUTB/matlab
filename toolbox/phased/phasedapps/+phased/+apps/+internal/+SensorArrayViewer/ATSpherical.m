


classdef ATSpherical<phased.apps.internal.SensorArrayViewer.ArrayType

    properties(SetObservable)
        Radius=1
        RadiusUnitsIndex=1
        ElemOnCirc=10
        CustomTaper=1
    end

    properties(SetAccess=private)
        TranslatedName=getString(message('phased:apps:arrayapp:Spherical'));
        ShortName='Sph'
    end

    methods
        function obj=ATSpherical(dlg)

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

            ratio=1;
            if obj.RadiusUnitsIndex~=1
                ratio=obj.PropSpeed/obj.SignalFreqs(1);
            end

            d=360/obj.ElemOnCirc;
            R=obj.Radius*ratio;
            az=-180:d:180-d;
            el=-(90-d):d:90-d;
            [az_grid,el_grid]=meshgrid(az,el);
            poles=[0,0;-90,90];
            nDir=[poles,[az_grid(:),el_grid(:)]'];
            N=size(nDir,2);
            [x,y,z]=sph2cart(deg2rad(nDir(1,:)),...
            deg2rad(nDir(2,:)),R*ones(1,N));

            set(obj.ArrayObj,'ElementPosition',[x;y;z]);
            set(obj.ArrayObj,'ElementNormal',nDir);

            obj.expandRangeForFreq();
            el=obj.getCurElementType();
            obj.ArrayObj.Element=el.getElement(obj);

        end

        function as=getArraySizeWithoutSave(~,pending)

            as=pending.ElemOnCirc*(pending.ElemOnCirc/2-1)+2;
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


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:ElementsCircum')),':']);
            c.Tag=[obj.ShortName,'_ElemOnCircTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ElementsCircumTT'));
            c.ValidAttributes={'real','scalar','>=',4,'integer','finite','nonempty','nonnan'};
            connectPropertyAndControl(obj,'ElemOnCirc',c);
            obj.newrow

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

            mcode.addcr('% Create a spherical array');
            mcode.addcr(['d = ',num2str(360/obj.ElemOnCirc),';']);
            mcode.addcr(['R = ',num2str(obj.Radius*ratio),';']);
            mcode.addcr('az = -180:d:180-d;');
            mcode.addcr('el = -(90-d):d:90-d;');
            mcode.addcr('[az_grid, el_grid] = meshgrid(az,el);');
            mcode.addcr('poles = [0 0; -90 90];');
            mcode.addcr('nDir = [poles [az_grid(:) el_grid(:)]''];');
            mcode.addcr('N = size(nDir,2);');
            mcode.addcr('[x, y, z] = sph2cart(deg2rad(nDir(1,:)), ...');
            mcode.addcr('    deg2rad(nDir(2,:)),R*ones(1,N));');
            mcode.addcr('h = phased.ConformalArray(''ElementPosition'', [x;y;z], ...');
            mcode.addcr('   ''ElementNormal'', nDir);');

        end
    end

end

