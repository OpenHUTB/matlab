
function combinedGTruth=mergeCustomGroundTruth(baseGTruth,customStruct,...
    connectorDrivingSignalName)











    if~(isa(baseGTruth,'groundTruth')||isa(baseGTruth,'groundTruthMultisignal'))
        combinedGTruth=[];
    elseif(~isempty(customStruct))&&(~isempty(customStruct.CustomLabelData))

        customLabelName=customStruct.CustomLabelName;
        customLabelDesc=customStruct.CustomLabelDesc;
        customLabelData=customStruct.CustomLabelData;

        tableHeading=baseGTruth.LabelDefinitions.Properties.VariableNames;
        numLabels=numel(string(customLabelName));

        if~iscell(customLabelName)
            customLabelName=cellstr(customLabelName);
        end



        if isa(baseGTruth,'groundTruth')
            newLabelData=baseGTruth.LabelData;
            numSignals=1;
        else
            signalNames=fields(baseGTruth.ROILabelData);
            numSignals=numel(signalNames);
            newLabelData=baseGTruth.ROILabelData;
        end


        if~all(baseGTruth.LabelDefinitions.SignalType==vision.labeler.loading.SignalType.Custom)
            newLabelDefinitions=baseGTruth.LabelDefinitions;
        else
            newLabelDefinitions=[];
        end

        drivingSigIdx=find(contains(signalNames,connectorDrivingSignalName));

        for sigIdx=1:numSignals
            if isa(baseGTruth,'groundTruth')

                newLabelData_i=newLabelData;
            else
                newLabelData_i=newLabelData.(signalNames{sigIdx});
            end

            if sigIdx==drivingSigIdx
                for idx=1:numLabels




                    newTableRow=cell(size(tableHeading));



                    nameIdx=find(contains(tableHeading,'Name'),1);
                    if~isempty(nameIdx)
                        newTableRow{nameIdx}=customLabelName{idx};
                    end

                    signalTypeIdx=find(contains(tableHeading,'SignalType'),1);
                    if~isempty(signalTypeIdx)
                        newTableRow{signalTypeIdx}=vision.labeler.loading.SignalType.Custom;
                    end

                    typeIdx=find(startsWith(tableHeading,'Type')|contains(tableHeading,'LabelType'),1);
                    if~isempty(typeIdx)
                        newTableRow{typeIdx}=labelType.Custom;
                    end

                    grpIdx=find(contains(tableHeading,'Group'),1);
                    if~isempty(grpIdx)
                        newTableRow{grpIdx}='None';
                    end

                    descIdx=find(contains(tableHeading,'Description'),1);
                    if~isempty(descIdx)
                        try
                            if isempty(customLabelDesc{idx})
                                newTableRow{descIdx}='';
                            else
                                newTableRow{descIdx}=customLabelDesc{idx};
                            end
                        catch


                            newTableRow{descIdx}='';
                        end
                    end

                    hierIdx=find(contains(tableHeading,'Hierarchy'),1);
                    if~isempty(hierIdx)
                        newTableRow{hierIdx}=[];
                    end

                    pixIdx=find(contains(tableHeading,'PixelLabelData'),1);
                    if~isempty(pixIdx)
                        newTableRow{pixIdx}=[];
                    end

                    newTableRow=cell2table(newTableRow);
                    newTableRow.Properties.VariableNames=tableHeading;


                    newLabelDefinitions=[newLabelDefinitions;newTableRow];%#ok<AGROW>


                    newLabelData_i=[newLabelData_i,customLabelData{:,idx+1}];%#ok<AGROW>

                    newLabelData_i.Properties.VariableNames{end}=customLabelName{idx};
                end
            end
            newLabelData.(signalNames{sigIdx})=newLabelData_i;

        end

        if isa(baseGTruth,'groundTruth')
            combinedGTruth=groundTruth(baseGTruth.DataSource,newLabelDefinitions,newLabelData);
        else

            newLabelData=convertStruct2Cell(newLabelData);


            tmp=vision.labeler.labeldata.ROILabelData(signalNames,newLabelData);
            combinedGTruth=groundTruthMultisignal(baseGTruth.DataSource,newLabelDefinitions,tmp,baseGTruth.SceneLabelData);
        end
    else
        combinedGTruth=baseGTruth;
    end
end

function cellLabelData=convertStruct2Cell(stLabelData)

    signalNames=fields(stLabelData);
    numSignals=numel(signalNames);
    cellLabelData=cell(1,numSignals);
    for i=1:numSignals
        cellLabelData{i}=stLabelData.(signalNames{i});
    end
end
