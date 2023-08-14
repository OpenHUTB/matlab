


classdef HdlParserInfo<handle



    properties
        Name='';
    end
    properties(Access=private)
        Message=[];
        Ports=[];
    end
    methods(Access=private)
        function r=getMessageIdByKind(obj,type)
            if(isempty(obj.Message))
                r={};
                return;
            end
            tmp=[obj.Message.type];
            errorIndx=(tmp==type);
            r={obj.Message(errorIndx).identifier};
        end
    end
    methods

        function obj=HdlParserInfo()
            obj.Message=[];
        end

        function msg=getAllMessage(obj)
            msg='';
            for m=1:length(obj.Message)
                msg=[msg,obj.Message(m).text];%#ok<AGROW>
            end
        end

        function r=getErrorId(obj)
            r=getMessageIdByKind(obj,3);
        end
        function r=getWarningId(obj)
            r=getMessageIdByKind(obj,2);
        end
        function r=getInfoId(obj)
            r=getMessageIdByKind(obj,1);
        end
        function r=hasMessage(obj)
            r=~isempty(obj.Message);
        end


        function obj=addInfoEntry(obj,id,msg)
            info.type=1;
            info.identifier=id;
            info.text=['** HDL Parser Info: ',msg,char(10)];
            obj.Message=[obj.Message,info];
        end
        function obj=addWarningEntry(obj,id,msg)
            info.type=2;
            info.identifier=id;
            info.text=['** HDL Parser Warning: ',msg,char(10)];
            obj.Message=[obj.Message,info];
        end
        function obj=addErrorEntry(obj,id,msg)
            info.type=3;
            info.identifier=id;
            info.text=['** HDL Parser Error: ',msg,char(10)];
            obj.Message=[obj.Message,info];
        end

    end
end

