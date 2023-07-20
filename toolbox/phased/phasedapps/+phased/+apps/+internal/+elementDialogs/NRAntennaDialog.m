classdef(Hidden,Sealed)NRAntennaDialog<handle






    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

PropSpeedLabel
PropSpeedEdit

SignalFreqLabel
SignalFreqEdit

PolarizationAngleLabel
PolarizationAngleEdit

PolarizationModelLabel
PolarizationModelEdit

AzBeamwidthLabel
AzBeamwidthEdit

ElBeamwidthLabel
ElBeamwidthEdit

AzSidelobeLevelLabel
AzSidelobeLevelEdit

ElSidelobeLevelLabel
ElSidelobeLevelEdit

MaximumAttenuationLabel
MaximumAttenuationEdit

MaximumGainLabel
MaximumGainEdit
    end

    properties(Dependent)
PropSpeed
SignalFreq
PolarizationAngle
PolarizationModel
AzBeamwidth
ElBeamwidth
AzSidelobeLevel
ElSidelobeLevel
MaximumAttenuation
MaximumGain
    end

    properties(Access=private)
Parent
Layout
        ValidPolarizationAngle=0
        ValidAzBeamwidth=65
        ValidElBeamidth=65
        ValidAzSidelobeLevel=30
        ValidElSidelobeLevel=30
        ValidMaximumAttenuation=30
        ValidMaximumGain=8
    end

    methods
        function obj=NRAntennaDialog(parent)

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


        function val=get.PolarizationAngle(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.PolarizationAngleEdit.String);
            else
                val=evalin('base',obj.PolarizationAngleEdit.Value);
            end
        end


        function set.PolarizationAngle(obj,val)
            if~isUIFigure(obj.Parent)
                obj.PolarizationAngleEdit.String=mat2str(val);
            else
                obj.PolarizationAngleEdit.Value=mat2str(val);
            end
        end


        function val=get.PolarizationModel(obj)
            if~isUIFigure(obj.Parent)
                val=obj.PolarizationModelEdit.String{obj.PolarizationModelEdit.Value};
            else
                val=obj.PolarizationModelEdit.Value;
            end
        end

        function set.PolarizationModel(obj,str)
            if~isUIFigure(obj.Parent)
                switch str
                case '1'
                    obj.PolarizationModelEdit.Value=1;
                case '2'
                    obj.PolarizationModelEdit.Value=2;
                end
            else
                switch str
                case '1'
                    obj.PolarizationModelEdit.Value='1';
                case '2'
                    obj.PolarizationModelEdit.Value='2';
                end
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



        function val=get.AzSidelobeLevel(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.AzSidelobeLevelEdit.String);
            else
                val=evalin('base',obj.AzSidelobeLevelEdit.Value);
            end
        end


        function set.AzSidelobeLevel(obj,val)
            if~isUIFigure(obj.Parent)
                obj.AzSidelobeLevelEdit.String=mat2str(val);
            else
                obj.AzSidelobeLevelEdit.Value=mat2str(val);
            end
        end


        function val=get.ElSidelobeLevel(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.ElSidelobeLevelEdit.String);
            else
                val=evalin('base',obj.ElSidelobeLevelEdit.Value);
            end
        end


        function set.ElSidelobeLevel(obj,val)
            if~isUIFigure(obj.Parent)
                obj.ElSidelobeLevelEdit.String=mat2str(val);
            else
                obj.ElSidelobeLevelEdit.Value=mat2str(val);
            end
        end


        function val=get.MaximumAttenuation(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.MaximumAttenuationEdit.String);
            else
                val=evalin('base',obj.MaximumAttenuationEdit.Value);
            end
        end


        function set.MaximumAttenuation(obj,val)
            if~isUIFigure(obj.Parent)
                obj.MaximumAttenuationEdit.String=mat2str(val);
            else
                obj.MaximumAttenuationEdit.Value=mat2str(val);
            end
        end


        function val=get.MaximumGain(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.MaximumGainEdit.String);
            else
                val=evalin('base',obj.MaximumGainEdit.Value);
            end
        end


        function set.MaximumGain(obj,val)
            if~isUIFigure(obj.Parent)
                obj.MaximumGainEdit.String=mat2str(val);
            else
                obj.MaximumGainEdit.Value=mat2str(val);
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


            obj.Parent.App.CurrentElement=phased.NRAntennaElement(...
            'FrequencyRange',Freq,'PolarizationAngle',obj.PolarizationAngle,...
            'PolarizationModel',str2double(obj.PolarizationModel),'Beamwidth',[obj.AzBeamwidth,obj.ElBeamwidth],...
            'SidelobeLevel',[obj.AzSidelobeLevel,obj.ElSidelobeLevel],...
            'MaximumAttenuation',obj.MaximumAttenuation,'MaximumGain',obj.MaximumGain);
        end

        function gencode(obj,sw)
            addcr(sw,'% Create an NR antenna element');
            addcr(sw,'Elem = phased.NRAntennaElement;')
            if isscalar(obj.SignalFreq)
                Freq=[0,obj.SignalFreq];
            else
                Freq=[min(obj.SignalFreq)...
                ,max(obj.SignalFreq)];
            end
            addcr(sw,['Elem.FrequencyRange = ',mat2str(Freq),';'])
            addcr(sw,['Elem.PolarizationAngle = ',mat2str(obj.PolarizationAngle),';'])
            addcr(sw,['Elem.PolarizationModel = ',obj.PolarizationModel,';'])
            addcr(sw,['Elem.Beamwidth = ',mat2str([obj.AzBeamwidth,obj.ElBeamwidth]),';'])
            addcr(sw,['Elem.SidelobeLevel = ',mat2str([obj.AzSidelobeLevel,obj.ElSidelobeLevel]),';'])
            addcr(sw,['Elem.MaximumAttenuation = ',mat2str(obj.MaximumAttenuation),';'])
            addcr(sw,['Elem.MaximumGain = ',mat2str(obj.MaximumGain),';'])
            addcr(sw,'Array.Element = Elem;');
            addcr(sw);
        end

        function genreport(obj,sw)
            addcr(sw,'% Element Type ......................................... NR Antenna Element')
            addcr(sw,['% Signal Frequencies (Hz) .............................. ',mat2str(obj.SignalFreq)])
            addcr(sw,['% Polarization Angle (deg) ............................. ',mat2str(obj.PolarizationAngle)])
            addcr(sw,['% Polarization Model ................................... ',mat2str(obj.PolarizationModel)])
            addcr(sw,['% Beam Width (deg)...................................... ',mat2str([obj.AzBeamwidth,obj.ElBeamwidth])])
            addcr(sw,['% Sidelobe Level (dB) .................................. ',mat2str([obj.AzSidelobeLevel,obj.ElSidelobeLevel])])
            addcr(sw,['% Maximum Attenuation (dB).............................. ',mat2str(obj.MaximumAttenuation)])
            addcr(sw,['% Maximum Gain (dB)..................................... ',mat2str(obj.MaximumGain)])
            addcr(sw,['% Propagation Speed (m/s) .............................. ',mat2str(obj.PropSpeed)])
        end

    end

    methods(Access=private)
        function createUIControls(obj)
            if~isUIFigure(obj.Parent)
                obj.Panel=obj.Parent.createPanel(obj.Parent.App.ParametersFig,...
                [getString(message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:NRAntenna'))]);
            else
                obj.Panel=obj.Parent.createPanel(obj.Parent.Layout,...
                [getString(message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:NRAntenna'))]);
            end

            hspacing=3;
            vspacing=4;

            obj.Layout=obj.Parent.createLayout(obj.Panel,...
            vspacing,hspacing,...
            [0,0,0,0,0,0,0,0,0,0,0,0,1],[0,1,0]);

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

            obj.PolarizationAngleLabel=obj.Parent.createTextLabel(parent,...
            [getString(message('phased:apps:arrayapp:PolarizationAngle')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.PolarizationAngleEdit=obj.Parent.createEditBox(parent,...
            '0',getString(message('phased:apps:arrayapp:PolarizationAngleTT')),'PolarizationAngleEdit',...
            @(h,e)parameterChanged(obj,e));


            obj.PolarizationModelLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:PolarizationModel')));

            obj.PolarizationModelEdit=obj.Parent.createDropDown(parent,...
            {'1','2'},2,getString(message('phased:apps:arrayapp:PolarizationModelTT')),'PolarizationModelEdit',...
            @(h,e)parameterChanged(obj,e));


            obj.AzBeamwidthLabel=obj.Parent.createTextLabel(parent,...
            [getString(message('phased:apps:arrayapp:AzBeamwidth')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.AzBeamwidthEdit=obj.Parent.createEditBox(parent,...
            '65',getString(message('phased:apps:arrayapp:AzBeamwidthTT')),'AzBeamwidthEdit',...
            @(h,e)parameterChanged(obj,e));


            obj.ElBeamwidthLabel=obj.Parent.createTextLabel(parent,...
            [getString(message('phased:apps:arrayapp:ElBeamwidth')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.ElBeamwidthEdit=obj.Parent.createEditBox(parent,...
            '65',getString(message('phased:apps:arrayapp:ElBeamwidthTT')),'ElBeamwidthEdit',...
            @(h,e)parameterChanged(obj,e));


            obj.AzSidelobeLevelLabel=obj.Parent.createTextLabel(parent,...
            [getString(message('phased:apps:arrayapp:AzSidelobeLevel')),' (',...
            getString(message('phased:apps:arrayapp:dB')),')']);

            obj.AzSidelobeLevelEdit=obj.Parent.createEditBox(parent,...
            '30',getString(message('phased:apps:arrayapp:AzSidelobeLevelNRantennaTT')),'AzSLLEdit',...
            @(h,e)parameterChanged(obj,e));


            obj.ElSidelobeLevelLabel=obj.Parent.createTextLabel(parent,...
            [getString(message('phased:apps:arrayapp:ElSidelobeLevel')),' (',...
            getString(message('phased:apps:arrayapp:dB')),')']);

            obj.ElSidelobeLevelEdit=obj.Parent.createEditBox(parent,...
            '30',getString(message('phased:apps:arrayapp:ElSidelobeLevelNRantennaTT')),'ElSLLEdit',...
            @(h,e)parameterChanged(obj,e));


            obj.MaximumAttenuationLabel=obj.Parent.createTextLabel(parent,...
            [getString(message('phased:apps:arrayapp:MaximumAttenuation')),' (',...
            getString(message('phased:apps:arrayapp:dB')),')']);

            obj.MaximumAttenuationEdit=obj.Parent.createEditBox(parent,...
            '30',getString(message('phased:apps:arrayapp:MaximumAttenuationTT')),'MaximumAttenuationEdit',...
            @(h,e)parameterChanged(obj,e));


            obj.MaximumGainLabel=obj.Parent.createTextLabel(parent,...
            [getString(message('phased:apps:arrayapp:MaximumGain')),' (',...
            getString(message('phased:apps:arrayapp:dB')),')']);

            obj.MaximumGainEdit=obj.Parent.createEditBox(parent,...
            '8',getString(message('phased:apps:arrayapp:MaximumGainTT')),'MaximumGainEdit',...
            @(h,e)parameterChanged(obj,e));

        end

        function layoutUIControls(obj)
            if~isUIFigure(obj.Parent)
                w1=obj.Parent.Width1+15;
                w2=obj.Parent.Width2;

                row=1;

                uiControlsHt=24;

                row=row+2;
                obj.Parent.addText(obj.Layout,obj.PropSpeedLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.PropSpeedEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.SignalFreqLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.SignalFreqEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.PolarizationAngleLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.PolarizationAngleEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.PolarizationModelLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.PolarizationModelEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.AzBeamwidthLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.AzBeamwidthEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ElBeamwidthLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ElBeamwidthEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.AzSidelobeLevelLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.AzSidelobeLevelEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ElSidelobeLevelLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ElSidelobeLevelEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.MaximumAttenuationLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.MaximumAttenuationEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.MaximumGainLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.MaximumGainEdit,row,2,w2,uiControlsHt)


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.PropSpeedLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.PropSpeedEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.SignalFreqLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.SignalFreqEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.PolarizationAngleLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.PolarizationAngleEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.PolarizationModelLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.PolarizationModelEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
                obj.AzBeamwidthLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',1);
                obj.AzBeamwidthEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',2);
                obj.ElBeamwidthLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',1);
                obj.ElBeamwidthEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',2);
                obj.AzSidelobeLevelLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',1);
                obj.AzSidelobeLevelEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',2);
                obj.ElSidelobeLevelLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',8,'Column',1);
                obj.ElSidelobeLevelEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',8,'Column',2);
                obj.MaximumAttenuationLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',9,'Column',1);
                obj.MaximumAttenuationEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',9,'Column',2);
                obj.MaximumGainLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',10,'Column',1);
                obj.MaximumGainEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',10,'Column',2);
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
            case 'PolarizationAngleEdit'
                try
                    sigdatatypes.validateAngle(obj.PolarizationAngle,'','PolarizationAngle',...
                    {'scalar','<=',180,'>=',-180});
                    obj.ValidPolarizationAngle=obj.PolarizationAngle;
                catch me
                    obj.PolarizationAngle=obj.ValidPolarizationAngle;
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
                    obj.ValidElBeamidth=obj.ElBeamwidth;
                catch me
                    obj.ElBeamwidth=obj.ValidElBeamidth;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'AzSLLEdit'
                try
                    validateattributes(obj.AzSidelobeLevel,{'double'},{'positive','real','finite','scalar'},...
                    '','Azimuth Sidelobe Level');
                    obj.ValidAzSidelobeLevel=obj.AzSidelobeLevel;
                catch me
                    obj.AzSidelobeLevel=obj.ValidAzSidelobeLevel;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'ElSLLEdit'
                try
                    validateattributes(obj.ElSidelobeLevel,{'double'},{'positive','real','finite','scalar'},...
                    '','Elevation Sidelobe Level');
                    obj.ValidElSidelobeLevel=obj.ElSidelobeLevel;
                catch me
                    obj.ElSidelobeLevel=obj.ValidElSidelobeLevel;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'MaximumAttenuationEdit'
                try
                    validateattributes(obj.MaximumAttenuation,{'double'},{'positive','real','finite','scalar'},...
                    '','Maximum Attenuation');
                    slmax=max([obj.AzSidelobeLevel,obj.ElSidelobeLevel]);
                    cond=obj.MaximumAttenuation<slmax;
                    if cond
                        error(getString(message('phased:phased:expectedGreaterThanOrEqualTo',...
                        'MaximumAttenuation',sprintf('%0.2f',slmax))));
                    end
                    obj.ValidMaximumAttenuation=obj.MaximumAttenuation;
                catch me
                    obj.MaximumAttenuation=obj.ValidMaximumAttenuation;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'MaximumGainEdit'
                try
                    validateattributes(obj.MaximumGain,{'double'},{'positive','real','finite','scalar'},...
                    '','Maximum Gain');
                    obj.ValidMaximumGain=obj.MaximumGain;
                catch me
                    obj.MaximumGain=obj.ValidMaximumGain;
                    throwError(obj.Parent.App,me);
                    return;
                end

            end


            enableAnalyzeButton(obj.Parent.App)
        end
    end
end

