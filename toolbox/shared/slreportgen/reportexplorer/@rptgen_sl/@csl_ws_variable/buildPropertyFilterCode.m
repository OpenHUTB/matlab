function filterCode=buildPropertyFilterCode(this)


    filterCode='';

    variableDelimiter='';

    keys=this.filteredPropHash.keys;
    for i=1:length(keys)

        variableName=keys{i};
        propertyNames=this.filteredPropHash(variableName);

        if(~isempty(propertyNames))

            variableNameCheck='';


            if(~strcmp(variableName,'*'))
                variableNameCheck=['strcmpi( class(variableObject), ''',variableName,''') &&'];
            end

            filterCode=[filterCode,...
            variableDelimiter,char(10),char(9),'(',variableNameCheck,'( ...'];

            propDelimiter='';

            for j=1:length(propertyNames)

                filterCode=[filterCode,...
                propDelimiter,char(10),char(9),char(9),'(strcmpi(propertyName, ''',propertyNames{j},'''))'];

                propDelimiter=' || ...';
            end

            filterCode=[filterCode,'))'];

            variableDelimiter=' || ...';
        end
    end

    if(~isempty(filterCode))
        filterCode=['isFiltered = ...',filterCode,';'];
    end


