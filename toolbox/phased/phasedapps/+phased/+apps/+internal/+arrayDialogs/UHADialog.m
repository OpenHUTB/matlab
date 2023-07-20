classdef(Hidden,Sealed)UHADialog<handle






    properties(Hidden,SetAccess=private)

Panel
        Width=0
        Height=0
Listeners

SideElementsLabel
SideElementsEdit

ElementSpacingLabel
ElementSpacingEdit
ElementSpacingUnits

TaperLabel
TaperEdit

        ArrayDialogTitle=getString(message('phased:apps:arrayapp:uha'));
    end

    properties(Dependent)
NumElementsSide
ElementSpacing
Taper
    end

    properties(Access=private)
Parent
Layout

        ValidElementSpacing=1
        ValidSideElements=4
        ValidTaper=1
    end

    methods
        function obj=UHADialog(parent)


            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods


        function val=get.NumElementsSide(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.SideElementsEdit.String);
            else
                val=evalin('base',obj.SideElementsEdit.Value);
            end
        end

        function set.NumElementsSide(obj,val)
            if~isUIFigure(obj.Parent)
                obj.SideElementsEdit.String=num2str(val);
            else
                obj.SideElementsEdit.Value=num2str(val);
            end
        end


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

            if obj.Parent.isUsingLambda(obj.ElementSpacingUnits)
                ratio=propSpeed/freq;
            else
                ratio=1;
            end

            Nside=obj.NumElementsSide;
            delta=obj.ElementSpacing*ratio;
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


            obj.Parent.App.CurrentArray=phased.ConformalArray(...
            'Element',obj.Parent.App.CurrentElement,...
            'ElementPosition',pos,...
            'ElementNormal',zeros(2,size(pos,2)),...
            'Taper',obj.Taper);
        end

        function validParams=verifyParameters(obj)


            SigFreqs=obj.Parent.ElementDialog.SignalFreq;
            usingLambda=obj.Parent.isUsingLambda(obj.ElementSpacingUnits);


            validParams=checkValidityOfWaveLengthUnits(obj.Parent,usingLambda,SigFreqs);
        end

        function numElem=getNumElements(obj)
            sideElement=obj.NumElementsSide;
            numElem=1+sum(6*(1:sideElement-1));
        end

        function gencode(obj,sw)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            addcr(sw,'% Create a uniform hexagonal array');
            addcr(sw,['Nside = ',mat2str(obj.NumElementsSide),';']);
            if obj.Parent.isUsingLambda(obj.ElementSpacingUnits)
                ratio=propSpeed/freq;
                addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                addcr(sw,['delta = ',mat2str(obj.ElementSpacing),'*',mat2str(ratio),';']);
            else
                addcr(sw,['delta = ',mat2str(obj.ElementSpacing),';']);
            end
            addcr(sw,'rows = [1:Nside Nside-1:-1:1];');
            addcr(sw,'Radius = delta * (Nside - 1);');
            addcr(sw,'pos = zeros(3,1);');
            addcr(sw,'count = 0;');
            addcr(sw,'for idx = 1:length(rows)');
            addcr(sw,'    y = -Radius/2 - (rows(idx)-1)*delta*0.5 : delta : ...');
            addcr(sw,'        Radius/2 + (rows(idx)-1)*delta*0.5;');
            addcr(sw,'    pos(2, count+1:count+length(y)) = y;');
            addcr(sw,'    pos(3, count+1:count+length(y)) = sqrt(3)/2*Radius - ...');
            addcr(sw,'        (idx-1)*delta*sind(60);');
            addcr(sw,'    count = count+length(y);');
            addcr(sw,'end');
            addcr(sw,'Array = phased.ConformalArray(''ElementPosition'', pos, ...');
            if~isUIFigure(obj.Parent)
                addcr(sw,['   ''ElementNormal'', zeros(2, size(pos,2)),''Taper'',',obj.TaperEdit.String,');']);
            else
                addcr(sw,['   ''ElementNormal'', zeros(2, size(pos,2)),''Taper'',',obj.TaperEdit.Value,');']);
            end
        end

        function genreport(obj,sw)

            if isa(obj.Parent.App.CurrentArray,'phased.ReplicatedSubarray')
                addcr(sw,'% Subarray Type ........................................ Uniform Hexagonal Subarray')
            else
                addcr(sw,'% Array Type ........................................... Uniform Hexagonal Array')
            end
            addcr(sw,['% Elements on Side ..................................... ',mat2str(obj.NumElementsSide)])
            addcr(sw,['% Element Spacing (m) .................................. ',mat2str(obj.ElementSpacing)])
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

            obj.SideElementsLabel=obj.Parent.createTextLabel(parent,...
            getString(...
            message('phased:apps:arrayapp:ElementsSide')));

            obj.SideElementsEdit=obj.Parent.createEditBox(parent,...
            '4',getString(...
            message('phased:apps:arrayapp:ElementsSideTT')),...
            'sideElementEdit',@(h,e)parameterChanged(obj,e));


            obj.ElementSpacingLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:ElementSpacing')));

            obj.ElementSpacingEdit=obj.Parent.createEditBox(parent,...
            '1',getString(...
            message('phased:apps:arrayapp:ElementSpacingTT')),...
            'elementSpacingEdit',@(h,e)parameterChanged(obj,e));

            unitStrings={getString(message('phased:apps:arrayapp:meter')),...
            char(955)};

            obj.ElementSpacingUnits=obj.Parent.createDropDown(...
            parent,unitStrings,1,' ',...
            'elementSpacingUnit',@(h,e)parameterChanged(obj,e));


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
                obj.Parent.addText(obj.Layout,obj.SideElementsLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.SideElementsEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ElementSpacingLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ElementSpacingEdit,row,2,w2,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.ElementSpacingUnits,row,3,w3,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.TaperLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.TaperEdit,row,2,w2,uiControlsHt)


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.SideElementsLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.SideElementsEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.ElementSpacingLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.ElementSpacingEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.ElementSpacingUnits.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',3);
                obj.TaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.TaperEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
            end
        end

        function parameterChanged(obj,e)




            prop=e.Source.Tag;
            switch prop
            case 'sideElementEdit'
                try
                    sigdatatypes.validateIndex(obj.NumElementsSide,...
                    '','NumElements',...
                    {'scalar','>=',2});
                    obj.ValidSideElements=obj.NumElementsSide;
                catch me
                    obj.NumElementsSide=obj.ValidSideElements;
                    throwError(obj.Parent.App,me);
                    return;
                end

            case 'elementSpacingEdit'
                try
                    sigdatatypes.validateDistance(...
                    obj.ElementSpacing,'','ElementSpacing',...
                    {'scalar','positive','finite'});
                    obj.ValidElementSpacing=obj.ElementSpacing;
                catch me
                    obj.ElementSpacing=obj.ValidElementSpacing;
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
