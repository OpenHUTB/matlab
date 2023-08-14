function out=showDynamicDependencyGraph(inarg,allProps)





    if(nargin==1)&&ischar(inarg)
        [controllerProps,allProps]=getDataFromClass(inarg);
    elseif(nargin==2)&&isstruct(inarg)&&iscellstr(allProps)%#ok<ISCLSTR>
        controllerProps=processDataFromError(inarg);
    else
        return
    end

    if isempty(allProps)
        return
    end

    propGraph=digraph;
    propGraph=addnode(propGraph,allProps);

    for prop=controllerProps(:)'
        for target=prop.ControlledDynamicEnumerations(:)'
            propGraph=addedge(propGraph,char(target),prop.Name);
        end
    end

    fig=figure;

    plot(propGraph);

    if nargout>0
        out=fig;
    end
end


function[controllerPropData,allPropNames]=getDataFromClass(className)
    metaClass=meta.class.fromName(className);
    if isempty(metaClass)
        return
    end

    properties=metaClass.PropertyList;

    dynamicProps=properties([properties.DynamicEnumeration]);
    controllerProps=properties(arrayfun(@(prop)~isempty(prop.ControlledDynamicEnumerations),properties));

    allPropNames=union({dynamicProps.Name},{controllerProps.Name});


    controllerPropData=struct('Name',{controllerProps.Name}',...
    'ControlledDynamicEnumerations',{controllerProps.ControlledDynamicEnumerations}');
end

function controllerProps=processDataFromError(controllerProps)
    for n=1:numel(controllerProps)
        controllerProps(n).ControlledDynamicEnumerations=string(controllerProps(n).ControlledDynamicEnumerations);
    end
end
