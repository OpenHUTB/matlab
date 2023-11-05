classdef ClockInterface<eda.internal.boardmanager.PredefinedInterface

    properties(Constant)
        Name='Clock';
        ClockTypeEnum={'Single-Ended','Differential'};
    end

    methods
        function obj=ClockInterface
            obj=obj@eda.internal.boardmanager.PredefinedInterface;
        end
        function defineInterface(obj)
            obj.addSignalDefinition('Clock','Clock','in',1);
            obj.addSignalDefinition('Clock_P','Clock_P','in',1);
            obj.addSignalDefinition('Clock_N','Clock_N','in',1);
            obj.addParameterDefinition('Frequency','100');
            obj.addParameterDefinition('ClockType','Single-Ended');
        end
    end

    methods

        function r=getSignalNames(obj)
            switch obj.getParam('ClockType')
            case 'Single-Ended'
                r={'Clock'};
            otherwise
                r={'Clock_P','Clock_N'};
            end
        end
        function r=getClkPin(obj)
            switch obj.getParam('ClockType')
            case 'Single-Ended'
                signal=obj.getSignal('Clock');
                r=signal.getPinsInFilFormat;
            otherwise
                signalp=obj.getSignal('Clock_P');
                signaln=obj.getSignal('Clock_N');
                r={signalp.getPinsInFilFormat,...
                signaln.getPinsInFilFormat};
            end
        end

        function setFrequency(obj,freq)
            tmp=num2str(freq);
            obj.setParam('Frequency',tmp);
        end

        function r=getFrequency(obj)
            r=str2double(obj.getParam('Frequency'));
        end

        function r=isDiffClock(obj)
            r=strcmpi(obj.getParam('ClockType'),'Differential');
        end

        function validateFrequency(obj)
            frequency=str2double(obj.getParam('Frequency'));

            if isnan(frequency)
                error(message('EDALink:boardmanager:ClockInvalidFrequency'));
            elseif frequency>300||frequency<5
                error(message('EDALink:boardmanager:ClockFrequencyOutRange',frequency));
            end
        end

        function validate(obj)
            obj.validateFrequency;

            switch obj.getParam('ClockType')
            case 'Single-Ended'
                signal=getSignal(obj,'Clock');
                signal.validate;
            case 'Differential'
                signal=getSignal(obj,'Clock_P');
                signal.validate;
                signal=getSignal(obj,'Clock_N');
                signal.validate;
            otherwise
                error(message('EDALink:boardmanager:ClockInvalidType'));
            end

        end

        function validateGigaEthFreq(obj)
            freqStr=obj.getParam('Frequency');
            frequency=str2double(freqStr);
            [n,d]=rat(125/frequency);
            isvalid=true;

            if mod(n,1)~=0||mod(d,1)~=0
                isvalid=false;
            elseif n<1||n>32
                isvalid=false;
            elseif d<1||d>32
                isvalid=false;
            end
            if~isvalid
                error(message('EDALink:boardmanager:InvalidGigaEthClockFreq',freqStr,n,d));
            end
        end

    end
end



