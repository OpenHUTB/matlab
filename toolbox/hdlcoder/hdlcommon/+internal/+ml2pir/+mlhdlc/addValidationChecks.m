function hasError=addValidationChecks(messages)




    for i=1:numel(messages)
        msg=messages(i);

        mlMsg=msg.getMatlabMessage;
        [file,line,col]=internal.mtree.getLoc(msg.fcnTypeInfo,msg.node);
        [~,filename]=fileparts(file);

        emlhdlcoder.EmlChecker.CheckRepository.addCgirCheck(...
        mlMsg.getString,msg.id,msg.type.char,filename,line,col);
    end


    hasError=internal.mtree.Message.containErrorMsgs(messages);
end

