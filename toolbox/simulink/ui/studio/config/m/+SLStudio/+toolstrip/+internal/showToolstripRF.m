



function showToolstripRF(cbinfo,action)
    st=cbinfo.studio;
    ts=st.getToolStrip;
    action.selected=strcmp(ts.DisplayState,'Expanded');
end
