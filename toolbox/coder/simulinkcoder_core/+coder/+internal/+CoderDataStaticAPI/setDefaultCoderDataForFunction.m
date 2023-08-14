function setDefaultCoderDataForFunction(dd,functionType,coderDataType,value)















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    isMemorySection=strcmp(coderDataType,'MemorySection');
    isFunctionClass=strcmp(coderDataType,'FunctionClass');
    if isMemorySection
        dd=hlp.openDD(dd);
        if hlp.hasSWCT(dd)
            swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
            cat=hlp.getProp(swc,functionType);
            if isMemorySection
                if isempty(value)
                    hlp.setProp(cat,'InitialMemorySection',Simulink.data.dictionary.Entry.empty);
                else
                    if~isa(value,'Simulink.data.dictionary.Entry')||...
                        ~isa(value,'mf.zero.ModelElement')
                        value=coder.internal.CoderDataStaticAPI.getByName(dd,coderDataType,value);
                    end
                    hlp.setProp(cat,'InitialMemorySection',value);
                end
            end
        end
    elseif isFunctionClass
        dd=hlp.openDD(dd);
        if hlp.hasSWCT(dd)
            swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
            cat=hlp.getProp(swc,functionType);
            if isFunctionClass
                if isempty(value)
                    hlp.setProp(cat,'InitialFunctionClass',Simulink.data.dictionary.Entry.empty);
                else
                    if~isa(value,'Simulink.data.dictionary.Entry')||...
                        ~isa(value,'mf.zero.ModelElement')
                        value=coder.internal.CoderDataStaticAPI.getByName(dd,coderDataType,value);
                    end
                    hlp.setProp(cat,'InitialFunctionClass',value);
                end
            end
        end
    end
end


