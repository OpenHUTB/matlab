classdef RmiTmEvent<event.EventData




    properties
testFile
testId
    end

    methods
        function data=RmiTmEvent(file,id)
            data.testFile=file;
            data.testId=id;
        end
    end
end
