function syncDataType(paramDef,slVar,mdlName,doWarning)


    import systemcomposer.internal.parameters.arch.sync.*

    if isa(slVar,'Simulink.Parameter')
        if strcmp(slVar.DataType,'auto')
            dataType="double";
        else
            dataType=processDataTypeObject(slVar.DataType,mdlName);
        end
    else
        dataType=string(class(slVar));
        if strcmp(dataType,"logical")

            dataType="boolean";
        end
    end
    if systemcomposer.internal.arch.internal.isParameterDataTypeUnsupported(dataType)

        if doWarning
            warning('SystemArchitecture:Parameter:UnsupportedParamDataType',...
            DAStudio.message(...
            'SystemArchitecture:Parameter:UnsupportedParamDataType',...
            maName,mdlName,dataType));
        end
        rootArch.removeParameter(paramDef.Name);

    else
        paramDef.getImpl.setBaseType(dataType);
    end
end
