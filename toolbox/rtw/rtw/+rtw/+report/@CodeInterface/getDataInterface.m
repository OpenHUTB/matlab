function out=getDataInterface(obj,data,srcHeading)
    import mlreportgen.dom.*
    if isempty(data)
        out=[];
        return
    end
    aTable=Table(4);

    aRow=TableRow();
    aRow.append(TableEntry(srcHeading));
    aRow.append(TableEntry(DAStudio.message('RTW:codeInfo:reportCodeIdentifierHeading')));
    aRow.append(TableEntry(DAStudio.message('RTW:codeInfo:reportDataTypeHeading')));
    aTableEntry=TableEntry(DAStudio.message('RTW:codeInfo:reportDimensionHeading'));

    aRow.append(aTableEntry);
    aTable.append(aRow);

    dash=Text('-');
    customStorage=Text(DAStudio.message('RTW:codeInfo:reportCustomStorage'));
    customStorage.Style={Italic()};
    for k=1:length(data)
        aRow=TableRow();
        aRow.append(TableEntry(obj.getGraphicalPath(data(k))));
        aTableEntry=TableEntry();
        varImp=data(k).Implementation;
        if~isempty(varImp)
            if varImp.isDefined
                identifier=Text(varImp.getExpression);
                aTableEntry.append(identifier);
            else
                if isa(varImp,'RTW.AutosarExpression')
                    switch(varImp.DataAccessMode)
                    case{'ExplicitSend','ImplicitSend'}
                        identifier=Text(DAStudio.message('RTW:codeInfo:reportProvidePort'));
                    case{'ExplicitReceive','ImplicitReceive','QueuedExplicitReceive'}
                        identifier=Text(DAStudio.message('RTW:codeInfo:reportRequirePort'));
                    case{'ModeReceive'}
                        identifier=Advisor.Text(DAStudio.message('RTW:codeInfo:reportModeRequirePort'));
                    case{'ErrorStatus'}
                        identifier=Text(DAStudio.message('RTW:codeInfo:reportErrorStatus'));
                    case{'Calibration'}
                        identifier=Text(DAStudio.message('RTW:codeInfo:reportCalibration'));
                    otherwise
                        identifier=Text(DAStudio.message('RTW:codeInfo:reportDefinedExternally'));
                    end
                    identifier.Style={Italic};
                    aTableEntry.append(identifier);
                elseif isa(varImp,'RTW.Variable')&&isequal(varImp.StorageSpecifier,'extern')
                    myText=Text(DAStudio.message('RTW:codeInfo:reportImportedData'));
                    myText.Style={Italic()};
                    aTableEntry.append(myText);
                    aTableEntry.append(Text(varImp.Identifier));
                elseif isa(varImp,'RTW.CustomExpression')
                    identifier=Text(DAStudio.message('RTW:codeInfo:reportImported'));
                    identifier.Style={Ialic()};
                    aTableEntry.append(identifier);
                else
                    identifier=Text(DAStudio.message('RTW:codeInfo:reportDefinedExternally'));
                    identifier.Style={Italic()};
                    aTableEntry.append(identifier);
                end
            end
            aRow.append(aTableEntry);
            aRow.append(TableEntry(getTypeIdentifier(data(k).Implementation.Type)));
            aTableEntry=TableEntry();

            if isa(data(k).Implementation.Type,'embedded.matrixtype')&&data(k).Implementation.Type.getWidth>1

                aTableEntry.append(Text(['[',num2str(data(k).Implementation.Type.Dimensions),']']));
            else

                aTableEntry.append(Text(num2str(data(k).Implementation.Type.getWidth)));
            end

            aRow.append(aTableEntry);
        else

            aRow.append(customStorage);
            aRow.append(dash);
            aRow.append(dash);
        end
        aTable.append(aRow);
    end
    aTable.StyleName='TableStyleAltRow';
    out=aTable;
end
