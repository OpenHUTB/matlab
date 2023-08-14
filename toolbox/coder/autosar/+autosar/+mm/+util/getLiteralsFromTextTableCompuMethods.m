
function[literalNames,literalValues,result]=getLiteralsFromTextTableCompuMethods(m3iObj)





    toolId='ARXML_CompuMethodInfo';
    tok=regexp(m3iObj.getExternalToolInfo(toolId).externalId,'#','split');
    literalNames={};
    literalValues=[];
    result=false;
    for jj=2:numel(tok)
        if strcmp(tok(jj),'LiteralValue')
            literalValues=[literalValues,str2double(tok(jj+1))];%#ok<AGROW>
            result=true;
        elseif strcmp(tok(jj),'LiteralText')
            literalNames=[literalNames,tok(jj+1)];%#ok<AGROW>
        end
        jj=jj+1;%#ok<FXSET>
    end
end


