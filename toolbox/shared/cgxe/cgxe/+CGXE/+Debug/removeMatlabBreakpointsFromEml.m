function removeMatlabBreakpointsFromEml(instancePath,scriptName,lineNumbers)








    assert(isa(lineNumbers,'int32'),...
    'removeMatlabBreakpointsFromEml takes an integer array');

    for i=1:length(lineNumbers)
        objectId=sfprivate('eml_script_cache_get_wrapper_for_breakpoints',scriptName);
        if(objectId~=0)
            sfprivate('eml_man','register_breakpoint',objectId,lineNumbers(i)+1,0,0);
            if CGXE.Debug.DebugRuntimeManager.isDebuggerOn()
                CGXE.internal.Debugger.addOrUpdateBreakpoint(instancePath,lineNumbers(i)+1,...
                scriptName,"","",false);
            end
        end
    end

end