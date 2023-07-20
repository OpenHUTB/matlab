


classdef ATUniformHexagonal<phased.apps.internal.SensorArrayViewer.ArrayType

    properties(SetObservable)
        NumElementsSide=4
        ElemSpacing=1
        ElemSpacingUnitsIndex=1
        CustomTaper=1
    end

    properties(SetAccess=private)
        TranslatedName=getString(message('phased:apps:arrayapp:uha'));
        ShortName='UHA';
    end

    methods
        function obj=ATUniformHexagonal(dlg)

            obj.ArrayObj=phased.ConformalArray();
            obj.CanPlotGratingLobe=true;

            if nargin<1
                return
            end

            obj.Application=dlg.Application;

        end

    end

    methods(Access=protected)

        function updateArrayObj(obj)

            ratio=1;
            if obj.ElemSpacingUnitsIndex~=1
                ratio=obj.PropSpeed/obj.SignalFreqs(1);
            end

            Nside=obj.NumElementsSide;
            delta=obj.ElemSpacing*ratio;
            rows=[1:Nside,Nside-1:-1:1];
            Radius=delta*(Nside-1);
            pos=zeros(3,1);
            count=0;
            for idx=1:length(rows)
                y=-Radius/2-(rows(idx)-1)*delta*0.5:delta:...
                Radius/2+(rows(idx)-1)*delta*0.5;
                pos(2,count+1:count+length(y))=y;
                pos(3,count+1:count+length(y))=sqrt(3)/2*Radius-...
                (idx-1)*delta*sind(60);
                count=count+length(y);
            end
            set(obj.ArrayObj,'ElementPosition',pos);
            set(obj.ArrayObj,'ElementNormal',zeros(2,size(pos,2)));

            obj.expandRangeForFreq();
            el=obj.getCurElementType();
            obj.ArrayObj.Element=el.getElement(obj);

        end

        function as=getArraySizeWithoutSave(~,pending)

            sideEl=pending.NumElementsSide;
            as=1+sum(6*(1:sideEl-1));
        end

    end

    methods(Access=protected)

        function initTable(obj)


            initTable@phased.apps.internal.SensorArrayViewer.ArrayType(obj);


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:ElementsSide')),':']);
            c.Tag=[obj.ShortName,'_ElementsSideTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ElementsSideTT'));
            c.ValidAttributes={'real','scalar','>=',2,'finite','integer','nonempty','nonnan'};
            connectPropertyAndControl(obj,'NumElementsSide',c);
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
            usingLambda=pending.ElemSpacingUnitsIndex~=1;

            if~isscalar(SigFreqs)&&usingLambda
                e=MException('SensorArray:InvalidWavelength','Signal Frequencies must be scalar when using wavelength units');
                throwAsCaller(e);
            end


        end
    end

    methods
        function genCode(obj,mcode)

            AS=obj.getArraySize();
            ratio=1;
            if obj.ElemSpacingUnitsIndex~=1
                ratio=obj.PropSpeed/obj.SignalFreqs(1);
            end

            mcode.addcr('% Create a uniform hexagonal array');
            mcode.addcr(['Nside = ',num2str(obj.NumElementsSide),';']);
            mcode.addcr(['delta = ',num2str(obj.ElemSpacing*ratio),';']);
            mcode.addcr('rows = [1:Nside Nside-1:-1:1];');
            mcode.addcr('Radius = delta * (Nside - 1);');
            mcode.addcr('pos = zeros(3,1);');
            mcode.addcr('count = 0;');
            mcode.addcr('for idx = 1:length(rows)');
            mcode.addcr('    y = -Radius/2 - (rows(idx)-1)*delta*0.5 : delta : ...');
            mcode.addcr('        Radius/2 + (rows(idx)-1)*delta*0.5;');
            mcode.addcr('    pos(2, count+1:count+length(y)) = y;');
            mcode.addcr('    pos(3, count+1:count+length(y)) = sqrt(3)/2*Radius - ...');
            mcode.addcr('        (idx-1)*delta*sind(60);');
            mcode.addcr('    count = count+length(y);');
            mcode.addcr('end');
            mcode.addcr('h = phased.ConformalArray(''ElementPosition'', pos, ...');
            mcode.addcr(['   ''ElementNormal'', zeros(2,',num2str(AS),'));']);

        end
    end
end

