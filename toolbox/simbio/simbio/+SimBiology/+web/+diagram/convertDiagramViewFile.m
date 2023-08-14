function out=convertDiagramViewFile(filename)












    fontMap=containers.Map('KeyType','char','ValueType','any');
    colorMap=containers.Map('KeyType','char','ValueType','any');

    tree=readstruct(filename,'FileType','xml');
    nodes=getObjectNodes(tree);
    props={};

    for i=1:numel(nodes)
        blockProps=getBlockProperties(nodes{i},fontMap,colorMap);
        blockProps.type=getObjectType(getAttribute(nodes{i}.object,'class'));
        props{end+1}=blockProps;%#ok<AGROW>
    end

    out=createOutputStruct(props);

end

function nodes=getObjectNodes(tree)

    nodes={};


    vnodes=tree.object.void;
    diagram=[];
    for i=1:numel(vnodes)
        if strcmp(getAttribute(vnodes(i),'property'),'diagram')
            diagram=vnodes(i);
            break;
        end
    end

    if~isempty(diagram)
        obj=getField(diagram,'object');
        if isempty(obj)

            vnodes=getField(diagram,'void');
        else

            vnodes=getField(obj,'void');
        end
        nodes=getObjectNodesRecursive(nodes,vnodes);
    end

end

function nodes=getObjectNodesRecursive(nodes,vnodes)

    for i=1:numel(vnodes)
        value=getAttribute(vnodes(i).object,'class');
        if startsWith(value,'com.mathworks.toolbox.simbio.desktop.editor.blocks.')
            nodes{end+1}=vnodes(i);%#ok<AGROW>  
        end

        children=getField(vnodes(i).object,'void');
        for j=1:length(children)
            nextObj=getField(children(j),'object');
            if~isempty(nextObj)
                nodes=getObjectNodesRecursive(nodes,children(j));
            end
        end
    end

end

function out=getBlockProperties(next,fontMap,colorMap)

    out=struct;
    children=next.object.void;

    for i=1:length(children)
        property=getAttribute(children(i),'property');
        switch(property)
        case 'index'
            out.index=getIntPropertyValue(children(i));
        case 'textPosition'
            textLocation=getIntPropertyValue(children(i));
            out.textLocation=translateTextLocation(textLocation);
        case 'bounds'
            bounds=getBoundsPropertyValue(children(i));
            out.position=bounds(1:2);
            out.size=bounds(3:4);
        case 'font'
            fontInfo=getFontPropertyValue(children(i),fontMap);
            out.fontFamily=fontInfo{1};
            out.fontWeight=translateFontWeight(fontInfo{2});
            out.fontSize=fontInfo{3};
        case 'background'
            color=getColorPropertyValue(children(i),colorMap);
            if~isempty(color)
                out.facecolor=color;
            end
        case 'foreground'
            color=getColorPropertyValue(children(i),colorMap);
            if~isempty(color)
                out.edgecolor=color;
            end
        case 'textColor'
            color=getColorPropertyValue(children(i),colorMap);
            if~isempty(color)
                out.textcolor=color;
            end
        case 'pinned'
            out.pin=getBooleanPropertyValue(children(i));
        case 'visible'
            out.visible=getBooleanPropertyValue(children(i));
        case 'orientation'
            out.rotate=rad2deg(getDoublePropertyValue(children(i)));
        case 'ruleType'
            ruleType=getIntPropertyValue(children(i));
            out.ruleType=translateRuleType(ruleType);
        case 'imageString'
            out.imageString=getStringPropertyValue(children(i));
        case 'blockShapeName'
            out.shape=getBlockShape(getStringPropertyValue(children(i)));
        end
    end

    if~isfield(out,'index')
        out.index=0;
    end

end

function out=getIntPropertyValue(next)




    out=getField(next,'int');

end

function out=getStringPropertyValue(next)




    out=char(getField(next,'string'));

end

function out=getBooleanPropertyValue(next)




    out=char(getField(next,'boolean'));


end

function out=getDoublePropertyValue(next)




    out=getField(next,'double');

end

function out=getBoundsPropertyValue(next)

    out=[0,0,0,0];
    objNode=getField(next,'object');
    if isstruct(objNode)

        out=getField(objNode,'int');
    else
        vnodes=next.void;
        for i=1:numel(vnodes)
            description=getField(vnodes(i),'string');
            value=getField(vnodes(i).void,'int');

            switch description
            case 'x'
                out(1)=value;
            case 'y'
                out(2)=value;
            case 'width'
                out(3)=value;
            case 'height'
                out(4)=value;
            end
        end
    end

end

function value=getColorPropertyValue(next,map)













    try
        id=getAttribute(next.object,'id');
        idRef=getAttribute(next.object,'idref');
        if isempty(idRef)
            out=getField(next.object,'int');



            if~isempty(id)
                map(id)=out;%#ok<NASGU>
            end
        else


            out=map(idRef);
        end

        value='#';
        value=[value,getHexValue(out(1))];
        value=[value,getHexValue(out(2))];
        value=[value,getHexValue(out(3))];
    catch
        value='';
    end

end

function out=getFontPropertyValue(next,map)













    try
        out={'',0,0};
        objectNode=getField(next,'object');
        if numel(objectNode,1)
            id=getAttribute(objectNode,'id');
            idRef=getAttribute(objectNode,'idref');
            if isempty(idRef)

                out{1}=getField(objectNode,'string');
                intNodes=getField(objectNode,'int');
                for i=1:length(intNodes)
                    out{i+1}=intNodes(i);
                end



                if~isempty(id)
                    map(id)=out;%#ok<NASGU>
                end
            else


                out=map(idRef);
            end
        end
    catch
    end

end

function type=getObjectType(value)

    switch(value)
    case 'com.mathworks.toolbox.simbio.desktop.editor.blocks.SpeciesBlock'
        type='species';
    case 'com.mathworks.toolbox.simbio.desktop.editor.blocks.ReactionBlock'
        type='reaction';
    case 'com.mathworks.toolbox.simbio.desktop.editor.blocks.SimBiologyCompartmentBlock'
        type='compartment';
    case 'com.mathworks.toolbox.simbio.desktop.editor.blocks.ParameterBlock'
        type='parameter';
    case 'com.mathworks.toolbox.simbio.desktop.editor.blocks.EventBlock'
        type='event';
    case 'com.mathworks.toolbox.simbio.desktop.editor.blocks.RuleBlock'
        type='rule';
    otherwise
        type='unknown';
    end

end

function out=translateRuleType(type)
    switch(type)
    case 1
        out='algebraic';
    case 2
        out='initialAssignment';
    case 3
        out='repeatedAssignment';
    case 4
        out='rate';
    end

end

function out=getBlockShape(shapeName)

    switch shapeName
    case 'shape2'
        out='chevron';
    case 'shape3'
        out='parallelogram';
    case 'shape5'
        out='hexagon';
    case 'shape6'
        out='triangle';
    case 'shape8'
        out='diamond';
    otherwise
        out='rectangle';
    end

end

function[width,height]=getDefaultSize(type)

    width=15;
    height=15;

    switch(type)
    case 'compartment'
        width=107;
        height=35;
    case 'species'
        width=30;
    case 'parameter'
        width=30;
        height=15;
    case 'event'
        width=20;
        height=20;
    case 'rule'
        width=20;
        height=20;
    end

end

function out=translateTextLocation(value)

    values={'top','left','bottom','right','center','none'};
    out=values{value+1};

end

function out=translateFontWeight(value)

    values={'plain','bold','italic','bold italic'};
    out=values{value+1};

end

function out=getHexValue(value)

    out=dec2hex(value);
    if length(out)==1
        out=['0',out];
    end

end

function out=createOutputStruct(values)

    out=struct;
    for i=1:length(values)
        type=values{i}.type;
        index=values{i}.index;
        name=[type,num2str(index)];


        bounds=values{i}.size;
        [w,h]=getDefaultSize(type);
        if bounds(1)==0
            bounds(1)=w;
        end
        if bounds(2)==0
            bounds(2)=h;
        end
        values{i}.size=bounds;

        next=values{i};
        next=rmfield(next,'index');

        if isfield(out,name)
            value=out.(name);
            if~iscell(value)
                value={value};
            end
            value{end+1}=next;%#ok<AGROW>
            out.(name)=value;
        else
            out.(name)=next;
        end
    end

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);
end
