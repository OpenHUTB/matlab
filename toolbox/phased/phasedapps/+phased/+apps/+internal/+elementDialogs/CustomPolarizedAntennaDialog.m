classdef(Hidden,Sealed)CustomPolarizedAntennaDialog<handle





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

HorizontalMagnitudePatternLabel
HorizontalMagnitudePatternEdit

VerticalMagnitudePatternLabel
VerticalMagnitudePatternEdit

HorizontalPhasePatternLabel
HorizontalPhasePatternEdit

VerticalPhasePatternLabel
VerticalPhasePatternEdit

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
HorizontalMagnitudePattern
HorizontalPhasePattern
VerticalMagnitudePattern
VerticalPhasePattern
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
        ValidHorizontalMagnitudePattern=zeros(181,361)
        ValidHorizontalPhasePattern=zeros(181,361)
        ValidVerticalMagnitudePattern=zeros(181,361)
        ValidVerticalPhasePattern=zeros(181,361)
        ValidPatternCoordinate=getString(message('phased:apps:arrayapp:azelcoord'))
        ValidPhiAngle=0:360
        ValidThetaAngle=0:180
    end

    methods
        function obj=CustomPolarizedAntennaDialog(parent)

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


        function val=get.HorizontalMagnitudePattern(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.HorizontalMagnitudePatternEdit.String);
            else
                val=evalin('base',obj.HorizontalMagnitudePatternEdit.Value);
            end
        end

        function set.HorizontalMagnitudePattern(obj,val)
            if(numel(size(val))==3)
                value=phased.apps.internal.SensorArrayApp.ndmat2str(val);
            else
                value=mat2str(val);
            end
            if~isUIFigure(obj.Parent)
                obj.HorizontalMagnitudePatternEdit.String=value;
            else
                obj.HorizontalMagnitudePatternEdit.Value=value;
            end
        end


        function val=get.HorizontalPhasePattern(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.HorizontalPhasePatternEdit.String);
            else
                val=evalin('base',obj.HorizontalPhasePatternEdit.Value);
            end
        end

        function set.HorizontalPhasePattern(obj,val)
            if(numel(size(val))==3)
                value=phased.apps.internal.SensorArrayApp.ndmat2str(val);
            else
                value=mat2str(val);
            end
            if~isUIFigure(obj.Parent)
                obj.HorizontalPhasePatternEdit.String=value;
            else
                obj.HorizontalPhasePatternEdit.Value=value;
            end
        end


        function val=get.VerticalMagnitudePattern(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.VerticalMagnitudePatternEdit.String);
            else
                val=evalin('base',obj.VerticalMagnitudePatternEdit.Value);
            end
        end

        function set.VerticalMagnitudePattern(obj,val)
            if(numel(size(val))==3)
                value=phased.apps.internal.SensorArrayApp.ndmat2str(val);
            else
                value=mat2str(val);
            end
            if~isUIFigure(obj.Parent)
                obj.VerticalMagnitudePatternEdit.String=value;
            else
                obj.VerticalMagnitudePatternEdit.Value=value;
            end
        end


        function val=get.VerticalPhasePattern(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.VerticalPhasePatternEdit.String);
            else
                val=evalin('base',obj.VerticalPhasePatternEdit.Value);
            end
        end

        function set.VerticalPhasePattern(obj,val)
            if(numel(size(val))==3)
                value=phased.apps.internal.SensorArrayApp.ndmat2str(val);
            else
                value=mat2str(val);
            end
            if~isUIFigure(obj.Parent)
                obj.VerticalPhasePatternEdit.String=value;
            else
                obj.VerticalPhasePatternEdit.Value=value;
            end
        end



        function updateElementObject(obj)

            updatePropSpeedandFrequency(obj.Parent.App);


            if strcmp(obj.PatternCoordinate,getString(message('phased:apps:arrayapp:azelcoord')))
                obj.Parent.App.CurrentElement=phased.CustomAntennaElement(...
                'FrequencyVector',obj.FrequencyVector,...
                'FrequencyResponse',obj.FrequencyResponse,...
                'PatternCoordinateSystem','az-el',...
                'AzimuthAngles',obj.AzimuthAngles,...
                'ElevationAngles',obj.ElevationAngles,...
                'SpecifyPolarizationPattern',true,...
                'HorizontalMagnitudePattern',obj.HorizontalMagnitudePattern,...
                'HorizontalPhasePattern',obj.HorizontalPhasePattern,...
                'VerticalMagnitudePattern',obj.VerticalMagnitudePattern,...
                'VerticalPhasePattern',obj.VerticalPhasePattern,...
                'MatchArrayNormal',obj.MatchArrayNormal);
            else
                obj.Parent.App.CurrentElement=phased.CustomAntennaElement(...
                'FrequencyVector',obj.FrequencyVector,...
                'FrequencyResponse',obj.FrequencyResponse,...
                'PatternCoordinateSystem','phi-theta',...
                'PhiAngles',obj.PhiAngles,...
                'ThetaAngles',obj.ThetaAngles,...
                'SpecifyPolarizationPattern',true,...
                'HorizontalMagnitudePattern',obj.HorizontalMagnitudePattern,...
                'HorizontalPhasePattern',obj.HorizontalPhasePattern,...
                'VerticalMagnitudePattern',obj.VerticalMagnitudePattern,...
                'VerticalPhasePattern',obj.VerticalPhasePattern,...
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
                'SpecifyPolarizationPattern',true,...
                'AzimuthAngles',obj.AzimuthAngles,...
                'ElevationAngles',obj.ElevationAngles,...
                'HorizontalMagnitudePattern',obj.HorizontalMagnitudePattern,...
                'HorizontalPhasePattern',obj.HorizontalPhasePattern,...
                'VerticalMagnitudePattern',obj.VerticalMagnitudePattern,...
                'VerticalPhasePattern',obj.VerticalPhasePattern,...
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
                addcr(sw,'Elem.SpecifyPolarizationPattern = true ;');
                if strcmp(obj.PatternCoordinate,getString(message('phased:apps:arrayapp:azelcoord')))
                    addcr(sw,['Elem.AzimuthAngles = ',obj.AzimuthAngleEdit.String,';'])
                    addcr(sw,['Elem.ElevationAngles = ',obj.ElevationAngleEdit.String,';']);
                else
                    addcr(sw,['Elem.PhiAngles = ',obj.PhiAngleEdit.String,';'])
                    addcr(sw,['Elem.ThetaAngles = ',obj.ThetaAngleEdit.String,';']);
                end
                addcr(sw,['Elem.HorizontalMagnitudePattern = ',obj.HorizontalMagnitudePatternEdit.String,';']);
                addcr(sw,['Elem.HorizontalPhasePattern = ',obj.HorizontalPhasePatternEdit.String,';'])
                addcr(sw,['Elem.VerticalMagnitudePattern = ',obj.VerticalMagnitudePatternEdit.String,';']);
                addcr(sw,['Elem.VerticalPhasePattern = ',obj.VerticalPhasePatternEdit.String,';'])
            else
                addcr(sw,['Elem.FrequencyVector = ',obj.FrequencyVectorEdit.Value,';'])
                addcr(sw,['Elem.FrequencyResponse = ',obj.FrequencyResponseEdit.Value,';'])
                addcr(sw,['Elem.PatternCoordinateSystem = ''',obj.PatternCoordinate,''';']);
                addcr(sw,'Elem.SpecifyPolarizationPattern = true ;');
                if strcmp(obj.PatternCoordinate,getString(message('phased:apps:arrayapp:azelcoord')))
                    addcr(sw,['Elem.AzimuthAngles = ',obj.AzimuthAngleEdit.Value,';'])
                    addcr(sw,['Elem.ElevationAngles = ',obj.ElevationAngleEdit.Value,';']);
                else
                    addcr(sw,['Elem.PhiAngles = ',obj.PhiAngleEdit.Value,';'])
                    addcr(sw,['Elem.ThetaAngles = ',obj.ThetaAngleEdit.Value,';']);
                end
                addcr(sw,['Elem.HorizontalMagnitudePattern = ',obj.HorizontalMagnitudePatternEdit.Value,';']);
                addcr(sw,['Elem.HorizontalPhasePattern = ',obj.HorizontalPhasePatternEdit.Value,';'])
                addcr(sw,['Elem.VerticalMagnitudePattern = ',obj.VerticalMagnitudePatternEdit.Value,';']);
                addcr(sw,['Elem.VerticalPhasePattern = ',obj.VerticalPhasePatternEdit.Value,';'])
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
                addcr(sw,['% Horizontal Magnitude Pattern (dB) .................... ',obj.HorizontalMagnitudePatternEdit.String])
                addcr(sw,['% Horizontal Phase Pattern (dB) ........................ ',obj.HorizontalPhasePatternEdit.String])
                addcr(sw,['% Vertical Magnitude Pattern (dB) ...................... ',obj.VerticalMagnitudePatternEdit.String])
                addcr(sw,['% Vertical Phase Pattern (dB) .......................... ',obj.VerticalPhasePatternEdit.String])
            else
                if strcmp(obj.PatternCoordinate,getString(message('phased:apps:arrayapp:azelcoord')))
                    addcr(sw,['% Azimuth Angles (deg) ................................. ',obj.AzimuthAngleEdit.Value])
                    addcr(sw,['% Elevation Angles (deg) ............................... ',obj.ElevationAngleEdit.Value])
                else
                    addcr(sw,['% Phi Angles (deg) ..................................... ',obj.PhiAngleEdit.Value])
                    addcr(sw,['% Theta Angles (deg) ................................... ',obj.ThetaAngleEdit.Value])
                end
                addcr(sw,['% Horizontal Magnitude Pattern (dB) .................... ',obj.HorizontalMagnitudePatternEdit.Value])
                addcr(sw,['% Horizontal Phase Pattern (dB) ........................ ',obj.HorizontalPhasePatternEdit.Value])
                addcr(sw,['% Vertical Magnitude Pattern (dB) ...................... ',obj.VerticalMagnitudePatternEdit.Value])
                addcr(sw,['% Vertical Phase Pattern (dB) .......................... ',obj.VerticalPhasePatternEdit.Value])
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
            [0,0,0,0,0,0,0,0,0,0,0,0,0,1],[0,1,0]);

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


            obj.HorizontalMagnitudePatternLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:HorizontalMagnitudePattern')),' (',...
            getString(message('phased:apps:arrayapp:dB')),')']);

            obj.HorizontalMagnitudePatternEdit=obj.Parent.createEditBox(...
            parent,'zeros(181,361)',...
            getString(message(...
            'phased:apps:arrayapp:HorizontalMagnitudePatternTT')),...
            'HorizontalMagEdit',@(h,e)parameterChanged(obj,e));


            obj.HorizontalPhasePatternLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:HorizontalPhasePattern')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.HorizontalPhasePatternEdit=obj.Parent.createEditBox(...
            parent,'zeros(181,361)',...
            getString(message(...
            'phased:apps:arrayapp:HorizontalPhasePatternTT')),...
            'HorizontalPhaseEdit',@(h,e)parameterChanged(obj,e));


            obj.VerticalMagnitudePatternLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:VerticalMagnitudePattern')),' (',...
            getString(message('phased:apps:arrayapp:dB')),')']);

            obj.VerticalMagnitudePatternEdit=obj.Parent.createEditBox(...
            parent,'zeros(181,361)',...
            getString(message(...
            'phased:apps:arrayapp:VerticalMagnitudePatternTT')),...
            'VerticalMagEdit',@(h,e)parameterChanged(obj,e));


            obj.VerticalPhasePatternLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:VerticalPhasePattern')),' (',...
            getString(message('phased:apps:arrayapp:degrees')),')']);

            obj.VerticalPhasePatternEdit=obj.Parent.createEditBox(...
            parent,'zeros(181,361)',...
            getString(message(...
            'phased:apps:arrayapp:VerticalPhasePatternTT')),...
            'VerticalPhaseEdit',@(h,e)parameterChanged(obj,e));
        end

        function layoutUIControls(obj)
            if~isUIFigure(obj.Parent)
                hspacing=3;
                vspacing=7;

                obj.Layout=obj.Parent.createLayout(obj.Panel,...
                vspacing,hspacing,...
                [0,0,0,0,0,0,0,0,0,0,0,0,0,1],[0,1,0]);

                w1=obj.Parent.Width1+35;
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
                obj.Parent.addText(obj.Layout,obj.HorizontalMagnitudePatternLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.HorizontalMagnitudePatternEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.HorizontalPhasePatternLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.HorizontalPhasePatternEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.VerticalMagnitudePatternLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.VerticalMagnitudePatternEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.VerticalPhasePatternLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.VerticalPhasePatternEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addCheckBox(obj.Layout,obj.MatchNormalCheck,row,1,w1,uiControlsHt)


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.PropSpeedLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.PropSpeedEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.SignalFreqLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.SignalFreqEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.FrequencyVectorLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.FrequencyVectorEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.FrequencyResponseLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.FrequencyResponseEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
                obj.PatternCoordinateLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',1);
                obj.PatternCoordinatePopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',2);

                obj.AzimuthAngleLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',1);
                obj.AzimuthAngleEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',2);
                obj.ElevationAngleLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',1);
                obj.ElevationAngleEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',2);
                obj.PhiAngleLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',8,'Column',1);
                obj.PhiAngleEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',8,'Column',2);
                obj.ThetaAngleLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',9,'Column',1);
                obj.ThetaAngleEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',9,'Column',2);

                obj.HorizontalMagnitudePatternLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',10,'Column',1);
                obj.HorizontalMagnitudePatternEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',10,'Column',2);
                obj.HorizontalPhasePatternLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',11,'Column',1);
                obj.HorizontalPhasePatternEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',11,'Column',2);
                obj.VerticalMagnitudePatternLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',12,'Column',1);
                obj.VerticalMagnitudePatternEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',12,'Column',2);
                obj.VerticalPhasePatternLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',13,'Column',1);
                obj.VerticalPhasePatternEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',14,'Column',2);
                obj.MatchNormalCheck.Layout=matlab.ui.layout.GridLayoutOptions('Row',14,'Column',1);

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

                    obj.Layout.RowHeight(8:9)={0,0};
                case getString(message('phased:apps:arrayapp:phithetacoord'))
                    obj.PhiAngleLabel.Visible='on';
                    obj.PhiAngleEdit.Visible='on';
                    obj.ThetaAngleLabel.Visible='on';
                    obj.ThetaAngleEdit.Visible='on';

                    obj.Layout.RowHeight(6:7)={0,0};
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
            case 'HorizontalMagEdit'
                try
                    if numel(size(obj.HorizontalMagnitudePattern))==3
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles),numel(obj.FrequencyVector)];
                    else
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles)];
                    end
                    validateattributes(obj.HorizontalMagnitudePattern,{'numeric'},...
                    {'nonempty','real','size',pattern_size},...
                    '','MagnitudePattern');
                    obj.ValidHorizontalMagnitudePattern=obj.HorizontalMagnitudePattern;
                catch me
                    obj.HorizontalMagnitudePattern=obj.ValidHorizontalMagnitudePattern;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'HorizontalPhaseEdit'
                try
                    if numel(size(obj.HorizontalPhasePattern))==3
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles),numel(obj.FrequencyVector)];
                    else
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles)];
                    end
                    validateattributes(obj.HorizontalPhasePattern,{'numeric'},...
                    {'nonempty','real','size',pattern_size},...
                    '','PhasePattern');
                    obj.ValidHorizontalPhasePattern=obj.HorizontalPhasePattern;
                catch me
                    obj.HorizontalPhasePattern=obj.ValidHorizontalPhasePattern;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'VerticalMagEdit'
                try
                    if numel(size(obj.VerticalMagnitudePattern))==3
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles),numel(obj.FrequencyVector)];
                    else
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles)];
                    end
                    validateattributes(obj.VerticalMagnitudePattern,{'numeric'},...
                    {'nonempty','real','size',pattern_size},...
                    '','MagnitudePattern');
                    obj.ValidVerticalMagnitudePattern=obj.VerticalMagnitudePattern;
                catch me
                    obj.VerticalMagnitudePattern=obj.ValidVerticalMagnitudePattern;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'VerticalPhaseEdit'
                try
                    if numel(size(obj.VerticalPhasePattern))==3
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles),numel(obj.FrequencyVector)];
                    else
                        pattern_size=[numel(obj.ElevationAngles)...
                        ,numel(obj.AzimuthAngles)];
                    end
                    validateattributes(obj.VerticalPhasePattern,{'numeric'},...
                    {'nonempty','real','size',pattern_size},...
                    '','PhasePattern');
                    obj.ValidVerticalPhasePattern=obj.VerticalPhasePattern;
                catch me
                    obj.VerticalPhasePattern=obj.ValidVerticalPhasePattern;
                    throwError(obj.Parent.App,me);
                    return;
                end
            end


            enableAnalyzeButton(obj.Parent.App);
        end
    end
end
