classdef(Hidden,Sealed)CosineAntennaDialog<handle





    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

CosinePowerLabel
CosinePowerEdit

PropSpeedLabel
PropSpeedEdit

SignalFreqLabel
SignalFreqEdit
    end

    properties(Dependent)
CosinePower
PropSpeed
SignalFreq
    end

    properties(Access=private)
Parent
Layout

        ValidCosinePower=[1,1]
    end

    methods
        function obj=CosineAntennaDialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods

        function cosPow=get.CosinePower(obj)
            if~isUIFigure(obj.Parent)
                cosPow=evalin('base',obj.CosinePowerEdit.String);
            else
                cosPow=evalin('base',obj.CosinePowerEdit.Value);
            end
        end

        function set.CosinePower(obj,val)
            if~isUIFigure(obj.Parent)
                obj.CosinePowerEdit.String=mat2str(val);
            else
                obj.CosinePowerEdit.Value=mat2str(val);
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


            obj.Parent.App.CurrentElement=phased.CosineAntennaElement(...
            'CosinePower',obj.CosinePower,...
            'FrequencyRange',Freq);
        end

        function gencode(obj,sw)
            addcr(sw,'% Create a cosine antenna element');
            addcr(sw,'Elem = phased.CosineAntennaElement;')
            addcr(sw,['Elem.CosinePower = ',mat2str(obj.CosinePower),';'])
            if isscalar(obj.SignalFreq)
                Freq=[0,obj.SignalFreq];
            else
                Freq=[min(obj.SignalFreq)...
                ,max(obj.SignalFreq)];
            end
            addcr(sw,['Elem.FrequencyRange = ',mat2str(Freq),';'])
            addcr(sw,'Array.Element = Elem;');
        end

        function genreport(obj,sw)
            addcr(sw,'% Element Type ......................................... Cosine Antenna Element')
            addcr(sw,['% Cosine Power ......................................... ',mat2str(obj.CosinePower)])
            addcr(sw,['% Signal frequencies (Hz) .............................. ',mat2str(obj.SignalFreq)])
            addcr(sw,['% Propagation Speed (m/s) .............................. ',mat2str(obj.PropSpeed)])
        end
    end

    methods(Access=private)
        function createUIControls(obj)
            if~isUIFigure(obj.Parent)
                obj.Panel=obj.Parent.createPanel(obj.Parent.App.ParametersFig,...
                [getString(message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:Cosine'))]);
            else
                obj.Panel=obj.Parent.createPanel(obj.Parent.Layout,...
                [getString(message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:Cosine'))]);
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

            obj.CosinePowerLabel=obj.Parent.createTextLabel(parent,...
            getString(message(...
            'phased:apps:arrayapp:CosinePower')));

            obj.CosinePowerEdit=obj.Parent.createEditBox(parent,...
            '[1 1]',getString(message(...
            'phased:apps:arrayapp:CosinePowerTT')),...
            'cosPowEdit',@(h,e)parameterChanged(obj,e));


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
                obj.Parent.addText(obj.Layout,obj.CosinePowerLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.CosinePowerEdit,row,2,w2,uiControlsHt)

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
                obj.CosinePowerLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.CosinePowerEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.PropSpeedLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.PropSpeedEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.SignalFreqLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.SignalFreqEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
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
            case 'cosPowEdit'
                try
                    validateattributes(obj.CosinePower,{'double'},...
                    {'nonempty','finite','size',[1,2],...
                    'nonnegative'},'','CosinePower');
                    obj.ValidCosinePower=obj.CosinePower;
                catch me
                    obj.CosinePower=obj.ValidCosinePower;
                    throwError(obj.Parent.App,me);
                    return;
                end
            end


            enableAnalyzeButton(obj.Parent.App);
        end
    end
end
