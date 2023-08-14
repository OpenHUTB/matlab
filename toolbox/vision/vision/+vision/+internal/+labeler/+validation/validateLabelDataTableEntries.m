function labelData=validateLabelDataTableEntries(labelData,labelDefs,signalType)




    if nargin<3
        signalType=vision.labeler.loading.SignalType.Image;
    end

    hasHierarchy=~isempty(find(strcmpi(labelDefs.Properties.VariableNames,'Hierarchy'),1));

    import vision.internal.labeler.validation.*


    for n=1:width(labelData)
        name=labelData.Properties.VariableNames{n};
        if strcmp(name,'PixelLabelData')
            type=labelType.PixelLabel;
        elseif strcmp(name,'ROILabelData')
            labelData=validateROILabelDataTableEntries(labelData,labelDefs,signalType);
            continue;
        else
            hasSignalType=any(string(labelDefs.Properties.VariableNames)=="SignalType");
            if hasSignalType
                type=labelDefs.LabelType(strcmpi(labelDefs.Name,name));
                if type~=labelType.Custom
                    supportedLabelTypes=signalType.getSupportedLabelTypes;
                    type=type(ismember(type,supportedLabelTypes));
                end
            else
                type=labelDefs.Type(strcmpi(labelDefs.Name,name));
            end
        end
        data=labelData.(name);
        switch type(1)
        case{labelType.Rectangle,labelType.ProjectedCuboid,labelType.Cuboid}




            if~iscell(data)
                data=num2cell(data,2);
                labelData.(name)=data;
            end

            validateLabelDataEntryType(data,hasHierarchy,name,type);



            [TF,data]=cellfun(@(x)validateShapeData(x,type),data,...
            'UniformOutput',false);

            if~all([TF{:}])
                if type==labelType.Rectangle
                    error(message('vision:groundTruth:badRectData',name));
                elseif type==labelType.ProjectedCuboid
                    error(message('vision:groundTruth:badProjCuboidData',name));
                elseif type==labelType.Cuboid
                    error(message('vision:groundTruth:badCuboidData',name));
                end
            end



            labelData.(name)=data;

        case{labelType.Line,labelType.Polygon}
            if~iscell(data)
                data=num2cell(data,2);
                labelData.(name)=data;
            end

            validateLabelDataEntryType(data,hasHierarchy,name,type(1));



            [TF,data]=cellfun(@(x)validateShapeData(x,type(1)),data,...
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
        case labelType.PixelLabel
            if~(iscell(data)||isstring(data))
                error(message('vision:groundTruth:badPixelLabelData',name));
            end

            TF=cellfun(@(x)validatePixelLabelData(x),data);
            if~all(TF)
                error(message('vision:groundTruth:badPixelLabelData',name));
            end
        end
    end
end
