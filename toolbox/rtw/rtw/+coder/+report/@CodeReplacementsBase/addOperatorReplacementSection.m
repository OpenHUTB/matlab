function addedContent=addOperatorReplacementSection(obj,op,titleMsgId,introMsg)




    [usedFcns,mergeIdxs]=obj.getUsedFunctions(op);
    addedContent=false;
    if~isempty(mergeIdxs)
        addedContent=true;
        p=Advisor.Paragraph;
        p.addItem([introMsg,' <br />']);
        contents=obj.createRepTable(usedFcns,mergeIdxs);
        obj.addSection('sec_operator_replacement',obj.getMessage(titleMsgId),p,contents)
    end
end
