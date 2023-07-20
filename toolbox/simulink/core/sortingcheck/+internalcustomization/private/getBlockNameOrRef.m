function retStr=getBlockNameOrRef(blockH,getRef)



    blockName=get_param(blockH,'Name');
    fullName=getfullname(blockH);
    nl=sprintf('\n');
    dispBlkName=regexprep(blockName,nl,' ');

    if getRef
        codeBlkName=modeladvisorprivate('HTMLjsencode',fullName,'encode');
        codeBlkName=[codeBlkName{:}];

        retStr=['<a href="matlab:modeladvisorprivate(''hiliteSystem'',''',codeBlkName,''');"> ',dispBlkName,'</a>'];
    else
        retStr=dispBlkName;
    end

