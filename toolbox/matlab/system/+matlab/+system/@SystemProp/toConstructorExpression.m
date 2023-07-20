function expression=toConstructorExpression(obj,varargin)





    p=matlab.system.internal.getToExpressionInputParser;
    p.parse(varargin{:});
    doSplit=p.Results.Split;
    includeHidden=p.Results.IncludeHidden;
    defaults=p.Results.Defaults;

    validateattributes(obj,{class(obj)},{'2d'},'system.toConstructorExpression');


    if doSplit
        delim=[', ...',sprintf('\n')];
    else
        delim=',';
    end


    pvPairs='';
    if includeHidden
        specialIncludeAttributes={'Dependent','Transient','Hidden'};
    else
        specialIncludeAttributes={'Dependent','Transient'};
    end
    constructorPropertyNames=getPublicProperties(obj,specialIncludeAttributes,defaults);





    displayPropertyNames=getDisplayPropertyNames(obj);
    propertyNames=intersect(displayPropertyNames,constructorPropertyNames,'stable');
    propertyNames=[propertyNames;setdiff(constructorPropertyNames,displayPropertyNames,'stable')];

    numProps=numel(propertyNames);
    for k=1:numProps
        propName=propertyNames{k};


        propExpr=matlab.system.internal.toExpression(obj.get(propName),'Split',doSplit,'IncludeHidden',includeHidden);
        pvPairs=[pvPairs,'''',propName,''',',propExpr];

        if k<numProps
            pvPairs=[pvPairs,delim];
        end
    end

    expression=class(obj);
    if~isempty(pvPairs)
        expression=[expression,'(',pvPairs,')'];
    end

end

function displayPropertyNames=getDisplayPropertyNames(obj)

    displayPropertyNames={};
    if isa(obj,'matlab.system.SFunSystem')||isa(obj,'matlab.system.CoreBlockSystem')
        regularProps=obj.getDisplayPropertiesImpl;
        if~islogical(regularProps)
            displayPropertyNames=regularProps;



            fixedProps=obj.getDisplayFixedPointPropertiesImpl;
            if~islogical(fixedProps)
                displayPropertyNames=[displayPropertyNames,fixedProps];
            end
        end
    else
        groups=matlab.system.display.internal.Memoizer.getPropertyGroups(class(obj));
        for group=groups
            displayPropertyNames=[displayPropertyNames,group.getPropertyNames()];%#ok<*AGROW>
            if group.IsSectionGroup
                sections=group.Sections;
                for section=sections
                    displayPropertyNames=[displayPropertyNames,section.getPropertyNames()];
                end
            end
        end
    end
    displayPropertyNames=displayPropertyNames(:);
end