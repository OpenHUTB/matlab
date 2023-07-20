function labelDefs=checkLabelDefinitions(labelDefs)









    validateattributes(labelDefs,{'table'},{'nonempty'},'groundTruthMultisignal','LabelDefinitions');

    import vision.internal.labeler.validation.*

    validateattributes(labelDefs,{'table'},{'nonempty'},mfilename,'LabelDefinitions');


    tableColumns=string(labelDefs.Properties.VariableNames);
    requiredColumns=["Name","SignalType","LabelType"];

    isReqVariableExist=all(ismember(requiredColumns,tableColumns));

    if~isReqVariableExist
        error(vision.getMessage('driving:groundTruthMultiSignal:LabelDefsRequiredNotExist'));
    end



    hasPixelLabel=any(labelDefs.LabelType==labelType.PixelLabel);
    pixelLabelColumn=(tableColumns=="PixelLabelID");
    hasPixelLabelColumn=any(pixelLabelColumn);
    isSinglePixelColumn=sum(pixelLabelColumn);

    if hasPixelLabel
        if~hasPixelLabelColumn
            error(message('vision:groundTruth:labelDefsMissingPixelLabelID'));
        end

        if~isSinglePixelColumn
            error(vision.getMessage('driving:groundTruthMultiSignal:LabelDefsInvalidPixelColumns'));
        end
    end


    TF=rowfun(@(varargin)validateLabelDefEntry(tableColumns,varargin{:}),labelDefs,...
    'OutputFormat','uniform','ExtractCellContents',true,...
    'NumOutputs',width(labelDefs));

    for idx=1:numel(tableColumns)
        columnName=tableColumns(idx);

        if~all(TF(:,idx))
            switch columnName
            case "Name"
                error(message('vision:groundTruth:labelDefsInvalidLabelNames'));
            case "SignalType"
                error(message('driving:groundTruthMultiSignal:LabelDefsInvalidSignalType'));
            case "LabelType"
                error(message('vision:groundTruth:labelDefsInvalidLabelType'));
            case "Group"
                error(message('vision:groundTruth:labelDefsInvalidLabelGroup'));
            case "Description"
                error(message('vision:groundTruth:labelDefsInvalidLabelDesc'));
            case "PixelLabelID"
                error(message('vision:groundTruth:labelDefsInvalidPixelLabelID'));
            case "Hierarchy"
                error(message('driving:groundTruthMultiSignal:LabelDefsInvalidSignalType'));
            case "LabelColor"
                error(vision.getMessage('driving:groundTruthMultiSignal:LabelDefsInvalidColor'));
            end
        end

    end


    for labelId=1:height(labelDefs)
        signalType=labelDefs.SignalType(labelId);
        currentLabelType=labelDefs.LabelType(labelId);

        supportedLabelTypes=signalType.getSupportedLabelTypes();
        if~any(supportedLabelTypes==currentLabelType)
            errorStr=strjoin(string(supportedLabelTypes),newline);

            error(message('driving:groundTruthMultiSignal:LabelDefsInvalidSignalAndLabelType',...
            string(signalType),errorStr));
        end
    end

    if hasPixelLabel
        idxPixLblId=find(pixelLabelColumn,1);
        validatePixelLabelIds(labelDefs,idxPixLblId);
    end


    isRectangleLabels=labelDefs.LabelType==labelType.Rectangle;
    isCuboidLabels=labelDefs.LabelType==labelType.Cuboid;
    isLineLabels=labelDefs.LabelType==labelType.Line;
    isPointCloudSignal=labelDefs.SignalType==vision.labeler.loading.SignalType.PointCloud;
    isPCLineLabels=isLineLabels&isPointCloudSignal;

    rectangleLabelNames=string(labelDefs.Name(isRectangleLabels));
    cuboidLabelNames=string(labelDefs.Name(isCuboidLabels));

    if rectangleLabelNames~=cuboidLabelNames
        error(vision.getMessage('driving:groundTruthMultiSignal:LabelDefsInvalidEquivalentTypes'));
    end

    filteredLabelDef=labelDefs(~(isCuboidLabels|isPCLineLabels),:);
    [~,uniqueIdx]=unique(filteredLabelDef.Name(:));
    if numel(uniqueIdx)<height(filteredLabelDef)
        error(message('vision:groundTruth:labelDefsNotUnique'))
    end



    badLabelNames=vision.internal.labeler.validation.invalidNames(labelDefs{:,1});
    if~isempty(badLabelNames)
        error(message('vision:groundTruth:invalidName',badLabelNames));
    end
end
