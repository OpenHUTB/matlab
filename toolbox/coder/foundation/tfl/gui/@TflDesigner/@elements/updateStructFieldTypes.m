function updateStructFieldTypes(h)


    [nrows,~]=size(h.cargstructfields);

    for rowIdx=1:nrows
        dtype=h.cargstructfields{rowIdx,2};
        [formattedString,~]=h.formatNumericTypeString(dtype);

        dtypeentries=h.getentries('Tfldesigner_ConceptualStructDatatype');
        idx=find(ismember(dtypeentries,formattedString),1);
        if isempty(idx)
            h.cargcustomdtype=[h.cargcustomdtype,formattedString];
        end
    end