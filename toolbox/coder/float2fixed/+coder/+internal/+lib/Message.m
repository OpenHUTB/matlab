classdef Message

    properties
        functionName;%#ok<*AGROW>
        specializationName;
        file;
        type;
        position;
        length;


        text;

        id;

        params;
    end
    properties(Hidden)
node
    end




    properties(Constant)
        DISP='Display';
        WARN='Warning';
        ERR='Error';
        USRLOG='Log';
    end

    methods
        function this=Message(fcnName,specialitionName,filePath,errType,errLoc,len,text,id)
            this.node.str='';
            this.node.charno=-1;
            this.node.lineno=-1;
            this.params={};

            if nargin>0
                this.functionName=fcnName;%#ok<*AGROW>
                this.specializationName=specialitionName;
                this.file=filePath;
                this.type=errType;
                this.position=errLoc;
                this.length=len;
                this.text=text;
                this.id=id;
            end
        end

        function strct=toStruct(this)
            strct.functionName=this.functionName;%#ok<*AGROW>
            strct.specializationName=this.specializationName;
            strct.file=this.file;
            strct.type=this.type;
            strct.position=this.position;
            strct.length=this.length;
            strct.text=this.text;
            strct.id=this.id;
            strct.node=this.node;
            strct.params=this.params;
        end

        function strct=toGUIStruct(this)



            strct.functionName=this.functionName;%#ok<*AGROW>
            strct.specializationName=this.specializationName;
            strct.file=this.file;
            strct.type=this.type;
            strct.position=this.position;
            strct.length=this.length;
            strct.text=this.text;
            strct.id=this.id;

            strct.ordinal=-1;
            strct.functionId='';
        end


        function msg=getMatlabMessage(this)
            msg=message(this.id,this.params{:});
        end
    end

    methods(Static)

        function res=isValidMessgeType(msgType)
            switch msgType
            case{coder.internal.lib.Message.DISP...
                ,coder.internal.lib.Message.WARN...
                ,coder.internal.lib.Message.ERR...
                ,coder.internal.lib.Message.USRLOG}
                res=true;
            otherwise
                res=false;
            end
        end


        function res=containErrorMsgs(msgs)
            res=~isempty(msgs)&&any(strcmp({msgs.type},coder.internal.lib.Message.ERR));
        end


        function res=containWarnMsgs(msgs)
            res=~isempty(msgs)&&any(strcmp({msgs.type},coder.internal.lib.Message.WARN));
        end


        function res=containDispMsgs(msgs)
            res=~isempty(msgs)&&any(strcmp({msgs.type},coder.internal.lib.Message.DISP));
        end



        function res=getNonLogMessages(msgs)
            res=msgs(~strcmp(coder.internal.lib.Message.USRLOG,{msgs.type}));
        end


        function res=getMessagesOfType(msgs,typeName)
            res=msgs(strcmp(typeName,{msgs.type}));
        end
    end

    methods(Static,Hidden)







        function msg=buildMessage(functionTypeInfo,node,msgType,msgId,msgParams)
            if nargin<5
                msgParams={};
            end

            if~iscell(msgParams)
                msgParams={msgParams};
            end

            msg=coder.internal.lib.Message();
            msg.functionName=functionTypeInfo.functionName;%#ok<*AGROW>
            msg.specializationName=functionTypeInfo.specializationName;
            msg.file=functionTypeInfo.scriptPath;
            msg.type=msgType;



            msg.position=node.lefttreepos()-1;
            msg.length=node.righttreepos-node.lefttreepos()+1;

            msg.text=message(msgId,msgParams{:}).getString();
            msg.id=msgId;
            msg.params=msgParams;

            msg.node.lineno=node.lineno;
            msg.node.charno=node.charno;
            msg.node.str=node.tree2str();
        end
    end
end

