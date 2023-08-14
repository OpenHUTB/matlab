function out=getPreview(obj)





    comment=obj.getMemorySectionComment;
    preStatement=obj.getMemorySectionPreStatement;
    postStatement=obj.getMemorySectionPostStatement;

    returnType='<span class="cp_placeholder">[RETURN_TYPE]</span>';
    arguments='<span class="cp_placeholder">[ARGUMENTS]</span>';
    definitionSectionHeader=message('Simulink:dialog:CSCUIDeclaration').getString;
    declarationSectionHeader=message('Simulink:dialog:CSCUIDefinition').getString;


    functionName=obj.resolveFunctionNameToken(obj.getFunctionNamingRule);
    functionBody='...';


    definition=obj.getPreviewSectionDiv(...
    sprintf('<p class="previewHeader">%s</p>',definitionSectionHeader),...
    sprintf('%s%s%s%s',comment,preStatement,...
    ['<p>',returnType,' ',functionName,'(',arguments,');</p>'],postStatement));


    declaration=obj.getPreviewSectionDiv(...
    sprintf('<p class="previewHeader">%s</p>',declarationSectionHeader),...
    sprintf('%s%s%s%s',comment,preStatement,...
    ['<p>',returnType,' ',functionName,'(',arguments,') {</p>'...
    ,'<p class="tabIndent">',functionBody,'</p><p>}</p>'],postStatement));


    out=struct('previewStr',sprintf('<pre>%s</pre>',[definition,declaration]),...
    'type',obj.EntryType);


