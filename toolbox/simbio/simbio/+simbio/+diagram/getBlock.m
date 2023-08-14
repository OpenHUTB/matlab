function out=getBlock(obj,varargin)
























































































    if isempty(obj)
        error('SimBiology:DIAGRAM_GET_INVALID_OBJECT','Invalid object. The input object must be a SimBiology object.');
    end


    for i=1:numel(obj)
        if isempty(regexp(class(obj(i)),'^SimBiology\.','once'))
            error('SimBiology:DIAGRAM_GET_INVALID_OBJECT','Invalid object. The input object must be a SimBiology object.');
        end
    end


    models=cell(1,length(obj));
    for i=1:length(obj)
        models{i}=getModelFromSessionID(obj(i).ParentModelSessionID);
        if~models{i}.hasDiagramSyntax
            error('SimBiology:DIAGRAM_GET_INVALID_DIAGRAM','Model does not have a diagram. Add the model to SimBiology Model Builder app to create the diagram.');
        end
    end
    models=[models{:}];


    blocks=[];
    property='';


    if nargin>3
        error('SimBiology:DIAGRAM_GET_INVALID_SYNTAX','Invalid syntax.');
    elseif nargin==2

        if isa(varargin{1},'SimBiology.Reaction')||isa(varargin{1},'SimBiology.Rule')
            expr=varargin{1};


            if numel(obj)>1
                error('SimBiology:DIAGRAM_GET_INVALID_SYNTAX','Input object must be a scalar species object.');
            end


            if numel(expr)>1
                error('SimBiology:DIAGRAM_GET_INVALID_SYNTAX','Expresion object must be a scalar reaction or rule object.');
            end


            blocks=SimBiology.web.diagram.utilhandler('getSplitBlock',models(1),obj,expr);
            if isempty(blocks)
                error('SimBiology:DIAGRAM_GET_INVALID_SYNTAX','Split block OBJ is not connected to expression block EXPR.');
            end
        elseif ischar(varargin{1})||iscellstr(varargin{1})||isstring(varargin{1})
            property=varargin{1};
        else
            error('SimBiology:DIAGRAM_GET_INVALID_SYNTAX','Invalid syntax.');
        end
    elseif nargin==3



        if numel(obj)>1
            error('SimBiology:DIAGRAM_GET_INVALID_SYNTAX','Input object must be a scalar species object.');
        end


        expr=varargin{1};
        if~isa(expr,'SimBiology.Reaction')&&~isa(expr,'SimBiology.Rule')
            error('SimBiology:DIAGRAM_GET_INVALID_SYNTAX','Expression object must be a scalar reaction or rule object.');
        end


        if numel(expr)>1
            error('SimBiology:DIAGRAM_GET_INVALID_SYNTAX','Expression object must be a scalar reaction or rule object.');
        end


        blocks=SimBiology.web.diagram.utilhandler('getSplitBlock',models(1),obj,expr);
        if isempty(blocks)
            error('SimBiology:DIAGRAM_GET_INVALID_SYNTAX','Split block OBJ is not connected to expression block EXPR.');
        end


        if ischar(varargin{2})||iscellstr(varargin{2})||isstring(varargin{2})
            property=varargin{2};
        else
            error('SimBiology:DIAGRAM_GET_INVALID_SYNTAX','Invalid syntax.');
        end
    end


    if isempty(blocks)
        blocks={};
        newModelList={};
        for i=1:length(obj)

            blockList=models(i).getEntitiesInMap(obj(i).SessionID);
            if isempty(blockList)
                error('SimBiology:DIAGRAM_GET_INVALID_OBJECT','Object does not have a block associated with it in the model diagram.');
            end

            for j=1:length(blockList)
                newModelList{end+1}=models(i);%#ok<AGROW>
                blocks{end+1}=blockList(j);%#ok<AGROW>
            end
        end

        blocks=[blocks{:}];
        models=[newModelList{:}];
    end

    try
        if isempty(property)

            out=getGetDisplay(models,blocks);
        else

            out=getBlockPropertyValues(models,blocks,property);
        end
    catch ex
        error(ex.identifier,ex.message);
    end


    function out=getGetDisplay(models,blocks)

        props=getDisplayProperties;
        out=simbio.diagram.internal.utilhandler('getGetDisplay',models,blocks,props,@getPropertyValues);


        function values=getBlockPropertyValues(models,blocks,props)

            values=simbio.diagram.internal.utilhandler('getPropertyValues',models,blocks,props,@getPropertyValues);


            function value=getPropertyValues(model,block,property)

                property=matchProperty(property);

                if strcmpi(property,'position')
                    value=getPosition(model,block);
                elseif strcmpi(property,'object')
                    value=getObject(model,block);
                elseif strcmpi(property,'connections')
                    value=getConnections(model,block);
                else
                    value=block.getAttribute(property).value;
                end

                switch lower(property)
                case{'edgecolor','facecolor','textcolor'}
                    value=updateColorValue(value);
                case{'pin','visible','cloned'}
                    value=strcmp(value,'true');
                case{'fontsize','rotate'}
                    if ischar(value)
                        value=str2double(value);
                    end
                end


                function value=updateColorValue(value)

                    value=simbio.diagram.internal.utilhandler('updateColorValueForGet',value);


                    function props=getDisplayProperties

                        props={'Connections','Cloned','EdgeColor','ExpressionLines',...
                        'FaceColor','FontName','FontSize','FontWeight','Object','Pin',...
                        'Position','Rotate','Shape','TextColor','TextLocation','Visible'};


                        function props=getProperties

                            props={'connections','cloned','edgecolor','lines','facecolor',...
                            'fontFamily','fontSize','fontWeight','object','pin','position',...
                            'rotate','shape','textcolor','textLocation','visible'};


                            function value=matchProperty(value)

                                value=simbio.diagram.internal.utilhandler('matchProperty',value,getDisplayProperties,getProperties);


                                function out=getConnections(model,block)

                                    out=SimBiology.web.diagram.utilhandler('getConnections',model,block);


                                    function out=getObject(model,block)

                                        sessionID=block.getAttribute('sessionID').value;
                                        out=sbioselect(model,'SessionID',sessionID);


                                        function out=getPosition(model,block)

                                            bSize=block.getSize;
                                            bPos=SimBiology.web.diagram.placementhandler('getBlockAbsolutePosition',model,block);
                                            out=round([bPos.x,bPos.y,bSize.width,bSize.height]);


                                            function out=getModelFromSessionID(sessionID)

                                                out=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);
