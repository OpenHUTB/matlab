




function variables=getImportableVariables()
    data=whos('global');
    variables=[];
    for i=1:numel(data)
        if strcmp(data(i).class,'coder.MexCodeConfig')...
            ||strcmp(data(i).class,'coder.EmbeddedCodeConfig')...
            ||strcmp(data(i).class,'coder.CodeConfig')

            variables(numel(variables)+1)=data(i).name;%#ok<AGROW>
        end
    end
end