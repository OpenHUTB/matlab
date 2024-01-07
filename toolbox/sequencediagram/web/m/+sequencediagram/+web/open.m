function open(url,editorId,debugMode,debugPort)

    webWindowId=editorId;
    if debugMode
        web(url,'-browser')
    else

        webWindowMgr=sequencediagram.web.WebWindowManager.getInstance();
        if webWindowMgr.hasWebWindow(webWindowId)
            CEFWindow=webWindowMgr.getWebWindow(webWindowId);
            CEFWindow.show();
            CEFWindow.bringToFront();
        else
            props=struct();
            props.URL=url;
            props.Title=message('sequencediagram:Editor:Title').getString();
            props.closeCallback=@(~,~)builtin('_destroy_sequence_diagram_editor_with_id',editorId);
            if nargin==4

                props.debugPort=debugPort;
            end
            webWindowMgr.createWebWindow(webWindowId,props);
        end
    end

end

