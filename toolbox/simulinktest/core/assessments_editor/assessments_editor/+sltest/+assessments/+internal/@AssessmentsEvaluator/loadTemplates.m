function templates=loadTemplates()
    templates=containers.Map('KeyType','char','ValueType','any');
    definitions=jsondecode(fileread(fullfile(matlabroot,'toolbox','simulinktest','core','assessments_editor','operator_definitions.json')));


    for category=definitions.categories'
        for operator=category.operators'
            if~isfield(operator,'code')
                continue;
            end

            assert(~isempty(operator.code),'code template must be non-empty');
            template.code=operator.code;

            assert(isfield(operator,'arguments'),'every operator with a code templates must have arguments');
            arguments=containers.Map('KeyType','char','ValueType','any');
            if~iscell(operator.arguments)

                operator.arguments=num2cell(operator.arguments);
            end
            for k=1:length(operator.arguments)
                arguments(operator.arguments{k}.label)=struct('index',k-1);
            end
            template.arguments=arguments;

            assert(isfield(operator,'template'),'every operator must have a text template');
            assert(~isempty(operator.template),'text template must be non-empty');
            template.text=operator.template;

            templates(operator.id)=template;
        end
    end
end
