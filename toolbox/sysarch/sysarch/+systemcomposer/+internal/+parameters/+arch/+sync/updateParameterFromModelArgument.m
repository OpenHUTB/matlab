function paramDef=updateParameterFromModelArgument(arch,model,paramName,argVar)




    doWarning=systemcomposer.internal.arch.internal.parameterSyncWarningStatus;

    if isa(argVar,'Simulink.Parameter')
        if numel(argVar.Dimensions)>2

            if doWarning
                warning('SystemArchitecture:Parameter:UnsupportedParamDimension',...
                DAStudio.message(...
                'SystemArchitecture:Parameter:UnsupportedParamDimension',...
                paramName,model));
            end
            return;
        end

        if strcmp(argVar.DataType,'auto')
            dataType="double";
        else
            dataType=systemcomposer.internal.parameters.arch.sync.processDataTypeObject(argVar.DataType,model);
        end
        if systemcomposer.internal.arch.internal.isParameterDataTypeUnsupported(dataType)

            if doWarning
                warning('SystemArchitecture:Parameter:UnsupportedParamDataType',...
                DAStudio.message(...
                'SystemArchitecture:Parameter:UnsupportedParamDataType',...
                paramName,model,dataType));
            end
            return;
        end
        paramDef=systemcomposer.internal.arch.internal.getOrAddParamDef(arch,paramName);
    else
        if numel(size(argVar))>2

            if doWarning
                warning('SystemArchitecture:Parameter:UnsupportedParamDimension',...
                DAStudio.message(...
                'SystemArchitecture:Parameter:UnsupportedParamDimension',...
                paramName,model));
            end
            return;
        end

        dataType=string(class(argVar));
        if strcmp(dataType,"logical")

            dataType="boolean";
        end
        if systemcomposer.internal.arch.internal.isParameterDataTypeUnsupported(dataType)

            if doWarning
                warning('SystemArchitecture:Parameter:UnsupportedParamDataType',...
                DAStudio.message(...
                'SystemArchitecture:Parameter:UnsupportedParamDataType',...
                paramName,model,dataType));
            end
            return;
        end
        paramDef=systemcomposer.internal.arch.internal.getOrAddParamDef(arch,paramName);




    end
end
































