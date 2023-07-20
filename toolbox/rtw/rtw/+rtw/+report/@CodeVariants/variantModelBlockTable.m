function modelBlockTable=variantModelBlockTable(obj,blockType,col1Heading,col3Heading,rptgenAPI)
    import mlreportgen.dom.*;
    codeVariantsRTWInfo=obj.Data;
    numVariantGroups=codeVariantsRTWInfo.NumCodeVariantGroups;


    numRows=0;
    for vg=1:numVariantGroups
        if numVariantGroups==1


            variantGroup=codeVariantsRTWInfo.CodeVariantGroup(vg);
        else


            variantGroup=codeVariantsRTWInfo.CodeVariantGroup{vg};
        end
        if strcmp(variantGroup.NonExpandedBlockType,blockType)
            numRows=numRows+variantGroup.NumExpandedBlocks;
        end
    end
    if numRows>0
        if rptgenAPI
            modelBlockTable=Table(3);
            modelBlockTable.StyleName='TableStyleAltRow';
            tblrow=TableRow();
            tblrow.append(TableEntry(col1Heading));
            tblrow.append(TableEntry('Variant'));
            tblrow.append(TableEntry(col3Heading));
            modelBlockTable.append(tblrow);
        else
            modelBlockTable=Advisor.Table(numRows,3);
            modelBlockTable.setBorder(1);
            modelBlockTable.setStyle('AltRow');
            modelBlockTable.setColHeading(1,col1Heading);
            modelBlockTable.setColHeading(2,'Variant');
            modelBlockTable.setColHeading(3,col3Heading);
        end
        rowNum=1;
        nl=sprintf('\n');
        for vg=1:numVariantGroups
            if numVariantGroups==1


                variantGroup=codeVariantsRTWInfo.CodeVariantGroup(vg);
            else


                variantGroup=codeVariantsRTWInfo.CodeVariantGroup{vg};
            end
            if strcmp(variantGroup.NonExpandedBlockType,blockType)
                modelBlockHTML=obj.getHyperlink(variantGroup.NonExpandedBlockSID,variantGroup.NonExpandedBlockName);
                if rptgenAPI
                    tblrow=TableRow();
                    tblrow.append(TableEntry(modelBlockHTML));
                else
                    modelBlockNameElement=Advisor.Text(modelBlockHTML);

                    modelBlockTable.setEntry(rowNum,1,modelBlockNameElement);
                end
                td2='';
                td3='';
                numVariantsInGroup=variantGroup.NumExpandedBlocks;
                for gv=1:numVariantsInGroup
                    if numVariantsInGroup==1
                        expandedBlock=variantGroup.ExpandedBlock(gv);
                    else
                        expandedBlock=variantGroup.ExpandedBlock{gv};
                    end

                    variantCondition=expandedBlock.VariantCondition;
                    if rptgenAPI
                        td2=[td2,variantCondition,nl];%#ok<*AGROW>
                    else
                        modelBlockTable.setEntry(rowNum,2,rtwprivate('rtwhtmlescape',variantCondition));
                    end
                    blockReference='';
                    if rptgenAPI

                        if isfield(expandedBlock,'ChoiceBlockSID')
                            choiceBlockHTML=obj.getHyperlink(expandedBlock.ChoiceBlockSID,expandedBlock.ChoiceBlockName);
                            blockReference=choiceBlockHTML;
                        elseif isfield(expandedBlock,'ReferencedModel')
                            blockReference=expandedBlock.ReferencedModel;
                        end
                        td3=[td3,blockReference,nl];
                    else

                        if isfield(expandedBlock,'ChoiceBlockSID')
                            choiceBlockHTML=obj.getHyperlink(expandedBlock.ChoiceBlockSID,expandedBlock.ChoiceBlockName);
                            blockReference=Advisor.Text(choiceBlockHTML);
                        elseif isfield(expandedBlock,'ReferencedModel')
                            blockReference=rtwprivate('rtwhtmlescape',expandedBlock.ReferencedModel);
                        end
                        modelBlockTable.setEntry(rowNum,3,blockReference);
                    end
                    rowNum=rowNum+1;
                end
                if rptgenAPI
                    tblrow.append(TableEntry(td2));
                    tblrow.append(TableEntry(td3));
                    modelBlockTable.append(tblrow);
                end
            end
        end
    else
        if rptgenAPI
            modelBlockTable=Paragraph(['(No ',blockType,' blocks that have Variants)']);
        else
            modelBlockTable=Advisor.Text(['(No ',blockType,' blocks that have Variants)']);
        end
    end
end
