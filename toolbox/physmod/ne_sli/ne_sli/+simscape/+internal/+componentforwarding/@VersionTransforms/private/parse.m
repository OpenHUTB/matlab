function componentTransforms=parse(xmlData)







    ch=xmlData.getChildNodes;
    components=ch.item(0);
    assert(strcmp(components.getTagName,'components'),'%s is an invalid update xml.  The tag of the root node must be ''comopents''');

    compChildren=components.getChildNodes;
    compChildren=compChildren.getElementsByTagName('component');

    for idx=0:(compChildren.getLength-1)
        c=compChildren.item(idx);
        compName=c.getAttribute('class');
        compName=strtrim(compName.toCharArray');

        assert(~isempty(compName),'%s is an invalid update xml.  Each component must have a class.')

        [targetClass,mappings,customTransform,startVersion,endVersion,targetVersion]=...
        parseComponentNode(c);
        if isempty(targetClass)
            targetClass=compName;
        end
        componentTransforms{idx+1}=...
        simscape.internal.componentforwarding.Transformation(...
        compName,targetClass,mappings,customTransform,startVersion,endVersion,targetVersion);%#ok<AGROW>
    end

end

function[targetClass,mappings,customTransform,startVersion,endVersion,targetVersion]=...
    parseComponentNode(compData)



    [startVersion,endVersion,targetVersion]=parseVersionNode(compData);


    targetClass=parseTargetClassNode(compData);


    customTransform=parseCustomTransform(compData);


    paramMappings=parseValueNodes(compData,'parameter');


    varMappings=parseValueNodes(compData,'variable');


    mappings=[paramMappings,varMappings];
end

function[startVersion,endVersion,targetVersion]=parseVersionNode(compData)
    start=compData.getAttribute('start');
    startVersion=getNumericVersion(start.toCharArray');
    stop=compData.getAttribute('end');
    endVersion=getNumericVersion(stop.toCharArray');
    stop=compData.getAttribute('target');
    targetVersion=getNumericVersion(stop.toCharArray');
end

function TargetClass=parseTargetClassNode(compData)

    nc=compData.getElementsByTagName('targetclass');
    assert(nc.getLength<=1,'simscape:compiler:sli:internal:parse:SingleTargetClassNode',...
    'There can only be 1 TargetClass node for each component update.');
    if nc.getLength>0
        it=nc.item(0);
        str=it.getAttribute('class');
        TargetClass=str.toCharArray';
    else
        TargetClass='';
    end

end

function customTransform=parseCustomTransform(compData)

    nc=compData.getElementsByTagName('customtransform');
    assert(nc.getLength<=1,'simscape:compiler:sli:internal:parse:SingleTargetClassNode',...
    'There can only be 1 CustomTransform node for each component update.');
    if nc.getLength>0
        it=nc.item(0);
        str=it.getAttribute('function');
        customTransform=str.toCharArray';
    else
        customTransform='';
    end

end

function values=parseValueNodes(compData,type)
    pc=compData.getElementsByTagName(type);

    values=repmat(struct('type',type,...
    'id',''...
    ,'substitution',''...
    ,'value',''...
    ,'unit',''...
    ,'priority',''),1,pc.getLength);
    for idx=1:pc.getLength
        it=pc.item(idx-1);
        id=lGetCharacterAttribute(it,'id');
        assert(lIsAttributeSet(id),'simscape:compiler:sli:internal:parse:NoParameterName',...
        sprintf('Nodes of type %s must have an ID attribute',type));

        subs=lGetCharacterAttribute(it,'substitution');
        value=lGetCharacterAttribute(it,'value');
        unit=lGetCharacterAttribute(it,'unit');
        priority=lGetCharacterAttribute(it,'priority');

        if lIsAttributeSet(subs)
            assert(~lIsAttributeSet(value),...
            'Cannot set substitution and value');
        elseif lIsAttributeSet(priority)
            assert(strcmp(type,'variable'),...
            'simscape:compiler:sli:internal:parse:BadPriority',...
            sprintf('Nodes of type %s can not have a PRIORITY attribute',type));
            values(idx).priority=priority;
        else
            assert(lIsAttributeSet(value)||...
            lIsAttributeSet(unit),...
            'At least one attribute of the %s entry must be set.',...
            type);
        end

        values(idx).type=type;
        values(idx).id=id;
        values(idx).substitution=subs;
        values(idx).value=value;
        values(idx).unit=unit;
        values(idx).priority=priority;

    end

end

function result=lIsAttributeSet(attributeValue)
    result=~isequal(attributeValue,...
    simscape.internal.componentforwarding.Transformation.UNSET_FIELD);
end

function result=lGetCharacterAttribute(item,attribute)

    persistent UNSET_FIELD
    if isempty(UNSET_FIELD)
        UNSET_FIELD=...
        simscape.internal.componentforwarding.Transformation.UNSET_FIELD;
    end

    resultObj=item.getAttribute(attribute);
    result=toCharArray(resultObj)';

    if isempty(result)
        result=UNSET_FIELD;
    end

end


function numericVersion=getNumericVersion(strVersion)
    numericVersion=str2double(regexp(strVersion,'\.','split'));
end