function addedContent=addFunctionReplacementSection(obj)




    [usedFcns,mergeIdxs]=obj.getUsedFunctions('');
    addedContent=false;
    if~isempty(mergeIdxs)
        addedContent=true;
        contents=obj.createRepTable(usedFcns,mergeIdxs);
        p=Advisor.Paragraph;
        p.addItem([obj.getCodeReplacmentsIntro,' <br />']);
        obj.addSection('sec_function_replacement',obj.getFunctionReplacmentTitle,p,contents)
    end
end
