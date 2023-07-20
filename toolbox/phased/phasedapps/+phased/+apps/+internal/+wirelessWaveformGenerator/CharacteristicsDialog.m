classdef CharacteristicsDialog < wirelessWaveformGenerator.Dialog
   
    %% Waveform Characteristics Summary Panel
    % Copyright 2022 The MathWorks, Inc.

    properties (Dependent)
        RangeResolution
        DopplerResolution
        MinUnambiguousRange
        MaxUnambiguousRange
        MaxDoppler
        TimeBWProduct
        DutyCycle
    end

    properties (Hidden)
        TitleString = getString(message('phased:apps:wirelesswavegenapp:WaveformCharacteristicsTitle'))

        RangeResolutionType = 'text'
        RangeResolutionLabel
        RangeResolutionGUI

        DopplerResolutionType = 'text'
        DopplerResolutionLabel
        DopplerResolutionGUI

        MinUnambiguousRangeType = 'text'
        MinUnambiguousRangeLabel
        MinUnambiguousRangeGUI

        MaxUnambiguousRangeType = 'text'
        MaxUnambiguousRangeLabel
        MaxUnambiguousRangeGUI

        MaxDopplerType = 'text'
        MaxDopplerLabel
        MaxDopplerGUI

        TimeBWProductType = 'text'
        TimeBWProductLabel
        TimeBWProductGUI

        DutyCycleType = 'text'
        DutyCycleLabel
        DutyCycleGUI

        configFcn = @struct
        configGenFcn = '' % no MATLAB code generation for info dialogs
        configGenVar = ''
    end

    methods
        function obj = CharacteristicsDialog(parent)
            obj@wirelessWaveformGenerator.Dialog(parent); % call base constructor

            setupDialog(obj); % layout controls
            obj.MinUnambiguousRangeGUI.Parent.ColumnWidth{1} = 160;
        end


        function restoreDefaults(obj)
            obj.RangeResolution     = '';
            obj.DopplerResolution   = '';
            obj.MinUnambiguousRange = '';
            obj.MaxUnambiguousRange = '';
            obj.MaxDoppler          = '';
            obj.TimeBWProduct       = '';
            obj.DutyCycle           = '';
        end

        function n = get.RangeResolution(obj)
            n = getTextNumVal(obj, 'RangeResolution');
        end
        function set.RangeResolution(obj, val)
            setTextVal(obj, 'RangeResolution', val)
        end

        function n = get.DopplerResolution(obj)
            n = getTextVal(obj, 'DopplerResolution');
        end
        function set.DopplerResolution(obj, val)
            setTextVal(obj, 'DopplerResolution', val)
        end

        function n = get.MinUnambiguousRange(obj)
            n = getTextNumVal(obj, 'MinUnambiguousRange');
        end
        function set.MinUnambiguousRange(obj, val)
            setTextVal(obj, 'MinUnambiguousRange', val)
        end

        function n = get.MaxUnambiguousRange(obj)
            n = getTextNumVal(obj, 'MaxUnambiguousRange');
        end
        function set.MaxUnambiguousRange(obj, val)
            setTextVal(obj,'MaxUnambiguousRange', val)
        end

        function n = get.MaxDoppler(obj)
            n = getTextNumVal(obj, 'MaxDoppler');
        end
        function set.MaxDoppler(obj, val)
            setTextVal(obj, 'MaxDoppler', val)
        end

        function n = get.TimeBWProduct(obj)
            n = getTextNumVal(obj, 'TimeBWProduct');
        end
        function set.TimeBWProduct(obj, val)
            setTextVal(obj,'TimeBWProduct', val)
        end

        function n = get.DutyCycle(obj)
            n = getTextNumVal(obj,'DutyCycle');
        end
        function set.DutyCycle(obj, val)
            setTextVal(obj,'DutyCycle', val)
        end

        function str = getCatalogPrefix(~)
            str = 'phased:apps:wirelesswavegenapp:';
        end
    end
end