function sfDataObj=getDataDefinedInHierarchy(sfObj,scopeType)











    scopeTypeStruct=struct('Local',1,...
    'Constant',2,...
    'Parameter',3,...
    'Input',4,...
    'Output',5,...
    'All',6);

    if scopeType==scopeTypeStruct.Local
        sfDataObj=getSFDataObj(sfObj,'Local');
    elseif scopeType==scopeTypeStruct.Constant
        sfDataObj=getSFDataObj(sfObj,'Constant');
    elseif scopeType==scopeTypeStruct.Parameter
        sfDataObj=getSFDataObj(sfObj,'Parameter');
    elseif scopeType==scopeTypeStruct.Input
        sfDataObj=getSFDataObj(sfObj,'Input');
    elseif scopeType==scopeTypeStruct.Output
        sfDataObj=getSFDataObj(sfObj,'Output');
    else
        sfDataObj=getSFDataObj(sfObj,'All');
    end
end


function sfDataObj=getSFDataObj(sfObj,scope)
    sfDataObj=[];
    sfObj=sfObj.getParent;
    while isa(sfObj,'Stateflow.State')||...
        isa(sfObj,'Stateflow.AtomicSubchart')||...
        isa(sfObj,'Stateflow.AtomicBox')||...
        isa(sfObj,'Stateflow.Box')||...
        isa(sfObj,'Stateflow.Chart')
        if strcmp(scope,'All')
            sfDataObj=[sfDataObj;sfObj.find('-isa','Stateflow.Data','-depth',1)];
        else
            sfDataObj=[sfDataObj;sfObj.find('-isa','Stateflow.Data','-depth',1,'Scope',scope)];
        end
        sfObj=sfObj.getParent;
    end
end