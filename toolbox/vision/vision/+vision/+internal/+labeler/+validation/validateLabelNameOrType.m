
function[labels,indices]=validateLabelNameOrType(labelDefs,labels,className)

    validateattributes(labels,...
    {'char','string','cell','labelType'},...
    {'nonempty','vector'},className,'label names or types');

    allLabelNames=labelDefs.Name;

    if any(string(labelDefs.Properties.VariableNames)=="SignalType")
        labelTypes=labelDefs.LabelType;
    else
        labelTypes=labelDefs.Type;
    end

    if isstring(labels)||ischar(labels)
        labels=cellstr(labels);
    end

    if iscellstr(labels)
        pixelLabels=allLabelNames(labelTypes==labelType.PixelLabel);

        if~isempty(intersect(labels,pixelLabels))
            error(message('vision:groundTruth:pixelLabelSelectByNameNotSupported'))
        end
    end

    if~(iscellstr(labels)||isa(labels,'labelType'))
        error(message('vision:groundTruth:invalidLabelSpecification'))
    end

    if isa(labels,'labelType')

        labType=labels;
        tempLabels={};
        for idx=1:numel(labType)
            tempLabels=[tempLabels;allLabelNames(labelTypes==labType(idx))];%#ok<AGROW>
        end
        labels=tempLabels;
        if isempty(labels)
            error(message('vision:groundTruth:typeNotPresent',char(labType)))
        end
    end


    labels=unique(labels,'stable');

    indices=labelName2Index(labelDefs,labels);
end

function indexList=labelName2Index(labelDefs,labelNames)



    allLabelNames=labelDefs.Name;


    indexList=zeros(numel(labelNames),1);
    for n=1:numel(labelNames)
        idx=find(strcmp(allLabelNames,labelNames{n}));
        if isempty(idx)
            error(message('vision:groundTruth:labelNotFound',labelNames{n}))
        end
        indexList(n)=idx(1);
    end
end