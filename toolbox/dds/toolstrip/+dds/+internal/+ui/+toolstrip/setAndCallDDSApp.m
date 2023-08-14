function setAndCallDDSApp(modelName,varargin)




    st=hgetUEStudio(modelName);
    ts=st.getToolStrip();
    as=ts.getActionService();
    as.executeActionSync('ddsAppAction',varargin{:});

