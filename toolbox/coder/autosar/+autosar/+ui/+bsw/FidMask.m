




classdef FidMask<handle
    properties(SetAccess=private)
        FID;
        Mask;
        EventId;
    end

    methods(Static)

        function maskValue=stringToVal(str)
            if iscell(str)
                maskValue=cellfun(@(x)autosar.ui.bsw.FidMask.stringToVal(x),str,'UniformOutput',false);
                return;
            end
            switch str
            case 'NONE'
                maskValue=0;
            case 'LAST_FAILED'
                maskValue=1;
            case 'NOT_TESTED'
                maskValue=2;
            case 'TESTED'
                maskValue=3;
            case 'TESTED_AND_FAILED'
                maskValue=4;
            otherwise
                maskValue=-1;
            end
        end


        function maskString=valToString(val)
            if numel(val)>1
                maskString=arrayfun(@(x)autosar.ui.bsw.FidMask.valToString(x),val,'UniformOutput',false);
                return;
            end
            switch val
            case 0
                maskString='NONE';
            case 1
                maskString='LAST_FAILED';
            case 2
                maskString='NOT_TESTED';
            case 3
                maskString='TESTED';
            case 4
                maskString='TESTED_AND_FAILED';
            otherwise
                maskString='NONE';
            end
        end
    end


    methods
        function obj=FidMask(fid)
            obj.FID=fid;
        end

        function setFID(obj,fid)
            obj.FID=fid;
        end

        function setEventId(obj,eventId)
            obj.EventId=eventId;
        end

        function setMask(obj,mask)
            obj.Mask=mask;
        end
    end
end


