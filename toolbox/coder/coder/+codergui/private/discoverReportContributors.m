function contributors=discoverReportContributors(command)
















    persistent implClasses;

    if isempty(implClasses)
        rootImplClass=?coder.report.contrib.InferenceReportContributor;
        implClasses=rootImplClass.ContainingPackage.ClassList;
        implClasses={implClasses(implClasses<?coder.report.Contributor&implClasses~=rootImplClass).Name};
        implClasses=sortImplementations(rootImplClass,implClasses);
    end

    if nargin==0
        command='discover';
    else
        command=validatestring(command,{'discover','instantiate'});
    end

    switch command
    case 'instantiate'
        contributors=instantiateContributors(implClasses);
    otherwise
        contributors=implClasses(:,1);
    end
end




function contributors=instantiateContributors(classes)
    contributors=cell(0,2);
    for i=1:size(classes,1)
        className=classes{i,1};
        if isempty(which(className))
            continue;
        end
        depNames=classes{i,2};
        try
            if~isempty(depNames)&&nargin(className)~=0
                deps=cellfun(@(d)contributors{strcmp(d,contributors(:,1)),2},...
                depNames,'UniformOutput',false);
            else
                deps={};
            end
            contributors{end+1,2}=feval(className,deps{:});%#ok<AGROW>
            contributors{end,1}=className;
        catch me
            coder.internal.gui.asyncDebugPrint(me);
        end
    end
    contributors=contributors(:,2);
end





function ordered=sortImplementations(rootClass,contribClassNames)
    depMap=containers.Map();
    for i=1:numel(contribClassNames)
        contribClassName=contribClassNames{i};
        depMap(contribClassName)=getDependenciesFromClass(meta.class.fromName(contribClassName));
    end
    ordered={rootClass.Name,{}};
    cellfun(@(c)visitContributorNode(c,{}),contribClassNames);

    function visitContributorNode(contribClassName,visited)
        if ismember(contribClassName,ordered(:,1))
            return;
        elseif ismember(contribClassName,visited)
            error('Cyclical contributor dependency for "%s"',contribClassName);
        end
        depNames=depMap(contribClassName);
        if~isempty(depNames)
            visited{end+1}=contribClassName;
            cellfun(@(c)visitContributorNode(c,visited),depNames);
        end
        ordered(end+1,:)={contribClassName,depNames};
    end
end




function depNames=getDependenciesFromClass(implClass)
    depProp=implClass.PropertyList(arrayfun(@(p)isDependencyProp(implClass,p),implClass.PropertyList));
    if~isempty(depProp)
        depNames=depProp(end).DefaultValue;
        if~iscell(depNames)
            if~isempty(depNames)
                depNames={depNames};
            else
                depNames={};
            end
        end
    else
        depNames={};
    end
end




function matched=isDependencyProp(implClass,propDef)
    matched=propDef.Name=="InjectedDependencies"&&propDef.Constant&&...
    propDef.HasDefault&&strcmp(propDef.DefiningClass.Name,implClass.Name);
end