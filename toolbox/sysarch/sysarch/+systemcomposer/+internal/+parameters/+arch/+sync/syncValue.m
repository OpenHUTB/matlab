function syncValue(paramDef,slVar,mdlName,doWarning)


    import systemcomposer.internal.parameters.arch.sync.*

    if isa(slVar,'Simulink.Parameter')
        if strcmpi(slVar.DataType,'auto')
            datatype='double';
        else
            datatype=processDataTypeObject(slVar.DataType,mdlName);
        end
        if strcmp(datatype,'boolean')
            val=slVar.Value;
            if isempty(slVar.Value)
                val=0;
            end
            val=mat2str(logical(val));
        else
            val=mat2str(slVar.Value);
        end
        paramDef.getImpl.setTypeValueAndDimension(datatype,val,uint64(slVar.Dimensions));
    else
        dataType=string(class(slVar));
        val=mat2str(slVar);
        if strcmp(dataType,"logical")

            dataType="boolean";
            val=mat2str(logical(slVar));
        end
        if~isequal(dataType,paramDef.DataType)
            if~systemcomposer.internal.arch.internal.isParameterDataTypeUnsupported(dataType)
                paramDef.getImpl.setBaseType(dataType);
            else
                if doWarning
                    warning('SystemArchitecture:Parameter:UnsupportedParamDataType',...
                    DAStudio.message(...
                    'SystemArchitecture:Parameter:UnsupportedParamDataType',...
                    maName,mdlName,dataType));
                end
            end
        end
        paramDef.getImpl.setValueAndDimension(val,uint64(size(slVar)));
        if(numel(size(slVar))>2)

            if doWarning
                warning('SystemArchitecture:Parameter:UnsupportedParamDimension',...
                DAStudio.message(...
                'SystemArchitecture:Parameter:UnsupportedParamDimension',...
                maName,mdlName));
            end
            rootArch.removeParameter(paramDef.Name);

        end
    end
end
