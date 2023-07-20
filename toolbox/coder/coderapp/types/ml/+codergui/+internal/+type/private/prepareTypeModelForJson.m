function state=prepareTypeModelForJson(arg,state)




    narginchk(1,2);

    if isa(arg,'codergui.internal.type.TypeMaker')
        processTypeMaker(arg);
    elseif isa(arg,'codergui.internal.type.MetaTypeSchema')
        processSchema(arg);
    elseif isa(arg,'codergui.internal.type.TypeMakerEventData')
        processEvent(arg);
    elseif isa(arg,'codergui.internal.type.TypeApplet')
        processApplet(arg);
    else
        error('Unsupported argument type: %s',class(arg));
    end



    function processTypeMaker(typeMaker)
        processSchema(typeMaker.MetaTypeSchema);
        state.model.nodes=getJsonEncodableNodeState(typeMaker.Nodes);
        state.model.roots=num2cell([typeMaker.Roots.Id]);
    end

    function processSchema(schema)
        metaTypes=num2cell(codergui.evalprivate('filterObjectForJson',schema.MetaTypes,'CamelCase',true));
        for i=1:numel(metaTypes)
            metaType=schema.MetaTypes(i);

            metaTypes{i}.attributes=postProcessAttrDef(metaType.Attributes,metaTypes{i}.attributes,true);
            removals={};
            if~isempty(metaType.CustomSizeAttribute)
                metaTypes{i}.customSizeAttribute=postProcessAttrDef(metaType.CustomSizeAttribute);
            else
                removals{1}='customSizeAttribute';
            end
            if~isempty(metaType.ChildAddressAttribute)
                metaTypes{i}.childAddressAttribute=postProcessAttrDef(metaType.ChildAddressAttribute);
            else
                removals{end+1}='childAddressAttribute';%#ok<AGROW>
            end
            if~isempty(removals)
                metaTypes{i}=rmfield(metaTypes{i},removals);
            end
        end
        state.model.metaTypes=metaTypes;

        state.model.classAttributeDef=postProcessAttrDef(codergui.internal.type.AttributeDefs.Class);
        state.model.sizeAttributeDef=postProcessAttrDef(codergui.internal.type.AttributeDefs.Size);
        state.model.addressAttributeDef=postProcessAttrDef(codergui.internal.type.AttributeDefs.Address);

        state.model.boundClasses=schema.BoundClasses;
        if~codergui.internal.undefined(schema.UnboundClassWhitelist)
            state.model.unboundClassWhitelist=schema.UnboundClassWhitelist;
        end
    end

    function processEvent(event)
        state.rootChanges=convertChangeStruct("root",event.RootChanges);
        state.nodeChanges=convertChangeStruct("node",event.NodeChanges);
        state.defunctNodeIds=num2cell(event.RemovedNodeIds);

        if~isempty(event.AddedNodeIds)
            state.newNodes=getJsonEncodableNodeState(event.Source.getNodes(event.AddedNodeIds));
        else
            state.newNodes={};
        end
    end

    function processApplet(applet)
        state.applet.customBoundMetaTypes=applet.CustomEditTypes;
        state.applet.customBoundAttributes=applet.CustomEditAttributes;
    end
end


function converted=getJsonEncodableNodeState(nodes)
    if isempty(nodes)
        converted={};
        return
    end
    nodeStates=nodes.getTransientNodeState(true);

    converted=num2cell(nodeStates);
    classStates=sanitizeAttribute(nodes(1),{nodeStates.class});
    addrStates=sanitizeAttribute(nodes(1),{nodeStates.address});
    sizeStates=sanitizeAttribute(nodes(1),{nodeStates.size});

    removables={'class','address','size','attributes','children'};
    removeFilter=false(size(removables));

    for i=1:numel(nodeStates)
        converted{i}.children=num2cell(nodeStates(i).children);
        removeFilter(1:end)=false;
        if~isempty(classStates{i})
            converted{i}.class=classStates{i};
        else
            removeFilter(1)=true;
        end
        if~isempty(addrStates{i})
            converted{i}.address=addrStates{i};
        else
            removeFilter(2)=true;
        end
        if~isempty(sizeStates{i})
            converted{i}.size=sizeStates{i};
        else
            removeFilter(3)=true;
        end
        attrState=sanitizeAttribute(nodes(i),nodeStates(i).attributes);
        if~isempty(attrState)
            converted{i}.attributes=attrState;
        else
            removeFilter(4)=true;
        end
        if any(removeFilter)
            converted{i}=rmfield(converted{i},removables(removeFilter));
        end
        if~isempty(nodes(i).MetaType)
            converted{i}.metaTypeId=nodes(i).MetaType.Id;
        end
    end

    converted=codergui.internal.flattenForJson(converted);
end


function converted=sanitizeAttribute(node,attrState)
    if isempty(attrState)
        converted={};
        return
    elseif isstruct(attrState)
        attrState=num2cell(attrState);
    end

    undefined=codergui.internal.undefined();
    fields={'value','allowedValues','isVisible','isEnabled','max','min'};
    filter=false(size(fields));
    converted=attrState;
    lastAttrDef=[];

    for i=1:numel(attrState)
        if isempty(attrState{i})
            continue
        end
        for j=1:numel(fields)
            filter(j)=undefined==attrState{i}.(fields{j});
        end
        if any(filter)

            converted{i}=rmfield(converted{i},fields(filter));
        end
        if~all(filter(1:2))

            if isempty(lastAttrDef)||~strcmp(lastAttrDef.Key,attrState{i}.key)
                lastAttrDef=node.attr(attrState{i}.key);
                lastAttrDef=lastAttrDef.Definition;
            end
            if~filter(1)
                converted{i}.value=lastAttrDef.valueToPresentation(converted{i}.value,true).toStruct();
            end
            if~filter(2)
                converted{i}.allowedValues=convertMultipleValues(lastAttrDef,converted{i}.allowedValues);
            end
        end
    end
end


function converted=convertChangeStruct(changeFormat,changes)
    if isempty(changes)
        converted={};
        return
    end
    converted=changes;


    nodeIds=[converted.node];
    nodeIds=num2cell([nodeIds.Id]);
    [converted.node]=nodeIds{:};


    changeVals=[changes.type];
    changeTypes=cellstr(changeVals);
    [converted.type]=changeTypes{:};

    if changeFormat=="root"
        converted=num2cell(converted);
        return
    end
    assert(changeFormat=="node",'Allowed changeFormat values are "root" and "node"');


    hasAnnotations=~cellfun('isempty',{changes.annotations});
    for i=find(hasAnnotations)
        converted(i).annotations=num2cell(converted(i).annotations);
    end


    attrChangeFilter=changeVals==codergui.internal.type.ChangeType.Attribute;
    attrChanges=changes(attrChangeFilter);
    changedAttrs=cell(1,numel(attrChanges));
    for i=1:numel(attrChanges)
        changedAttrs{i}=attrChanges(i).node.attr(attrChanges(i).info);
    end
    changedAttrs=[changedAttrs{:}];
    if~isempty(changedAttrs)
        describedAttrs=num2cell(changedAttrs.describe(true,true));
        for i=1:numel(describedAttrs)
            describedAttrs{i}=sanitizeAttribute(changedAttrs(i).Node,describedAttrs{i});
        end
        describedAttrs=[describedAttrs{:}];
    else
        describedAttrs={};
    end
    [converted(attrChangeFilter).info]=describedAttrs{:};
    converted=num2cell(converted);
end


function attrDefStruct=postProcessAttrDef(attrDefs,attrDefStruct,toCell)
    if nargin<2
        attrDefStruct=codergui.evalprivate('filterObjectForJson',attrDefs,'CamelCase',true);
    end
    attrDefStruct=num2cell(attrDefStruct);
    for i=1:numel(attrDefs)
        attrDef=attrDefs(i);

        attrDefStruct{i}.valueType=attrDef.ValueType.Id;
        attrDefStruct{i}.initialValue=attrDef.valueToPresentation(attrDef.InitialValue,true).toStruct();
        if~isempty(attrDef.InitialAllowedValues)
            attrDefStruct{i}.initialAllowedValues=convertMultipleValues(attrDef,attrDef.InitialAllowedValues);
        end

        if~isempty(attrDef.Category)
            attrDefStruct{i}.category=struct(...
            'id',attrDef.Category.Identifier,...
            'name',attrDef.Category.getString());
        else
            attrDefStruct{i}=rmfield(attrDefStruct{i},'category');
        end
    end
    if nargin<3||~toCell
        attrDefStruct=[attrDefStruct{:}];
    end
end


function converted=convertMultipleValues(attrDef,values)
    converted=cell(1,numel(values));
    if~iscell(values)
        values=num2cell(values);
    end
    for i=1:numel(values)
        converted{i}=attrDef.valueToPresentation(values{i},true).toStruct();
    end
end
