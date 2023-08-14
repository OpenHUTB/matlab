function differentFields=compareStructures(structure1,structure2,varargin)



    ignoreFields={};
    if(nargin>2)
        ignoreFields=varargin{1};
    end

    differentFields={};
    allfields=union(fieldnames(structure1),fieldnames(structure2));
    allfields=setdiff(allfields,ignoreFields);
    for i=1:length(allfields)
        field=allfields{i};
        if~isfield(structure1,field)||...
            ~isfield(structure2,field)||...
            ~isequal(structure1.(field),structure2.(field))
            differentFields=[differentFields,{field}];%#ok<AGROW>
        end
    end
end
