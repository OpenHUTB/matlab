function labelDefs=checkLabelDefinitions(labelDefs)






    validateattributes(labelDefs,{'table'},{'nonempty'},'groundTruth','LabelDefinitions');

    import vision.internal.labeler.validation.*

    numWidth=width(labelDefs);
    if(numWidth>=2&&numWidth<=7)


        type=labelDefs{:,2};
        if all(isa(type,'labelType'))
            hasPixelLabelType=any(type==labelType.PixelLabel);
        else
            error(message('vision:groundTruth:labelDefsMissingType'));
        end

        hasLabllHierarchy=hasLabelHierarchy(labelDefs);

        if hasPixelLabelType&&numWidth<3

            error(message('vision:groundTruth:labelDefsMissingPixelLabelID'));
        end


        columnNames=labelDefs.Properties.VariableNames;
        TF=rowfun(@(varargin)validateLabelDefEntry(columnNames,varargin{:}),labelDefs,...
        'OutputFormat','uniform','ExtractCellContents',true,...
        'NumOutputs',width(labelDefs));

        if~all(TF(:,1))
            error(message('vision:groundTruth:labelDefsInvalidLabelNames'))
        end

        if~all(TF(:,2))
            error(message('vision:groundTruth:labelDefsInvalidLabelType'))
        end

        hasDescription=hasLabelDescription(labelDefs);
        hasPixelLabel=hasPixelLabelID(labelDefs);
        hasGroup=hasLabelGroup(labelDefs);
        hasColor=hasLabelColor(labelDefs);


        expTableW=2+hasGroup+hasColor+double(hasDescription)+double(hasLabllHierarchy)+double(hasPixelLabel);


        if(numWidth~=expTableW)
            error(message('vision:groundTruth:invalidLabelDefinitionColumnsPixelLabel'));
        end

        if numWidth==expTableW

            colNum=expTableW;


            if hasLabllHierarchy
                idxHier=colNum;
                if~all(TF(:,idxHier))
                    if hasPixelLabelType
                        error(message('vision:groundTruth:labelHierarchyInvalidPixelLabelID'));
                    else
                        error(message('vision:groundTruth:labelHierarchyInvalidLabelDesc'));
                    end
                end
                colNum=colNum-1;
            end


            if hasDescription
                idxDes=colNum;
                if~all(TF(:,idxDes))
                    error(message('vision:groundTruth:labelDefsInvalidLabelDesc'));
                end
                colNum=colNum-1;
            end


            if hasGroup
                idxGroup=colNum;
                if~all(TF(:,idxGroup))
                    error(message('vision:groundTruth:labelDefsInvalidLabelGroup'));
                end
                colNum=colNum-1;
            end


            if hasPixelLabelType
                idxPxl=colNum;
                if~all(TF(:,idxPxl))
                    error(message('vision:groundTruth:labelDefsInvalidPixelLabelID'));
                end
                colNum=colNum-1;
            end


            if hasColor
                idxPxl=colNum;
                if~all(TF(:,idxPxl))
                    error(message('vision:groundTruth:labelDefsInvalidLabelColor'));
                end
            end
        end

        if hasPixelLabelType
            idxPixLblId=find(string(labelDefs.Properties.VariableNames)=="PixelLabelID");
            validatePixelLabelIds(labelDefs,idxPixLblId);
        end
    else
        error(message('vision:groundTruth:invalidLabelDefinitionColumns'))
    end

    [~,uniqueIdx]=unique(labelDefs(:,1));
    if numel(uniqueIdx)<height(labelDefs)
        error(message('vision:groundTruth:labelDefsNotUnique'))
    end



    idx=1;
    labelDefs.Properties.VariableNames{idx}='Name';
    idx=idx+1;
    labelDefs.Properties.VariableNames{idx}='Type';
    idx=idx+1;

    if hasColor
        labelDefs.Properties.VariableNames{idx}='LabelColor';
        idx=idx+1;
    end

    if hasPixelLabel
        labelDefs.Properties.VariableNames{idx}='PixelLabelID';
        idx=idx+1;
    end

    if hasGroup
        labelDefs.Properties.VariableNames{idx}='Group';
        idx=idx+1;
    else
        numElements=height(labelDefs);
        Group=repmat({'None'},[numElements,1]);
        labelDefs=addvars(labelDefs,Group,'After',idx-1);
        idx=idx+1;
    end

    if hasDescription
        labelDefs.Properties.VariableNames{idx}='Description';
        idx=idx+1;
    end

    if hasLabllHierarchy
        labelDefs.Properties.VariableNames{idx}='Hierarchy';
    end



    badLabelNames=vision.internal.labeler.validation.invalidNames(labelDefs{:,1});
    if~isempty(badLabelNames)
        error(message('vision:groundTruth:invalidName',badLabelNames));
    end
end

function TF=hasPixelLabelID(labelDefTable)


    columnExists=strcmp('PixelLabelID',labelDefTable.Properties.VariableNames);
    TF=any(columnExists);
end

function TF=hasLabelDescription(labelDefTable)


    columnExists=strcmp('Description',labelDefTable.Properties.VariableNames);
    TF=any(columnExists);
end

function TF=hasLabelGroup(labelDefTable)


    columnExists=strcmp('Group',labelDefTable.Properties.VariableNames);
    TF=any(columnExists);
end

function TF=hasLabelColor(labelDefTable)


    columnExists=strcmp('LabelColor',labelDefTable.Properties.VariableNames);
    TF=any(columnExists);
end

function TF=hasLabelHierarchy(labelDefTable)


    columnExists=strcmp('Hierarchy',labelDefTable.Properties.VariableNames);
    TF=any(columnExists);
end


