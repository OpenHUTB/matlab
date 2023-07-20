classdef(Hidden,Sealed)ConcentricDialog<handle





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

        ArrayDialogTitle=getString(message('phased:apps:arrayapp:Concentric'));
    end

    properties(Dependent)
ElementsOnRing
Radius
Taper
    end

    properties(Access=private)
Parent
Layout

        ValidTaper=1
        ValidRadius=[1,1.5,2]
        ValidNumElements=[4,8,16]
    end

    methods
        function obj=ConcentricDialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods


        function val=get.ElementsOnRing(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.NumElementsEdit.String);
            else
                val=evalin('base',obj.NumElementsEdit.Value);
            end
        end

        function set.ElementsOnRing(obj,val)
            if~isUIFigure(obj.Parent)
                obj.NumElementsEdit.String=mat2str(val);
            else
                obj.NumElementsEdit.Value=mat2str(val);
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
                obj.RadiusEdit.String=mat2str(val);
            else
                obj.RadiusEdit.Value=mat2str(val);
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

            shift=0;
            radius=obj.Radius*ratio;
            n=obj.ElementsOnRing;
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


            obj.Parent.App.CurrentArray=phased.ConformalArray(...
            'Element',obj.Parent.App.CurrentElement,...
            'ElementPosition',actual_pos,...
            'ElementNormal',elNormal,...
            'Taper',obj.Taper);
        end

        function validParam=verifyParameters(obj)


            SigFreqs=obj.Parent.ElementDialog.SignalFreq;
            usingLambda=obj.Parent.isUsingLambda(obj.RadiusUnits);
            radius=obj.Radius;
            elemOnRing=obj.ElementsOnRing;

            if~isscalar(elemOnRing)&&length(radius)~=length(elemOnRing)
                if strcmp(obj.Parent.App.Container,'ToolGroup')
                    h=errordlg(getString(message('phased:apps:arrayapp:RadiusNumElements')),...
                    getString(message('phased:apps:arrayapp:errordlg')),...
                    'modal');
                    uiwait(h)
                else
                    uialert(obj.Parent.App.ToolGroup,getString(message('phased:apps:arrayapp:RadiusNumElements')),...
                    getString(message('phased:apps:arrayapp:errordlg')));
                end
                validElemRadius=false;
            else
                validElemRadius=true;
            end


            validSignalFreq=checkValidityOfWaveLengthUnits(obj.Parent,usingLambda,SigFreqs);
            validParam=validElemRadius&&validSignalFreq;
        end

        function numElem=getNumElements(obj)
            numElem=sum(obj.ElementsOnRing);
        end

        function gencode(obj,sw)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            addcr(sw,'% Create a concentric array');
            addcr(sw,'shift = 0;');
            if obj.Parent.isUsingLambda(obj.RadiusUnits)
                ratio=propSpeed/freq;
                addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                addcr(sw,['radius = ',mat2str(obj.Radius),' * ',mat2str(ratio),';']);
            else
                addcr(sw,['radius = ',mat2str(obj.Radius),';']);
            end
            addcr(sw,['n = ',mat2str(obj.ElementsOnRing),';']);
            addcr(sw,'if length(n) == 1');
            addcr(sw,'    n = n*ones(1, length(radius));');
            addcr(sw,'end');
            addcr(sw,'Nelements = sum(n);');
            addcr(sw,'stop = cumsum(n);');
            addcr(sw,'start = stop - n + 1;');
            addcr(sw,'actual_pos = zeros(3, Nelements);');
            addcr(sw,'for idx = 1:length(n)');
            addcr(sw,'    angles = (0:n(idx)-1)*360/n(idx);');
            addcr(sw,'    angles = angles + shift;');
            addcr(sw,'    shift = sum(angles(1:2))/2;');
            addcr(sw,'    pos = [zeros(1, length(angles));cosd(angles);sind(angles)];');
            addcr(sw,'    actual_pos(:, start(idx):stop(idx)) = pos*radius(idx);');
            addcr(sw,'end');
            addcr(sw,'elNormal = [ones(1,Nelements);zeros(1,Nelements)];');
            addcr(sw,'Array = phased.ConformalArray(''ElementPosition'', actual_pos, ...');
            if~isUIFigure(obj.Parent)
                addcr(sw,['   ''ElementNormal'', elNormal,''Taper'',',obj.TaperEdit.String,');']);
            else
                addcr(sw,['   ''ElementNormal'', elNormal,''Taper'',',obj.TaperEdit.Value,');']);
            end
        end

        function genreport(obj,sw)

            if isa(obj.Parent.App.CurrentArray,'phased.ReplicatedSubarray')
                addcr(sw,'% Subarray Type ........................................ Concentric Subarray')
            else
                addcr(sw,'% Array Type ........................................ Concentric Array')
            end
            addcr(sw,['% Radius (m) ........................................... ',mat2str(obj.Radius)])
            addcr(sw,['% Elements on Ring ..................................... ',mat2str(obj.ElementsOnRing)])
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
            parent,getString(message(...
            'phased:apps:arrayapp:ElementsRing')));

            obj.NumElementsEdit=obj.Parent.createEditBox(...
            parent,'[4 8 16]',...
            getString(...
            message('phased:apps:arrayapp:ElementsRingTT')),...
            'numElemEdit',@(h,e)parameterChanged(obj,e));


            obj.RadiusLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:Radius')));

            obj.RadiusEdit=obj.Parent.createEditBox(...
            parent,'[1 1.5 2]',...
            getString(...
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

            obj.TaperEdit=obj.Parent.createEditBox(...
            parent,'1',getString(...
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
                    sigdatatypes.validateIndex(obj.ElementsOnRing,...
                    '','NumElements',{'real','row','>=',2,...
                    'integer','finite','nonempty','nonnan'});
                    obj.ValidNumElements=obj.ElementsOnRing;
                catch me
                    obj.ElementsOnRing=obj.ValidNumElements;
                    throwError(obj.Parent.App,me);
                    return;
                end

            case 'radiusEdit'
                try
                    sigdatatypes.validateDistance(obj.Radius,'',...
                    'Radius',{'real','row','positive','finite',...
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
