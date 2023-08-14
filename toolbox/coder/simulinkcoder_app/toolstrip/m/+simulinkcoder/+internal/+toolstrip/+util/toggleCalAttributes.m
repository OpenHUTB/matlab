function toggleCalAttributes(cbinfo,app)



    if strcmp(app,'embeddedCoderApp')
        st=cbinfo.studio;
        context=st.App.getAppContextManager.getCustomContext(app);
        context.ShowCalAttributes=~context.ShowCalAttributes;
        ShowCalAttributes=context.ShowCalAttributes;
        save(simulinkcoder.internal.toolstrip.util.getPrefFileName(),'ShowCalAttributes');



        ss=st.getComponent('GLUE2:SpreadSheet','CodeProperties');
        ed=DAStudio.EventDispatcher;ed.broadcastEvent('PropertyChangedEvent',ss.getSource);
    end

end
