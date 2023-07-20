classdef CauseRationale<handle




    properties
causeException
rationaleID
    end

    methods
        function obj=CauseRationale(exceptionOccurred,messageID)


            obj.causeException=exceptionOccurred;
            obj.rationaleID=messageID;
        end

        function rationaleDetails=getRationale(obj)


            rationaleDetails=fxptui.message(obj.rationaleID);
        end
    end
end

