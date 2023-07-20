function out=libraryhandler(action,varargin)











    out={action};

    switch(action)
    case 'addUnit'
        out=addUnit(varargin{:});
    case 'addUnitPrefix'
        out=addUnitPrefix(varargin{:});
    case 'addAKL'
        out=addAKL(varargin{:});
    case 'removeUnit'
        removeFromLibrary('unit',varargin{:});
    case 'removeUnitPrefix'
        removeFromLibrary('unitprefix',varargin{:});
    case 'removeAKL'
        removeFromLibrary('kineticlaw',varargin{:});
    case 'configureUnit'
        out=configureUnit(varargin{:});
    case 'configureUnitPrefix'
        out=configureUnitPrefix(varargin{:});
    case 'configureAKL'
        out=configureAKL(varargin{:});
    end

end

function out=addUnit(input)


    out.name=input.name;
    out.composition=input.composition;
    out.multiplier=input.multiplier;
    out.message='';

    if ischar(input.multiplier)
        input.multiplier=str2double(input.multiplier);
    end


    unit=sbiounit(input.name,input.composition,input.multiplier);

    try
        sbioaddtolibrary(unit);
    catch ex
        out.message=SimBiology.web.internal.errortranslator(ex);
    end

end

function out=addUnitPrefix(input)


    out.name=input.name;
    out.exponent=input.exponent;
    out.message='';

    exponent=input.exponent;
    if ischar(exponent)
        exponent=str2double(exponent);
    end


    if~isnan(exponent)
        unit=sbiounitprefix(input.name,exponent);

        try
            sbioaddtolibrary(unit);
        catch ex
            out.message=SimBiology.web.internal.errortranslator(ex);
        end
    else
        out.message='Invalid exponent. Exponent must be numeric.';
    end

end

function out=addAKL(input)


    out.name=input.name;
    out.expression=input.expression;
    out.parameters={};
    out.species={};
    out.message='';
    out.property=input.property;

    warningID='SimBiology:UnableToParseAKL';
    originalWarning=warning('query',warningID);
    warning('off',warningID);

    akl=sbioabstractkineticlaw(input.name,input.expression);

    if~strcmpi(input.property,'expression')
        if isempty(input.parameters)
            input.parameters={};
        end

        if isempty(input.species)
            input.species={};
        end


        set(akl,'ParameterVariables',input.parameters);
        set(akl,'SpeciesVariables',input.species);

        out.parameters=input.parameters;
        out.species=input.species;
    else

        out.parameters=getparsedexpression(akl);
        set(akl,'ParameterVariables',out.parameters);
    end

    try
        sbioaddtolibrary(akl);
    catch ex
        out.message=SimBiology.web.internal.errortranslator(ex);
    end


    warning(originalWarning.state,warningID);

end

function out=configureUnit(input)

    root=sbioroot;
    names=get(root.UserDefinedLibrary.Units,{'Name'});

    if any(strcmp(input.oldName,names))
        sbioremovefromlibrary('unit',input.oldName);
    end

    out=addUnit(input);

end

function out=configureUnitPrefix(input)

    root=sbioroot;
    names=get(root.UserDefinedLibrary.UnitPrefixes,{'Name'});

    if any(strcmp(input.oldName,names))
        sbioremovefromlibrary('unitprefix',input.oldName);
    end

    out=addUnitPrefix(input);

end

function out=configureAKL(input)

    root=sbioroot;
    names=get(root.UserDefinedLibrary.KineticLaws,{'Name'});

    if any(strcmp(input.oldName,names))
        sbioremovefromlibrary('kineticlaw',input.oldName);
    end

    out=addAKL(input);

end

function removeFromLibrary(type,input)

    root=sbioroot;

    switch(type)
    case 'unit'
        names=get(root.UserDefinedLibrary.Units,{'Name'});
    case 'unitprefix'
        names=get(root.UserDefinedLibrary.UnitPrefixes,{'Name'});
    case 'kineticlaw'
        names=get(root.UserDefinedLibrary.KineticLaws,{'Name'});
    end

    for i=1:length(input.names)
        if any(strcmp(input.names{i},names))
            sbioremovefromlibrary(type,input.names{i});
        end
    end
end
