function out=getLine(obj1,varargin)














































    if isempty(obj1)
        error('SimBiology:DIAGRAM_GETLINE_INVALID_OBJECT','Invalid object. The input object must be a SimBiology object.');
    end


    for i=1:numel(obj1)
        if isempty(regexp(class(obj1(i)),'^SimBiology\.','once'))
            error('SimBiology:DIAGRAM_GETLINE_INVALID_OBJECT','Invalid object. The input object must be a SimBiology object.');
        end
    end


    models=cell(1,length(obj1));
    for i=1:length(obj1)
        models{i}=getModelFromSessionID(obj1(i).ParentModelSessionID);
        if~models{i}.hasDiagramSyntax
            error('SimBiology:DIAGRAM_GETLINE_INVALID_DIAGRAM','Model does not have a diagram. Add the model to the SimBiology Model Builder app to create the diagram.');
        end
    end
    models=[models{:}];


    lines=[];
    property='';


    if nargin>3
        error('SimBiology:DIAGRAM_GETLINE_INVALID_SYNTAX','Invalid syntax.');
    elseif nargin==2

        if~isempty(regexp(class(varargin{1}),'^SimBiology\.','once'))

            obj2=varargin{1};


            if numel(obj1)>1
                error('SimBiology:DIAGRAM_GETLINE_INVALID_SYNTAX','First input object  must be a scalar SimBiology object.');
            end


            if numel(obj2)>1
                error('SimBiology:DIAGRAM_GETLINE_INVALID_SYNTAX','Second input object must be a scalar SimBiology object.');
            end


            lines=SimBiology.web.diagram.linehandler('getLineBetweenBlocksUsingSessionID',models(1),obj1.SessionID,obj2.SessionID);
            if isempty(lines)
                error('SimBiology:DIAGRAM_GETLINE_INVALID_SYNTAX','No line is connected between the two input objects.');
            end
        elseif ischar(varargin{1})||iscellstr(varargin{1})||isstring(varargin{1})
            property=varargin{1};
        else
            error('SimBiology:DIAGRAM_GETLINE_INVALID_SYNTAX','Invalid syntax.');
        end
    elseif nargin==3



        if numel(obj1)>1
            error('SimBiology:DIAGRAM_GETLINE_INVALID_SYNTAX','First input object must be a scalar SimBiology object.');
        end


        obj2=varargin{1};
        if isempty(regexp(class(obj2),'^SimBiology\.','once'))
            error('SimBiology:DIAGRAM_GETLINE_INVALID_SYNTAX','Second input object must be a scalar SimBiology object.');
        end


        if numel(obj2)>1
            error('SimBiology:DIAGRAM_GETLINE_INVALID_SYNTAX','Second input object must be a scalar SimBiology object.');
        end


        lines=SimBiology.web.diagram.linehandler('getLineBetweenBlocksUsingSessionID',models(1),obj1.SessionID,obj2.SessionID);
        if isempty(lines)
            error('SimBiology:DIAGRAM_GETLINE_INVALID_SYNTAX','No line is connected between OBJ1 and OBJ2.');
        end


        if ischar(varargin{2})||iscellstr(varargin{2})||isstring(varargin{2})
            property=varargin{2};
        else
            error('SimBiology:DIAGRAM_GETLINE_INVALID_SYNTAX','Invalid syntax.');
        end
    end


    if isempty(lines)
        lines={};
        newModelList={};

        for i=1:length(obj1)

            blockList=models(i).getEntitiesInMap(obj1(i).SessionID);
            if isempty(blockList)
                error('SimBiology:DIAGRAM_GETLINE_INVALID_OBJECT','Object does not have a block associated with it in the model diagram.');
            end

            for j=1:length(blockList)
                connections=blockList(j).connections;
                for k=1:numel(connections)
                    newModelList{end+1}=models(i);%#ok<AGROW>
                    lines{end+1}=connections(k);%#ok<AGROW>
                end
            end
        end

        lines=[lines{:}];
        models=[newModelList{:}];
    end

    try
        if isempty(property)

            out=getGetDisplay(models,lines);
        else

            out=getLinePropertyValues(models,lines,property);
        end
    catch ex
        error(ex.identifier,ex.message);
    end


    function out=getGetDisplay(models,lines)

        props=getDisplayProperties;
        out=simbio.diagram.internal.utilhandler('getGetDisplay',models,lines,props,@getPropertyValues);


        function values=getLinePropertyValues(models,lines,props)

            values=simbio.diagram.internal.utilhandler('getPropertyValues',models,lines,props,@getPropertyValues);


            function value=getPropertyValues(model,line,property)

                property=matchProperty(property);

                if strcmpi(property,'connections')
                    value=getConnections(model,line);
                else
                    value=line.getAttribute(property).value;
                end

                switch lower(property)
                case{'linecolor'}
                    value=updateColorValue(value);
                case{'linewidth'}
                    if ischar(value)
                        value=str2double(value);
                    end
                end


                function value=updateColorValue(value)

                    value=simbio.diagram.internal.utilhandler('updateColorValueForGet',value);


                    function props=getDisplayProperties

                        props={'Color','Connections','Width'};


                        function props=getProperties

                            props={'linecolor','connections','linewidth'};


                            function value=matchProperty(value)

                                value=simbio.diagram.internal.utilhandler('matchProperty',value,getDisplayProperties,getProperties);


                                function out=getConnections(model,line)

                                    source=line.getAttribute('sourceSessionID').value;
                                    dest=line.getAttribute('destinationSessionID').value;
                                    obj1=sbioselect(model,'SessionID',source);
                                    obj2=sbioselect(model,'SessionID',dest);
                                    out=[obj1,obj2];


                                    function out=getModelFromSessionID(sessionID)

                                        out=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);
