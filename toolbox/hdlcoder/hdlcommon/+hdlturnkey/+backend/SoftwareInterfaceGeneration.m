

classdef(Abstract)SoftwareInterfaceGeneration<handle









    properties

        hTurnkey=[];
    end

    properties(Abstract,SetAccess=protected)
Vendor
    end

    properties(Abstract,Access=protected)

MessageString
    end

    methods
        function obj=SoftwareInterfaceGeneration(hTurnkey)

            obj.hTurnkey=hTurnkey;
        end
    end

    methods(Hidden)
        function isit=isCommandLineDisplay(obj)
            isit=obj.hTurnkey.hD.cmdDisplay;
        end
    end

    methods(Access=protected)
    end


    methods(Access=protected)

        function[status,result]=publishMessage(obj,msg,status,result)
            hDI=obj.hTurnkey.hD;
            if hDI.cmdDisplay
                hdldisp(msg);
            else
                result=sprintf('%s\n%s',result,msg.getString);
            end
        end
    end
end
