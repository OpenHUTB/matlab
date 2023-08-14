function warning(id,msg)



    prev_state=warning('query','backtrace');
    warning('backtrace','off');
    bt=onCleanup(@()warning('backtrace',prev_state.state));
    warning(id,msg);
end
