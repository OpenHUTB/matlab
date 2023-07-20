classdef(Hidden,Sealed)UCADialog<handle






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

ArrayNormalLabel
ArrayNormalPopup

TaperLabel
TaperEdit

        ArrayDialogTitle=getString(message('phased:apps:arrayapp:uca'));
    end

    properties(Dependent)
NumElements
Radius
ArrayNormal
Taper
    end

    properties(Access=private)
Parent
Layout

        ValidNumElements=16
        ValidRadius=1
        ValidArrayNormal=getString(message('phased:apps:arrayapp:zaxis'))
        ValidTaper=1
    end

    methods
        function obj=UCADialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods


        function val=get.NumElements(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.NumElementsEdit.String);
            else
                val=evalin('base',obj.NumElementsEdit.Value);
            end
        end

        function set.NumElements(obj,val)
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


        function val=get.ArrayNormal(obj)
            if~isUIFigure(obj.Parent)
                val=obj.ArrayNormalPopup.String{obj.ArrayNormalPopup.Value};
            else
                val=obj.ArrayNormalPopup.Value;
            end
        end

        function set.ArrayNormal(obj,str)
            if~isUIFigure(obj.Parent)
                if strcmp(str,...
                    getString(message('phased:apps:arrayapp:xaxis')))
                    obj.ArrayNormalPopup.Value=1;
                elseif strcmp(str,...
                    getString(message('phased:apps:arrayapp:yaxis')))
                    obj.ArrayNormalPopup.Value=2;
                else
                    obj.ArrayNormalPopup.Value=3;
                end
            else
                if strcmp(str,...
                    getString(message('phased:apps:arrayapp:xaxis')))
                    obj.ArrayNormalPopup.Value=getString(message('phased:apps:arrayapp:xaxis'));
                elseif strcmp(str,...
                    getString(message('phased:apps:arrayapp:yaxis')))
                    obj.ArrayNormalPopup.Value=getString(message('phased:apps:arrayapp:yaxis'));
                else
                    obj.ArrayNormalPopup.Value=getString(message('phased:apps:arrayapp:zaxis'));
                end
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

            radius=obj.Radius*ratio;


            obj.Parent.App.CurrentArray=phased.UCA(...
            'Element',obj.Parent.App.CurrentElement,...
            'NumElements',obj.NumElements,...
            'Radius',radius,...
            'ArrayNormal',obj.ArrayNormal,...
            'Taper',obj.Taper);
        end

        function validParams=verifyParameters(obj)


            SigFreqs=obj.Parent.ElementDialog.SignalFreq;
            usingLambda=obj.Parent.isUsingLambda(obj.RadiusUnits);


            validParams=checkValidityOfWaveLengthUnits(obj.Parent,usingLambda,SigFreqs);
        end

        function numElem=getNumElements(obj)
            numElem=obj.NumElements;
        end

        function gencode(obj,sw)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            addcr(sw,'%Create a uniform circular array');
            addcr(sw,['Array = phased.UCA(''NumElements'',',mat2str(obj.NumElements),',...'])
            if~isUIFigure(obj.Parent)
                addcr(sw,['''ArrayNormal'',''',obj.ArrayNormal,''',''Taper'',',obj.TaperEdit.String,');'])
            else
                addcr(sw,['''ArrayNormal'',''',obj.ArrayNormal,''',''Taper'',',obj.TaperEdit.Value,');'])
            end
            if obj.Parent.isUsingLambda(obj.RadiusUnits)
                ratio=propSpeed/freq;
                addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                addcr(sw,['Array.Radius = ',mat2str(obj.Radius),'*',mat2str(ratio),';'])
            else
                addcr(sw,['Array.Radius = ',mat2str(obj.Radius),';'])
            end
        end

        function genreport(obj,sw)

            if isa(obj.Parent.App.CurrentArray,'phased.ReplicatedSubarray')
                addcr(sw,'% Subarray Type ........................................ Uniform Circular Subarray')
            else
                addcr(sw,'% Array Type ........................................... Uniform Circular Array')
            end
            addcr(sw,['% Radius (m) ........................................... ',mat2str(obj.Radius)])
            addcr(sw,['% Array Normal ......................................... ',obj.ArrayNormal])
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

            obj.NumElementsLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:NumElements')));

            obj.NumElementsEdit=obj.Parent.createEditBox(parent,...
            '16',getString(...
            message('phased:apps:arrayapp:NumElementsTT')),...
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


            obj.ArrayNormalLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:ArrayNormal')));

            axispop={getString(message('phased:apps:arrayapp:xaxis')),...
            getString(message('phased:apps:arrayapp:yaxis')),...
            getString(message('phased:apps:arrayapp:zaxis'))};

            obj.ArrayNormalPopup=obj.Parent.createDropDown(parent,...
            axispop,3,getString(...
            message('phased:apps:arrayapp:ArrayNormalTT')),...
            'arrayNormalPopup',@(h,e)parameterChanged(obj,e));


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
                obj.Parent.addText(obj.Layout,obj.NumElementsLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.NumElementsEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.RadiusLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.RadiusEdit,row,2,w2,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.RadiusUnits,row,3,w3,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ArrayNormalLabel,row,1,w1,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.ArrayNormalPopup,row,2,w2,uiControlsHt)

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
                obj.ArrayNormalLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.ArrayNormalPopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.TaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.TaperEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
            end
        end

        function parameterChanged(obj,e)




            prop=e.Source.Tag;
            switch prop
            case 'numElemEdit'
                try
                    sigdatatypes.validateIndex(obj.NumElements,...
                    '','NumElements',{'scalar','>=',2});
                    obj.ValidNumElements=obj.NumElements;
                catch me
                    obj.NumElements=obj.ValidNumElements;
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
