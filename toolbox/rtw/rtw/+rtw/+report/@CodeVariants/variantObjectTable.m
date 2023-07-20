function objectTable=variantObjectTable(obj,rptgenAPI)
    import mlreportgen.dom.*;
    codeVariantsRTWInfo=obj.Data;
    numVariantObjects=codeVariantsRTWInfo.NumSimulinkVariantObjects;


    numRows=0;
    for vo=1:numVariantObjects
        if numVariantObjects==1


            variantObject=codeVariantsRTWInfo.SimulinkVariantObject(vo);
            if(iscell(variantObject))
                variantObject=variantObject{1};
            end
        else


            variantObject=codeVariantsRTWInfo.SimulinkVariantObject{vo};
        end
        numRows=numRows+size(variantObject.ReferencedByBlockNames,1);
    end
    if numRows>0
        if rptgenAPI
            objectTable=Table(3);
            objectTable.StyleName='TableStyleAltRow';
            tblrow=TableRow();
            tblrow.append(TableEntry('Variant'));
            tblrow.append(TableEntry('Condition'));
            tblrow.append(TableEntry('Used in Blocks'));
            objectTable.append(tblrow);
        else
            objectTable=Advisor.Table(numRows,3);
            objectTable.setBorder(1);
            objectTable.setStyle('AltRow');
            objectTable.setColHeading(1,'Variant');
            objectTable.setColHeading(2,'Condition');
            objectTable.setColHeading(3,'Used in Blocks');
        end
        rowNum=1;
        nl=sprintf('\n');
        for vo=1:numVariantObjects
            if numVariantObjects==1
                variantObject=codeVariantsRTWInfo.SimulinkVariantObject(vo);
                if(iscell(variantObject))
                    variantObject=variantObject{1};
                end
            else
                variantObject=codeVariantsRTWInfo.SimulinkVariantObject{vo};
            end
            if rptgenAPI
                tblrow=TableRow();
                tblrow.append(TableEntry(variantObject.Name));
                tblrow.append(TableEntry(variantObject.Condition));
            else

                objectTable.setEntry(rowNum,1,variantObject.Name);

                objectTable.setEntry(rowNum,2,rtwprivate('rtwhtmlescape',variantObject.Condition));
            end


            blockNames=variantObject.ReferencedByBlockNames;

            blockSID=variantObject.ReferencedByBlockSID;
            numRefBlocks=size(blockNames,1);
            td3='';
            for rb=1:numRefBlocks
                blockName=deblank(blockNames(rb,:));
                modelBlockHTML=obj.getHyperlink(blockSID{rb},blockName);
                if rptgenAPI
                    td3=[td3,modelBlockHTML,nl];
                else
                    modelBlockNameElement=Advisor.Text(modelBlockHTML);
                    objectTable.setEntry(rowNum,3,modelBlockNameElement);
                end
                rowNum=rowNum+1;
            end
            if rptgenAPI
                tblrow.append(TableEntry(td3));
                objectTable.append(tblrow);
            end
        end
    else
        if rptgenAPI
            objectTable=Paragraph('(No Variant controls)');
        else
            objectTable=Advisor.Text('(No Variant controls)');
        end
    end
end
