classdef(Hidden,Sealed)ProjectorDialog<handle





    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

BBCheck

VoltageResponseLabel
VoltageResponseEdit

PropSpeedLabel
PropSpeedEdit

SignalFreqLabel
SignalFreqEdit
    end

    properties(Dependent)
BackBaffled
VoltageResponse
PropSpeed
SignalFreq
    end

    properties(Access=private)
Parent
Layout

        ValidVoltageResponse=120;
    end

    methods
        function obj=ProjectorDialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods


        function val=get.BackBaffled(obj)
            if obj.BBCheck.Value
                val=true;
            else
                val=false;
            end
        end

        function set.BackBaffled(obj,val)
            obj.BBCheck.Value=val;
        end


        function val=get.VoltageResponse(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.VoltageResponseEdit.String);
            else
                val=evalin('base',obj.VoltageResponseEdit.Value);
            end
        end

        function set.VoltageResponse(obj,val)
            if~isUIFigure(obj.Parent)
                obj.VoltageResponseEdit.String=mat2str(val);
            else
                obj.VoltageResponseEdit.Value=mat2str(val);
            end
        end


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



        function updateElementObject(obj)
            if isscalar(obj.SignalFreq)
                Freq=[0,obj.SignalFreq];
            else
                Freq=[min(obj.SignalFreq)...
                ,max(obj.SignalFreq)];
            end

            updatePropSpeedandFrequency(obj.Parent.App);


            obj.Parent.App.CurrentElement=phased.IsotropicProjector(...
            'VoltageResponse',obj.VoltageResponse,...
            'BackBaffled',obj.BackBaffled,...
            'FrequencyRange',Freq);
        end

        function gencode(obj,sw)
            addcr(sw,'% Create an isotropic projector')
            addcr(sw,'Elem = phased.IsotropicProjector;')
            if~isUIFigure(obj.Parent)
                addcr(sw,['Elem.VoltageResponse = ',obj.VoltageResponseEdit.String,';'])
            else
                addcr(sw,['Elem.VoltageResponse = ',obj.VoltageResponseEdit.Value,';'])
            end
            if obj.BackBaffled
                addcr(sw,'Elem.BackBaffled = true;')
            end
            if isscalar(obj.SignalFreq)
                Freq=[0,obj.SignalFreq];
            else
                Freq=[min(obj.SignalFreq)...
                ,max(obj.SignalFreq)];
            end
            addcr(sw,['Elem.FrequencyRange = ',mat2str(Freq),';'])
            addcr(sw,'Array.Element = Elem; ')
        end

        function genreport(obj,sw)
            addcr(sw,'% Element Type ......................................... Isotropic Projector')
            addcr(sw,['% Voltage Response ..................................... ',mat2str(obj.VoltageResponse)])
            addcr(sw,['% Back Baffled ......................................... ',mat2str(obj.BackBaffled)])
            addcr(sw,['% Propagation Speed (m/s) .............................. ',mat2str(obj.PropSpeed)])
            addcr(sw,['% Signal Frequencies (Hz) .............................. ',mat2str(obj.SignalFreq)])
        end
    end

    methods(Access=private)
        function createUIControls(obj)
            if~isUIFigure(obj.Parent)
                obj.Panel=obj.Parent.createPanel(obj.Parent.App.ParametersFig,...
                [getString(...
                message('phased:apps:arrayapp:sonarelement')),' - ',...
                getString(message('phased:apps:arrayapp:projectordialog'))]);
            else
                obj.Panel=obj.Parent.createPanel(obj.Parent.Layout,...
                [getString(...
                message('phased:apps:arrayapp:sonarelement')),' - ',...
                getString(message('phased:apps:arrayapp:projectordialog'))]);
            end

            hspacing=3;
            vspacing=5;


            obj.Layout=obj.Parent.createLayout(obj.Panel,...
            vspacing,hspacing,...
            [0,0,0,0,0,1],[0,1,0]);

            if~isUIFigure(obj.Parent)
                parent=obj.Panel;
            else
                parent=obj.Layout;
            end

            obj.BBCheck=obj.Parent.createCheckBox(parent,0,...
            getString(message(...
            'phased:apps:arrayapp:BackBaffled')),...
            getString(message(...
            'phased:apps:arrayapp:BackBaffledTT')),...
            'BBCheck',@(h,e)parameterChanged(obj,e));


            obj.VoltageResponseLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:VolResp')),' (',...
            getString(message('phased:apps:arrayapp:dB')),')']);

            obj.VoltageResponseEdit=obj.Parent.createEditBox(...
            parent,'120',getString(message(...
            'phased:apps:arrayapp:VolRespTT')),...
            'volRespEdit',@(h,e)parameterChanged(obj,e));


            obj.PropSpeedLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:PropagationSpeed')),' (',...
            getString(message('phased:apps:arrayapp:meter')),'/',...
            getString(message('phased:apps:arrayapp:second')),')']);

            obj.PropSpeedEdit=obj.Parent.createEditBox(parent,...
            '1500',getString(message(...
            'phased:apps:arrayapp:PropagationSpeedTT')),...
            'propSpeedEdit',@(h,e)parameterChanged(obj,e));


            obj.SignalFreqLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:Frequency')),' (',...
            getString(message('phased:apps:arrayapp:Hz')),')']);

            obj.SignalFreqEdit=obj.Parent.createEditBox(...
            parent,'10e3',getString(message(...
            'phased:apps:arrayapp:FrequencyTT')),...
            'signalFreqEdit',@(h,e)parameterChanged(obj,e));
        end

        function layoutUIControls(obj)
            if~isUIFigure(obj.Parent)
                w1=obj.Parent.Width1;
                w2=obj.Parent.Width2;


                row=1;

                uiControlsHt=24;

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.VoltageResponseLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.VoltageResponseEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.PropSpeedLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.PropSpeedEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.SignalFreqLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.SignalFreqEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addCheckBox(obj.Layout,obj.BBCheck,row,1,w1,uiControlsHt)



                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.VoltageResponseLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.VoltageResponseEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.PropSpeedLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.PropSpeedEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.SignalFreqLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.SignalFreqEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.BBCheck.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
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
            case 'volRespEdit'
                try
                    validateattributes(obj.VoltageResponse,...
                    {'double'},{'finite','row'},...
                    '','VoltageSensitivity');
                    obj.ValidVoltageResponse=obj.VoltageResponse;
                catch me
                    obj.VoltageResponse=obj.ValidVoltageResponse;
                    throwError(obj.Parent.App,me);
                    return;
                end
            end


            enableAnalyzeButton(obj.Parent.App);
        end
    end
end
