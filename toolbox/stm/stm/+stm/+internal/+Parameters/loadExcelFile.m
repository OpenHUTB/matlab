function paramList=loadExcelFile(fileName,sheet,simIndex)


    T=xls.internal.ReadTable(fileName,'Sheet',sheet);
    params=T.readParameters(simIndex);

    if isempty(params)
        paramList=[];
        return;
    end

    workspace=string({params.Workspace});

    maskIdx=workspace.contains('/');
    mdlRefIdx=workspace.strlength>0&~maskIdx;
    sourceTypes=strings(1,numel(params));
    sourceTypes(maskIdx)="mask workspace";
    sourceTypes(mdlRefIdx)="model workspace";

    paramList=struct(...
    'Name',{params.Name},...
    'ClassName','char',...
    'CanShow',true,...
    'DerivedDisplayValue',getDisplayValues(params),...
    'SourceType',sourceTypes.cellstr,...
    'Source',workspace.cellstr);
end

function displayValues=getDisplayValues(params)
    import stm.internal.util.getDisplayValue;
    [~,displayValues]=arrayfun(@(param)getDisplayValue(param.Value.char),...
    params.','Uniform',false);
end
