classdef(Hidden,Sealed)CylindricalDialog<handle





    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

NumRingsLabel
NumRingsEdit

ElementsOnRingLabel
ElementsOnRingEdit

RadiusLabel
RadiusEdit
RadiusUnits

RingSpacingLabel
RingSpacingEdit
RingSpacingUnits

TaperLabel
TaperEdit

        ArrayDialogTitle=getString(message('phased:apps:arrayapp:Cylindrical'));
    end


    properties(Dependent)
ElementsOnRing
NumRings
RingSpacing
Radius
Taper
    end


    properties(Access=private)
Parent
Layout

        ValidNumElements=10
        ValidNumRings=10
        ValidRadius=1
        ValidRingSpacing=0.5
        ValidTaper=1
    end

    methods
        function obj=CylindricalDialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods

        function val=get.ElementsOnRing(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.ElementsOnRingEdit.String);
            else
                val=evalin('base',obj.ElementsOnRingEdit.Value);
            end
        end

        function set.ElementsOnRing(obj,val)
            if~isUIFigure(obj.Parent)
                obj.ElementsOnRingEdit.String=num2str(val);
            else
                obj.ElementsOnRingEdit.Value=num2str(val);
            end
        end


        function val=get.NumRings(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.NumRingsEdit.String);
            else
                val=evalin('base',obj.NumRingsEdit.Value);
            end
        end

        function set.NumRings(obj,val)
            if~isUIFigure(obj.Parent)
                obj.NumRingsEdit.String=num2str(val);
            else
                obj.NumRingsEdit.Value=num2str(val);
            end
        end


        function val=get.RingSpacing(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.RingSpacingEdit.String);
            else
                val=evalin('base',obj.RingSpacingEdit.Value);
            end
        end

        function set.RingSpacing(obj,val)
            if~isUIFigure(obj.Parent)
                obj.RingSpacingEdit.String=num2str(val);
            else
                obj.RingSpacingEdit.Value=num2str(val);
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
                radiusRatio=propSpeed/freq;
            else
                radiusRatio=1;
            end

            if obj.Parent.isUsingLambda(obj.RingSpacingUnits)
                ringRatio=propSpeed/freq;
            else
                ringRatio=1;
            end

            R=obj.Radius*radiusRatio;
            N=obj.ElementsOnRing;
            RS=obj.RingSpacing*ringRatio;
            NR=obj.NumRings;
            angles=(0:N-1)/N*360-180;
            xy=[R*cosd(angles);R*sind(angles)];
            height=RS*NR;
            z=-height/2:RS:height/2;
            xy=kron(ones(1,NR),xy);
            xy=[xy;zeros(1,size(xy,2))];
            angles=kron(ones(1,NR),angles);
            for idx=1:NR
                xy(3,(idx-1)*N+1:idx*N)=z(idx);
            end
            nDir=[angles;zeros(size(angles))];


            obj.Parent.App.CurrentArray=phased.ConformalArray(...
            'Element',obj.Parent.App.CurrentElement,...
            'ElementPosition',xy,...
            'ElementNormal',nDir,...
            'Taper',obj.Taper);
        end

        function validParams=verifyParameters(obj)


            SigFreqs=obj.Parent.ElementDialog.SignalFreq;
            usingLambda=obj.Parent.isUsingLambda(obj.RadiusUnits)||...
            obj.Parent.isUsingLambda(obj.RingSpacingUnits);


            validParams=checkValidityOfWaveLengthUnits(obj.Parent,usingLambda,SigFreqs);
        end

        function numElem=getNumElements(obj)
            numElem=obj.ElementsOnRing*obj.NumRings;
        end

        function gencode(obj,sw)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            addcr(sw,'% Create a cylindrical array');
            if obj.Parent.isUsingLambda(obj.RadiusUnits)
                radiusRatio=propSpeed/freq;
                addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                addcr(sw,['Radius = ',mat2str(obj.Radius),' * ',mat2str(radiusRatio),';']);
            else
                addcr(sw,['Radius = ',mat2str(obj.Radius),';']);
            end

            addcr(sw,['NumElements = ',mat2str(obj.ElementsOnRing),';']);

            if obj.Parent.isUsingLambda(obj.RingSpacingUnits)
                ringRatio=propSpeed/freq;
                addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                addcr(sw,['RingSpacing = ',mat2str(obj.RingSpacing),' * ',mat2str(ringRatio),';']);
            else
                addcr(sw,['RingSpacing = ',mat2str(obj.RingSpacing),';']);
            end

            addcr(sw,['NumRings = ',mat2str(obj.NumRings),';']);
            addcr(sw,'angles = (0:NumElements-1)/NumElements*360-180;');
            addcr(sw,'xy = [Radius*cosd(angles); Radius*sind(angles)];');
            addcr(sw,'Height = RingSpacing * NumRings;');
            addcr(sw,'z = -Height/2:RingSpacing:Height/2;');
            addcr(sw,'xy = kron(ones(1, NumRings),xy);');
            addcr(sw,'xy = [xy;zeros(1,size(xy,2))];');
            addcr(sw,'angles = kron(ones(1,NumRings),angles);');
            addcr(sw,'for idx = 1:NumRings');
            addcr(sw,'    xy(3,(idx-1)*NumElements+1:idx*NumElements) = z(idx);');
            addcr(sw,'end');
            addcr(sw,'nDir = [angles;zeros(size(angles))];');
            addcr(sw,'Array = phased.ConformalArray(''ElementPosition'', xy, ...');
            if~isUIFigure(obj.Parent)
                addcr(sw,['   ''ElementNormal'', nDir, ''Taper'',',obj.TaperEdit.String,');']);
            else
                addcr(sw,['   ''ElementNormal'', nDir, ''Taper'',',obj.TaperEdit.Value,');']);
            end
        end

        function genreport(obj,sw)

            if isa(obj.Parent.App.CurrentArray,'phased.ReplicatedSubarray')
                addcr(sw,'% Subarray Type ........................................ Cylindrical Subarray')
            else
                addcr(sw,'% Array Type ........................................... Cylindrical Array')
            end
            addcr(sw,['% Radius (m) ........................................... ',mat2str(obj.Radius)])
            addcr(sw,['% Elements on Ring ..................................... ',mat2str(obj.ElementsOnRing)])
            addcr(sw,['% Number of Rings ...................................... ',mat2str(obj.NumRings)])
            addcr(sw,['% Ring Spacing (m) ..................................... ',mat2str(obj.RingSpacing)])
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

            obj.NumRingsLabel=obj.Parent.createTextLabel(parent,...
            getString(...
            message('phased:apps:arrayapp:NumRings')));

            obj.NumRingsEdit=obj.Parent.createEditBox(parent,...
            '10',getString(...
            message('phased:apps:arrayapp:NumRingsTT')),...
            'numRingEdit',@(h,e)parameterChanged(obj,e));


            obj.ElementsOnRingLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:ElementsRing')));

            obj.ElementsOnRingEdit=obj.Parent.createEditBox(...
            parent,'10',...
            getString(...
            message('phased:apps:arrayapp:ElementsRingCylTT')),...
            'numElemEdit',@(h,e)parameterChanged(obj,e));


            obj.RingSpacingLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:RingSpacing')));

            obj.RingSpacingEdit=obj.Parent.createEditBox(...
            parent,'0.5',...
            getString(...
            message('phased:apps:arrayapp:RingSpacingTT')),...
            'ringSpacingEdit',@(h,e)parameterChanged(obj,e));

            unitsString={getString(message('phased:apps:arrayapp:meter')),...
            char(955)};

            obj.RingSpacingUnits=obj.Parent.createDropDown(parent,...
            unitsString,1,' ',...
            'ringSpacingUnit',@(h,e)parameterChanged(obj,e));


            obj.RadiusLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:Radius')));

            obj.RadiusEdit=obj.Parent.createEditBox(parent,...
            '1',getString(...
            message('phased:apps:arrayapp:RadiusTT')),...
            'radiusEdit',@(h,e)parameterChanged(obj,e));

            obj.RadiusUnits=obj.Parent.createDropDown(parent,...
            unitsString,1,' ',...
            'radiusUnit',@(h,e)parameterChanged(obj,e));


            obj.TaperLabel=obj.Parent.createTextLabel(parent,...
            getString(...
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
                obj.Parent.addText(obj.Layout,obj.RadiusLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.RadiusEdit,row,2,w2,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.RadiusUnits,row,3,w3,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ElementsOnRingLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ElementsOnRingEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.NumRingsLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.NumRingsEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.RingSpacingLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.RingSpacingEdit,row,2,w2,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.RingSpacingUnits,row,3,w3,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.TaperLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.TaperEdit,row,2,w2,uiControlsHt)


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.RadiusLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.RadiusEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.RadiusUnits.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',3);
                obj.ElementsOnRingLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.ElementsOnRingEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.NumRingsLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.NumRingsEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.RingSpacingLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.RingSpacingEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
                obj.RingSpacingUnits.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',3);
                obj.TaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',1);
                obj.TaperEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',2);
            end
        end

        function parameterChanged(obj,e)




            prop=e.Source.Tag;
            switch prop
            case 'numElemEdit'
                try
                    sigdatatypes.validateIndex(obj.ElementsOnRing,...
                    '','ElementsOnRing',{'real','scalar','>=',4,...
                    'integer','finite','nonempty','nonnan'});
                    obj.ValidNumElements=obj.ElementsOnRing;
                catch me
                    obj.ElementsOnRing=obj.ValidNumElements;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'numRingEdit'
                try
                    sigdatatypes.validateIndex(obj.NumRings,...
                    '','NumRings',{'real','scalar','>=',2,...
                    'integer','finite','nonempty','nonnan'});
                    obj.ValidNumRings=obj.NumRings;
                catch me
                    obj.NumRings=obj.ValidNumRings;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'ringSpacingEdit'
                try
                    sigdatatypes.validateDistance(obj.RingSpacing,...
                    '','Ring Spacing',{'real','scalar',...
                    'positive','finite','nonempty','nonnan'});
                    obj.ValidRingSpacing=obj.RingSpacing;
                catch me
                    obj.RingSpacing=obj.ValidRingSpacing;
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
