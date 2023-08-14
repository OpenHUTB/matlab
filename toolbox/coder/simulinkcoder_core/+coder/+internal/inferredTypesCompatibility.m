function msg=inferredTypesCompatibility(modelName,compilerOutput)





    expr='^.*?tmwtypes\.h.*?$';

    tmwTypesLines=regexp(compilerOutput,expr,'lineanchors','match');


    expr1='redefinition';
    expr2='typedef';
    expr3='redefine';

    expr=sprintf('(%s)|(%s)|(%s)',expr1,expr2,expr3);

    matchResults=regexp(tmwTypesLines,expr,'match','once');

    found=~all(strcmp(matchResults,''));

    if found
        fixCmd=sprintf...
        ('set_param(''%s'', ''InferredTypesCompatibility'', ''on'')',...
        modelName);
        hyperlink=sprintf('<a href="matlab:%s">%s</a>',fixCmd,fixCmd);
        DAStudio.error('RTW:buildProcess:InferredTypesCompatibility',...
        hyperlink);
    else
        msg='';
    end


