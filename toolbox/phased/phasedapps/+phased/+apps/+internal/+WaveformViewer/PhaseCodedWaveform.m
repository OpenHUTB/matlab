classdef PhaseCodedWaveform<phased.apps.internal.WaveformViewer.WaveformElements



    properties(SetObservable)
Code
NumChips
ChipWidth
    end

    properties(Access=private,Constant)
        DefaultCode=getString(message('phased:apps:waveformapp:Barker'));
        DefaultNumChips='4';
        DefaultChipWidth=1e-6;
        DefaultSeqIndex=1;
    end
    properties(Hidden,Access=public)
SequenceIndex
    end

    methods(Access=protected,Hidden)
        function p=makeInputParser(self)
            p=makeInputParser@phased.apps.internal.WaveformViewer.WaveformElements(self);
            addParameter(p,'Code',self.DefaultCode);
            addParameter(p,'NumChips',self.DefaultNumChips);
            addParameter(p,'ChipWidth',self.DefaultChipWidth);
            addParameter(p,'SequenceIndex',self.DefaultSeqIndex);
        end

        function setParsedProperties(self,p)
            setParsedProperties@phased.apps.internal.WaveformViewer.WaveformElements(self,p);
            self.Code=p.Results.Code;
            self.NumChips=p.Results.NumChips;
            self.ChipWidth=p.Results.ChipWidth;
            self.SequenceIndex=p.Results.SequenceIndex;
        end
    end

    methods
        function self=PhaseCodedWaveform(varargin)
            narginchk(0,20)
            p=makeInputParser(self);
            parse(p,varargin{:});
            setParsedProperties(self,p);
        end

        function set.Code(self,value)
            value=validatestring(value,{getString(message('phased:apps:waveformapp:Barker')),getString(message('phased:apps:waveformapp:Frank')),getString(message('phased:apps:waveformapp:P1')),getString(message('phased:apps:waveformapp:P2')),getString(message('phased:apps:waveformapp:P3')),getString(message('phased:apps:waveformapp:P4')),getString(message('phased:apps:waveformapp:Px')),getString(message('phased:apps:waveformapp:ZadoffChu'))});
            self.Code=value;
        end
        function set.SequenceIndex(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','integer','nonsparse'},...
            '',getString(message('phased:apps:waveformapp:errorSequenceIndex','Sequence Index')))
            self.SequenceIndex=value;
        end
        function set.NumChips(self,value)
            switch self.Code %#ok<MCSUP>
            case getString(message('phased:apps:waveformapp:Barker'))
                validatestring(value,{'2','3','4','5','7','11','13'});
            case getString(message('phased:apps:waveformapp:Frank'))
                value=str2double(value);
                validateattributes(value,{'single','double'},...
                {'nonempty','scalar','real','finite','positive','integer','nonsparse'},...
                '',getString(message('phased:apps:waveformapp:errorNumberChips','Number of Chips')))
                value=num2str(value);
            case getString(message('phased:apps:waveformapp:P1'))
                value=str2double(value);
                validateattributes(value,{'single','double'},...
                {'nonempty','scalar','real','finite','positive','integer','nonsparse'},...
                '',getString(message('phased:apps:waveformapp:errorNumberChips','Number of Chips')))
                value=num2str(value);
            case getString(message('phased:apps:waveformapp:P2'))
                value=str2double(value);
                validateattributes(value,{'single','double'},...
                {'nonempty','scalar','real','finite','positive','integer','nonsparse'},...
                '',getString(message('phased:apps:waveformapp:errorNumberChips','Number of Chips')))
                value=num2str(value);
            case getString(message('phased:apps:waveformapp:P3'))
                value=str2double(value);
                validateattributes(value,{'single','double'},...
                {'nonempty','scalar','real','finite','positive','integer','nonsparse'},...
                '',getString(message('phased:apps:waveformapp:errorNumberChips','Number of Chips')))
                value=num2str(value);
            case getString(message('phased:apps:waveformapp:P4'))
                value=str2double(value);
                validateattributes(value,{'single','double'},...
                {'nonempty','scalar','real','finite','positive','integer','nonsparse'},...
                '',getString(message('phased:apps:waveformapp:errorNumberChips','Number of Chips')))
                value=num2str(value);
            case getString(message('phased:apps:waveformapp:Px'))
                value=str2double(value);
                validateattributes(value,{'single','double'},...
                {'nonempty','scalar','real','finite','positive','integer','nonsparse'},...
                '',getString(message('phased:apps:waveformapp:errorNumberChips','Number of Chips')))
                value=num2str(value);
            case getString(message('phased:apps:waveformapp:ZadoffChu'))
                value=str2double(value);
                validateattributes(value,{'single','double'},...
                {'nonempty','scalar','real','finite','positive','integer','nonsparse'},...
                '',getString(message('phased:apps:waveformapp:errorNumberChips','Number of Chips')))
                value=num2str(value);
            end
            self.NumChips=value;
        end

        function set.ChipWidth(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},...
            '',getString(message('phased:apps:waveformapp:errorChipWidth','Chip Width')))
            self.ChipWidth=value;
        end

        function waveformObject=getWaveformObject(self)


            if~strcmp(self.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
                waveformObject=phased.PhaseCodedWaveform(...
                'SampleRate',self.SampleRate,...
                'PRF',self.PRF,...
                'NumPulses',self.NumPulses,...
                'FrequencyOffset',self.FrequencyOffset,...
                'Code',self.Code,...
                'ChipWidth',self.ChipWidth,...
                'NumChips',str2double(self.NumChips));
            else
                waveformObject=phased.PhaseCodedWaveform(...
                'SampleRate',self.SampleRate,...
                'PRF',self.PRF,...
                'NumPulses',self.NumPulses,...
                'FrequencyOffset',self.FrequencyOffset,...
                'Code',self.Code,...
                'ChipWidth',self.ChipWidth,...
                'NumChips',str2double(self.NumChips),...
                'SequenceIndex',self.SequenceIndex);
            end
        end
    end
    methods(Access=protected)
        function op=objectProperties(self)
            op=objectProperties@phased.apps.internal.WaveformViewer.WaveformElements(self);
            op{end+1,1}='Chipwidth';
            op{end,2}=sprintf('%.15g',self.ChipWidth);
            op{end+1,1}='Code';
            op{end,2}=sprintf('%s',self.Code);
            op{end+1,1}='NumChips';
            op{end,2}=sprintf('%s',self.NumChips);
            if strcmp(self.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
                op{end+1,1}='SequenceIndex';
                op{end,2}=sprintf('%.15g',self.SequenceIndex);
            end
        end
    end

    properties(Constant,Access=protected)
        DefaultName=getString(message('phased:apps:waveformapp:PhaseCoded'))
    end
end