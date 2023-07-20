


classdef Signal<matlab.mixin.Copyable

    properties
        SignalName='Temp';
        Description='';
        Direction='out';
        BitWidth=1;
        FPGAPin='';
        IOStandard='';
    end
    properties(Constant)
        DirectionEnum={'in','out','inout'};
    end
    methods(Static,Access=private)
        function valid=isValidVHDLName(value)
            identifier='[a-zA-Z][a-zA-Z0-9_]*';
            tmp=regexp(value,identifier,'match','once');
            valid=strcmp(tmp,value);
        end
    end
    methods
        function pins=getPinsInFilFormat(obj)
            Pin=getAdjustedPin(obj);
            if obj.BitWidth==1
                pins=Pin;
            else
                loc=textscan(Pin,'%s','Delimiter',',');
                pins=loc{1}';
            end
        end
        function pins=getPinsInTurnkeyFormat(obj)
            Pin=getAdjustedPin(obj);
            loc=textscan(Pin,'%s','Delimiter',',');
            pins=loc{1}';
        end
        function obj=Signal(Name)
            obj.SignalName=Name;
        end
        function set.SignalName(obj,Name)
            Name=strtrim(Name);

            obj.SignalName=Name;
        end

        function validate(obj)
            if~obj.isValidVHDLName(obj.SignalName)
                error(message('EDALink:boardmanager:SignalInvalidName',obj.SignalName));
            end

            if~any(strcmp(obj.Direction,obj.DirectionEnum))
                error(message('EDALink:boardmanager:SignalInvalidDirection',obj.DirectionEnum{:}));
            end

            if~isnumeric(obj.BitWidth)||obj.BitWidth<=0
                error(message('EDALink:boardmanager:SignalInvalidBitWidth',obj.SignalName));
            end

            if isempty(obj.FPGAPin)
                error(message('EDALink:boardmanager:SignalPinEmpty',obj.SignalName));
            end

            if any(double(obj.FPGAPin)>127)
                error(message('EDALink:boardmanagergui:OnlyASCIIChars',[obj.SignalName,' FPGA pin']))
            end

            loc=textscan(obj.FPGAPin,'%s','Delimiter',',');
            if numel(loc{1})~=obj.BitWidth
                error(message('EDALink:boardmanager:SignalInvalidPinBits',obj.SignalName));
            end

            if any(cellfun(@(x)isempty(x),loc{1}))
                error(message('EDALink:boardmanager:SignalNotAllPinAssigned',obj.SignalName));
            end
        end

        function r=getAdjustedPin(obj)
            r=regexprep(obj.FPGAPin,'pin_','','ignorecase');
        end

    end

end


