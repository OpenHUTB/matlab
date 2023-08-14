



function showToolstripCB(cbinfo,~)
    st=cbinfo.studio;
    ts=st.getToolStrip;
    if cbinfo.EventData
        ts.DisplayState='Expanded';
    else
        ts.DisplayState='Collapsed';
    end
end
