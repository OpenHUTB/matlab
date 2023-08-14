function[iTree,scalarVariableList]=addInternalVarToList(modelName,iTree,scalarVariableList,varSource,blkPath,varName,compiledPortAttrib)






    try
        var=Simulink.data.evalinGlobal(modelName,varName);
    catch


        return;
    end


    orig_iTreeLength=length(iTree);
    orig_scalarLength=length(scalarVariableList);

    try
        if isa(var,'Simulink.Signal')



            if isequal(var.Dimensions,-1)
                var_sz=uint32(compiledPortAttrib.dim);
            else
                var_sz=uint32(var.Dimensions);
            end
            if strcmp(var.DataType,'auto')
                var_dt=compiledPortAttrib.dt;
                if~isempty(enumeration(var_dt))
                    var_dt=['Enum: ',var_dt];
                end
            else
                var_dt=FMU2ExpCSDialog.resolveAliasType(modelName,var.DataType);
            end
            if isempty(var.InitialValue)

                warnID='FMUExport:FMU:FMU2ExpCSIVInitialValueNotSpecified';
                coder.internal.fmuexport.reportMsg(message(warnID,varName),'Warning',modelName);
            else
                varMetaData=struct('description',var.Description,'unit',var.Unit,'blockPath',blkPath);
                [iTree,scalarVariableList]=recursiveAddVariableToList(iTree,scalarVariableList,modelName,varName,var_sz,var_dt,varSource,str2num(var.InitialValue),varMetaData,true);
            end

        elseif isnumeric(var)||islogical(var)||isstruct(var)||ischar(var)



            var_sz=uint32(size(var));
            var_dt=class(var);
            if~isempty(enumeration(var_dt))
                var_dt=['Enum: ',var_dt];
            end
            varMetaData=struct('description','','unit','','blockPath',blkPath);
            [iTree,scalarVariableList]=recursiveAddVariableToList(iTree,scalarVariableList,modelName,varName,var_sz,var_dt,varSource,var,varMetaData,true);
        end
    catch ex
        if strcmp(ex.identifier,'FMUExport:skipVariable')


            [iTree,scalarVariableList]=FMU2ExpCSDialog.removeScalarVariableFromList(iTree,scalarVariableList,orig_iTreeLength+1,orig_scalarLength+1);
        else
            rethrow(ex);
        end
    end
end

function[iTree,scalarVariableList]=recursiveAddVariableToList(iTree,scalarVariableList,modelName,varName,var_sz,var_dt,varSource,varValue,varMetaData,isRootNode)

    if length(var_sz)==2&&var_sz(2)==1
        var_sz=var_sz(1);
    end

    if prod(var_sz)>1&&~strcmp(var_dt,'char')

        [iTree,scalarVariableList]=FMU2ExpCSDialog.addArrayVariableToList(iTree,scalarVariableList,modelName,varName,var_sz,var_dt,varSource,varValue,varMetaData,true,varName,isRootNode);
    elseif strcmp(var_dt,'struct')||startsWith(var_dt,'Bus:')

        assert(isstruct(varValue));
        [iTree,scalarVariableList]=FMU2ExpCSDialog.addStructVariableToList(iTree,scalarVariableList,modelName,varName,uint32.empty(1,0),var_dt,varSource,varValue,varMetaData,true,varName,isRootNode);
    else

        assert(isscalar(varValue)||ischar(varValue));
        [iTree,scalarVariableList]=FMU2ExpCSDialog.addScalarVariableToList(iTree,scalarVariableList,modelName,varName,uint32.empty(1,0),var_dt,varSource,varValue,varMetaData,true,varName,isRootNode);
    end
end
