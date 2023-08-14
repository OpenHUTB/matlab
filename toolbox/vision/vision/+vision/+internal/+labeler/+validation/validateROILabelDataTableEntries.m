function labelData=validateROILabelDataTableEntries(labelData,labelDefs,signalType)

    if nargin<3
        signalType=vision.labeler.loading.SignalType.Image;
    end

    hasHierarchy=~isempty(find(strcmpi(labelDefs.Properties.VariableNames,'Hierarchy'),1));%#ok<NASGU>


    removeIdx=((labelDefs.Type==labelType.Scene)|(labelDefs.Type==labelType.PixelLabel));

    labelTypes=labelDefs{~removeIdx,2};


    if(~any(strcmp(labelData.Properties.VariableNames,'ROILabelData')))
        assert(false,'No column names ROILabelData');
    end

    roiLabelData=labelData.ROILabelData;


    supportedFieldNames=arrayfun(@(x){getROILabelDataFieldName(x)},unique(labelTypes));

    roiLabelData=arrayfun(@(x)validateROILabelDataStruct(x,supportedFieldNames,labelDefs),roiLabelData,'UniformOutput',true);

    labelData.ROILabelData=roiLabelData;
end

function datum=validateROILabelDataStruct(datum,supportedFieldNames,labelDefs)

    import vision.internal.labeler.validation.*

    if(iscell(datum))
        if(isempty(datum{1}))
            return;
        end
    end

    if(isempty(datum))
        return;
    end


    if(~isstruct(datum))
        error(message('vision:groundTruth:badROILabelData'));
    end


    fields=fieldnames(datum);
    isValidFields=cellfun(@(x)any(strcmp(x,supportedFieldNames)),...
    fields,'UniformOutput',false);

    if(~all(cell2mat(isValidFields)))
        error(message('vision:groundTruth:badROILabelDataField'));
    end

    labelTypes=labelDefs{:,2};
    labelNames=labelDefs{:,1};


    for idx=1:numel(fields)

        currentLabelType=getROILabelTypeFromFieldName(fields{idx});
        supportedLabelNames=labelNames(labelTypes==currentLabelType);


        roiLabelNames=unique(datum.(fields{idx})(:,2));

        isvalidLabelnames=cellfun(@(x)any(strcmp(x,supportedLabelNames)),...
        roiLabelNames);

        if(~all(isvalidLabelnames))
            error(message('vision:groundTruth:badROILabelDataLabelName'));
        end


        roiData=datum.(fields{idx})(:,1);

        if~iscell(roiData)
            assert(false,'Should be Cell');
        end



        [TF,roiData]=cellfun(@(x)validateShapeData(x,currentLabelType),roiData,...
        'UniformOutput',false);
        datum.(fields{idx})(:,1)=roiData;

        if~all([TF{:}])
            name='ROILabelData';
            switch currentLabelType
            case labelType.Rectangle
                error(message('vision:groundTruth:badRectData',[name,'.RectangleData']));
            case labelType.ProjectedCuboid
                error(message('vision:groundTruth:badProjCuboidData',[name,'.ProjCuboidData']));
            case labelType.Line
                error(message('vision:groundTruth:badLineData',[name,'.LineData']));
            case labelType.Polygon
                error(message('vision:groundTruth:badPolygonData',[name,'.PolygonData']));
            end
        end

    end
end

function fieldName=getROILabelDataFieldName(labeltype)

    switch labeltype
    case labelType.Rectangle
        fieldName='RectangleData';

    case labelType.Line
        fieldName='LineData';

    case labelType.Polygon
        fieldName='PolygonData';

    case labelType.ProjectedCuboid
        fieldName='ProjCuboidData';

    case labelType.PixelLabel
        fieldName='PixelLabelData';
    case labelType.Custom
        fieldName='CustomData';
    otherwise
        error('Error');
    end
end

function labeltype=getROILabelTypeFromFieldName(fieldName)

    switch fieldName
    case 'RectangleData'
        labeltype=labelType.Rectangle;
    case 'LineData'
        labeltype=labelType.Line;
    case 'PolygonData'
        labeltype=labelType.Polygon;
    case 'ProjCuboidData'
        labeltype=labelType.ProjectedCuboid;
    case 'CustomData'
        labeltype=labelType.Custom;
    otherwise
        error('Error');
    end
end