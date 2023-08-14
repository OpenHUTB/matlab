function d=load_transforms()






    f=which('-all','pmcomponentupdates.xml');


    p=matlab.io.xml.dom.Parser;
    p.Configuration.AllowDoctype=true;
    p.Configuration.ValidateIfSchema=true;
    p.Configuration.Comments=false;
    p.Configuration.ElementContentWhitespace=false;


    d=[];
    for idx=1:numel(f)
        xmlData=p.parseFile(f{idx});
        d=[d,lExtractTransforms(xmlData.Children(2).Children)];%#ok<AGROW>
    end

end

function t=lExtractTransforms(comps)

    import simscape.internal.componentforwarding.Transformation
    nComps=numel(comps);

    for iComp=1:nComps
        c=comps(iComp);
        a=lAttributes2Struct(c.getAttributes());
        for iAttribute=1:numel(a)
            d.(a(iAttribute).Name)=a(iAttribute).Value;
        end
        startVersion=lNumeric(d.start);
        endVersion=lNumeric(d.end);
        targetVersion=lNumeric(d.target);
        xForm=lExtractTransform(c.Children);

        targetClass=xForm.TargetClass;
        if isempty(targetClass)
            targetClass=d.class;
        end

        if isfield(xForm,'LegacyBlockClass')


            xForm.CustomTransform=@(x)feval(xForm.LegacyBlockClass).forward(x);
            simscape.internal.upgradeadvisor.LegacyBlock.register(xForm.LegacyBlockClass);
        end

        t(iComp)=Transformation(d.class,targetClass,xForm.Mappings,...
        xForm.CustomTransform,startVersion,endVersion,targetVersion);%#ok<AGROW>
    end
end

function numericVersion=lNumeric(strVersion)
    numericVersion=str2double(regexp(strVersion,'\.','split'));
end

function d=lExtractTransform(children)
    mappings=[];
    d.CustomTransform='';
    d.TargetClass='';
    for idx=1:numel(children)
        ch=children(idx);
        type=ch.TagName;
        switch type
        case 'parameter'
            m=lMapping(ch);
            assert(isempty(m.priority));
            mappings=[mappings,m];%#ok<AGROW>
        case 'variable'
            m=lMapping(ch);
            mappings=[mappings,m];%#ok<AGROW>
        case 'targetclass'
            d.TargetClass=lRequireAttribute(ch,'class');
        case 'customtransform'
            d.CustomTransform=lRequireAttribute(ch,'function');
        case 'legacyblock'
            d.LegacyBlockClass=lRequireAttribute(ch,'class');
        otherwise



            error('physmod:ne_sli:componentupdates:UnrecognizedField',...
            'Invalid pmcomponentupdates.xml. Unsupported component child type ''%s''.',type);
        end
    end
    d.Mappings=mappings;
end

function value=lRequireAttribute(ch,name)
    atr=lAttributes2Struct(ch.getAttributes());
    assert(isscalar(atr)&&strcmp(atr.Name,name));
    value=atr.Value;
end

function s=lMapping(ch)
    s=lMappingStruct(ch.TagName);
    atr=lAttributes2Struct(ch.getAttributes());
    for iAttribute=1:numel(atr)
        s.(atr(iAttribute).Name)=atr(iAttribute).Value;
    end


    assert(isvarname(s.id),...
    '''%s'' is an invalid ''id''. Must be a non-empty, valid matlab id.',...
    s.id);

    assert(isempty(s.value)||isempty(s.substitution),...
    'Transformation for ''%s'' cannot include both ''value'' and ''substitution''',...
    s.id);

end

function s=lMappingStruct(type)
    s=struct(...
    'type',{type},...
    'id',{''},...
    'substitution',{''},...
    'value',{''},...
    'unit',{''},...
    'priority',{''});
end

function s=lAttributes2Struct(a)


    n=0;
    if~isempty(a)
        n=a.Length;
    end


    for idx=1:n
        i=item(a,idx-1);
        if~isempty(i)
            s(idx).Name=i.Name;%#ok<AGROW>
            s(idx).Value=i.TextContent;%#ok<AGROW>
        end
    end

end