classdef(Hidden,Sealed)SincAntennaDialog<handle






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

AzBeamwidthLabel
AzBeamwidthEdit

ElBeamwidthLabel
ElBeamwidthEdit

    end

    properties(Dependent)
PropSpeed
SignalFreq
AzBeamwidth
ElBeamwidth
    end

    properties(Access=private)
Parent
Layout
        ValidAzBeamwidth=10
        ValidElBeamwidth=10
    end

    methods
        function obj=SincAntennaDialog(parent)

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


        function set.AzBeamwidth(obj,val)
            if~isUIFigure(obj.Parent)
                obj.AzBeamwidthEdit.String=mat2str(val);
            else
                obj.AzBeamwidthEdit.Value=mat2str(val);
            end
        end

        function val=get.AzBeamwidth(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.AzBeamwidthEdit.String);
            else
                val=evalin('base',obj.AzBeamwidthEdit.Value);
            end
        end

        function set.ElBeamwidth(obj,val)
            if~isUIFigure(obj.Parent)
                obj.ElBeamwidthEdit.String=mat2str(val);
            else
                obj.ElBeamwidthEdit.Value=mat2str(val);
            end
        end


        function val=get.ElBeamwidth(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.ElBeamwidthEdit.String);
            else
                val=evalin('base',obj.ElBeamwidthEdit.Value);
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


            obj.Parent.App.CurrentElement=phased.SincAntennaElement(...
            'FrequencyRange',Freq,'Beamwidth',[obj.AzBeamwidth,obj.ElBeamwidth]);
        end

        function gencode(obj,sw)
            addcr(sw,'% Create an sinc antenna element');
            addcr(sw,'Elem = phased.SincAntennaElement;')
            if isscalar(obj.SignalFreq)
                Freq=[0,obj.SignalFreq];
            else
                Freq=[min(obj.SignalFreq)...
                ,max(obj.SignalFreq)];
            end
            addcr(sw,['Elem.FrequencyRange = ',mat2str(Freq),';'])
            addcr(sw,['Elem.Beamwidth = ',mat2str([obj.AzBeamwidth,obj.ElBeamwidth]),';'])
            addcr(sw,'Array.Element = Elem;');
            addcr(sw);
        end

        function genreport(obj,sw)
            addcr(sw,'% Element Type ......................................... Sinc Antenna Element')
            addcr(sw,['% Signal Frequencies (Hz) .............................. ',mat2str(obj.SignalFreq)])
            addcr(sw,['% Beam Width  (deg) .................................... ',mat2str([obj.AzBeamwidth,obj.ElBeamwidth])])
            addcr(sw,['% Propagation Speed (m/s) .............................. ',mat2str(obj.PropSpeed)])
        end

    end

    methods(Access=private)
        function createUIControls(obj)
            if~isUIFigure(obj.Parent)
                obj.Panel=obj.Parent.createPanel(obj.Parent.App.ParametersFig,...
                [getString(message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:Sinc'))]);
            else
                obj.Panel=obj.Parent.createPanel(obj.Parent.Layout,...
                [getString(message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:Sinc'))]);
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


            obj.AzBeamwidthLabel=obj.Parent.createTextLabel(parent,...
            [getString(message(...
            'phased:apps:arrayapp:AzBeamwidth')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.AzBeamwidthEdit=obj.Parent.createEditBox(parent,...
            '10',getString(message(...
            'phased:apps:arrayapp:AzBeamwidthTT')),'AzBeamwidthEdit',...
            @(h,e)parameterChanged(obj,e));


            obj.ElBeamwidthLabel=obj.Parent.createTextLabel(parent,...
            [getString(message(...
            'phased:apps:arrayapp:ElBeamwidth')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.ElBeamwidthEdit=obj.Parent.createEditBox(parent,...
            '10',getString(message(...
            'phased:apps:arrayapp:ElBeamwidthTT')),'ElBeamwidthEdit',...
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
                obj.Parent.addText(obj.Layout,obj.AzBeamwidthLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.AzBeamwidthEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ElBeamwidthLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ElBeamwidthEdit,row,2,w2,uiControlsHt)


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.PropSpeedLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.PropSpeedEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.SignalFreqLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.SignalFreqEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.AzBeamwidthLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.AzBeamwidthEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.ElBeamwidthLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.ElBeamwidthEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
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
            case 'AzBeamwidthEdit'
                try
                    validateattributes(obj.AzBeamwidth,{'double'},...
                    {'nonempty','nonnan','finite','scalar','real',...
                    'nonnegative','<=',180},'','Azimuth Beamwidth');
                    obj.ValidAzBeamwidth=obj.AzBeamwidth;
                catch me
                    obj.AzBeamwidth=obj.ValidAzBeamwidth;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'ElBeamwidthEdit'
                try
                    validateattributes(obj.ElBeamwidth,{'double'},...
                    {'nonempty','nonnan','finite','scalar','real',...
                    'nonnegative','<=',180},'','Elevation Beamwidth');
                    obj.ValidElBeamwidth=obj.ElBeamwidth;
                catch me
                    obj.ElBeamwidth=obj.ValidElBeamwidth;
                    throwError(obj.Parent.App,me);
                    return;
                end
            end


            enableAnalyzeButton(obj.Parent.App)
        end
    end
end

