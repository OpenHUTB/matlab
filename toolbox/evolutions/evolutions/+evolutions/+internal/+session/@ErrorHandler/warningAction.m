function warningAction(this,~,data)




    id=data.EventData.msgId;
    msg=data.EventData.msg;
    if~this.DebugMode
        origState=warning('off','backtrace');
        cleanup.warning=onCleanup(@()warning(origState));
    end

    warning(id,'%s',msg);
end
