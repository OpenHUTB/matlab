




classdef Message<handle

    properties(GetAccess=public,SetAccess=immutable)

        type(1,1)internal.mtree.MessageType


        id(1,:)char


        params(1,:)cell


node

fcnTypeInfo
    end

    methods(Access=public)



        function this=Message(functionTypeInfo,node,msgType,msgId,varargin)
            this.type=msgType;
            this.id=msgId;
            this.params=varargin;
            this.node=node;
            this.fcnTypeInfo=functionTypeInfo;
        end

        function v=toHdlValidateStruct(this)
            msg=this.getMatlabMessage;


            switch this.type
            case internal.mtree.MessageType.Display
                status=3;
            case internal.mtree.MessageType.Warning
                status=2;
            case internal.mtree.MessageType.Error
                status=1;
            otherwise
                assert(isequal(this.type,internal.mtree.MessageType.Log),...
                'invalid message type found');
                status=0;
            end

            v=hdlvalidatestruct(status,msg);
        end

        function msg=getMatlabMessage(this)
            msg=message(this.id,this.params{:});
        end

        function printMessage(this)
            printfLoc=1;
            strPrefix='';

            switch this.type
            case internal.mtree.MessageType.Warning

                strPrefix='Warning : ';
            case internal.mtree.MessageType.Error

                printfLoc=2;


                strPrefix='Error: ';
            end

            fprintf(printfLoc,'%s%s\n',strPrefix,this.getMatlabMessage);
        end
    end

    methods(Static)


        function res=containErrorMsgs(msgs)
            res=ismember(internal.mtree.MessageType.Error,[msgs.type]);
        end


        function res=containWarnMsgs(msgs)
            res=ismember(internal.mtree.MessageType.Warning,[msgs.type]);
        end


        function res=containDispMsgs(msgs)
            res=ismember(internal.mtree.MessageType.Display,[msgs.type]);
        end



        function res=getNonLogMessages(msgs)
            res=msgs(~ismember([msgs.type],internal.mtree.MessageType.Log));
        end


        function res=getMessagesOfType(msgs,msgType)
            res=msgs(ismember([msgs.type],msgType));
        end


        function msgs=preallocate(numMsgs)
            dummyMsg=internal.mtree.Message([],[],internal.mtree.MessageType.Log,'');
            msgs=repmat(dummyMsg,1,numMsgs);
        end
    end
end


