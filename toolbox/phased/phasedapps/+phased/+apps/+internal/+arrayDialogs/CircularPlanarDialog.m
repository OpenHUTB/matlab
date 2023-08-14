classdef(Hidden,Sealed)CircularPlanarDialog<handle






    properties(Hidden,SetAccess=private)

Panel
        Width=0
        Height=0
Listeners

ElementSpacingLabel
ElementSpacingEdit
ElementSpacingUnits

RadiusLabel
RadiusEdit
RadiusUnits

LatticeLabel
LatticePopup

TaperLabel
TaperEdit

        ArrayDialogTitle=getString(message('phased:apps:arrayapp:CircularPlanar'));
    end

    properties(Dependent)
ElementSpacing
Radius
Lattice
Taper
    end

    properties(Access=private)
Parent
Layout

        ValidElementSpacing=0.5
        ValidRadius=1
        ValidTaper=1
        ValidLattice=getString(message('phased:apps:arrayapp:Rectangular'));
    end

    methods
        function obj=CircularPlanarDialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods


        function val=get.ElementSpacing(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.ElementSpacingEdit.String);
            else
                val=evalin('base',obj.ElementSpacingEdit.Value);
            end
        end

        function set.ElementSpacing(obj,val)
            if~isUIFigure(obj.Parent)
                obj.ElementSpacingEdit.String=num2str(val);
            else
                obj.ElementSpacingEdit.Value=num2str(val);
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


        function val=get.Lattice(obj)
            if~isUIFigure(obj.Parent)
                val=obj.LatticePopup.String{obj.LatticePopup.Value};
            else
                val=obj.LatticePopup.Value;
            end
        end

        function set.Lattice(obj,str)
            if~isUIFigure(obj.Parent)
                if strcmp(str,'Rectangular')
                    obj.LatticePopup.Value=1;
                elseif strcmp(str,'Triangular')
                    obj.LatticePopup.Value=2;
                end
            else
                if strcmp(str,'Rectangular')
                    obj.LatticePopup.Value='Rectangular';
                elseif strcmp(str,'Triangular')
                    obj.LatticePopup.Value='Triangular';
                end
            end
        end



        function updateArrayObject(obj)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            pos=formCircularPlanarArray(obj,propSpeed,freq);


            obj.Parent.App.CurrentArray=phased.ConformalArray(...
            'Element',obj.Parent.App.CurrentElement,...
            'ElementPosition',pos,...
            'ElementNormal',[1;0]*ones(1,size(pos,2)),...
            'Taper',obj.Taper);
        end

        function pos=formCircularPlanarArray(obj,propSpeed,freq)
            if obj.Parent.isUsingLambda(obj.RadiusUnits)
                radiusRatio=propSpeed/freq;
            else
                radiusRatio=1;
            end

            if obj.Parent.isUsingLambda(obj.ElementSpacingUnits)
                elemSpacingRatio=propSpeed/freq;
            else
                elemSpacingRatio=1;
            end

            radius=obj.Radius*radiusRatio;
            delta=obj.ElementSpacing*elemSpacingRatio;
            n=round(radius/delta*2);

            if n<2
                error('SensorArray:InvalidNumElements',...
                getString(message('phased:apps:arrayapp:NumElementsSmall')));
            end

            htemp=phased.URA(n,delta,...
            'Lattice',obj.Lattice);
            pos=getElementPosition(htemp);
            elemToRemove=sum(pos.^2)>radius^2;
            pos(:,elemToRemove)=[];
        end

        function validParams=verifyParameters(obj)


            SigFreqs=obj.Parent.ElementDialog.SignalFreq;
            usingLambda=obj.Parent.isUsingLambda(obj.RadiusUnits)||...
            obj.Parent.isUsingLambda(obj.ElementSpacingUnits);


            validParams=checkValidityOfWaveLengthUnits(obj.Parent,usingLambda,SigFreqs);
        end

        function numElem=getNumElements(obj)
            propSpeed=obj.Parent.ElementDialog.PropSpeed;
            freq=obj.Parent.ElementDialog.SignalFreq(1);

            pos=formCircularPlanarArray(obj,propSpeed,freq);
            numElem=size(pos,2);
        end

        function gencode(obj,sw)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            addcr(sw,'% Create a circular planar array');
            if obj.Parent.isUsingLambda(obj.RadiusUnits)
                radiusRatio=propSpeed/freq;
                addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                addcr(sw,['radius = ',mat2str(obj.Radius),' * ',mat2str(radiusRatio),';']);
            else
                addcr(sw,['radius = ',mat2str(obj.Radius),';'])
            end

            if obj.Parent.isUsingLambda(obj.ElementSpacingUnits)
                elemSpacingRatio=propSpeed/freq;
                addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                addcr(sw,['delta = ',mat2str(obj.ElementSpacing),' * ',mat2str(elemSpacingRatio),';']);
            else
                addcr(sw,['delta = ',mat2str(obj.ElementSpacing),';'])
            end
            addcr(sw,'n = round(radius/delta*2);');
            addcr(sw,'htemp = phased.URA(n, delta, ...');
            addcr(sw,['   ''Lattice'', ''',obj.Lattice,''');']);
            addcr(sw,'pos = getElementPosition(htemp);');
            addcr(sw,'elemToRemove = sum(pos.^2)>radius^2;');
            addcr(sw,'pos(:,elemToRemove) = [];');
            addcr(sw,'Array = phased.ConformalArray(''ElementPosition'', pos, ...');
            if~isUIFigure(obj.Parent)
                addcr(sw,['   ''ElementNormal'', [1;0]*ones(1,size(pos,2)),''Taper'',',obj.TaperEdit.String,');']);
            else
                addcr(sw,['   ''ElementNormal'', [1;0]*ones(1,size(pos,2)),''Taper'',',obj.TaperEdit.Value,');']);
            end
        end

        function genreport(obj,sw)

            if isa(obj.Parent.App.CurrentArray,'phased.ReplicatedSubarray')
                addcr(sw,'% Subarray Type ........................................ Circular Planar Subarray')
            else
                addcr(sw,'% Array Type ........................................... Circular Planar Array')
            end
            addcr(sw,['% Radius (m) ........................................... ',mat2str(obj.Radius)])
            addcr(sw,['% Element Spacing (m) .................................. ',mat2str(obj.ElementSpacing)])
            addcr(sw,['% Lattice .............................................. ',obj.Lattice])
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
            vspacing=5;


            obj.Layout=obj.Parent.createLayout(obj.Panel,...
            vspacing,hspacing,...
            [0,0,0,0,0,0,1],[0,1,0]);

            if~isUIFigure(obj.Parent)
                parent=obj.Panel;
            else
                parent=obj.Layout;
            end

            obj.ElementSpacingLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:ElementSpacing')));

            obj.ElementSpacingEdit=obj.Parent.createEditBox(...
            parent,'0.5',...
            getString(...
            message('phased:apps:arrayapp:ElementSpacingTT')),...
            'elementSpacingEdit',@(h,e)parameterChanged(obj,e));

            unitStrings={getString(message('phased:apps:arrayapp:meter')),...
            char(955)};

            obj.ElementSpacingUnits=obj.Parent.createDropDown(...
            parent,...
            unitStrings,1,' ',...
            'elementSpacingUnit',@(h,e)parameterChanged(obj,e));

            obj.RadiusLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:Radius')));

            obj.RadiusEdit=obj.Parent.createEditBox(parent,...
            '1',getString(...
            message('phased:apps:arrayapp:RadiusTT')),...
            'radiusEdit',@(h,e)parameterChanged(obj,e));

            radUnits={getString(message('phased:apps:arrayapp:meter')),...
            char(955)};

            obj.RadiusUnits=obj.Parent.createDropDown(...
            parent,radUnits,1,' ',...
            'radiusUnit',@(h,e)parameterChanged(obj,e));

            obj.LatticeLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:Lattice')));

            LatticeNames={getString(message('phased:apps:arrayapp:Rectangular')),...
            getString(message('phased:apps:arrayapp:Triangular'))};

            obj.LatticePopup=obj.Parent.createDropDown(parent,...
            LatticeNames,1,getString(...
            message('phased:apps:arrayapp:LatticeTT')),...
            'latticePopup',@(h,e)parameterChanged(obj,e));

            obj.TaperLabel=obj.Parent.createTextLabel(parent,...
            getString(...
            message('phased:apps:arrayapp:CustomTaper')));

            obj.TaperEdit=obj.Parent.createEditBox(parent,'1',...
            getString(...
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
                obj.Parent.addText(obj.Layout,obj.ElementSpacingLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ElementSpacingEdit,row,2,w2,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.ElementSpacingUnits,row,3,w3,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.RadiusLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.RadiusEdit,row,2,w2,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.RadiusUnits,row,3,w3,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.LatticeLabel,row,1,w1,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.LatticePopup,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.TaperLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.TaperEdit,row,2,w2,uiControlsHt)

                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.ElementSpacingLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.ElementSpacingEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.ElementSpacingUnits.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',3);
                obj.RadiusLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.RadiusEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.RadiusUnits.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',3);
                obj.LatticeLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.LatticePopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.TaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.TaperEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
            end
        end

        function parameterChanged(obj,e)




            prop=e.Source.Tag;
            switch prop
            case 'elementSpacingEdit'
                try
                    sigdatatypes.validateDistance(...
                    obj.ElementSpacing,'','Element Spacing',...
                    {'scalar','positive','finite'});
                    obj.ValidElementSpacing=obj.ElementSpacing;
                catch me
                    obj.ElementSpacing=obj.ValidElementSpacing;
                    throwError(obj.Parent.App,me);
                    return;
                end

            case 'radiusEdit'
                try
                    sigdatatypes.validateDistance(obj.Radius,'',...
                    'Radius',{'scalar','positive','finite'});
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
