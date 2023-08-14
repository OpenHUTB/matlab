















function[dataType,bNeedsFlag]=getDataTypeFromTreeNode(system,treeNode,resolvedSymbolIds)


    dataType='';
    bNeedsFlag=false;

    dataIds=Advisor.Utils.Stateflow.filterSymbolIds(resolvedSymbolIds,'data');
    scriptIds=Advisor.Utils.Stateflow.filterSymbolIds(resolvedSymbolIds,'script');
    stateIds=Advisor.Utils.Stateflow.filterSymbolIds(resolvedSymbolIds,'state');
    stateIdNames=arrayfun(@(x)sf('get',x,'.name'),stateIds,'UniformOutput',false);
    switch treeNode.kind
    case 'ID'
        idName=treeNode.string;

        dataIdNames=arrayfun(@(x)sf('get',x,'.name'),dataIds,'UniformOutput',false);

        if ismember(idName,stateIdNames)
            dataType='state';
        elseif ismember(idName,dataIdNames)
            dataObject=idToHandle(sfroot,dataIds(strcmp(idName,dataIdNames)));
            dataType=Advisor.Utils.Stateflow.getBuiltInDataType(system,dataObject.CompiledType);
            if contains(dataObject.DataType,'Enum:')...
                ||contains(dataObject.DataType,'Inherit:')...
                ||~isempty(dataObject.Props.Type.EnumType)...
                ||~isempty(dataObject.Props.Type.Hybrid)
                ens=enumeration(dataObject.CompiledType);
                if~isempty(ens)
                    meta=metaclass(ens(1));
                    dataType=getTopLevelSuperClassName(meta);
                end
            end
        else

            dataType=Advisor.Utils.Stateflow.getDataTypeFromDataDict(system,idName);
            if isempty(dataType)

                ens=enumeration(idName);
                if~isempty(ens)
                    meta=metaclass(ens(1));
                    dataType=getTopLevelSuperClassName(meta);
                end
            end
        end

    case 'PARENS'
        dataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,treeNode.Arg,resolvedSymbolIds);

    case 'CALL'
        functionName=treeNode.Left.string;
        for index=1:length(stateIds)
            name=sf('get',stateIds(index),'.name');
            if strcmp(functionName,name)==1
                functionObject=idToHandle(sfroot,stateIds(index));
                outputObjects=functionObject.find('-isa','Stateflow.Data',...
                'Scope','Output');
                if~isempty(outputObjects)
                    dataType=outputObjects(1).CompiledType;
                else
                    dataType='unknown';
                end
                break;
            end
        end
        if isempty(dataType)
            for index=1:length(scriptIds)
                name=sf('get',scriptIds(index),'.name');
                name=removeFileExtension(name);
                if strcmp(functionName,name)==1
                    dataType=Advisor.Utils.Stateflow.getBuiltInDataType(system,name);
                    break;
                end
            end
        end

    case 'DOT'





        BaseIdDataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,treeNode.Left,resolvedSymbolIds);

        if strcmp(BaseIdDataType,'unknown')
            dataType='unknown';
        elseif strcmp(BaseIdDataType,'state')

            StateObj=idToHandle(sfroot,stateIds(strcmp(treeNode.Left.string,stateIdNames)));











            dataObject=find(StateObj,'name',treeNode.Right.string);
            if~isempty(dataObject)&&isa(dataObject,'Stateflow.Data')
                dataType=dataObject.CompiledType;
            else
                dataType='unknown';
            end
        elseif Advisor.Utils.Simulink.isBusDataTypeStr(system,BaseIdDataType)


            if strncmpi(BaseIdDataType,'Bus:',4)
                BaseIdDataType=regexprep(BaseIdDataType,'(.*: )','');
            end


            DataObject=Advisor.Utils.safeEvalinGlobalScope(bdroot(system),BaseIdDataType);


            if~isempty(DataObject)

                if isa(DataObject,'Simulink.Bus')





                    idx=find(strcmp(treeNode.Right.string,{DataObject.Elements(:).Name}),1);
                    if isempty(idx)
                        dataType=BaseIdDataType;
                    else
                        dataType=DataObject.Elements(idx).DataType;
                    end
                end
            else

                meta=metaclass(Advisor.Utils.safeEvalinGlobalScope(bdroot(system),treeNode.tree2str));
                dataType=getTopLevelSuperClassName(meta);
            end
        else
            dataType=BaseIdDataType;
        end

    case 'SUBSCR'
        dataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,treeNode.Left,resolvedSymbolIds);
    case 'INT'
        dataType='int32';
        bNeedsFlag=true;

    case 'DOUBLE'
        dataType='double';
        bNeedsFlag=true;

    case 'UMINUS'
        [dataType,bNeedsFlag]=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,treeNode.Arg,resolvedSymbolIds);

    case{'GT','LT','GE','LE','EQ','NE'}
        dataType='boolean';

    case{'PLUS','MINUS','TIMES','DIVIDE','LDIVIDE','EXP','ANDAND','OROR'}
        [lType,l_bNeedsFlag]=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,treeNode.Left,resolvedSymbolIds);
        [rType,r_bNeedsFlag]=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,treeNode.Right,resolvedSymbolIds);
        if strcmp(lType,rType)&&~l_bNeedsFlag&&~r_bNeedsFlag
            dataType=lType;
        else
            dataType=lType;
            bNeedsFlag=true;
        end
    otherwise
        dataType='unknown';
    end
    if isempty(dataType)
        dataType='unknown';
    end

end

function newName=removeFileExtension(oldName)
    [~,theBody]=fileparts(oldName);
    newName=theBody;
end

function metaName=getTopLevelSuperClassName(metaclass)
    if~isempty(metaclass.SuperclassList)
        metaName=getTopLevelSuperClassName(metaclass.SuperclassList(1));
    else
        metaName=metaclass.Name;
    end
end

