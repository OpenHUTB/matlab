function labelData=validateLabelDataTableEntries(labelData,labelDefs,signalType)





    hasHierarchy=~isempty(find(strcmpi(labelDefs.Properties.VariableNames,'Hierarchy'),1));

    import vision.internal.labeler.validation.*
    import lidar.internal.labeler.validation.*


    for n=1:width(labelData)
        name=labelData.Properties.VariableNames{n};
        if strcmp(name,'VoxelLabelData')
            type={lidarLabelType.Voxel};
        else
            hasSignalType=any(string(labelDefs.Properties.VariableNames)=="SignalType");
            if hasSignalType
                type=labelDefs.LabelType(strcmpi(labelDefs.Name,name));
                if type~=labelType.Custom
                    supportedLabelTypes={labelType.Cuboid,labelType.Line,lidarLabelType.Voxel};
                    for i=1:numel(supportedLabelTypes)
                        if type==supportedLabelTypes{i}
                            type={type};
                            break;
                        end
                    end

                end
            else
                type=labelDefs.Type(strcmpi(labelDefs.Name,name));
                if~iscell(type)
                    type={type};
                end
            end
        end
        data=labelData.(name);
        if~isempty(type)
            type=type{1};
        end
        switch type
        case labelType.Cuboid
            if~iscell(data)
                data=num2cell(data,2);
                labelData.(name)=data;
            end

            validateLabelDataEntryType(data,hasHierarchy,name,type);



            [TF,data]=cellfun(@(x)validateShapeData(x,type),data,...
            'UniformOutput',false);

            if~all([TF{:}])
                if type==labelType.Cuboid
                    error(message('vision:groundTruth:badCuboidData',name));
                end
            end



            labelData.(name)=data;

        case labelType.Line
            if~iscell(data)
                data=num2cell(data,2);
                labelData.(name)=data;
            end

            validateLabelDataEntryType(data,hasHierarchy,name,type);



            [TF,data]=cellfun(@(x)validateShapeData(x,type),data,...
            'UniformOutput',false);

            if~all([TF{:}])
                error(message('vision:groundTruth:badLineData',name))
            end

            labelData.(name)=data;

        case labelType.Scene
            if iscell(data)
                error(message('vision:groundTruth:badSceneData',name))
            end
            TF=islogical(data);
            if~all(TF)
                error(message('vision:groundTruth:badSceneData',name))
            end
        case lidarLabelType.Voxel
            if~(iscell(data)||isstring(data))
                error(message('lidar:groundTruthLidar:badVoxelLabelData',name));
            end

            TF=cellfun(@(x)validateVoxelLabelData(x),data);
            if~all(TF)
                error(message('lidar:groundTruthLidar:badVoxelLabelData',name));
            end
        end
    end
end
