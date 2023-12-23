function initCloseMulticoreUI(method,modelH)
    appmgr=multicoredesigner.internal.UIManager.getInstance;

    switch(method)

    case 'close'
        appmgr.closePerspective(modelH);
    end


