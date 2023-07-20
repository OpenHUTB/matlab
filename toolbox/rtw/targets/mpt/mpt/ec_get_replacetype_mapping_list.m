function[repTypes,slTypes,varargout]=ec_get_replacetype_mapping_list(modelName)











    builtinRepTypes=get_param(modelName,'ReplacementTypes');
    builtinTypes=fieldnames(builtinRepTypes);
    varargout{1}=builtinRepTypes;

    slTypes={};
    repTypes={};
    for i=1:length(builtinTypes)
        rep=builtinRepTypes.(builtinTypes{i});
        if~isempty(rep)
            slTypes{end+1}=builtinTypes{i};
            repTypes{end+1}=rep;
        end
    end





