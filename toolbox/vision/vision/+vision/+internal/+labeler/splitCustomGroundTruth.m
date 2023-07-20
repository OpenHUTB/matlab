
function[gTruthReg,gTruthCustom]=splitCustomGroundTruth(gTruth)













    [regLabelDef,customLabelDef]=vision.internal.labeler.splitCustomLabelDefinitions(gTruth.LabelDefinitions);

    if isa(gTruth,'groundTruthMultisignal')
        gTruthReg=gTruth;

        signalNames=[gTruth.DataSource.SignalName];
        [~,customLabelDataTable]=...
        splitRegularAndCustomLabelDataTable(...
        gTruth.ROILabelData.(signalNames(1)),gTruth.LabelDefinitions);
    else

        [regLabelDataTable,customLabelDataTable]=...
        splitRegularAndCustomLabelDataTable(...
        gTruth.LabelData,gTruth.LabelDefinitions);


        if~isempty(regLabelDef)
            gTruthReg=groundTruth(gTruth.DataSource,regLabelDef,regLabelDataTable);
        else
            gTruthReg=[];
        end
    end

    if~isempty(customLabelDef)
        gTruthCustom.CustomLabelName={customLabelDef.CustomLabelName};
        gTruthCustom.CustomLabelDesc={customLabelDef.CustomLabelDesc};
        gTruthCustom.CustomLabelData=customLabelDataTable;
    else
        gTruthCustom=[];
    end
end


function[regLabelDataTable,customLabelDataTable]=...
    splitRegularAndCustomLabelDataTable(LabelDataTable,definitions)

    regLabelDataTable=LabelDataTable;
    if istimetable(LabelDataTable)
        customLabelDataTable=timetable2table(LabelDataTable);
    elseif istable(LabelDataTable)
        customLabelDataTable=LabelDataTable;
    else
        assert(false,'splitCustomGroundTruth:splitRegularAndCustomLabelDataTable: Input must be a table or a timetable.');
    end

    if any(string(definitions.Properties.VariableNames)=="LabelType")
        typeCol='LabelType';
    else
        typeCol='Type';
    end


    if any(definitions.(typeCol)==labelType.PixelLabel)
        if ismember(customLabelDataTable.Properties.VariableNames,'PixelLabelData')
            customLabelDataTable.PixelLabelData=[];
        end
    end


    for idx=1:height(definitions)
        if(definitions.(typeCol)(idx)==labelType.Custom)

            regLabelDataTable.(definitions.Name{idx})=[];
        elseif(definitions.(typeCol)(idx)==labelType.PixelLabel)

            continue;
        else

            if iscell(definitions.Name(idx))
                if any(string(customLabelDataTable.Properties.VariableNames)==definitions.Name{idx})
                    customLabelDataTable.(definitions.Name{idx})=[];
                end
            else
                if any(string(customLabelDataTable.Properties.VariableNames)==definitions.Name)
                    customLabelDataTable.(definitions.Name)=[];
                end
            end
        end
    end
end