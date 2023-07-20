classdef(Hidden,Sealed)SphericalDialog<handle





    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

NumElementsLabel
NumElementsEdit

RadiusLabel
RadiusEdit
RadiusUnits

TaperLabel
TaperEdit

        ArrayDialogTitle=getString(message('phased:apps:arrayapp:Spherical'));
    end

    properties(Dependent)
ElementsOnCircum
Radius
Taper
    end

    properties(Access=private)
Parent
Layout

        ValidNumElements=10
        ValidRadius=1
        ValidTaper=1
    end

    methods
        function obj=SphericalDialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods


        function val=get.ElementsOnCircum(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.NumElementsEdit.String);
            else
                val=evalin('base',obj.NumElementsEdit.Value);
            end
        end

        function set.ElementsOnCircum(obj,val)
            if~isUIFigure(obj.Parent)
                obj.NumElementsEdit.String=num2str(val);
            else
                obj.NumElementsEdit.Value=num2str(val);
            end
        end


        function val=get.Radius(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.RadiusEdit.String);
            else
                val=evalin('base',obj.RadiusEdit.Value);
            end
        end

        function set.Radius(obj,val)
            if~isUIFigure(obj.Parent)
                obj.RadiusEdit.String=num2str(val);
            else
                obj.RadiusEdit.Value=num2str(val);
            end
        end


        function val=get.Taper(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.TaperEdit.String);
            else
                val=evalin('base',obj.TaperEdit.Value);
            end
        end

        function set.Taper(obj,val)
            if~isUIFigure(obj.Parent)
                obj.TaperEdit.String=mat2str(val);
            else
                obj.TaperEdit.Value=mat2str(val);
            end
        end



        function updateArrayObject(obj)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            if obj.Parent.isUsingLambda(obj.RadiusUnits)
                ratio=propSpeed/freq;
            else
                ratio=1;
            end

            d=360/obj.ElementsOnCircum;
            R=obj.Radius*ratio;
            az=-180:d:180-d;
            el=-(90-d):d:90-d;
            [az_grid,el_grid]=meshgrid(az,el);
            poles=[0,0;-90,90];
            nDir=[poles,[az_grid(:),el_grid(:)]'];
            N=size(nDir,2);
            [x,y,z]=sph2cart(deg2rad(nDir(1,:)),...
            deg2rad(nDir(2,:)),R*ones(1,N));


            obj.Parent.App.CurrentArray=phased.ConformalArray(...
            'Element',obj.Parent.App.CurrentElement,...
            'ElementPosition',[x;y;z],...
            'ElementNormal',nDir,...
            'Taper',obj.Taper);
        end

        function validParams=verifyParameters(obj)


            SigFreqs=obj.Parent.ElementDialog.SignalFreq;
            usingLambda=obj.Parent.isUsingLambda(obj.RadiusUnits);


            validParams=checkValidityOfWaveLengthUnits(obj.Parent,usingLambda,SigFreqs);
        end

        function numElem=getNumElements(obj)
            numElem=obj.ElementsOnCircum*(obj.ElementsOnCircum/2-1)+2;
        end

        function gencode(obj,sw)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            addcr(sw,'% Create a spherical array');
            addcr(sw,['d =  360/',mat2str(obj.ElementsOnCircum),';']);
            if obj.Parent.isUsingLambda(obj.RadiusUnits)
                ratio=propSpeed/freq;
                addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                addcr(sw,['Radius = ',mat2str(obj.Radius),' * ',mat2str(ratio),';']);
            else
                addcr(sw,['Radius = ',mat2str(obj.Radius),';']);
            end
            addcr(sw,'az = -180:d:180-d;');
            addcr(sw,'el = -(90-d):d:90-d;');
            addcr(sw,'[az_grid, el_grid] = meshgrid(az,el);');
            addcr(sw,'poles = [0 0; -90 90];');
            addcr(sw,'nDir = [poles [az_grid(:) el_grid(:)]''];');
            addcr(sw,'N = size(nDir,2);');
            addcr(sw,'[x, y, z] = sph2cart(deg2rad(nDir(1,:)), ...');
            addcr(sw,'    deg2rad(nDir(2,:)),Radius*ones(1,N));');
            addcr(sw,'Array = phased.ConformalArray(''ElementPosition'', [x;y;z], ...');
            if~isUIFigure(obj.Parent)
                addcr(sw,['   ''ElementNormal'', nDir, ''Taper'',',obj.TaperEdit.String,');']);
            else
                addcr(sw,['   ''ElementNormal'', nDir, ''Taper'',',obj.TaperEdit.Value,');']);
            end
        end

        function genreport(obj,sw)

            if isa(obj.Parent.App.CurrentArray,'phased.ReplicatedSubarray')
                addcr(sw,'% Subarray Type ........................................ Spherical Subarray')
            else
                addcr(sw,'% Array Type ........................................... Spherical Array')
            end
            addcr(sw,['% Radius (m) ........................................... ',mat2str(obj.Radius)])
            addcr(sw,['% Elements on Circumference ............................ ',mat2str(obj.ElementsOnCircum)])
            if~isUIFigure(obj.Parent)
                addcr(sw,['% Taper ................................................ ',obj.TaperEdit.String])
            else
                addcr(sw,['% Taper ................................................ ',obj.TaperEdit.Value])
            end
        end

        function title=assignArrayDialogTitle(obj)

            if obj.Parent.App.IsSubarray
                if strcmp(obj.Parent.AdditionalConfigDialog.SubarrayType,...
                    getString(message('phased:apps:arrayapp:replicatesubarray')))
                    title=[getString(message('phased:apps:arrayapp:subarraygeo')),...
                    ' - ',obj.ArrayDialogTitle];
                else
                    title=[getString(...
                    message('phased:apps:arrayapp:ArrayGeometry')),' - ',...
                    obj.ArrayDialogTitle];
                end
            else
                title=[getString(...
                message('phased:apps:arrayapp:ArrayGeometry')),' - ',...
                obj.ArrayDialogTitle];
            end
        end
    end

    methods(Access=private)
        function createUIControls(obj)

            dialogtitle=assignArrayDialogTitle(obj);
            if~isUIFigure(obj.Parent)
                obj.Panel=obj.Parent.createPanel(obj.Parent.App.ParametersFig,...
                dialogtitle);
            else
                obj.Panel=obj.Parent.createPanel(obj.Parent.Layout,...
                dialogtitle);
            end

            hspacing=3;
            vspacing=4;


            obj.Layout=obj.Parent.createLayout(obj.Panel,...
            vspacing,hspacing,...
            [0,0,0,0,0,0,1],[0,1,0]);

            if~isUIFigure(obj.Parent)
                parent=obj.Panel;
            else
                parent=obj.Layout;
            end

            obj.NumElementsLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:ElementsCircum')));

            obj.NumElementsEdit=obj.Parent.createEditBox(parent,...
            '10',getString(...
            message('phased:apps:arrayapp:ElementsCircumTT')),...
            'numElemEdit',@(h,e)parameterChanged(obj,e));


            obj.RadiusLabel=obj.Parent.createTextLabel(parent,...
            getString(...
            message('phased:apps:arrayapp:Radius')));

            obj.RadiusEdit=obj.Parent.createEditBox(parent,...
            '1',getString(...
            message('phased:apps:arrayapp:RadiusTT')),...
            'radiusEdit',@(h,e)parameterChanged(obj,e));

            radUnits={getString(message('phased:apps:arrayapp:meter')),...
            char(955)};

            obj.RadiusUnits=obj.Parent.createDropDown(parent,...
            radUnits,1,' ',...
            'radiusUnit',@(h,e)parameterChanged(obj,e));


            obj.TaperLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:CustomTaper')));

            obj.TaperEdit=obj.Parent.createEditBox(parent,...
            '1',getString(...
            message('phased:apps:arrayapp:CustomTaperTT')),...
            'taperEdit',@(h,e)parameterChanged(obj,e));
        end

        function layoutUIControls(obj)
            if~isUIFigure(obj.Parent)
                w1=obj.Parent.Width1;
                w2=obj.Parent.Width2;
                w3=obj.Parent.Width3;

                row=1;

                uiControlsHt=24;
                row=row+1;
                obj.Parent.addText(obj.Layout,obj.NumElementsLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.NumElementsEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.RadiusLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.RadiusEdit,row,2,w2,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.RadiusUnits,row,3,w3,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.TaperLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.TaperEdit,row,2,w2,uiControlsHt)


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.NumElementsLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.NumElementsEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.RadiusLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.RadiusEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.RadiusUnits.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',3);
                obj.TaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.TaperEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
            end
        end

        function parameterChanged(obj,e)




            prop=e.Source.Tag;
            switch prop
            case 'numElemEdit'
                try
                    sigdatatypes.validateIndex(obj.ElementsOnCircum,...
                    '','NumElements',{'real','scalar','>=',4,...
                    'integer','finite','nonempty','nonnan'});
                    obj.ValidNumElements=obj.ElementsOnCircum;
                catch me
                    obj.ElementsOnCircum=obj.ValidNumElements;
                    throwError(obj.Parent.App,me);
                    return;
                end

            case 'radiusEdit'
                try
                    sigdatatypes.validateDistance(obj.Radius,'',...
                    'Radius',{'real','scalar','positive','finite',...
                    'nonempty','nonnan'});
                    obj.ValidRadius=obj.Radius;
                catch me
                    obj.Radius=obj.ValidRadius;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'taperEdit'
                try
                    validateattributes(obj.Taper,{'double'},...
                    {'nonnan','nonempty','finite','vector'},...
                    '','Taper');
                    obj.ValidTaper=obj.Taper;
                catch me
                    obj.Taper=obj.ValidTaper;
                    throwError(obj.Parent.App,me);
                    return;
                end
            end


            enableAnalyzeButton(obj.Parent.App);
        end
    end
end
