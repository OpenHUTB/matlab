function out=filterObjectForJson(object,varargin)



    assert(isobject(object));
    options=processOptions(varargin);

    metaclass=meta.class.fromName(class(object));
    classes=getClassHierarchy(metaclass);
    out=repmat(struct(),size(object));
    flattenOpts=[];

    if isempty(out)
        return
    end

    for i=1:numel(classes)
        props=classes(i).PropertyList;
        for j=1:numel(props)
            overlayProperty(props(j));
        end
    end

    if options.ToJson
        out=jsonencode(out);
    end


    function overlayProperty(prop)
        if ismember(prop.Name,options.Blacklist)
            return;
        elseif prop.Transient&&~options.IncludeTransient
            return;
        elseif prop.Hidden&&~options.IncludeHidden
            return;
        elseif~strcmp(prop.GetAccess,'public')
            return;
        end

        if options.Flatten
            if isempty(flattenOpts)
                flattenArg={'CustomObjectSerializer',@(v)filterObjectForJson(v,options)};
            else
                flattenArg={flattenOpts};
            end
            [value,flattenOpts]=codergui.internal.flattenForJson({object.(prop.Name)},true,flattenArg{:});
        else
            value={object.(prop.Name)};
        end
        outName=prop.Name;
        if options.CamelCase
            outName=[lower(outName(1)),outName(2:end)];
        end
        [out.(outName)]=value{:};
    end
end



function classes=getClassHierarchy(metaclass)
    current=metaclass;
    classes=repmat(metaclass,0,1);
    while~isempty(current)&&~strcmp(current.Name,'handle')
        classes(end+1)=current;%#ok<AGROW>
        current=current.SuperclassList;
        current=current(~startsWith({current.Name},'matlab.mixin.'));
        assert(numel(current)<=1);
    end
    classes=flip(classes);
end


function options=processOptions(args)
    persistent ip;
    if isempty(args)||~isstruct(args{1})
        if isempty(ip)
            ip=inputParser();
            ip.addParameter('IncludeTransient',false,@islogical);
            ip.addParameter('IncludeHidden',false,@islogical);
            ip.addParameter('Blacklist',{},@iscellstr);
            ip.addParameter('Flatten',true,@islogical);
            ip.addParameter('ToJson',false,@islogical);
            ip.addParameter('CamelCase',false,@islogical);
        end
        ip.parse(args{:});
        options=ip.Results;
    else

        options=args{1};
    end
end