classdef ConvertSystemToSingle<handle



    properties(Access=private)

BlockConverters


TopSystem




statefulFiles
    end

    methods(Access=public)

        function initialize(this,modelName)

            this.BlockConverters=containers.Map;


            this.TopSystem=modelName;



            this.statefulFiles=containers.Map;
        end

        function[err,messageStrs]=check(this,blockPath)

            [conv,err,messages]=checkImpl(this,blockPath);


            conv.deleteWorkingDir;



            messageStrs=this.convertMessages(messages);
        end

        function convert(this)
            converters=this.BlockConverters.values;

            for i=1:numel(converters)
                converters{i}.replaceMLFB;
            end
        end
    end

    methods(Access=private)

        function[conv,err,messages]=checkImpl(this,blockPath)
            conv=coder.internal.mlfbDoubleToSingle.ConvertToSingle(blockPath);
            this.BlockConverters(blockPath)=conv;


            MLFBObj=get_param(blockPath,'Object');
            err=SimulinkFixedPoint.TracingUtils.IsUnderReadOnlySystem(MLFBObj);
            if err
                messages=coder.internal.lib.Message();
                messages.type=coder.internal.lib.Message.ERR;
                messages.text=message('Coder:FXPCONV:DTS_LOCKED_MLFB',blockPath).getString();
                messages.params={blockPath};
                messages.id='Coder:FXPCONV:DTS_LOCKED_MLFB';
                return;
            end

            try
                conv.initializeFcnInfoRegistry;
            catch ex
                err=true;
                messages=coder.internal.lib.Message();
                messages.type=coder.internal.lib.Message.ERR;
                messages.text=message(ex.identifier,blockPath).getString();
                messages.params={blockPath};
                messages.id=ex.identifier;
                return;
            end


            messages=conv.runConformanceCheck;
            err=coder.internal.lib.Message.containErrorMsgs(messages);

            if err
                return
            end


            proposeTypesMessages=conv.proposeTypes;
            messages=[messages,proposeTypesMessages];
            err=coder.internal.lib.Message.containErrorMsgs(proposeTypesMessages);

            if err
                return
            end



            [convertMessages,this.statefulFiles]=conv.convert(this.statefulFiles);
            messages=[messages,convertMessages];
            err=coder.internal.lib.Message.containErrorMsgs(convertMessages);
        end




        function messageStrs=convertMessages(~,messages)

            messageStrs=cell(1,numel(messages));

            for i=1:numel(messages)
                msg=messages(i);
                messageStrs{i}=msg.getMatlabMessage.getString;
            end
        end

    end

end


