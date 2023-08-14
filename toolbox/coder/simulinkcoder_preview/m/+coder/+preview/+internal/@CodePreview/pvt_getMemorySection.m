


function[msComment,msPreStatement,msPostStatement]=pvt_getMemorySection(obj,...
    property,...
    comment,...
    prePragma,...
    postPragma)



    msComment='';
    msPreStatement='';
    msPostStatement='';

    if~isempty(comment.string)
        tooltipStr=comment.tooltip;
        classStr='comment';
        propertyStr=property;
        previewStr=obj.escapeHTML(comment.string);
        msComment=[obj.getPropertyPreview(tooltipStr,classStr,propertyStr,previewStr),newline];
    end
    if~isempty(prePragma.string)
        tooltipStr=prePragma.tooltip;
        classStr='';
        propertyStr=property;
        previewStr=obj.escapeHTML(prePragma.string);
        msPreStatement=[obj.getPropertyPreview(tooltipStr,classStr,propertyStr,previewStr),newline];
    end
    if~isempty(postPragma.string)
        tooltipStr=postPragma.tooltip;
        classStr='';
        propertyStr=property;
        previewStr=obj.escapeHTML(postPragma.string);
        msPostStatement=obj.getPropertyPreview(tooltipStr,classStr,propertyStr,previewStr);
    end
end
