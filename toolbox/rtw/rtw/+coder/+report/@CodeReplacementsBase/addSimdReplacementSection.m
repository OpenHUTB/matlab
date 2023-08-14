function addedContent=addSimdReplacementSection(obj)




    [usedFcns,mergeIdxs]=obj.getUsedFunctions('SIMD');
    addedContent=false;
    if~isempty(mergeIdxs)
        addedContent=true;
        contents=obj.createRepTable(usedFcns,mergeIdxs);
        p=Advisor.Paragraph;
        p.addItem([obj.getSimdReplacementIntro,' <br />']);
        obj.addSection('sec_simd_replacement',obj.getSimdReplacementTitle,p,contents)
    end
end
