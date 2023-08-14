function structtable=populateConceptualStructTable(h,structtable)









    tblData=cell(2,2);
    [nrows,~]=size(tblData);





    if isempty(h.cargstructfields)
        for rowIdx=1:nrows
            h.cargstructfields{rowIdx,1}='';
            h.cargstructfields{rowIdx,2}='double';

            if~isempty(h.object.ConceptualArgs)&&...
                h.isDataTypeStruct(h.object.ConceptualArgs(h.activeconceptarg).toString(true))
                emStructType=h.object.ConceptualArgs(h.activeconceptarg).Type;

                currElement=emStructType.Elements(rowIdx);
                try
                    tempArg=RTW.TflArgNumeric;
                    tempArg.Type=currElement.Type;
                    elemTypeStr=tempArg.toString;
                catch
                    errorMsg=DAStudio.message('CoderFoundation:tfl:UnsupportedDataType',...
                    currElement.Type.tostring);
                    ME=MException('tfl:UnsupportedDataType',errorMsg);
                    throw(ME);
                end


                dtypeentries=h.getentries('Tfldesigner_ConceptualStructDatatype');
                idx=find(ismember(dtypeentries,elemTypeStr),1);
                if isempty(idx)
                    h.cargcustomdtype=[h.cargcustomdtype,elemTypeStr];
                end


                h.cargstructfields{rowIdx,1}=currElement.Identifier;
                h.cargstructfields{rowIdx,2}=elemTypeStr;
            end
        end
    end

    for rowIdx=1:nrows
        fieldname.Type='edit';
        fieldname.Value=h.cargstructfields{rowIdx,1};

        fieldtype.Type='combobox';

        dtypeentries=h.getentries('Tfldesigner_ConceptualStructDatatype');
        idx=find(ismember(dtypeentries,h.cargstructfields{rowIdx,2}));

        assert(~isempty(idx));










        fieldtype.Entries=dtypeentries;
        fieldtype.Value=idx-1;
        fieldtype.Editable=true;

        tblData{rowIdx,1}=fieldname;
        tblData{rowIdx,2}=fieldtype;
    end

    structtable.Data=tblData;
