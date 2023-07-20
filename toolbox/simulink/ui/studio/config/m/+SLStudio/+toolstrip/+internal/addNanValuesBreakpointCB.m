function addNanValuesBreakpointCB(cbinfo)




    breakpointType=slbreakpoints.datamodel.ModelBreakpointType.NanValues;
    SLStudio.toolstrip.internal.modelBreakpointCB(cbinfo,breakpointType);
end
