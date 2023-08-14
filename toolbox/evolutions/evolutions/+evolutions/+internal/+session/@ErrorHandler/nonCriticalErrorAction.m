function nonCriticalErrorAction(this,~,data)




    printMsg(this,data.EventData);
    if this.DebugMode
        for idx=1:numel(data.EventData.cause)
            cause=data.EventData.cause{idx};
            printMsg(this,cause);
        end
    end
end

function printMsg(this,exception)

    if this.DebugMode
        report=exception.getReport;
    else
        report=exception.getReport('basic');
    end
    evolutions.internal.session.EventHandler.publish('Warning',...
    evolutions.internal.ui.GenericEventData(struct('msgId',...
    exception.identifier,'msg',report)));
end
