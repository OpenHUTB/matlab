function togglePerspective(obj,editor)




    status=obj.getStatus(editor);

    st=editor.getStudio;
    ts=st.getToolStrip;
    as=ts.getActionService;
    as.executeAction('modelClonesIdentifierAppAction',status);
end

