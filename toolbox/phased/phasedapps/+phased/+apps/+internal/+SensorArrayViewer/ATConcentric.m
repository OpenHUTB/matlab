


classdef ATConcentric<phased.apps.internal.SensorArrayViewer.ArrayType

    properties(SetObservable)
        Radius=[1,1.5,2]
        RadiusUnitsIndex=1
        ElemOnRing=[4,8,16]
        CustomTaper=1
    end

    properties(SetAccess=private)
        TranslatedName=getString(message('phased:apps:arrayapp:Concentric'));
        ShortName='Con'
    end

    methods
        function obj=ATConcentric(dlg)

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

            shift=0;
            radius=obj.Radius*ratio;
            n=obj.ElemOnRing;
            if length(n)==1
                n=n*ones(1,length(radius));
            end
            Nelements=sum(n);
            stop=cumsum(n);
            start=stop-n+1;
            actual_pos=zeros(3,Nelements);
            for idx=1:length(n)
                angles=(0:n(idx)-1)*360/n(idx);
                angles=angles+shift;
                shift=sum(angles(1:2))/2;
                pos=[zeros(1,length(angles));cosd(angles);sind(angles)];
                actual_pos(:,start(idx):stop(idx))=pos*radius(idx);
            end
            elNormal=[ones(1,Nelements);zeros(1,Nelements)];

            set(obj.ArrayObj,'ElementPosition',actual_pos);
            set(obj.ArrayObj,'ElementNormal',elNormal);

            obj.expandRangeForFreq();
            el=obj.getCurElementType();
            obj.ArrayObj.Element=el.getElement(obj);

        end

        function as=getArraySizeWithoutSave(~,pending)
            as=sum(pending.ElemOnRing);
        end
    end

    methods(Access=protected)

        function initTable(obj)

            initTable@phased.apps.internal.SensorArrayViewer.ArrayType(obj);


            c=uieditv(obj,'[1 1.5 2]','label',[getString(message('phased:apps:arrayapp:Radius')),':']);
            c.Tag=[obj.ShortName,'_RadiusTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:RadiusTT'));
            c.ValidAttributes={'real','row','positive','finite','nonempty','nonnan'};
            connectPropertyAndControl(obj,'Radius',c);

            c=uipopup(obj,{getString(message('phased:apps:arrayapp:meter')),...
            getString(message('phased:apps:arrayapp:Lambda'))});
            c.Tag=[obj.ShortName,'_RadiusUnitsTag'];
            connectPropertyAndControl(obj,'RadiusUnitsIndex',c,'value');
            obj.newrow;


            c=uieditv(obj,'[4 8 16]','label',[getString(message('phased:apps:arrayapp:ElementsRing')),':']);
            c.Tag=[obj.ShortName,'_ElemOnRingTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ElementsRingTT'));
            c.ValidAttributes={'real','row','>=',2,'integer','finite','nonempty','nonnan'};
            connectPropertyAndControl(obj,'ElemOnRing',c);
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


            radius=pending.Radius;
            elemOnRing=pending.ElemOnRing;

            if~isscalar(elemOnRing)&&length(radius)~=length(elemOnRing)
                e=MException('SensorArray:LengthMismatch','Radius and Elements on Ring are not compatible in length');
                throwAsCaller(e);
            end


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

            mcode.addcr('% Create a concentric array');
            mcode.addcr('shift = 0;');
            mcode.addcr(['radius = ',mat2str(obj.Radius*ratio),';']);
            mcode.addcr(['n = ',mat2str(obj.ElemOnRing),';']);
            mcode.addcr('if length(n) == 1');
            mcode.addcr('    n = n*ones(1, length(radius));');
            mcode.addcr('end');
            mcode.addcr('Nelements = sum(n);');
            mcode.addcr('stop = cumsum(n);');
            mcode.addcr('start = stop - n + 1;');
            mcode.addcr('actual_pos = zeros(3, Nelements);');
            mcode.addcr('for idx = 1:length(n)');
            mcode.addcr('    angles = (0:n(idx)-1)*360/n(idx);');
            mcode.addcr('    angles = angles + shift;');
            mcode.addcr('    shift = sum(angles(1:2))/2;');
            mcode.addcr('    pos = [zeros(1, length(angles));cosd(angles);sind(angles)];');
            mcode.addcr('    actual_pos(:, start(idx):stop(idx)) = pos*radius(idx);');
            mcode.addcr('end');
            mcode.addcr('elNormal = [ones(1,Nelements);zeros(1,Nelements)];');
            mcode.addcr('h = phased.ConformalArray(''ElementPosition'', actual_pos, ...');
            mcode.addcr('   ''ElementNormal'', elNormal);');

        end
    end

end

