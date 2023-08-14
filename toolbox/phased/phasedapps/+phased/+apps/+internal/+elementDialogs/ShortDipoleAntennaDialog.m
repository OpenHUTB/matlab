classdef(Hidden,Sealed)ShortDipoleAntennaDialog<handle






    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

BBCheck

PropSpeedLabel
PropSpeedEdit

SignalFreqLabel
SignalFreqEdit

AxisDirectionLabel
AxisDirectionPopup

CustomAxisDirectionLabel
CustomAxisDirectionEdit
    end

    properties(Dependent)
PropSpeed
SignalFreq
AxisDirection
CustomAxisDirection
    end

    properties(Access=private)
Parent
Layout
        ValidCustomAxisDirection=[0;0;1]
    end

    methods
        function obj=ShortDipoleAntennaDialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods


        function val=get.PropSpeed(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.PropSpeedEdit.String);
            else
                val=evalin('base',obj.PropSpeedEdit.Value);
            end
        end

        function set.PropSpeed(obj,val)
            if~isUIFigure(obj.Parent)
                obj.PropSpeedEdit.String=num2str(val);
            else
                obj.PropSpeedEdit.Value=num2str(val);
            end
        end


        function val=get.SignalFreq(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.SignalFreqEdit.String);
            else
                val=evalin('base',obj.SignalFreqEdit.Value);
            end
        end

        function set.SignalFreq(obj,val)
            if~isUIFigure(obj.Parent)
                obj.SignalFreqEdit.String=mat2str(val);
            else
                obj.SignalFreqEdit.Value=mat2str(val);
            end
        end


        function val=get.AxisDirection(obj)
            if~isUIFigure(obj.Parent)
                val=obj.AxisDirectionPopup.String{obj.AxisDirectionPopup.Value};
            else
                val=obj.AxisDirectionPopup.Value;
            end
        end

        function set.AxisDirection(obj,str)
            if~isUIFigure(obj.Parent)
                if strcmp(str,'x')
                    obj.AxisDirectionPopup.Value=1;
                elseif strcmp(str,'y')
                    obj.AxisDirectionPopup.Value=2;
                elseif strcmp(str,'z')
                    obj.AxisDirectionPopup.Value=3;
                else
                    obj.AxisDirectionPopup.Value=4;
                end
            else
                if strcmp(str,'x')
                    obj.AxisDirectionPopup.Value='x';
                elseif strcmp(str,'y')
                    obj.AxisDirectionPopup.Value='y';
                elseif strcmp(str,'z')
                    obj.AxisDirectionPopup.Value='z';
                else
                    obj.AxisDirectionPopup.Value='Custom';
                end
            end
        end


        function val=get.CustomAxisDirection(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.CustomAxisDirectionEdit.String);
            else
                val=evalin('base',obj.CustomAxisDirectionEdit.Value);
            end
        end

        function set.CustomAxisDirection(obj,val)
            if~isUIFigure(obj.Parent)
                obj.CustomAxisDirectionEdit.String=mat2str(val);
            else
                obj.CustomAxisDirectionEdit.Value=mat2str(val);
            end
        end



        function updateElementObject(obj)
            if isscalar(obj.SignalFreq)
                Freq=[0,obj.SignalFreq];
            else
                Freq=[min(obj.SignalFreq)...
                ,max(obj.SignalFreq)];
            end

            updatePropSpeedandFrequency(obj.Parent.App);

            if strcmp(obj.AxisDirection,'Custom')

                obj.Parent.App.CurrentElement=phased.ShortDipoleAntennaElement(...
                'FrequencyRange',Freq,'AxisDirection',obj.AxisDirection,'CustomAxisDirection',obj.CustomAxisDirection);
            else
                obj.Parent.App.CurrentElement=phased.ShortDipoleAntennaElement(...
                'FrequencyRange',Freq,'AxisDirection',obj.AxisDirection);
            end
        end

        function gencode(obj,sw)
            addcr(sw,'% Create an short dipole antenna element');
            addcr(sw,'Elem = phased.ShortDipoleAntennaElement;')
            if isscalar(obj.SignalFreq)
                Freq=[0,obj.SignalFreq];
            else
                Freq=[min(obj.SignalFreq)...
                ,max(obj.SignalFreq)];
            end
            addcr(sw,['Elem.FrequencyRange = ',mat2str(Freq),';'])
            addcr(sw,['Elem.AxisDirection = ',mat2str(obj.AxisDirection),';'])
            if strcmp(obj.AxisDirection,'Custom')
                addcr(sw,['Elem.CustomAxisDirection = ',mat2str(obj.CustomAxisDirection),';'])
            end
            addcr(sw,'Array.Element = Elem;');
            addcr(sw);
        end

        function genreport(obj,sw)
            addcr(sw,'% Element Type ......................................... Short Dipole Antenna Element')
            addcr(sw,['% Propagation Speed (m/s) .............................. ',mat2str(obj.PropSpeed)])
            addcr(sw,['% Signal Frequencies (Hz) .............................. ',mat2str(obj.SignalFreq)])
            addcr(sw,['% Axis Direction .......................................',mat2str(obj.AxisDirection)])
            if strcmp(obj.AxisDirection,'Custom')
                addcr(sw,['% Custom Axis Direction .......................................',mat2str(obj.CustomAxisDirection)])
            end
        end
    end

    methods(Access=private)
        function createUIControls(obj)
            if~isUIFigure(obj.Parent)
                obj.Panel=obj.Parent.createPanel(obj.Parent.App.ParametersFig,...
                [getString(message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:ShortDipole'))]);
            else
                obj.Panel=obj.Parent.createPanel(obj.Parent.Layout,...
                [getString(message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:ShortDipole'))]);
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

            obj.PropSpeedLabel=obj.Parent.createTextLabel(parent,...
            [getString(message(...
            'phased:apps:arrayapp:PropagationSpeed')),' (',...
            getString(message('phased:apps:arrayapp:meter')),'/',...
            getString(message('phased:apps:arrayapp:second')),')']);

            obj.PropSpeedEdit=obj.Parent.createEditBox(parent,...
            '3e8',getString(message(...
            'phased:apps:arrayapp:PropagationSpeedTT')),...
            'propSpeedEdit',@(h,e)parameterChanged(obj,e));


            obj.SignalFreqLabel=obj.Parent.createTextLabel(parent,...
            [getString(message(...
            'phased:apps:arrayapp:Frequency')),' (',...
            getString(message('phased:apps:arrayapp:Hz')),')']);

            obj.SignalFreqEdit=obj.Parent.createEditBox(parent,...
            '3e8',getString(message(...
            'phased:apps:arrayapp:FrequencyTT')),'signalFreqEdit',...
            @(h,e)parameterChanged(obj,e));


            obj.AxisDirectionLabel=obj.Parent.createTextLabel(parent,getString(message('phased:apps:arrayapp:AxisDirection')));

            axispop={'x','y','z','Custom'};

            obj.AxisDirectionPopup=obj.Parent.createDropDown(parent,...
            axispop,3,getString(...
            message('phased:apps:arrayapp:AxisDirectionTT')),...
            'AxisDirectionPopUp',@(h,e)parameterChanged(obj,e));


            obj.CustomAxisDirectionLabel=obj.Parent.createTextLabel(parent,...
            'Custom Axis Direction');

            obj.CustomAxisDirectionEdit=obj.Parent.createEditBox(parent,...
            '[0;0;1]',getString(...
            message('phased:apps:arrayapp:CustomAxisDirectionTT')),'CustomAxisDirectionEdit',...
            @(h,e)parameterChanged(obj,e));

        end

        function layoutUIControls(obj)
            if~isUIFigure(obj.Parent)
                w1=obj.Parent.Width1;
                w2=obj.Parent.Width2;

                row=1;

                uiControlsHt=24;

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.PropSpeedLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.PropSpeedEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.SignalFreqLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.SignalFreqEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.AxisDirectionLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.AxisDirectionPopup,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.CustomAxisDirectionLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.CustomAxisDirectionEdit,row,2,w2,uiControlsHt)


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.PropSpeedLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.PropSpeedEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.SignalFreqLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.SignalFreqEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.AxisDirectionLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.AxisDirectionPopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.CustomAxisDirectionLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.CustomAxisDirectionEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
            end
        end

        function parameterChanged(obj,e)



            prop=e.Source.Tag;
            validPropSpeed=obj.Parent.App.PropagationSpeed;
            validFreq=obj.Parent.App.SignalFrequencies;
            switch prop
            case 'propSpeedEdit'
                try
                    sigdatatypes.validateSpeed(obj.PropSpeed,...
                    '','PropagationSpeed',...
                    {'double'},{'scalar','positive'});
                catch me
                    obj.PropSpeed=validPropSpeed;
                    throwError(obj.Parent.App,me);
                    return;
                end

            case 'signalFreqEdit'
                try
                    sigdatatypes.validateFrequency(obj.SignalFreq,'',...
                    'Frequency',{'double'},{'nonempty','finite',...
                    'nonnegative'});
                catch me
                    obj.SignalFreq=validFreq;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'AxisDirectionPopUp'
                if strcmp(obj.AxisDirection,'x')
                    obj.CustomAxisDirection=[1;0;0];
                elseif strcmp(obj.AxisDirection,'y')
                    obj.CustomAxisDirection=[0;1;0];
                else
                    obj.CustomAxisDirection=[0;0;1];
                end
            case 'CustomAxisDirectionEdit'
                try
                    sigdatatypes.validate3DCartCoord(obj.CustomAxisDirection,'','CustomAxisDirection',...
                    {'column'});
                    cond=all(obj.CustomAxisDirection==0);
                    if cond
                        error(getString(message('phased:apps:arrayapp:zeroColumns','Custom Axis Direction')));
                    end
                    if isequal(obj.CustomAxisDirection,[1;0;0])
                        obj.AxisDirection='x';
                    elseif isequal(obj.CustomAxisDirection,[0;1;0])
                        obj.AxisDirection='y';
                    elseif isequal(obj.CustomAxisDirection,[0;0;1])
                        obj.AxisDirection='z';
                    else
                        obj.AxisDirection='custom';
                    end
                    obj.ValidCustomAxisDirection=obj.CustomAxisDirection;
                catch me
                    obj.CustomAxisDirection=obj.ValidCustomAxisDirection;
                    throwError(obj.Parent.App,me);
                    return;
                end
            end


            enableAnalyzeButton(obj.Parent.App)
        end
    end
end

