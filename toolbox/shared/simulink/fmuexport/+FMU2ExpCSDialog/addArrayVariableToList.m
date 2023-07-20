function[pTree,scalarVariableList]=addArrayVariableToList(pTree,scalarVariableList,modelName,varOrFieldName,var_sz,var_dt,varSource,varValue,varMetaData,isFirstVisit,varNameNoIdx,isRootNode)
    assert(prod(var_sz)>1&&isa(var_sz,'uint32'));
    assert(~strcmp(var_dt,'char'));



    dims=num2cell(ones(1,length(var_sz)));
    for iter=1:prod(var_sz)
        dimsStr=['(',strjoin(cellfun(@(x)num2str(x),dims,'UniformOutput',false),','),')'];
        if length(var_sz)>1
            elementValue=varValue(sub2ind(var_sz,dims{:}));
        else
            elementValue=varValue(dims{1});
        end

        if strcmp(var_dt,'struct')||startsWith(var_dt,'Bus:')
            assert(isstruct(elementValue));
            [pTree,scalarVariableList]=FMU2ExpCSDialog.addStructVariableToList(pTree,scalarVariableList,modelName,[varOrFieldName,dimsStr],var_sz,var_dt,varSource,elementValue,varMetaData,(isFirstVisit&&iter==1),varNameNoIdx,isRootNode);
        else
            assert(isscalar(elementValue)||ischar(elementValue));
            [pTree,scalarVariableList]=FMU2ExpCSDialog.addScalarVariableToList(pTree,scalarVariableList,modelName,[varOrFieldName,dimsStr],var_sz,var_dt,varSource,elementValue,varMetaData,(isFirstVisit&&iter==1),varNameNoIdx,isRootNode);
        end


        j=length(dims);
        while 1
            dims{j}=dims{j}+1;
            if(j==1||dims{j}<=var_sz(j))
                break;
            end
            dims{j}=1;j=j-1;
        end
    end
end