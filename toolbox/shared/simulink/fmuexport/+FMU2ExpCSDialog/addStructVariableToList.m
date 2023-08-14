function[pTree,scalarVariableList]=addStructVariableToList(pTree,scalarVariableList,modelName,varOrIdxName,var_sz,var_dt,varSource,varValue,varMetaData,isFirstVisit,varNameNoIdx,isRootNode)

    if strcmp(var_dt,'struct')
        fields=fieldnames(varValue);
        nElem=length(fields);
        if nElem==0
            throw(MException('FMUExport:skipVariable','no struct elements'));
        end
        elementValue=cell(1,nElem);
        elementType=cell(1,nElem);
        elementSize=cell(1,nElem);
        for i=1:nElem
            elementValue{i}=varValue.(fields{i});
            elementType{i}=class(elementValue{i});


            if~isempty(enumeration(elementType{i}))
                elementType{i}=['Enum: ',elementType{i}];
            end
            elementSize{i}=uint32(size(elementValue{i}));


            if length(elementSize{i})==2&&elementSize{i}(2)==1
                elementSize{i}=elementSize{i}(1);
            end
            if prod(elementSize{i})==0
                throw(MException('FMUExport:skipVariable','no struct elements'));
            end
        end

    else
        assert(startsWith(var_dt,'Bus:'));
        assert(isstruct(varValue));


        dtObj=Simulink.data.evalinGlobal(modelName,strtrim(var_dt(5:end)));
        fields={dtObj.Elements.Name}';
        nElem=length(fields);
        if nElem==0
            throw(MException('FMUExport:skipVariable','no bus elements'));
        end
        elementValue=cell(1,nElem);
        elementType={dtObj.Elements.DataType};
        elementSize=cellfun(@uint32,{dtObj.Elements.Dimensions},'UniformOutput',false);
        for i=1:nElem
            elementValue{i}=varValue.(fields{i});
            elementType{i}=FMU2ExpCSDialog.resolveAliasType(modelName,elementType{i});







            if length(elementSize{i})==2&&elementSize{i}(2)==1
                elementSize{i}=elementSize{i}(1);
            end
            if prod(elementSize{i})==0
                throw(MException('FMUExport:skipVariable','no bus elements'));
            end
        end
    end


    if isFirstVisit
        pTree=FMU2ExpCSDialog.addToTree(pTree,varNameNoIdx,var_sz,uint32(ones(1,nElem)),false,var_dt,varSource,modelName,isRootNode);
        cur=length(pTree);
    end


    for i=1:nElem

        if isFirstVisit
            pTree(cur).ChildrenIndex(i)=length(pTree)+1;
        end




        if prod(elementSize{i})>1&&~strcmp(elementType{i},'char')
            assert(~isscalar(elementValue{i})&&~ischar(elementValue{i}));
            [pTree,scalarVariableList]=FMU2ExpCSDialog.addArrayVariableToList(pTree,scalarVariableList,modelName,[varOrIdxName,'.',fields{i}],elementSize{i},elementType{i},varSource,elementValue{i},varMetaData,isFirstVisit,fields{i},false);
        elseif strcmp(elementType{i},'struct')||startsWith(elementType{i},'Bus:')
            assert(isstruct(elementValue{i}));
            [pTree,scalarVariableList]=FMU2ExpCSDialog.addStructVariableToList(pTree,scalarVariableList,modelName,[varOrIdxName,'.',fields{i}],uint32.empty(1,0),elementType{i},varSource,elementValue{i},varMetaData,isFirstVisit,fields{i},false);
        else
            assert(isscalar(elementValue{i})||ischar(elementValue{i}));
            [pTree,scalarVariableList]=FMU2ExpCSDialog.addScalarVariableToList(pTree,scalarVariableList,modelName,[varOrIdxName,'.',fields{i}],uint32.empty(1,0),elementType{i},varSource,elementValue{i},varMetaData,isFirstVisit,fields{i},false);
        end

    end
end