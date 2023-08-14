classdef(Hidden,Sealed)CrossedDipoleAntennaDialog<handle






    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

PropSpeedLabel
PropSpeedEdit

SignalFreqLabel
SignalFreqEdit

RotationAngleLabel
RotationAngleEdit

PolarizationLabel
PolarizationEdit
    end

    properties(Dependent)
PropSpeed
SignalFreq
RotationAngle
Polarization
    end

    properties(Access=private)
Parent
Layout
        ValidRotationAngle=0;
    end

    methods
        function obj=CrossedDipoleAntennaDialog(parent)

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


        function val=get.RotationAngle(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.RotationAngleEdit.String);
            else
                val=evalin('base',obj.RotationAngleEdit.Value);
            end
        end


        function set.RotationAngle(obj,val)
            if~isUIFigure(obj.Parent)
                obj.RotationAngleEdit.String=mat2str(val);
            else
                obj.RotationAngleEdit.Value=mat2str(val);
            end
        end


        function val=get.Polarization(obj)
            if~isUIFigure(obj.Parent)
                val=obj.PolarizationEdit.String{obj.PolarizationEdit.Value};
            else
                val=obj.PolarizationEdit.Value;
            end
        end

        function set.Polarization(obj,str)
            if~isUIFigure(obj.Parent)
                switch str
                case 'RHCP'
                    obj.PolarizationEdit.Value=1;
                case 'LHCP'
                    obj.PolarizationEdit.Value=2;
                case 'Linear'
                    obj.PolarizationEdit.Value=3;
                end
            else
                switch str
                case 'RHCP'
                    obj.PolarizationEdit.Value='RHCP';
                case 'LHCP'
                    obj.PolarizationEdit.Value='LHCP';
                case 'Linear'
                    obj.PolarizationEdit.Value='Linear';
                end
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


            obj.Parent.App.CurrentElement=phased.CrossedDipoleAntennaElement(...
            'FrequencyRange',Freq,'Polarization',obj.Polarization,...
            'RotationAngle',obj.RotationAngle);
        end

        function gencode(obj,sw)
            addcr(sw,'% Create an crossed dipole antenna element');
            addcr(sw,'Elem = phased.CrossedDipoleAntennaElement;')
            if isscalar(obj.SignalFreq)
                Freq=[0,obj.SignalFreq];
            else
                Freq=[min(obj.SignalFreq)...
                ,max(obj.SignalFreq)];
            end
            addcr(sw,['Elem.FrequencyRange = ',mat2str(Freq),';'])
            addcr(sw,['Elem.RotationAngle = ',mat2str(obj.RotationAngle),';'])
            addcr(sw,['Elem.Polarization = ',mat2str(obj.Polarization),';'])
            addcr(sw,'Array.Element = Elem;');
            addcr(sw);
        end

        function genreport(obj,sw)
            addcr(sw,'% Element Type ......................................... Crossed Dipole Antenna Element')
            addcr(sw,['% Signal Frequencies (Hz) .............................. ',mat2str(obj.SignalFreq)])
            addcr(sw,['% Rotation Angle (deg) ................................. ',mat2str(obj.RotationAngle)])
            addcr(sw,['% Propagation Speed (m/s) .............................. ',mat2str(obj.PropSpeed)])
        end
    end

    methods(Access=private)
        function createUIControls(obj)
            if~isUIFigure(obj.Parent)
                obj.Panel=obj.Parent.createPanel(obj.Parent.App.ParametersFig,...
                [getString(message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:CrossedDipole'))]);
            else
                obj.Panel=obj.Parent.createPanel(obj.Parent.Layout,...
                [getString(message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:CrossedDipole'))]);
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


            obj.RotationAngleLabel=obj.Parent.createTextLabel(parent,...
            [getString(message('phased:apps:arrayapp:RotationAngle')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.RotationAngleEdit=obj.Parent.createEditBox(parent,...
            '0',getString(message('phased:apps:arrayapp:RotationAngleTT')),'RotationAngleEdit',...
            @(h,e)parameterChanged(obj,e));


            obj.PolarizationLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:Polarization')));

            obj.PolarizationEdit=obj.Parent.createDropDown(parent,...
            {'RHCP','LHCP','Linear'},1,getString(message('phased:apps:arrayapp:PolarizationTT')),'PolarizationEdit',...
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
                obj.Parent.addText(obj.Layout,obj.RotationAngleLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.RotationAngleEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.PolarizationLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.PolarizationEdit,row,2,w2,uiControlsHt)


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.PropSpeedLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.PropSpeedEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.SignalFreqLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.SignalFreqEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.RotationAngleLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.RotationAngleEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.PolarizationLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.PolarizationEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
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

            case 'RotationAngleEdit'
                try
                    sigdatatypes.validateAngle(obj.RotationAngle,'','RotationAngle',{'scalar','>=',-45,'<=',45});
                    obj.ValidRotationAngle=obj.RotationAngle;
                catch me
                    obj.RotationAngle=obj.ValidRotationAngle;
                    throwError(obj.Parent.App,me);
                    return;
                end
            end


            enableAnalyzeButton(obj.Parent.App)
        end
    end
end

