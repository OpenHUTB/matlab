classdef(Hidden,Sealed)CustomAntennaDialog<handle





    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

MatchNormalCheck

FrequencyVectorLabel
FrequencyVectorEdit

FrequencyResponseLabel
FrequencyResponseEdit

AzimuthAngleLabel
AzimuthAngleEdit

ElevationAngleLabel
ElevationAngleEdit

MagnitudePatternLabel
MagnitudePatternEdit

PhasePatternLabel
PhasePatternEdit

PropSpeedLabel
PropSpeedEdit

SignalFreqLabel
SignalFreqEdit

PatternCoordinateLabel
PatternCoordinatePopup

PhiAngleLabel
PhiAngleEdit

ThetaAngleLabel
ThetaAngleEdit
    end

    properties(Dependent)
FrequencyVector
FrequencyResponse
AzimuthAngles
ElevationAngles
MagnitudePattern
PhasePattern
MatchArrayNormal
PropSpeed
SignalFreq
PatternCoordinate
PhiAngles
ThetaAngles
    end

    properties(Access=private)
Parent
Layout

        ValidFrequencyVector=[0,1e20]
        ValidFrequencyResponse=[0,0]
        ValidAzimuthAngle=-180:180
        ValidElevationAngle=-90:90
        ValidMagnitudePattern=zeros(181,361)
        ValidPhasePattern=zeros(181,361)
        ValidPatternCoordinate=getString(message('phased:apps:arrayapp:azelcoord'))
        ValidPhiAngle=0:360
        ValidThetaAngle=0:180
    end

    methods
        function obj=CustomAntennaDialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods


        function val=get.MatchArrayNormal(obj)
            if obj.MatchNormalCheck.Value
                val=true;
            else
                val=false;
            end
        end

        function set.MatchArrayNormal(obj,val)
            obj.MatchNormalCheck.Value=val;
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



        function val=get.PatternCoordinate(obj)
            if~isUIFigure(obj.Parent)
                val=obj.PatternCoordinatePopup.String{obj.PatternCoordinatePopup.Value};
            else
                val=obj.PatternCoordinatePopup.Value;
            end
        end

        function set.PatternCoordinate(obj,str)
            if~isUIFigure(obj.Parent)
                if strcmp(str,getString(message('phased:apps:arrayapp:azelcoord')))
                    obj.PatternCoordinatePopup.Value=1;
                else
                    obj.PatternCoordinatePopup.Value=2;
                end
            else
                if strcmp(str,getString(message('phased:apps:arrayapp:azelcoord')))
                    obj.PatternCoordinatePopup.Value=getString(message('phased:apps:arrayapp:azelcoord'));
                else
                    obj.PatternCoordinatePopup.Value=getString(message('phased:apps:arrayapp:phithetacoord'));
                end
            end
        end


        function val=get.AzimuthAngles(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.AzimuthAngleEdit.String);
            else
                val=evalin('base',obj.AzimuthAngleEdit.Value);
            end
        end

        function set.AzimuthAngles(obj,val)
            if~isUIFigure(obj.Parent)
                obj.AzimuthAngleEdit.String=mat2str(val);
            else
                obj.AzimuthAngleEdit.Value=mat2str(val);
            end
        end


        function val=get.ElevationAngles(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.ElevationAngleEdit.String);
            else
                val=evalin('base',obj.ElevationAngleEdit.Value);
            end
        end

        function set.ElevationAngles(obj,val)
            if~isUIFigure(obj.Parent)
                obj.ElevationAngleEdit.String=mat2str(val);
            else
                obj.ElevationAngleEdit.Value=mat2str(val);
            end
        end


        function val=get.PhiAngles(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.PhiAngleEdit.String);
            else
                val=evalin('base',obj.PhiAngleEdit.Value);
            end
        end

        function set.PhiAngles(obj,val)
            if~isUIFigure(obj.Parent)
                obj.PhiAngleEdit.String=mat2str(val);
            else
                obj.PhiAngleEdit.Value=mat2str(val);
            end
        end


        function val=get.ThetaAngles(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.ThetaAngleEdit.String);
            else
                val=evalin('base',obj.ThetaAngleEdit.Value);
            end
        end

        function set.ThetaAngles(obj,val)
            if~isUIFigure(obj.Parent)
                obj.ThetaAngleEdit.String=mat2str(val);
            else
                obj.ThetaAngleEdit.Value=mat2str(val);
            end
        end


        function val=get.MagnitudePattern(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.MagnitudePatternEdit.String);
            else
                val=evalin('base',obj.MagnitudePatternEdit.Value);
            end
        end

        function set.MagnitudePattern(obj,val)
            if(numel(size(val))==3)
                value=phased.apps.internal.SensorArrayApp.ndmat2str(val);
            else
                value=mat2str(val);
            end
            if~isUIFigure(obj.Parent)
                obj.MagnitudePatternEdit.String=value;
            else
                obj.MagnitudePatternEdit.Value=value;
            end
        end


        function val=get.PhasePattern(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.PhasePatternEdit.String);
            else
                val=evalin('base',obj.PhasePatternEdit.Value);
            end
        end

        function set.PhasePattern(obj,val)
            if(numel(size(val))==3)
                value=phased.apps.internal.SensorArrayApp.ndmat2str(val);
            else
                value=mat2str(val);
            end
            if~isUIFigure(obj.Parent)
                obj.PhasePatternEdit.String=value;
            else
                obj.PhasePatternEdit.Value=value;
            end
        end



        function updateElementObject(obj)

            updatePropSpeedandFrequency(obj.Parent.App);


            if strcmp(obj.PatternCoordinate,getString(message('phased:apps:arrayapp:azelcoord')))
                obj.Parent.App.CurrentElement=phased.CustomAntennaElement(...
                'FrequencyVector',obj.FrequencyVector,...
                'FrequencyResponse',obj.FrequencyResponse,...
                'AzimuthAngles',obj.AzimuthAngles,...
                'ElevationAngles',obj.ElevationAngles,...
                'MagnitudePattern',obj.MagnitudePattern,...
                'PhasePattern',obj.PhasePattern,...
                'MatchArrayNormal',obj.MatchArrayNormal);
            else
                obj.Parent.App.CurrentElement=phased.CustomAntennaElement(...
                'FrequencyVector',obj.FrequencyVector,...
                'FrequencyResponse',obj.FrequencyResponse,...
                'PatternCoordinateSystem','phi-theta',...
                'PhiAngles',obj.PhiAngles,...
                'ThetaAngles',obj.ThetaAngles,...
                'MagnitudePattern',obj.MagnitudePattern,...
                'PhasePattern',obj.PhasePattern,...
                'MatchArrayNormal',obj.MatchArrayNormal);
            end
        end

        function validElement=verifyParameters(obj)

            sigFreq=obj.SignalFreq;
            freqVector=obj.FrequencyVector;
            try

                customElement=phased.CustomAntennaElement(...
                'FrequencyVector',obj.FrequencyVector,...
                'FrequencyResponse',obj.FrequencyResponse,...
                'AzimuthAngles',obj.AzimuthAngles,...
                'ElevationAngles',obj.ElevationAngles,...
                'MagnitudePattern',obj.MagnitudePattern,...
                'PhasePattern',obj.PhasePattern,...
                'MatchArrayNormal',obj.MatchArrayNormal);


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
            addcr(sw,'% Create a custom antenna element')
            addcr(sw,'Elem = phased.CustomAntennaElement;')
            if~isUIFigure(obj.Parent)
                addcr(sw,['Elem.FrequencyVector = ',obj.FrequencyVectorEdit.String,';'])
                addcr(sw,['Elem.FrequencyResponse = ',obj.FrequencyResponseEdit.String,';'])
                addcr(sw,['Elem.PatternCoordinateSystem = ''',obj.PatternCoordinate,''';']);
                if strcmp(obj.PatternCoordinate,getString(message('phased:apps:arrayapp:azelcoord')))
                    addcr(sw,['Elem.AzimuthAngles = ',obj.AzimuthAngleEdit.String,';'])
                    addcr(sw,['Elem.ElevationAngles = ',obj.ElevationAngleEdit.String,';']);
                else
                    addcr(sw,['Elem.PhiAngles = ',obj.PhiAngleEdit.String,';'])
                    addcr(sw,['Elem.ThetaAngles = ',obj.ThetaAngleEdit.String,';']);
                end
                addcr(sw,['Elem.MagnitudePattern = ',obj.MagnitudePatternEdit.String,';']);
                addcr(sw,['Elem.PhasePattern = ',obj.PhasePatternEdit.String,';'])
            else
                addcr(sw,['Elem.FrequencyVector = ',obj.FrequencyVectorEdit.Value,';'])
                addcr(sw,['Elem.FrequencyResponse = ',obj.FrequencyResponseEdit.Value,';'])
                addcr(sw,['Elem.PatternCoordinateSystem = ''',obj.PatternCoordinate,''';']);
                if strcmp(obj.PatternCoordinate,getString(message('phased:apps:arrayapp:azelcoord')))
                    addcr(sw,['Elem.AzimuthAngles = ',obj.AzimuthAngleEdit.Value,';'])
                    addcr(sw,['Elem.ElevationAngles = ',obj.ElevationAngleEdit.Value,';']);
                else
                    addcr(sw,['Elem.PhiAngles = ',obj.PhiAngleEdit.Value,';'])
                    addcr(sw,['Elem.ThetaAngles = ',obj.ThetaAngleEdit.Value,';']);
                end
                addcr(sw,['Elem.MagnitudePattern = ',obj.MagnitudePatternEdit.Value,';']);
                addcr(sw,['Elem.PhasePattern = ',obj.PhasePatternEdit.Value,';'])
            end
            if obj.MatchArrayNormal
                addcr(sw,'Elem.MatchArrayNormal = true;');
            else
                addcr(sw,'Elem.MatchArrayNormal = false;');
            end
            addcr(sw,'Array.Element = Elem;');
        end

        function genreport(obj,sw)
            addcr(sw,'% Element Type ......................................... Custom Antenna Element')
            addcr(sw,['% Frequency Vector (Hz) ................................ ',mat2str(obj.FrequencyVector)])
            addcr(sw,['% Frequency Response (dB) .............................. ',mat2str(obj.FrequencyResponse)])
            addcr(sw,['% Input Pattern Coordinate System ...................... ',obj.PatternCoordinate])
            if~isUIFigure(obj.Parent)
                if strcmp(obj.PatternCoordinate,getString(message('phased:apps:arrayapp:azelcoord')))
                    addcr(sw,['% Azimuth Angles (deg) ................................. ',obj.AzimuthAngleEdit.String])
                    addcr(sw,['% Elevation Angles (deg) ............................... ',obj.ElevationAngleEdit.String])
                else
                    addcr(sw,['% Phi Angles (deg) ..................................... ',obj.PhiAngleEdit.String])
                    addcr(sw,['% Theta Angles (deg) ................................... ',obj.ThetaAngleEdit.String])
                end
                addcr(sw,['% Magnitude Pattern (dB) ............................... ',obj.MagnitudePatternEdit.String])
                addcr(sw,['% Phase Pattern (dB) ................................... ',obj.PhasePatternEdit.String])
            else
                if strcmp(obj.PatternCoordinate,getString(message('phased:apps:arrayapp:azelcoord')))
                    addcr(sw,['% Azimuth Angles (deg) ................................. ',obj.AzimuthAngleEdit.Value])
                    addcr(sw,['% Elevation Angles (deg) ............................... ',obj.ElevationAngleEdit.Value])
                else
                    addcr(sw,['% Phi Angles (deg) ..................................... ',obj.PhiAngleEdit.Value])
                    addcr(sw,['% Theta Angles (deg) ................................... ',obj.ThetaAngleEdit.Value])
                end
                addcr(sw,['% Magnitude Pattern (dB) ............................... ',obj.MagnitudePatternEdit.Value])
                addcr(sw,['% Phase Pattern (dB) ................................... ',obj.PhasePatternEdit.Value])
            end
            addcr(sw,['% Match Array Normal ................................... ',mat2str(obj.MatchArrayNormal)])
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
                getString(message('phased:apps:arrayapp:CustomAntenna'))]);
            else
                obj.Panel=obj.Parent.createPanel(obj.Parent.Layout,...
                [getString(...
                message('phased:apps:arrayapp:element')),' - ',...
                getString(message('phased:apps:arrayapp:CustomAntenna'))]);
            end

            hspacing=3;
            vspacing=7;

            obj.Layout=obj.Parent.createLayout(obj.Panel,...
            vspacing,hspacing,...
            [0,0,0,0,0,0,0,0,0,0,0,1],[0,1,0]);

            if~isUIFigure(obj.Parent)
                parent=obj.Panel;
            else
                parent=obj.Layout;
            end

            obj.MatchNormalCheck=obj.Parent.createCheckBox(parent,...
            1,getString(message(...
            'phased:apps:arrayapp:matchNormal')),...
            getString(message(...
            'phased:apps:arrayapp:MatchNormalTT')),...
            'MACheck',@(h,e)parameterChanged(obj,e));


            obj.PropSpeedLabel=obj.Parent.createTextLabel(parent,...
            [getString(message(...
            'phased:apps:arrayapp:PropagationSpeed')),' (',...
            getString(message('phased:apps:arrayapp:meter')),'/'...
            ,getString(message('phased:apps:arrayapp:second')),')']);

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


            obj.FrequencyVectorLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:FrequencyVector')),' (',...
            getString(message('phased:apps:arrayapp:Hz')),')']);

            obj.FrequencyVectorEdit=obj.Parent.createEditBox(...
            parent,'[0 1e20]',...
            getString(message(...
            'phased:apps:arrayapp:FrequencyVectorTT')),...
            'freqVectorEdit',@(h,e)parameterChanged(obj,e));


            obj.FrequencyResponseLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:FrequencyResponse')),' (',...
            getString(message('phased:apps:arrayapp:dB')),')']);

            obj.FrequencyResponseEdit=obj.Parent.createEditBox(...
            parent,'[0 0]',...
            getString(message(...
            'phased:apps:arrayapp:FrequencyResponseTT')),...
            'freqRespEdit',@(h,e)parameterChanged(obj,e));

            obj.PatternCoordinateLabel=obj.Parent.createTextLabel(...
            parent,getString(message('phased:apps:arrayapp:coordlabel')));

            coordPopup={getString(message('phased:apps:arrayapp:azelcoord')),...
            getString(message('phased:apps:arrayapp:phithetacoord'))};

            obj.PatternCoordinatePopup=obj.Parent.createDropDown(...
            parent,coordPopup,1,...
            'Select the input pattern Coordinate',...
            'patternCoordPopUp',@(h,e)parameterChanged(obj,e));


            obj.AzimuthAngleLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:AzimuthAngles')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.AzimuthAngleEdit=obj.Parent.createEditBox(...
            parent,'[-180:180]',...
            getString(message(...
            'phased:apps:arrayapp:AzimuthAnglesTT')),...
            'AzAngEdit',@(h,e)parameterChanged(obj,e));


            obj.ElevationAngleLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:ElevationAngles')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.ElevationAngleEdit=obj.Parent.createEditBox(...
            parent,'[-90:90]',...
            getString(message(...
            'phased:apps:arrayapp:ElevationAnglesTT')),...
            'ElAngEdit',@(h,e)parameterChanged(obj,e));


            obj.PhiAngleLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:PhiAngles')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')'],...
            'off');

            obj.PhiAngleEdit=obj.Parent.createEditBox(...
            parent,'[0:360]',...
            getString(message(...
            'phased:apps:arrayapp:PhiAnglesTT')),...
            'PhiAngEdit',@(h,e)parameterChanged(obj,e),'off');


            obj.ThetaAngleLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:ThetaAngles')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')'],...
            'off');

            obj.ThetaAngleEdit=obj.Parent.createEditBox(...
            parent,'[0:180]',...
            getString(message(...
            'phased:apps:arrayapp:ThetaAnglesTT')),...
            'ThetaAngEdit',@(h,e)parameterChanged(obj,e),'off');


            obj.MagnitudePatternLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:MagnitudePattern')),' (',...
            getString(message('phased:apps:arrayapp:dB')),')']);

            obj.MagnitudePatternEdit=obj.Parent.createEditBox(...
            parent,'zeros(181,361)',...
            getString(message(...
            'phased:apps:arrayapp:MagnitudePatternTT')),...
            'MagEdit',@(h,e)parameterChanged(obj,e));


            obj.PhasePatternLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:PhasePattern')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.PhasePatternEdit=obj.Parent.createEditBox(...
            parent,'zeros(181,361)',...
            getString(message(...
            'phased:apps:arrayapp:PhasePatternTT')),...
            'PhaseEdit',@(h,e)parameterChanged(obj,e));
        end

        function layoutUIControls(obj)
            if~isUIFigure(obj.Parent)
                hspacing=3;
                vspacing=7;

                obj.Layout=obj.Parent.createLayout(obj.Panel,...
                vspacing,hspacing,...
                [0,0,0,0,0,0,0,0,0,0,0,1],[0,1,0]);

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
                obj.Parent.addText(obj.Layout,obj.PatternCoordinateLabel,row,1,w1,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.PatternCoordinatePopup,row,2,w2,uiControlsHt)

                switch obj.PatternCoordinatePopup.Value
                case 1
                    obj.AzimuthAngleLabel.Visible='on';
                    obj.AzimuthAngleEdit.Visible='on';
                    obj.ElevationAngleLabel.Visible='on';
                    obj.ElevationAngleEdit.Visible='on';
                    obj.PhiAngleLabel.Visible='off';
                    obj.PhiAngleEdit.Visible='off';
                    obj.ThetaAngleLabel.Visible='off';
                    obj.ThetaAngleEdit.Visible='off';
                    row=row+1;
                    obj.Parent.addText(obj.Layout,obj.AzimuthAngleLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addEdit(obj.Layout,obj.AzimuthAngleEdit,row,2,w2,uiControlsHt)

                    row=row+1;
                    obj.Parent.addText(obj.Layout,obj.ElevationAngleLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addEdit(obj.Layout,obj.ElevationAngleEdit,row,2,w2,uiControlsHt)
                case 2
                    obj.AzimuthAngleLabel.Visible='off';
                    obj.AzimuthAngleEdit.Visible='off';
                    obj.ElevationAngleLabel.Visible='off';
                    obj.ElevationAngleEdit.Visible='off';
                    obj.PhiAngleLabel.Visible='on';
                    obj.PhiAngleEdit.Visible='on';
                    obj.ThetaAngleLabel.Visible='on';
                    obj.ThetaAngleEdit.Visible='on';

                    row=row+1;
                    obj.Parent.addText(obj.Layout,obj.PhiAngleLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addEdit(obj.Layout,obj.PhiAngleEdit,row,2,w2,uiControlsHt)

                    row=row+1;
                    obj.Parent.addText(obj.Layout,obj.ThetaAngleLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addEdit(obj.Layout,obj.ThetaAngleEdit,row,2,w2,uiControlsHt)
                end
                row=row+1;
                obj.Parent.addText(obj.Layout,obj.MagnitudePatternLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.MagnitudePatternEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.PhasePatternLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.PhasePatternEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addCheckBox(obj.Layout,obj.MatchNormalCheck,row,1,w1,uiControlsHt)

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
                obj.PatternCoordinateLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.PatternCoordinatePopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);

                obj.AzimuthAngleLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.AzimuthAngleEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
                obj.ElevationAngleLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',1);
                obj.ElevationAngleEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',2);
                obj.PhiAngleLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',1);
                obj.PhiAngleEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',2);
                obj.ThetaAngleLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',1);
                obj.ThetaAngleEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',2);

                obj.MagnitudePatternLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',8,'Column',1);
                obj.MagnitudePatternEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',8,'Column',2);
                obj.PhasePatternLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',9,'Column',1);
                obj.PhasePatternEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',9,'Column',2);
                obj.MatchNormalCheck.Layout=matlab.ui.layout.GridLayoutOptions('Row',10,'Column',1);
                obj.PropSpeedLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',11,'Column',1);
                obj.PropSpeedEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',11,'Column',2);
                obj.SignalFreqLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',12,'Column',1);
                obj.SignalFreqEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',12,'Column',2);

                obj.AzimuthAngleLabel.Visible='off';
                obj.AzimuthAngleEdit.Visible='off';
                obj.ElevationAngleLabel.Visible='off';
                obj.ElevationAngleEdit.Visible='off';
                obj.PhiAngleLabel.Visible='off';
                obj.PhiAngleEdit.Visible='off';
                obj.ThetaAngleLabel.Visible='off';
                obj.ThetaAngleEdit.Visible='off';
                obj.Layout.RowHeight={'fit','fit','fit','fit','fit','fit','fit','fit','fit','fit','fit','fit'};
                switch obj.PatternCoordinatePopup.Value
                case getString(message('phased:apps:arrayapp:azelcoord'))
                    obj.AzimuthAngleLabel.Visible='on';
                    obj.AzimuthAngleEdit.Visible='on';
                    obj.ElevationAngleLabel.Visible='on';
                    obj.ElevationAngleEdit.Visible='on';

                    obj.Layout.RowHeight(6:7)={0,0};
                case getString(message('phased:apps:arrayapp:phithetacoord'))
                    obj.PhiAngleLabel.Visible='on';
                    obj.PhiAngleEdit.Visible='on';
                    obj.ThetaAngleLabel.Visible='on';
                    obj.ThetaAngleEdit.Visible='on';

                    obj.Layout.RowHeight(4:5)={0,0};
                end
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
            case 'patternCoordPopUp'
                if~isUIFigure(obj.Parent)
                    obj.PatternCoordinate=obj.PatternCoordinatePopup.String{obj.PatternCoordinatePopup.Value};
                    layoutUIControls(obj)
                    if obj.Parent.App.IsSubarray
                        remove(obj.Parent.Layout,3,1)
                        add(obj.Parent.Layout,obj.Parent.ElementDialog.Panel,3,1,...
                        'MinimumWidth',obj.Width,...
                        'Fill','Horizontal',...
                        'MinimumHeight',obj.Height,...
                        'Anchor','North')
                    else
                        remove(obj.Parent.Layout,2,1)
                        add(obj.Parent.Layout,obj.Parent.ElementDialog.Panel,2,1,...
                        'MinimumWidth',obj.Width,...
                        'Fill','Horizontal',...
                        'MinimumHeight',obj.Height,...
                        'Anchor','North')
                    end

                    update(obj.Parent.Layout,'force');
                else
                    obj.PatternCoordinate=obj.PatternCoordinatePopup.Value;
                    layoutUIControls(obj);
                    adjustLayout(obj.Parent.App);
                end
            case 'AzAngEdit'
                try
                    sigdatatypes.validateAngle(obj.AzimuthAngles,...
                    'phased.CustomAntennaElement','AzimuthAngles',...
                    {'vector','>=',-180,'<=',180});
                    obj.ValidAzimuthAngle=obj.AzimuthAngles;
                catch me
                    obj.AzimuthAngles=obj.ValidAzimuthAngle;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'ElAngEdit'
                try
                    sigdatatypes.validateAngle(obj.ElevationAngles,...
                    'phased.CustomAntennaElement','ElevationAngles',...
                    {'vector','>=',-90,'<=',90});
                    obj.ValidElevationAngle=obj.ElevationAngles;
                catch me
                    obj.ElevationAngles=obj.ValidElevationAngle;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'PhiAngEdit'
                try
                    sigdatatypes.validateAngle(obj.PhiAngles,...
                    'phased.CustomAntennaElement','PhiAngles',...
                    {'vector','>=',0,'<=',360});
                    obj.ValidPhiAngle=obj.PhiAngles;
                catch me
                    obj.PhiAngles=obj.ValidPhiAngle;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'ThetaAngEdit'
                try
                    sigdatatypes.validateAngle(obj.ThetaAngles,...
                    'phased.CustomAntennaElement','ThetaAngles',...
                    {'vector','>=',0,'<=',180});
                    obj.ValidThetaAngle=obj.ThetaAngles;
                catch me
                    obj.ThetaAngles=obj.ValidThetaAngle;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'MagEdit'
                try
                    if numel(size(obj.MagnitudePattern))==3
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles),numel(obj.FrequencyVector)];
                    else
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles)];
                    end
                    validateattributes(obj.MagnitudePattern,{'numeric'},...
                    {'nonempty','real','size',pattern_size},...
                    '','MagnitudePattern');
                    obj.ValidMagnitudePattern=obj.MagnitudePattern;
                catch me
                    obj.MagnitudePattern=obj.ValidMagnitudePattern;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'PhaseEdit'
                try
                    if numel(size(obj.PhasePattern))==3
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles),numel(obj.FrequencyVector)];
                    else
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles)];
                    end
                    validateattributes(obj.PhasePattern,{'numeric'},...
                    {'nonempty','real','size',pattern_size},...
                    '','PhasePattern');
                    obj.ValidPhasePattern=obj.PhasePattern;
                catch me
                    obj.PhasePattern=obj.ValidPhasePattern;
                    throwError(obj.Parent.App,me);
                    return;
                end
            end


            enableAnalyzeButton(obj.Parent.App);
        end
    end
end
