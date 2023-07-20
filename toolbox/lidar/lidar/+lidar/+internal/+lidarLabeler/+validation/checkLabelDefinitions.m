function labelDefs=checkLabelDefinitions(labelDefs)








    validateattributes(labelDefs,{'table'},{'nonempty'},'groundTruthLidar','LabelDefinitions');

    import vision.internal.labeler.validation.*

    validateattributes(labelDefs,{'table'},{'nonempty'},mfilename,'LabelDefinitions');


    tableColumns=string(labelDefs.Properties.VariableNames);
    requiredColumns=["Name","Type"];

    isReqVariableExist=all(ismember(requiredColumns,tableColumns));

    if~isReqVariableExist
        error(vision.getMessage('lidar:groundTruthLidar:LabelDefsRequiredNotExist'));
    end



    TF=rowfun(@(varargin)lidar.internal.labeler.validation.validateLabelDefEntry(tableColumns,varargin{:}),labelDefs,...
    'OutputFormat','uniform','ExtractCellContents',true,...
    'NumOutputs',width(labelDefs));

    for idx=1:numel(tableColumns)
        columnName=tableColumns(idx);

        if~all(TF(:,idx))
            switch columnName
            case "Name"
                error(message('vision:groundTruth:labelDefsInvalidLabelNames'));
            case "Type"
                error(message('vision:groundTruth:labelDefsInvalidLabelType'));
            case "Group"
                error(message('vision:groundTruth:labelDefsInvalidLabelGroup'));
            case "Description"
                error(message('vision:groundTruth:labelDefsInvalidLabelDesc'));
            case "Hierarchy"
                error(message('lidar:groundTruthLidar:LabelDefsInvalidSignalType'));
            case "LabelColor"
                error(message('lidar:groundTruthLidar:LabelDefsInvalidColor'));
            end
        end

    end

    isCuboidLabels=findLabelTypeIdx(labelDefs.Type,labelType.Cuboid);
    isSceneLabels=findLabelTypeIdx(labelDefs.Type,labelType.Scene);
    isLine3DLabels=findLabelTypeIdx(labelDefs.Type,labelType.Line);
    isVoxelLabels=findLabelTypeIdx(labelDefs.Type,lidarLabelType.Voxel);

    if sum(isSceneLabels)+sum(isCuboidLabels)+sum(isLine3DLabels)+sum(isVoxelLabels)~=numel(labelDefs.Type)
        error(message('lidar:groundTruthLidar:labelDefsNotCuboidOrScene'));
    end

    filteredLabelDef=labelDefs(~isCuboidLabels,:);
    [~,uniqueIdx]=unique(filteredLabelDef.Name(:));
    if numel(uniqueIdx)<height(filteredLabelDef)
        error(message('vision:groundTruth:labelDefsNotUnique'));
    end



    badLabelNames=lidar.internal.labeler.validation.invalidNames(labelDefs{:,1});
    if~isempty(badLabelNames)
        error(message('vision:groundTruth:invalidName',badLabelNames));
    end
end

function idx=findLabelTypeIdx(labelTypeChoicesEnum,labels)

    idx=zeros(1,numel(labelTypeChoicesEnum));
    if~iscell(labelTypeChoicesEnum)
        for i=1:numel(labelTypeChoicesEnum)
            idx(i)=labelTypeChoicesEnum(i)==labels;
        end
    else
        for i=1:numel(labelTypeChoicesEnum)
            idx(i)=labelTypeChoicesEnum{i}==labels;
        end
    end
end