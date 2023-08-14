classdef(Hidden,Sealed)ArbitraryDialog<handle






    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

ElementPositionLabel
ElementPositionEdit
ElementPositionUnits

ElementNormalLabel
ElementNormalEdit

TaperLabel
TaperEdit

        ArrayDialogTitle=getString(message('phased:apps:arrayapp:Arbitraryarray'));
    end

    properties(Dependent)
ElementPosition
ElementNormal
Taper
    end

    properties(Access=private)
Parent
Layout

        ValidPosition=[1,0,0;0,1,-1;0,0,0]
        ValidNormal=[0,120,-120;0,0,0]
        ValidTaper=1
    end

    methods
        function obj=ArbitraryDialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods


        function val=get.ElementPosition(obj)
            if~obj.Parent.isUIFigure()
                val=evalin('base',obj.ElementPositionEdit.String);
            else
                val=evalin('base',obj.ElementPositionEdit.Value);
            end
        end

        function set.ElementPosition(obj,val)
            if~obj.Parent.isUIFigure()
                obj.ElementPositionEdit.String=mat2str(val);
            else
                obj.ElementPositionEdit.Value=mat2str(val);
            end
        end


        function val=get.ElementNormal(obj)
            if~obj.Parent.isUIFigure()
                val=evalin('base',obj.ElementNormalEdit.String);
            else
                val=evalin('base',obj.ElementNormalEdit.Value);
            end
        end

        function set.ElementNormal(obj,val)
            if~obj.Parent.isUIFigure()
                obj.ElementNormalEdit.String=mat2str(val);
            else
                obj.ElementNormalEdit.Value=mat2str(val);
            end
        end


        function val=get.Taper(obj)
            if~obj.Parent.isUIFigure()
                val=evalin('base',obj.TaperEdit.String);
            else
                val=evalin('base',obj.TaperEdit.Value);
            end
        end

        function set.Taper(obj,val)
            if~obj.Parent.isUIFigure()
                obj.TaperEdit.String=mat2str(val);
            else
                obj.TaperEdit.Value=mat2str(val);
            end
        end



        function updateArrayObject(obj)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            if obj.Parent.isUsingLambda(obj.ElementPositionUnits)
                ratio=propSpeed/freq;
            else
                ratio=1;
            end

            elemPosition=obj.ElementPosition*ratio;


            obj.Parent.App.CurrentArray=phased.ConformalArray(...
            'Element',obj.Parent.App.CurrentElement,...
            'ElementPosition',elemPosition,...
            'ElementNormal',obj.ElementNormal,...
            'Taper',obj.Taper);
        end

        function validParams=verifyParameters(obj)


            SigFreqs=obj.Parent.ElementDialog.SignalFreq;
            usingLambda=obj.Parent.isUsingLambda(obj.ElementPositionUnits);
            pos=obj.ElementPosition;
            normal=obj.ElementNormal;


            validSignalFreq=checkValidityOfWaveLengthUnits(obj.Parent,usingLambda,SigFreqs);

            if size(pos,2)~=size(normal,2)
                if strcmp(obj.Parent.App.Container,'ToolGroup')
                    h=errordlg(getString(...
                    message('phased:apps:arrayapp:ElementNormalError',size(pos,2))),...
                    getString(message('phased:apps:arrayapp:errordlg')),...
                    'modal');
                    uiwait(h)
                else
                    uialert(obj.Parent.App.ToolGroup,getString(...
                    message('phased:apps:arrayapp:ElementNormalError',size(pos,2))),...
                    getString(message('phased:apps:arrayapp:errordlg')));
                end
                validElemNormal=false;
            else
                validElemNormal=true;
            end

            validParams=validElemNormal&&validSignalFreq;
        end

        function numElem=getNumElements(obj)
            numElem=size(obj.ElementPosition,2);
        end

        function gencode(obj,sw)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            addcr(sw,'% Create an arbitrary geometry array');
            addcr(sw,'Array = phased.ConformalArray();');
            if obj.Parent.isUsingLambda(obj.ElementPositionUnits)
                ratio=propSpeed/freq;
                addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                addcr(sw,['Array.ElementPosition = ',mat2str(obj.ElementPosition),' .* ',mat2str(ratio),';']);
            else
                addcr(sw,['Array.ElementPosition = ',mat2str(obj.ElementPosition),';']);
            end
            addcr(sw,['Array.ElementNormal = ',mat2str(obj.ElementNormal),';']);
            if~obj.Parent.isUIFigure()
                addcr(sw,['Array.Taper = ',obj.TaperEdit.String,';']);
            else
                addcr(sw,['Array.Taper = ',obj.TaperEdit.Value,';']);
            end
        end

        function genreport(obj,sw)

            if isa(obj.Parent.App.CurrentArray,'phased.ReplicatedSubarray')
                addcr(sw,'% Subarray Type ........................................ Arbitrary Geometry Subarray')
            else
                addcr(sw,'% Array Type ........................................... Arbitrary Geometry Array')
            end
            addcr(sw,['% Element Position (m) ................................. ',mat2str(obj.ElementPosition)])
            addcr(sw,['% Element Normal (deg) ................................. ',mat2str(obj.ElementNormal)])
            if~obj.Parent.isUIFigure()
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
            if~obj.Parent.isUIFigure()
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
            [0,0,0,0,0,0,0,1],[0,1,0]);

            if~obj.Parent.isUIFigure()
                parent=obj.Panel;
            else
                parent=obj.Layout;
            end

            obj.ElementPositionLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:ElementPosition')));

            obj.ElementPositionEdit=obj.Parent.createEditBox(...
            parent,'[1 0 0; 0 1 -1; 0 0 0]',...
            getString(...
            message('phased:apps:arrayapp:ElementPositionTT')),...
            'elementPosEdit',@(h,e)parameterChanged(obj,e));

            elemUnits={getString(message('phased:apps:arrayapp:meter')),...
            char(955)};

            obj.ElementPositionUnits=obj.Parent.createDropDown(...
            parent,elemUnits,1,' ',...
            'elementPosUnit',@(h,e)parameterChanged(obj,e));


            obj.ElementNormalLabel=obj.Parent.createTextLabel(...
            parent,[getString(...
            message('phased:apps:arrayapp:ElementNormal')),' ('...
            ,getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.ElementNormalEdit=obj.Parent.createEditBox(...
            parent,'[0 120 -120;0 0 0]',...
            getString(message('phased:apps:arrayapp:ElementNormalTT')),...
            'elementNormEdit',@(h,e)parameterChanged(obj,e));


            obj.TaperLabel=obj.Parent.createTextLabel(parent,...
            getString(...
            message('phased:apps:arrayapp:CustomTaper')));

            obj.TaperEdit=obj.Parent.createEditBox(parent,...
            '1',getString(...
            message('phased:apps:arrayapp:CustomTaperTT')),...
            'taperEdit',@(h,e)parameterChanged(obj,e));
        end

        function layoutUIControls(obj)

            if~obj.Parent.isUIFigure()
                w1=obj.Parent.Width1;
                w2=obj.Parent.Width2;
                w3=obj.Parent.Width3;

                row=1;

                uiControlsHt=24;

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ElementPositionLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ElementPositionEdit,row,2,w2,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.ElementPositionUnits,row,3,w3,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ElementNormalLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ElementNormalEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.TaperLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.TaperEdit,row,2,w2,uiControlsHt)


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.ElementPositionLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.ElementPositionEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.ElementPositionUnits.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',3);
                obj.ElementNormalLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.ElementNormalEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.TaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.TaperEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
            end
        end

        function parameterChanged(obj,e)




            prop=e.Source.Tag;
            switch prop
            case 'elementPosEdit'
                try
                    sigdatatypes.validate3DCartCoord(...
                    obj.ElementPosition,'','Element Position');
                    obj.ValidPosition=obj.ElementPosition;
                catch me
                    obj.ElementPosition=obj.ValidPosition;
                    throwError(obj.Parent.App,me);
                    return;
                end

            case 'elementNormEdit'
                try
                    sigdatatypes.validateAzElAngle(obj.ElementNormal,...
                    '','Element Normal');
                    obj.ValidNormal=obj.ElementNormal;
                catch me
                    obj.ElementNormal=obj.ValidNormal;
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
