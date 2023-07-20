

classdef ErrorInfo<handle

    methods(Access=public)
        function obj=ErrorInfo(timeStamp,blockUri,id,errorMessage)
            obj.timeStamp=timeStamp;
            obj.blockUri=blockUri;
            obj.propertyId=id;
            obj.errMsg=errorMessage;
        end
    end

    properties(Access=public)
        timeStamp=[];
        blockUri=[];
        propertyId=[];
        errMsg=[];
    end
end
