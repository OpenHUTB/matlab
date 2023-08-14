



classdef SimscapeCov<handle
    properties
covData
    end
    methods
        function this=SimscapeCov()
        end
        init(this)
        start(this)
        term(this)
        function setInitLog(this,logData)

        end
        function setEvalLog(this,logData)

        end
        processPLogData(logData)
    end
    methods(Static)
        function rLogData=handlePrototypeLogData(logData)
            persistent pLogData;
            if nargin==1
                pLogData=logData;
            end
            rLogData=pLogData;
        end
        function rPrototypeId=handlePrototypeId(val)
            persistent PrototypeId;
            if nargin==1
                PrototypeId=val;
            end
            rPrototypeId=PrototypeId;
        end

    end
end














