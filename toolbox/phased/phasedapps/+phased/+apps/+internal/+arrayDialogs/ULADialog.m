classdef(Hidden,Sealed)ULADialog<handle





    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

NumElementsLabel
NumElementsEdit

ElementSpacingLabel
ElementSpacingEdit
ElementSpacingUnits

ArrayAxisLabel
ArrayAxisPopup

TaperLabel
CustomTaperLabel
CustomTaperEdit

SideLobeAttenuationLabel
SideLobeAttenuationEdit

NbarLabel
NbarEdit

BetaLabel
BetaEdit

        ArrayDialogTitle=getString(message('phased:apps:arrayapp:ula'));
    end

    properties(Hidden)
TaperPopup
    end

    properties(Dependent)
NumElements
ElementSpacing
ArrayAxis
Taper
CustomTaper
SideLobeAttenuation
Nbar
Beta
    end

    properties(Access=private)
Parent
Layout

        ValidElementSpacing=0.5
        ValidNumElements=4
        ValidCustomTaper=1
        ValidSideLobeAttenuation=30
        ValidNbar=4
        ValidBeta=0.5
        ValidArrayAxis=getString(message('phased:apps:arrayapp:yaxis'))
    end

    methods
        function obj=ULADialog(parent)

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


        function val=get.CustomTaper(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.CustomTaperEdit.String);
            else
                val=evalin('base',obj.CustomTaperEdit.Value);
            end
        end

        function set.CustomTaper(obj,val)
            if~isUIFigure(obj.Parent)
                obj.CustomTaperEdit.String=mat2str(val);
            else
                obj.CustomTaperEdit.Value=mat2str(val);
            end
        end


        function val=get.Taper(obj)
            if~isUIFigure(obj.Parent)
                val=obj.TaperPopup.String{obj.TaperPopup.Value};
            else
                val=obj.TaperPopup.Value;
            end
        end

        function set.Taper(obj,str)
            if~isUIFigure(obj.Parent)
                switch str
                case getString(message('phased:apps:arrayapp:None'))
                    obj.TaperPopup.Value=1;
                case getString(message('phased:apps:arrayapp:Hamming'))
                    obj.TaperPopup.Value=2;
                case getString(message('phased:apps:arrayapp:Chebyshev'))
                    obj.TaperPopup.Value=3;
                case getString(message('phased:apps:arrayapp:Hann'))
                    obj.TaperPopup.Value=4;
                case getString(message('phased:apps:arrayapp:Kaiser'))
                    obj.TaperPopup.Value=5;
                case getString(message('phased:apps:arrayapp:Taylor'))
                    obj.TaperPopup.Value=6;
                case getString(message('phased:apps:arrayapp:Custom'))
                    obj.TaperPopup.Value=7;
                end
            else
                switch str
                case getString(message('phased:apps:arrayapp:None'))
                    obj.TaperPopup.Value=...
                    getString(message('phased:apps:arrayapp:None'));
                case getString(message('phased:apps:arrayapp:Hamming'))
                    obj.TaperPopup.Value=...
                    getString(message('phased:apps:arrayapp:Hamming'));
                case getString(message('phased:apps:arrayapp:Chebyshev'))
                    obj.TaperPopup.Value=...
                    getString(message('phased:apps:arrayapp:Chebyshev'));
                case getString(message('phased:apps:arrayapp:Hann'))
                    obj.TaperPopup.Value=getString(message('phased:apps:arrayapp:Hann'));
                case getString(message('phased:apps:arrayapp:Kaiser'))
                    obj.TaperPopup.Value=getString(message('phased:apps:arrayapp:Kaiser'));
                case getString(message('phased:apps:arrayapp:Taylor'))
                    obj.TaperPopup.Value=getString(message('phased:apps:arrayapp:Taylor'));
                case getString(message('phased:apps:arrayapp:Custom'))
                    obj.TaperPopup.Value=getString(message('phased:apps:arrayapp:Custom'));
                end
            end
        end


        function val=get.SideLobeAttenuation(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.SideLobeAttenuationEdit.String);
            else
                val=evalin('base',obj.SideLobeAttenuationEdit.Value);
            end
        end

        function set.SideLobeAttenuation(obj,val)
            if~isUIFigure(obj.Parent)
                obj.SideLobeAttenuationEdit.String=mat2str(val);
            else
                obj.SideLobeAttenuationEdit.Value=mat2str(val);
            end
        end


        function val=get.Nbar(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.NbarEdit.String);
            else
                val=evalin('base',obj.NbarEdit.Value);
            end
        end

        function set.Nbar(obj,val)
            if~isUIFigure(obj.Parent)
                obj.NbarEdit.String=mat2str(val);
            else
                obj.NbarEdit.Value=mat2str(val);
            end
        end


        function val=get.Beta(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.BetaEdit.String);
            else
                val=evalin('base',obj.BetaEdit.Value);
            end
        end

        function set.Beta(obj,val)
            if~isUIFigure(obj.Parent)
                obj.BetaEdit.String=mat2str(val);
            else
                obj.BetaEdit.Value=mat2str(val);
            end
        end


        function val=get.ArrayAxis(obj)
            if~isUIFigure(obj.Parent)
                val=obj.ArrayAxisPopup.String{obj.ArrayAxisPopup.Value};
            else
                val=obj.ArrayAxisPopup.Value;
            end
        end

        function set.ArrayAxis(obj,str)
            if~isUIFigure(obj.Parent)
                if strcmp(str,...
                    getString(message('phased:apps:arrayapp:xaxis')))
                    obj.ArrayAxisPopup.Value=1;
                elseif strcmp(str,...
                    getString(message('phased:apps:arrayapp:yaxis')))
                    obj.ArrayAxisPopup.Value=2;
                else
                    obj.ArrayAxisPopup.Value=3;
                end
            else
                if strcmp(str,...
                    getString(message('phased:apps:arrayapp:xaxis')))
                    obj.ArrayAxisPopup.Value=getString(message('phased:apps:arrayapp:xaxis'));
                elseif strcmp(str,...
                    getString(message('phased:apps:arrayapp:yaxis')))
                    obj.ArrayAxisPopup.Value=getString(message('phased:apps:arrayapp:yaxis'));
                else
                    obj.ArrayAxisPopup.Value=getString(message('phased:apps:arrayapp:zaxis'));
                end
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

            elemSpacing=obj.ElementSpacing*ratio;
            tapertype=getCurTaperType(obj);

            taper=computeTaper(obj,tapertype,obj.NumElements,...
            obj.SideLobeAttenuation,obj.Nbar,obj.Beta,obj.CustomTaper);


            obj.Parent.App.CurrentArray=phased.ULA(...
            'Element',obj.Parent.App.CurrentElement,...
            'NumElements',obj.NumElements,...
            'ElementSpacing',elemSpacing,...
            'ArrayAxis',obj.ArrayAxis,...
            'Taper',taper);
        end

        function validParams=verifyParameters(obj)


            SigFreqs=obj.Parent.ElementDialog.SignalFreq;
            usingLambda=obj.Parent.isUsingLambda(obj.ElementSpacingUnits);


            validParams=checkValidityOfWaveLengthUnits(obj.Parent,usingLambda,SigFreqs);
        end

        function numElem=getNumElements(obj)
            numElem=obj.NumElements;
        end

        function taperType=getCurTaperType(obj)
            taperType=phased.apps.internal.TaperType.getTaperAtPos(obj.TaperPopup.Value,obj.Parent.App.Container);
        end

        function t=computeTaper(~,tapertype,numElements,...
            sidelobeAttenuation,...
            nbar,...
            beta,...
            customTaper)

            t=tapertype.TaperGetCallback(...
            tapertype,numElements,...
            sidelobeAttenuation,...
            beta,...
            nbar,...
            customTaper);
        end

        function gencode(obj,sw)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            addcr(sw,'% Create a Uniform Linear Array Object');
            addcr(sw,['Array = phased.ULA(''NumElements'',',mat2str(obj.NumElements),',...'])
            addcr(sw,['''ArrayAxis'',''',obj.ArrayAxis,''');'])
            if obj.Parent.isUsingLambda(obj.ElementSpacingUnits)
                ratio=propSpeed/freq;
                addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                addcr(sw,['Array.ElementSpacing = ',mat2str(obj.ElementSpacing),'*',mat2str(ratio),';'])
            else
                addcr(sw,['Array.ElementSpacing = ',mat2str(obj.ElementSpacing),';'])
            end
            taperType=getCurTaperType(obj);
            if~isUIFigure(obj.Parent)
                genTaper(obj,taperType,sw,'Array.Taper',obj.NumElements,obj.SideLobeAttenuation,...
                obj.Nbar,obj.Beta,obj.CustomTaper,obj.CustomTaperEdit.String)
            else
                genTaper(obj,taperType,sw,'Array.Taper',obj.NumElements,obj.SideLobeAttenuation,...
                obj.Nbar,obj.Beta,obj.CustomTaper,obj.CustomTaperEdit.Value)
            end
        end

        function genTaper(~,taperType,sw,wind,numElements,sidelobeAttenuation,nbar,...
            beta,customTaper,customTaperString)


            taperType.GenCodeCallback(taperType,sw,...
            wind,numElements,...
            sidelobeAttenuation,...
            beta,...
            nbar,...
            customTaper,...
            customTaperString);
        end

        function genreport(obj,sw)

            if isa(obj.Parent.App.CurrentArray,'phased.ReplicatedSubarray')
                addcr(sw,'% Subarray Type ........................................ Uniform Linear Geometry')
                addcr(sw,['% Element Spacing (m) .................................. ',mat2str(obj.ElementSpacing)])
                addcr(sw,['% Subarray Axis ........................................ ',obj.ArrayAxis])
            else
                addcr(sw,'% Array Type ........................................... Uniform Linear Array')
                addcr(sw,['% Element Spacing (m) .................................. ',mat2str(obj.ElementSpacing)])
                addcr(sw,['% Array Axis ........................................... ',obj.ArrayAxis])
            end

            addcr(sw,['% Taper ................................................ ',obj.Taper])
            tapertype=getCurTaperType(obj);
            switch tapertype
            case getString(message('phased:apps:arrayapp:Chebyshev'))
                addcr(sw,['% Sidelobe Attenuation (dB) ............................ ',mat2str(obj.SideLobeAttenuation)]);
            case getString(message('phased:apps:arrayapp:Kaiser'))
                addcr(sw,['% beta ................................................. ',mat2str(obj.Beta)]);
            case getString(message('phased:apps:arrayapp:Taylor'))
                addcr(sw,['% Sidelobe Attenuation (dB) ............................ ',mat2str(obj.SideLobeAttenuation)]);
                addcr(sw,['% nbar ................................................. ',mat2str(obj.Nbar)]);
            case getString(message('phased:apps:arrayapp:Custom'))
                if~isUIFigure(obj.Parent)
                    addcr(sw,['% Custom Taper ......................................... ',obj.CustomTaperEdit.String]);
                else
                    addcr(sw,['% Custom Taper ......................................... ',obj.CustomTaperEdit.Value]);
                end
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
            [0,0,0,0,0,0,0,1],[0,1,0]);

            if~isUIFigure(obj.Parent)
                parent=obj.Panel;
            else
                parent=obj.Layout;
            end

            obj.NumElementsLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:NumElements')));

            obj.NumElementsEdit=obj.Parent.createEditBox(parent,...
            '4',getString(...
            message('phased:apps:arrayapp:NumElementsTT')),...
            'numElemEdit',@(h,e)parameterChanged(obj,e));


            obj.ElementSpacingLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:ElementSpacing')));

            obj.ElementSpacingEdit=obj.Parent.createEditBox(parent,...
            '0.5',getString(...
            message('phased:apps:arrayapp:ElementSpacingTT')),...
            'elementSpacingEdit',@(h,e)parameterChanged(obj,e));

            unitStrings={getString(message('phased:apps:arrayapp:meter')),...
            char(955)};

            obj.ElementSpacingUnits=obj.Parent.createDropDown(parent,...
            unitStrings,1,' ',...
            'elementSpacingUnit',@(h,e)parameterChanged(obj,e));


            obj.ArrayAxisLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:ArrayAxis')));

            axispop={getString(message('phased:apps:arrayapp:xaxis')),...
            getString(message('phased:apps:arrayapp:yaxis')),...
            getString(message('phased:apps:arrayapp:zaxis'))};

            obj.ArrayAxisPopup=obj.Parent.createDropDown(parent,...
            axispop,2,getString(...
            message('phased:apps:arrayapp:ArrayAxisTT')),...
            'arrayAxisPopUp',@(h,e)parameterChanged(obj,e));


            obj.TaperLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:Taper')));

            taperpopup=phased.apps.internal.TaperType.names;

            obj.TaperPopup=obj.Parent.createDropDown(parent,...
            taperpopup,1,getString(...
            message('phased:apps:arrayapp:TaperTT')),...
            'taperPopup',@(h,e)parameterChanged(obj,e));


            obj.CustomTaperLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:CustomTaper')),...
            'off');

            obj.CustomTaperEdit=obj.Parent.createEditBox(...
            parent,'1',getString(...
            message('phased:apps:arrayapp:CustomTaperTT')),...
            'taperEdit',@(h,e)parameterChanged(obj,e),'off');


            obj.SideLobeAttenuationLabel=obj.Parent.createTextLabel(...
            parent,[getString(...
            message('phased:apps:arrayapp:SidelobeAttenuation')),...
            ' (',getString(message('phased:apps:arrayapp:dB')),')'],...
            'off');

            obj.SideLobeAttenuationEdit=obj.Parent.createEditBox(parent,...
            '30',getString(message('phased:apps:arrayapp:SidelobeLevelTT')),...
            'sideLobeEdit',@(h,e)parameterChanged(obj,e),'off');


            obj.NbarLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:nbar')),...
            'off');

            obj.NbarEdit=obj.Parent.createEditBox(parent,...
            '4',getString(message('phased:apps:arrayapp:nbarTaylorTT')),...
            'nBarEdit',@(h,e)parameterChanged(obj,e),'off');



            obj.BetaLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:beta')),...
            'off');

            obj.BetaEdit=obj.Parent.createEditBox(parent,...
            '0.5',getString(message('phased:apps:arrayapp:betaKaiserTT')),...
            'betaEdit',@(h,e)parameterChanged(obj,e),'off');
        end
    end
    methods(Hidden)
        function layoutUIControls(obj)
            if~isUIFigure(obj.Parent)
                hspacing=3;
                vspacing=5;


                obj.Layout=obj.Parent.createLayout(obj.Panel,...
                vspacing,hspacing,...
                [0,0,0,0,0,0,0,1],[0,1,0]);

                w1=obj.Parent.Width1;
                w2=obj.Parent.Width2;
                w3=obj.Parent.Width3;

                row=1;

                uiControlsHt=24;
                row=row+1;
                obj.Parent.addText(obj.Layout,obj.NumElementsLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.NumElementsEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ElementSpacingLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ElementSpacingEdit,row,2,w2,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.ElementSpacingUnits,row,3,w3,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ArrayAxisLabel,row,1,w1,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.ArrayAxisPopup,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.TaperLabel,row,1,w1,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.TaperPopup,row,2,w2,uiControlsHt)

                switch obj.TaperPopup.String{obj.TaperPopup.Value}
                case getString(message('phased:apps:arrayapp:None'))
                    obj.SideLobeAttenuationLabel.Visible='off';
                    obj.SideLobeAttenuationEdit.Visible='off';
                    obj.BetaLabel.Visible='off';
                    obj.BetaEdit.Visible='off';
                    obj.NbarLabel.Visible='off';
                    obj.NbarEdit.Visible='off';
                    obj.CustomTaperLabel.Visible='off';
                    obj.CustomTaperEdit.Visible='off';
                case getString(message('phased:apps:arrayapp:Hamming'))
                    obj.SideLobeAttenuationLabel.Visible='off';
                    obj.SideLobeAttenuationEdit.Visible='off';
                    obj.BetaLabel.Visible='off';
                    obj.BetaEdit.Visible='off';
                    obj.NbarLabel.Visible='off';
                    obj.NbarEdit.Visible='off';
                    obj.CustomTaperLabel.Visible='off';
                    obj.CustomTaperEdit.Visible='off';
                case getString(message('phased:apps:arrayapp:Chebyshev'))
                    row=row+1;
                    obj.Parent.addText(obj.Layout,obj.SideLobeAttenuationLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addEdit(obj.Layout,obj.SideLobeAttenuationEdit,row,2,w2,uiControlsHt)

                    obj.SideLobeAttenuationLabel.Visible='on';
                    obj.SideLobeAttenuationEdit.Visible='on';
                    obj.BetaLabel.Visible='off';
                    obj.BetaEdit.Visible='off';
                    obj.NbarLabel.Visible='off';
                    obj.NbarEdit.Visible='off';
                    obj.CustomTaperLabel.Visible='off';
                    obj.CustomTaperEdit.Visible='off';

                case getString(message('phased:apps:arrayapp:Hann'))
                    obj.SideLobeAttenuationLabel.Visible='off';
                    obj.SideLobeAttenuationEdit.Visible='off';
                    obj.BetaLabel.Visible='off';
                    obj.BetaEdit.Visible='off';
                    obj.NbarLabel.Visible='off';
                    obj.NbarEdit.Visible='off';
                    obj.CustomTaperLabel.Visible='off';
                    obj.CustomTaperEdit.Visible='off';
                case getString(message('phased:apps:arrayapp:Kaiser'))
                    row=row+1;
                    obj.Parent.addText(obj.Layout,obj.BetaLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addEdit(obj.Layout,obj.BetaEdit,row,2,w2,uiControlsHt)

                    obj.SideLobeAttenuationLabel.Visible='off';
                    obj.SideLobeAttenuationEdit.Visible='off';
                    obj.BetaLabel.Visible='on';
                    obj.BetaEdit.Visible='on';
                    obj.NbarLabel.Visible='off';
                    obj.NbarEdit.Visible='off';
                    obj.CustomTaperLabel.Visible='off';
                    obj.CustomTaperEdit.Visible='off';

                case getString(message('phased:apps:arrayapp:Taylor'))
                    row=row+1;
                    obj.Parent.addText(obj.Layout,obj.SideLobeAttenuationLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addEdit(obj.Layout,obj.SideLobeAttenuationEdit,row,2,w2,uiControlsHt)

                    row=row+1;
                    obj.Parent.addText(obj.Layout,obj.NbarLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addEdit(obj.Layout,obj.NbarEdit,row,2,w2,uiControlsHt)

                    obj.SideLobeAttenuationLabel.Visible='on';
                    obj.SideLobeAttenuationEdit.Visible='on';
                    obj.BetaLabel.Visible='off';
                    obj.BetaEdit.Visible='off';
                    obj.NbarLabel.Visible='on';
                    obj.NbarEdit.Visible='on';
                    obj.CustomTaperLabel.Visible='off';
                    obj.CustomTaperEdit.Visible='off';

                case getString(message('phased:apps:arrayapp:Custom'))

                    row=row+1;
                    obj.Parent.addText(obj.Layout,obj.CustomTaperLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addEdit(obj.Layout,obj.CustomTaperEdit,row,2,w2,uiControlsHt)

                    obj.SideLobeAttenuationLabel.Visible='off';
                    obj.SideLobeAttenuationEdit.Visible='off';
                    obj.BetaLabel.Visible='off';
                    obj.BetaEdit.Visible='off';
                    obj.NbarLabel.Visible='off';
                    obj.NbarEdit.Visible='off';
                    obj.CustomTaperLabel.Visible='on';
                    obj.CustomTaperEdit.Visible='on';
                end


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.NumElementsLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.NumElementsEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.ElementSpacingLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.ElementSpacingEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.ElementSpacingUnits.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',3);
                obj.ArrayAxisLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.ArrayAxisPopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.TaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.TaperPopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);

                obj.SideLobeAttenuationLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',1);
                obj.SideLobeAttenuationEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',2);
                obj.NbarLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',1);
                obj.NbarEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',2);
                obj.BetaLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',1);
                obj.BetaEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',2);
                obj.CustomTaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',8,'Column',1);
                obj.CustomTaperEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',8,'Column',2);

                obj.SideLobeAttenuationLabel.Visible='off';
                obj.SideLobeAttenuationEdit.Visible='off';
                obj.BetaLabel.Visible='off';
                obj.BetaEdit.Visible='off';
                obj.NbarLabel.Visible='off';
                obj.NbarEdit.Visible='off';
                obj.CustomTaperLabel.Visible='off';
                obj.CustomTaperEdit.Visible='off';
                obj.Layout.RowHeight={'fit','fit','fit','fit','fit','fit','fit','fit'};
                switch obj.TaperPopup.Value
                case getString(message('phased:apps:arrayapp:None'))

                    obj.Layout.RowHeight(5:8)={0,0,0,0};
                case getString(message('phased:apps:arrayapp:Hamming'))

                    obj.Layout.RowHeight(5:8)={0,0,0,0};
                case getString(message('phased:apps:arrayapp:Chebyshev'))

                    obj.SideLobeAttenuationLabel.Visible='on';
                    obj.SideLobeAttenuationEdit.Visible='on';
                    obj.Layout.RowHeight(6:8)={0,0,0};
                case getString(message('phased:apps:arrayapp:Hann'))

                    obj.Layout.RowHeight(5:8)={0,0,0,0};
                case getString(message('phased:apps:arrayapp:Kaiser'))

                    obj.BetaLabel.Visible='on';
                    obj.BetaEdit.Visible='on';
                    obj.Layout.RowHeight([5:6,8])={0,0,0};
                case getString(message('phased:apps:arrayapp:Taylor'))

                    obj.SideLobeAttenuationLabel.Visible='on';
                    obj.SideLobeAttenuationEdit.Visible='on';
                    obj.NbarLabel.Visible='on';
                    obj.NbarEdit.Visible='on';
                    obj.Layout.RowHeight(7:8)={0,0};
                case getString(message('phased:apps:arrayapp:Custom'))

                    obj.CustomTaperLabel.Visible='on';
                    obj.CustomTaperEdit.Visible='on';
                    obj.Layout.RowHeight(5:7)={0,0,0};
                end
            end
        end

        function parameterChanged(obj,e)




            prop=e.Source.Tag;
            switch prop
            case 'numElemEdit'
                try
                    sigdatatypes.validateIndex(obj.NumElements,...
                    '','Number of Elements',{'scalar','>=',2});
                    obj.ValidNumElements=obj.NumElements;
                catch me
                    obj.NumElements=obj.ValidNumElements;
                    throwError(obj.Parent.App,me);
                    return;
                end

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

            case 'taperEdit'
                try
                    validateattributes(obj.CustomTaper,{'double'},...
                    {'nonnan','nonempty','finite','vector'},...
                    '','Taper');
                    obj.ValidCustomTaper=obj.CustomTaper;
                catch me
                    obj.CustomTaper=obj.ValidCustomTaper;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'taperPopup'
                if~isUIFigure(obj.Parent)
                    obj.Taper=obj.TaperPopup.String{obj.TaperPopup.Value};
                    layoutUIControls(obj)
                    remove(obj.Parent.Layout,1,1)
                    add(obj.Parent.Layout,obj.Parent.ArrayDialog.Panel,1,1,...
                    'MinimumWidth',obj.Width,...
                    'Fill','Horizontal',...
                    'MinimumHeight',obj.Height,...
                    'Anchor','North')

                    update(obj.Parent.Layout,'force');
                else
                    obj.Taper=obj.TaperPopup.Value;
                    layoutUIControls(obj)
                    adjustLayout(obj.Parent.App);
                end
            case 'sideLobeEdit'
                try
                    validateattributes(obj.SideLobeAttenuation,...
                    {'double'},{'positive','scalar','finite',...
                    'nonnan','nonempty','real'},'',...
                    'Sidelobe Attenuation');
                    obj.ValidSideLobeAttenuation=obj.SideLobeAttenuation;
                catch me
                    obj.SideLobeAttenuation=obj.ValidSideLobeAttenuation;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'betaEdit'
                try
                    validateattributes(obj.Beta,{'double'},...
                    {'scalar','finite','nonnan','nonempty',...
                    'real'},'','Beta');
                    obj.ValidBeta=obj.Beta;
                catch me
                    obj.Beta=obj.ValidBeta;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'nBarEdit'
                try
                    validateattributes(obj.Nbar,{'double'},...
                    {'positive','scalar','integer','finite',...
                    'nonnan','nonempty','real'},'','Nbar');
                    obj.ValidNbar=obj.Nbar;
                catch me
                    obj.Nbar=obj.ValidNbar;
                    throwError(obj.Parent.App,me);
                    return;
                end
            end


            enableAnalyzeButton(obj.Parent.App);
        end
    end
end
