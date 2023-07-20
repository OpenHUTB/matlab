function labelData=checkLabelData(labelData,dataSource,labelDefs)










    import lidar.internal.labeler.validation.*

    types=labelDefs{:,2};
    isVoxelLabel=findVoxelLabels(types);

    if any(isVoxelLabel)
        numLabelDefs=height(labelDefs)-sum(isVoxelLabel)+1;
    else
        numLabelDefs=height(labelDefs);
    end

    if iscell(dataSource.Timestamp)
        numTimes=numel(dataSource.Timestamp{1});
        allowedLabelDataClass={'table','timetable'};
    else
        numTimes=numel(dataSource.SourceName);
        allowedLabelDataClass={'table'};
    end
    validateattributes(labelData,allowedLabelDataClass,{'nonempty','nrows',numTimes},'groundTruthLidar','LabelData');

    dataNames=labelData.Properties.VariableNames;
    defNames=labelDefs.Name;

    if any(isVoxelLabel)

        vxData=strcmp(dataNames,'VoxelLabelData');
        if~any(vxData)||sum(vxData)>1
            error(message('lidar:groundTruthLidar:labelDataMissingVoxelLabelData'))
        end


        dataNames(vxData)=[];
        defNames(isVoxelLabel)=[];
    end


    if~isempty(setdiff(dataNames,[defNames;{'ROILabelData'}]))
        error(message('vision:groundTruth:inconsistentLabelDefNames'))
    end


    try
        labelData=lidar.internal.lidarLabeler.validation.validateLabelDataTableEntries(labelData,...
        labelDefs,vision.labeler.loading.SignalType.PointCloud);
    catch ME
        msg=ME.message;
        if contains(msg,'Cuboid')
            error(message('lidar:groundTruthLidar:badCuboidData'));
        else
            error(msg);
        end
    end



    if iscell(dataSource.Timestamp)
        timestamps=dataSource.Timestamp{1};
        if size(timestamps,1)==1
            timestamps=timestamps';
        end
        s.TimeStamps=timestamps;
        if isa(labelData,'timetable')
            try
                vision.internal.labeler.validation.checkTimes(labelData,s);
            catch ME
                msg=ME.message;
                error(message('lidar:groundTruthLidar:ValidateLabelDataError',...
                msg));
            end

        else
            labelData=table2timetable(labelData,'RowTimes',s.TimeStamps);
        end
    end
end


function isVoxelLabel=findVoxelLabels(types)
    isVoxelLabel=zeros(numel(types),1);
    if iscell(types)
        for i=1:numel(types)
            if types{i}==lidarLabelType.Voxel
                isVoxelLabel(i)=true;
            end
        end
    else
        for i=1:numel(types)
            if types(i)==lidarLabelType.Voxel
                isVoxelLabel(i)=true;
            end
        end
    end
    isVoxelLabel=logical(isVoxelLabel);
end