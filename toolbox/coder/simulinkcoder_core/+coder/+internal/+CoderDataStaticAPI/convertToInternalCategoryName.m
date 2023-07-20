function out=convertToInternalCategoryName(category)



    out=category;
    switch category
    case 'SelfDataStructure'
        out='ModelData';
    case 'ModelParameters'
        out='LocalParameters';
    case 'ModelParameterArguments'
        out='ParameterArguments';
    case 'ExternalParameterObjects'
        out='GlobalParameters';
    case 'ExternalParameters'
        out='GlobalParameters';
    end