function[selectedLabelNames,selectedLabelDefs]=validateGroupNames(groups,labeldefs,className)

    if nargin<3
        className='groundTruth';
    end

    validateattributes(groups,...
    {'char','string','cell'},...
    {'nonempty','vector'},className,'groups');

    allGroupNames=labeldefs.Group;

    if isstring(groups)||ischar(groups)
        groups=cellstr(groups);
    end


    groups=unique(groups,'stable');


    for idx=1:numel(groups)
        if~ismember(groups{idx},allGroupNames)
            error(message('vision:groundTruth:groupNotFound',groups{idx}));
        end
    end

    [~,indices]=ismember(allGroupNames,groups);

    labelIndices=find(indices);

    selectedLabelDefs=labeldefs(labelIndices,:);

    hasSignalType=any(string(labeldefs.Properties.VariableNames)=="SignalType");

    if~hasSignalType
        selectedLabelTypes=selectedLabelDefs.Type;
    else
        selectedLabelTypes=selectedLabelDefs.LabelType;
    end

    pixelLabelTypeIndices=(selectedLabelTypes==labelType.PixelLabel);

    labelIndices(pixelLabelTypeIndices)=[];
    nonPxlLabelDefs=labeldefs(labelIndices,:);
    selectedLabelNames=nonPxlLabelDefs.Name;

    if any(pixelLabelTypeIndices)
        selectedLabelNames{end+1}='PixelLabelData';
    end

    if ischar(selectedLabelNames)||isstring(selectedLabelNames)
        selectedLabelNames=cellstr(selectedLabelNames);
    end

end