









function msg=getMessage(this,msgType,msgId,msgParams,node)



    if nargin<5
        node=this.tree.Fname;
    end

    msg=coder.internal.lib.Message();
    msg.functionName=this.functionName;
    msg.specializationName=this.specializationName;
    msg.file=this.scriptPath;
    msg.type=msgType;

    msg.position=node.lefttreepos()-1;
    msg.length=node.righttreepos-msg.position;

    msg.text=message(msgId,msgParams{:}).getString();
    msg.id=msgId;
    msg.params=msgParams;
end


