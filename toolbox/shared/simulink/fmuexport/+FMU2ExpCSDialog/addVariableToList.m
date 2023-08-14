function[pTree,scalarVariableList]=addVariableToList(modelName,pTree,scalarVariableList,varSource,varName)






    try
        if strcmp(varSource,'base workspace')

            var=Simulink.data.evalinGlobal(modelName,varName);
        elseif strcmp(varSource,'model argument')

            modelWS=get_param(modelName,'ModelWorkspace');
            var=modelWS.evalin(varName);
        elseif contains(varSource,'InstArg_')

            modelWS=get_param(modelName,'ModelWorkspace');
            var=modelWS.evalin(varName);
        else

            sldd=get_param(modelName,'DataDictionary');
            ddObj=Simulink.data.dictionary.open(sldd);
            dDataSectObj=getSection(ddObj,'Design Data');
            var=evalin(dDataSectObj,varName);
        end
    catch

        return;
    end


    orig_pTreeLength=length(pTree);
    orig_scalarLength=length(scalarVariableList);

    try




        if contains(varSource,'InstArg_')
            blockPath=varSource(9:end);
            bps=strsplit(blockPath,':');
            for i=1:length(bps)
                bp=strsplit(bps{i},'/');
                pTree=FMU2ExpCSDialog.addToTree(pTree,bp{end},uint32.empty(1,0),uint32(length(pTree)+2),false,'struct','',modelName,false);
            end
        end


        if isa(var,'Simulink.Parameter')

            if isa(var.Value,'Simulink.data.Expression')

                c_expr=char(var.Value.ExpressionString);
                var.Value=slResolve(c_expr,modelName,'expression');
                var.Dimensions=size(var.Value);
            end
            var_sz=uint32(var.Dimensions);
            if strcmp(var.DataType,'auto')
                var_dt=class(var.Value);
                if~isempty(enumeration(var_dt))
                    var_dt=['Enum: ',var_dt];
                end
            else
                var_dt=FMU2ExpCSDialog.resolveAliasType(modelName,var.DataType);
            end
            varMetaData=struct('description',var.Description,'unit',var.Unit,'blockPath','');

            [pTree,scalarVariableList]=recursiveAddVariableToList(pTree,scalarVariableList,modelName,varName,var_sz,var_dt,varSource,var.Value,varMetaData,true);

        elseif isnumeric(var)||islogical(var)||isstruct(var)||ischar(var)

            var_sz=uint32(size(var));
            var_dt=class(var);
            if~isempty(enumeration(var_dt))
                var_dt=['Enum: ',var_dt];
            end
            varMetaData=struct('description','','unit','','blockPath','');

            [pTree,scalarVariableList]=recursiveAddVariableToList(pTree,scalarVariableList,modelName,varName,var_sz,var_dt,varSource,var,varMetaData,true);

        elseif isa(var,'Simulink.LookupTable')


            if iscell(var.Breakpoints)
                pTree=FMU2ExpCSDialog.addToTree(pTree,varName,uint32.empty(1,0),uint32(length(pTree)+2),false,'struct',varSource,modelName,true);
            else
                pTree=FMU2ExpCSDialog.addToTree(pTree,varName,uint32.empty(1,0),uint32([length(pTree)+2,length(pTree)+4]),false,'struct',varSource,modelName,true);
                pTree=FMU2ExpCSDialog.addToTree(pTree,[varName,'.Table'],uint32.empty(1,0),uint32(length(pTree)+2),false,'struct',varSource,modelName,false);
            end
            var_sz=uint32(var.Table.Dimensions);
            var_dt=class(var.Table.Value);
            if~isempty(enumeration(var_dt))
                var_dt=['Enum: ',var_dt];
            end
            varMetaData=struct('description',var.Table.Description,'unit',var.Table.Unit,'blockPath','');

            [pTree,scalarVariableList]=recursiveAddVariableToList(pTree,scalarVariableList,modelName,[varName,'.Table.Value'],var_sz,var_dt,varSource,var.Table.Value,varMetaData,false);

            if isa(var.Breakpoints,'Simulink.lookuptable.Evenspacing')

                pTree=FMU2ExpCSDialog.addToTree(pTree,[varName,'.Breakpoints'],uint32.empty(1,0),uint32([length(pTree)+2,length(pTree)+3]),false,'struct',varSource,modelName,false);

                if strcmp(var.Breakpoints.DataType,'auto')
                    var_dt=class(var.Breakpoints.FirstPoint);
                    if~isempty(enumeration(var_dt))
                        var_dt=['Enum: ',var_dt];
                    end
                else
                    var_dt=FMU2ExpCSDialog.resolveAliasType(modelName,var.Breakpoints.DataType);
                end
                varMetaData=struct('description',var.Breakpoints.Description,'unit',var.Breakpoints.Unit,'blockPath','');

                assert(isscalar(var.Breakpoints.FirstPoint)||ischar(var.Breakpoints.FirstPoint));
                [pTree,scalarVariableList]=FMU2ExpCSDialog.addScalarVariableToList(pTree,scalarVariableList,modelName,[varName,'.Breakpoints.FirstPoint'],uint32.empty(1,0),var_dt,varSource,var.Breakpoints.FirstPoint,varMetaData,true,[varName,'.Breakpoints.FirstPoint'],false);


                if strcmp(var.Breakpoints.DataType,'auto')
                    var_dt=class(var.Breakpoints.Spacing);
                    if~isempty(enumeration(var_dt))
                        var_dt=['Enum: ',var_dt];
                    end
                else
                    var_dt=FMU2ExpCSDialog.resolveAliasType(modelName,var.Breakpoints.DataType);
                end
                varMetaData=struct('description',var.Breakpoints.Description,'unit',var.Breakpoints.Unit,'blockPath','');

                assert(isscalar(var.Breakpoints.Spacing)||ischar(var.Breakpoints.Spacing));
                [pTree,scalarVariableList]=FMU2ExpCSDialog.addScalarVariableToList(pTree,scalarVariableList,modelName,[varName,'.Breakpoints.Spacing'],uint32.empty(1,0),var_dt,varSource,var.Breakpoints.Spacing,varMetaData,true,[varName,'.Breakpoints.Spacing'],false);
            elseif isa(var.Breakpoints,'Simulink.lookuptable.Breakpoint')

                pTree=FMU2ExpCSDialog.addToTree(pTree,[varName,'.Breakpoints'],uint32.empty(1,0),uint32(length(pTree)+2+(0:(length(var.Breakpoints)-1))),false,'struct',varSource,modelName,false);
                for i=1:length(var.Breakpoints)
                    var_sz=uint32(var.Breakpoints(i).Dimensions);
                    if strcmp(var.Breakpoints(i).DataType,'auto')
                        var_dt=class(var.Breakpoints(i).Value);
                        if~isempty(enumeration(var_dt))
                            var_dt=['Enum: ',var_dt];
                        end
                    else
                        var_dt=FMU2ExpCSDialog.resolveAliasType(modelName,var.Breakpoints(i).DataType);
                    end
                    varMetaData=struct('description',var.Breakpoints(i).Description,'unit',var.Breakpoints(i).Unit,'blockPath','');

                    [pTree,scalarVariableList]=recursiveAddVariableToList(pTree,scalarVariableList,modelName,[varName,'.Breakpoints.Value'],var_sz,var_dt,varSource,var.Breakpoints(i).Value,varMetaData,false);
                end
            end

        elseif isa(var,'Simulink.Breakpoint')

            pTree=FMU2ExpCSDialog.addToTree(pTree,varName,uint32.empty(1,0),uint32(length(pTree)+2+(0:(length(var.Breakpoints)-1))),false,'struct',varSource,modelName,true);

            var_sz=uint32(var.Breakpoints.Dimensions);
            if strcmp(var.Breakpoints.DataType,'auto')
                var_dt=class(var.Breakpoints.Value);
                if~isempty(enumeration(var_dt))
                    var_dt=['Enum: ',var_dt];
                end
            else
                var_dt=FMU2ExpCSDialog.resolveAliasType(modelName,var.Breakpoints.DataType);
            end
            varMetaData=struct('description',var.Breakpoints.Description,'unit',var.Breakpoints.Unit,'blockPath','');
            [pTree,scalarVariableList]=recursiveAddVariableToList(pTree,scalarVariableList,modelName,[varName,'.Value'],var_sz,var_dt,varSource,var.Breakpoints.Value,varMetaData,false);
        else


        end
    catch ex
        if strcmp(ex.identifier,'FMUExport:skipVariable')


            [pTree,scalarVariableList]=FMU2ExpCSDialog.removeScalarVariableFromList(pTree,scalarVariableList,orig_pTreeLength+1,orig_scalarLength+1);
        else
            rethrow(ex);
        end
    end
end

function[pTree,scalarVariableList]=recursiveAddVariableToList(pTree,scalarVariableList,modelName,varName,var_sz,var_dt,varSource,varValue,varMetaData,isRootNode)

    if length(var_sz)==2&&var_sz(2)==1
        var_sz=var_sz(1);
    end

    if prod(var_sz)>1&&~strcmp(var_dt,'char')

        [pTree,scalarVariableList]=FMU2ExpCSDialog.addArrayVariableToList(pTree,scalarVariableList,modelName,varName,var_sz,var_dt,varSource,varValue,varMetaData,true,varName,isRootNode);
    elseif strcmp(var_dt,'struct')||startsWith(var_dt,'Bus:')


        assert(isstruct(varValue));
        [pTree,scalarVariableList]=FMU2ExpCSDialog.addStructVariableToList(pTree,scalarVariableList,modelName,varName,uint32.empty(1,0),var_dt,varSource,varValue,varMetaData,true,varName,isRootNode);
    else

        assert(isscalar(varValue)||ischar(varValue));

        [pTree,scalarVariableList]=FMU2ExpCSDialog.addScalarVariableToList(pTree,scalarVariableList,modelName,varName,uint32.empty(1,0),var_dt,varSource,varValue,varMetaData,true,varName,isRootNode);
    end
end
