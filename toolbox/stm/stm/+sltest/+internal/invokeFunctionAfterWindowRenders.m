



function invokeFunctionAfterWindowRenders(callback)
    if sltest.testmanager.isOpen

        sltestmgr;
        callback();
    else
        openAndInvoke(callback);
    end
end

function openAndInvoke(callback)

    sub=message.subscribe('/stm/messaging/stmrendered',@stmrendered);


    assert(~sltest.testmanager.isOpen);
    sltestmgr;

    function stmrendered(varargin)

        message.unsubscribe(sub);
        callback();
    end
end
