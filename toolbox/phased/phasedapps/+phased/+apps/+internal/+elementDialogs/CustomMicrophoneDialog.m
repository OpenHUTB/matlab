classdef(Hidden,Sealed)CustomMicrophoneDialog<handle





    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

FrequencyVectorLabel
FrequencyVectorEdit

FrequencyResponseLabel
FrequencyResponseEdit

PolarPatternFreqLabel
PolarPatternFreqEdit

PolarPatternAngLabel
PolarPatternAngEdit

PolarPatternLabel
PolarPatternEdit

PropSpeedLabel
PropSpeedEdit

SignalFreqLabel
SignalFreqEdit
    end

    properties(Dependent)
FrequencyVector
FrequencyResponse
PolarPatternFreq
PolarPatternAng
PolarPattern
PropSpeed
SignalFreq
    end

    properties(Access=private)
Parent
Layout

        ValidFrequencyVector=[0,1e20]
        ValidFrequencyResponse=[0,0]
        ValidPolarAngle=-180:180
        ValidPolarFrequency=1000
        ValidPolarPattern=zeros(1,361);
    end

    methods
        function obj=CustomMicrophoneDialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods

        function val=get.FrequencyVector(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.FrequencyVectorEdit.String);
            else
                val=evalin('base',obj.FrequencyVectorEdit.Value);
            end
        end

        function set.FrequencyVector(obj,val)
            if~isUIFigure(obj.Parent)
                obj.FrequencyVectorEdit.String=mat2str(val);
            else
                obj.FrequencyVectorEdit.Value=mat2str(val);
            end
        end


        function val=get.FrequencyResponse(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.FrequencyResponseEdit.String);
            else
                val=evalin('base',obj.FrequencyResponseEdit.Value);
            end
        end

        function set.FrequencyResponse(obj,val)
            if~isUIFigure(obj.Parent)
                obj.FrequencyResponseEdit.String=mat2str(val);
            else
                obj.FrequencyResponseEdit.Value=mat2str(val);
            end
        end


        function val=get.PolarPatternFreq(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.PolarPatternFreqEdit.String);
            else
                val=evalin('base',obj.PolarPatternFreqEdit.Value);
            end
        end

        function set.PolarPatternFreq(obj,val)
            if~isUIFigure(obj.Parent)
                obj.PolarPatternFreqEdit.String=mat2str(val);
            else
                obj.PolarPatternFreqEdit.Value=mat2str(val);
            end
        end


        function val=get.PolarPatternAng(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.PolarPatternAngEdit.String);
            else
                val=evalin('base',obj.PolarPatternAngEdit.Value);
            end
        end

        function set.PolarPatternAng(obj,val)
            if~isUIFigure(obj.Parent)
                obj.PolarPatternAngEdit.String=mat2str(val);
            else
                obj.PolarPatternAngEdit.Value=mat2str(val);
            end
        end


        function val=get.PolarPattern(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.PolarPatternEdit.String);
            else
                val=evalin('base',obj.PolarPatternEdit.Value);
            end
        end

        function set.PolarPattern(obj,val)
            if~isUIFigure(obj.Parent)
                obj.PolarPatternEdit.String=mat2str(val);
            else
                obj.PolarPatternEdit.Value=mat2str(val);
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


            updatePropSpeedandFrequency(obj.Parent.App);


            obj.Parent.App.CurrentElement=phased.CustomMicrophoneElement(...
            'FrequencyVector',obj.FrequencyVector,...
            'FrequencyResponse',obj.FrequencyResponse,...
            'PolarPatternAngles',obj.PolarPatternAng,...
            'PolarPatternFrequencies',obj.PolarPatternFreq,...
            'PolarPattern',obj.PolarPattern);
        end

        function validElement=verifyParameters(obj)

            sigFreq=obj.SignalFreq;
            freqVector=obj.FrequencyVector;
            try

                customElement=phased.CustomMicrophoneElement(...
                'FrequencyVector',obj.FrequencyVector,...
                'FrequencyResponse',obj.FrequencyResponse,...
                'PolarPatternAngles',obj.PolarPatternAng,...
                'PolarPatternFrequencies',obj.PolarPatternFreq,...
                'PolarPattern',obj.PolarPattern);


                step(customElement,0,0);



                if(min(sigFreq)<min(freqVector))||(max(sigFreq)>max(freqVector))
                    freqRange=mat2str([min(freqVector),max(freqVector)]);
                    error(getString(...
                    message('phased:apps:arrayapp:errorFreqVector',freqRange)));
                end

                validElement=true;
            catch me
                validElement=false;
                throwError(obj.Parent.App,me);
                return;
            end
        end

        function gencode(obj,sw)
            addcr(sw,'% Create a custom microphone element')
            addcr(sw,'Elem = phased.CustomMicrophoneElement;');
            if~isUIFigure(obj.Parent)
                addcr(sw,['Elem.FrequencyVector = ',obj.FrequencyVectorEdit.String,';']);
                addcr(sw,['Elem.FrequencyResponse = ',obj.FrequencyResponseEdit.String,';']);
                addcr(sw,['Elem.PolarPatternFrequencies = ',obj.PolarPatternFreqEdit.String,';']);
                addcr(sw,['Elem.PolarPatternAngles = ',obj.PolarPatternAngEdit.String,';']);
                addcr(sw,['Elem.PolarPattern = ',obj.PolarPatternEdit.String,';']);
            else
                addcr(sw,['Elem.FrequencyVector = ',obj.FrequencyVectorEdit.Value,';']);
                addcr(sw,['Elem.FrequencyResponse = ',obj.FrequencyResponseEdit.Value,';']);
                addcr(sw,['Elem.PolarPatternFrequencies = ',obj.PolarPatternFreqEdit.Value,';']);
                addcr(sw,['Elem.PolarPatternAngles = ',obj.PolarPatternAngEdit.Value,';']);
                addcr(sw,['Elem.PolarPattern = ',obj.PolarPatternEdit.Value,';']);
            end
            addcr(sw,'Array.Element = Elem;')
        end

        function genreport(obj,sw)
            addcr(sw,'% Element Type ......................................... Custom Microphone Element')
            addcr(sw,['% Frequency Vector (Hz) ................................ ',mat2str(obj.FrequencyVector)])
            addcr(sw,['% Frequency Response (dB) .............................. ',mat2str(obj.FrequencyResponse)])
            if~isUIFigure(obj.Parent)
                addcr(sw,['% Polar Frequencies (Hz) ............................... ',obj.PolarPatternFreqEdit.String])
                addcr(sw,['% Polar Pattern Angles (deg) ........................... ',obj.PolarPatternAngEdit.String])
                addcr(sw,['% Polar Pattern (dB) ................................... ',obj.PolarPatternEdit.String])
            else
                addcr(sw,['% Polar Frequencies (Hz) ............................... ',obj.PolarPatternFreqEdit.Value])
                addcr(sw,['% Polar Pattern Angles (deg) ........................... ',obj.PolarPatternAngEdit.Value])
                addcr(sw,['% Polar Pattern (dB) ................................... ',obj.PolarPatternEdit.Value])
            end
            addcr(sw,['% Signal Frequencies (Hz) .............................. ',mat2str(obj.SignalFreq)])
            addcr(sw,['% Propagation Speed (m/s) .............................. ',mat2str(obj.PropSpeed)])
        end
    end

    methods(Access=private)
        function createUIControls(obj)
            if~isUIFigure(obj.Parent)
                obj.Panel=obj.Parent.createPanel(obj.Parent.App.ParametersFig,...
                [getString(...
                message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:custommicrophone'))]);
            else
                obj.Panel=obj.Parent.createPanel(obj.Parent.Layout,...
                [getString(...
                message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:custommicrophone'))]);
            end
            hspacing=3;
            vspacing=5;

            obj.Layout=obj.Parent.createLayout(obj.Panel,...
            vspacing,hspacing,...
            [0,0,0,0,0,0,0,0,1],[0,1,0]);

            if~isUIFigure(obj.Parent)
                parent=obj.Panel;
            else
                parent=obj.Layout;
            end

            obj.FrequencyVectorLabel=obj.Parent.createTextLabel(parent,...
            [getString(message(...
            'phased:apps:arrayapp:FrequencyVector')),' (',...
            getString(message('phased:apps:arrayapp:Hz')),')']);

            obj.FrequencyVectorEdit=obj.Parent.createEditBox(parent,...
            '[0 1e20]',getString(message(...
            'phased:apps:arrayapp:FrequencyVectorMTT')),...
            'freqVectorEdit',@(h,e)parameterChanged(obj,e));


            obj.FrequencyResponseLabel=obj.Parent.createTextLabel(parent,...
            [getString(message(...
            'phased:apps:arrayapp:FrequencyResponse')),' (',...
            getString(message('phased:apps:arrayapp:dB')),')']);

            obj.FrequencyResponseEdit=obj.Parent.createEditBox(...
            parent,'[0 0]',getString(message(...
            'phased:apps:arrayapp:FrequencyResponseTT')),...
            'freqRespEdit',@(h,e)parameterChanged(obj,e));


            obj.PolarPatternFreqLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:PolarPatternFreq')),' (',...
            getString(message('phased:apps:arrayapp:Hz')),')']);

            obj.PolarPatternFreqEdit=obj.Parent.createEditBox(...
            parent,'1000',getString(message(...
            'phased:apps:arrayapp:PolarPatternFreqTT')),...
            'polarFreqEdit',@(h,e)parameterChanged(obj,e));


            obj.PolarPatternAngLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:PolarPatternAngle')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.PolarPatternAngEdit=obj.Parent.createEditBox(parent,...
            '[-180:180]',...
            getString(message(...
            'phased:apps:arrayapp:PolarPatternAngleTT')),...
            'polarAngEdit',@(h,e)parameterChanged(obj,e));


            obj.PolarPatternLabel=obj.Parent.createTextLabel(parent,...
            [getString(message(...
            'phased:apps:arrayapp:PolarPattern')),' (',...
            getString(message('phased:apps:arrayapp:dB')),')']);

            obj.PolarPatternEdit=obj.Parent.createEditBox(parent,...
            'ones(1,361)',...
            getString(message(...
            'phased:apps:arrayapp:PolarPatternTT')),...
            'polarPatEdit',@(h,e)parameterChanged(obj,e));


            obj.PropSpeedLabel=obj.Parent.createTextLabel(parent,...
            [getString(message(...
            'phased:apps:arrayapp:PropagationSpeed')),' (',...
            getString(message('phased:apps:arrayapp:meter')),'/',...
            getString(message('phased:apps:arrayapp:second')),')']);

            obj.PropSpeedEdit=obj.Parent.createEditBox(parent,...
            '343',getString(message(...
            'phased:apps:arrayapp:PropagationSpeedTT')),...
            'propSpeedEdit',@(h,e)parameterChanged(obj,e));


            obj.SignalFreqLabel=obj.Parent.createTextLabel(parent,...
            [getString(message(...
            'phased:apps:arrayapp:Frequency')),' (',...
            getString(message('phased:apps:arrayapp:Hz')),')']);

            obj.SignalFreqEdit=obj.Parent.createEditBox(parent,...
            '0.1e3',getString(message(...
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
                obj.Parent.addText(obj.Layout,obj.FrequencyVectorLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.FrequencyVectorEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.FrequencyResponseLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.FrequencyResponseEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.PolarPatternFreqLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.PolarPatternFreqEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.PolarPatternAngLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.PolarPatternAngEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.PolarPatternLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.PolarPatternEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.PropSpeedLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.PropSpeedEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.SignalFreqLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.SignalFreqEdit,row,2,w2,uiControlsHt)


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.FrequencyVectorLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.FrequencyVectorEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.FrequencyResponseLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.FrequencyResponseEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.PolarPatternFreqLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.PolarPatternFreqEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.PolarPatternAngLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.PolarPatternAngEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
                obj.PolarPatternLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',1);
                obj.PolarPatternEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',2);
                obj.PropSpeedLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',1);
                obj.PropSpeedEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',2);
                obj.SignalFreqLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',1);
                obj.SignalFreqEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',2);
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
            case 'freqVectorEdit'
                try
                    validateattributes(obj.FrequencyVector,...
                    {'double'},{'nonempty','finite','row',...
                    'nonnegative'},'','FrequencyVector');
                    obj.ValidFrequencyVector=obj.FrequencyVector;
                catch me
                    obj.FrequencyVector=obj.ValidFrequencyVector;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'freqRespEdit'
                try
                    validateattributes(obj.FrequencyResponse,...
                    {'double'},{'real','row','nonnan'},...
                    '','FrequencyResponse');
                    obj.ValidFrequencyResponse=obj.FrequencyResponse;
                catch me
                    obj.FrequencyResponse=obj.ValidFrequencyResponse;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'polarFreqEdit'
                try
                    validateattributes(obj.PolarPatternFreq,{'double'},...
                    {'nonempty','row','nonnegative',...
                    'finite'},'','PolarPatternFrequencies');
                    obj.ValidPolarFrequency=obj.PolarPatternFreq;
                catch me
                    obj.PolarPatternFreq=obj.ValidPolarFrequency;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'polarAngEdit'
                try
                    sigdatatypes.validateAngle(obj.PolarPatternAng,...
                    ' ','PolarPatternAngles',...
                    {'row','>=',-180,'<=',180});
                    obj.ValidPolarAngle=obj.PolarPatternAng;
                catch me
                    obj.PolarPatternAng=obj.ValidPolarAngle;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'polarPatEdit'
                try
                    validateattributes(obj.PolarPattern,{'double'},...
                    {'2d','real','nonempty','nonnan'},...
                    '','PolarPattern');
                    obj.ValidPolarPattern=obj.PolarPattern;
                catch me
                    obj.PolarPattern=obj.ValidPolarPattern;
                    throwError(obj.Parent.App,me);
                    return;
                end
            end


            enableAnalyzeButton(obj.Parent.App);
        end
    end
end
