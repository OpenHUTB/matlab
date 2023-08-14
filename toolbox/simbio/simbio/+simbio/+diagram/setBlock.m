function varargout=setBlock(obj,varargin)























































































































    if isempty(obj)
        error('SimBiology:DIAGRAM_SET_INVALID_OBJECT','Invalid syntax. The input object must be a SimBiology object.');
    end


    for i=1:numel(obj)
        if isempty(regexp(class(obj(i)),'^SimBiology\.','once'))
            error('SimBiology:DIAGRAM_SET_INVALID_OBJECT','Invalid syntax. The input object must be a SimBiology object.');
        end
    end


    models=cell(1,length(obj));
    for i=1:length(obj)
        models{i}=getModelFromSessionID(obj(i).ParentModelSessionID);
        if~models{i}.hasDiagramSyntax
            error('SimBiology:DIAGRAM_SET_INVALID_DIAGRAM','Model does not have a diagram. Add the model to the SimBiology Model Builder app to create the diagram.');
        end
    end
    models=[models{:}];


    blocks=[];
    pvpairs={};
    onClone=false;


    switch(nargin)
    case 1

        if numel(obj)>1
            error('SimBiology:DIAGRAM_SET_INVALID_OBJECT','Input object must be scalar.');
        end
    case 2

        if isa(varargin{1},'SimBiology.Reaction')||isa(varargin{1},'SimBiology.Rule')

            onClone=true;
            expr=varargin{1};


            if numel(obj)>1
                error('SimBiology:DIAGRAM_SET_INVALID_SYNTAX','Input object must be a scalar species object.');
            end


            if numel(expr)>1
                error('SimBiology:DIAGRAM_SET_INVALID_SYNTAX','Expression object must be a scalar reaction or rule object.');
            end


            blocks=SimBiology.web.diagram.utilhandler('getSplitBlock',models(1),obj,expr);
            if isempty(blocks)
                error('SimBiology:DIAGRAM_SET_INVALID_SYNTAX','Split block OBJ is not connected to the expression block EXPR.');
            end
        elseif(ischar(varargin{1})||isstring(varargin{1}))

            pvpairs=varargin;
            if numel(obj)>1
                error('SimBiology:DIAGRAM_SET_INVALID_ARGUMENT','Input object must be scalar.');
            end
        elseif isstruct(varargin{1})

            pvpairs=varargin;
        else
            error('SimBiology:DIAGRAM_SET_INVALID_ARGUMENT','Invalid input argument. Type ''help simbio.diagram.setBlock'' for more information.');
        end
    otherwise

        if isa(varargin{1},'SimBiology.Reaction')||isa(varargin{1},'SimBiology.Rule')

            onClone=true;
            expr=varargin{1};


            if numel(obj)>1
                error('SimBiology:DIAGRAM_SET_INVALID_SYNTAX','Input object must be a scalar species object.');
            end


            if numel(expr)>1
                error('SimBiology:DIAGRAM_SET_INVALID_SYNTAX','Expression object must be a scalar reaction or rule object.');
            end


            blocks=SimBiology.web.diagram.utilhandler('getSplitBlock',models(1),obj,expr);
            if isempty(blocks)
                error('SimBiology:DIAGRAM_SET_INVALID_SYNTAX','Split block OBJ is not connected to the expression block EXPR.');
            end
            pvpairs=varargin(2:end);
        else
            pvpairs=varargin;
        end
    end


    if isempty(blocks)
        blocks={};
        newModelList={};
        objList={};
        for i=1:length(obj)

            blockList=models(i).getEntitiesInMap(obj(i).SessionID);
            if isempty(blockList)
                error('SimBiology:DIAGRAM_SET_INVALID_OBJECT','Input object does not have a block associated with it in the model diagram.');
            end

            for j=1:length(blockList)
                newModelList{end+1}=models(i);%#ok<AGROW>
                objList{end+1}=obj(i);%#ok<AGROW>
                blocks{end+1}=blockList(j);%#ok<AGROW>
            end
        end

        blocks=[blocks{:}];
        models=[newModelList{:}];
        objList=[objList{:}];
    end

    if isempty(pvpairs)

        if numel(blocks)>1

            error('SimBiology:DIAGRAM_SET_INVALID_OBJECT','Input object must be scalar and cannot be a split block.');
        end

        out=getSetDisplay(obj);
        if nargout==0
            disp(out);
        else
            varargout={out};
        end
    else
        try
            if numel(pvpairs)==1&&~isstruct(pvpairs{1})
                out=getSetPropertyDisplay(obj,pvpairs{:});
                varargout={out};
            else
                if onClone

                    configureCloneBlockProperties(models,obj,blocks,pvpairs{:});
                else

                    configureBlockProperties(models,objList,blocks,pvpairs{:});
                end
            end
        catch ex
            error(ex.identifier,ex.message);
        end
    end


    function out=getSetDisplay(obj)

        out=struct;
        props=getProperties;
        displayProps=getDisplayProperties;

        for i=1:length(props)
            if isSettable(props{i})
                if strcmp(props{i},'shape')
                    out.(displayProps{i})=getShapeOptions(obj);
                else
                    out.(displayProps{i})=getOptions(props{i});
                end
            end
        end


        function out=getSetPropertyDisplay(obj,property)

            property=matchProperty(property);
            if isSettable(property)
                if strcmp(property,'shape')
                    out=getShapeOptions(obj);
                else
                    out=getOptions(property);
                end
            else
                updateReadOnlyProperty(property);
            end


            function configureBlockProperties(modelList,objList,blockList,varargin)

                pvpairs=cleanupPVPairs(varargin{:});
                verifyPVPairSizes(blockList,pvpairs);

                models=unique(modelList);
                for i=1:numel(models)
                    model=models(i);
                    blocks=blockList((modelList==model));
                    objs=objList((modelList==model));

                    syntax=model.getDiagramSyntax;
                    syntax.modify(@(operations)configureBlockPropertiesOperations(operations,model,objs,blocks,pvpairs));
                end


                function configureBlockPropertiesOperations(operations,model,objs,blocks,pvpairs)

                    evt.pvpairs=struct;
                    transaction=SimBiology.Transaction.create(model);
                    currentValues={};
                    newValues={};

                    for i=1:numel(blocks)
                        if blocks(i).isValid
                            propList={};
                            oldValues={};

                            for j=1:2:length(pvpairs)
                                prop=pvpairs{j};
                                value=pvpairs{j+1};
                                nextValue=getPropertyValueFromList(value,i);

                                if strcmp(prop,'position')
                                    pos=SimBiology.web.diagram.placementhandler('getBlockAbsolutePosition',model,blocks(i));
                                    bsize=blocks(i).getSize;
                                    oldValue=[pos.x,pos.y,bsize.width,bsize.height];
                                else
                                    oldValue=blocks(i).getAttribute(prop).value;
                                end

                                if strcmp(prop,'position')
                                    setPosition(operations,model,blocks(i),nextValue);
                                elseif strcmp(prop,'visible')
                                    setVisible(operations,blocks(i),objs(i),nextValue);
                                elseif strcmp(prop,'shape')
                                    setShape(operations,blocks(i),objs(i),nextValue);
                                elseif strcmp(prop,'rotate')
                                    setRotate(operations,blocks(i),objs(i),nextValue);
                                elseif strcmp(prop,'lines')
                                    setExpressionLines(operations,blocks(i),objs(i),nextValue);
                                else
                                    operations.setAttributeValue(blocks(i),prop,nextValue);
                                end

                                includeProp=true;
                                if strcmp(prop,'position')
                                    pin=blocks(i).getAttribute('pin').value;
                                    includeProp=strcmp(pin,'false');
                                end

                                if includeProp
                                    propList{end+1}=prop;%#ok<AGROW>
                                    propList{end+1}=nextValue;%#ok<AGROW>
                                    oldValues{end+1}=prop;%#ok<AGROW>
                                    oldValues{end+1}=oldValue;%#ok<AGROW>
                                end
                            end

                            evt.pvpairs(i).sessionID=objs(i).SessionID;
                            evt.pvpairs(i).uuid=blocks(i).uuid;
                            evt.pvpairs(i).pvpairs=propList;


                            currentValue=struct;
                            currentValue.sessionID=objs(i).SessionID;
                            currentValue.diagramUUID=blocks(i).uuid;
                            currentValue.values=createUndoStruct(oldValues);

                            newValue=struct;
                            newValue.sessionID=objs(i).SessionID;
                            newValue.diagramUUID=blocks(i).uuid;
                            newValue.values=createUndoStruct(propList);

                            currentValues{end+1}=currentValue;%#ok<AGROW>
                            newValues{end+1}=newValue;%#ok<AGROW>
                        end
                    end

                    postEvent(evt,model,objs);


                    currentValues=[currentValues{:}];
                    newValues=[newValues{:}];

                    transaction.push(@()SimBiology.web.diagram.undo.blockAttributeLambda(model,currentValues,newValues));
                    transaction.commit();


                    function configureCloneBlockProperties(models,obj,block,varargin)

                        pvpairs=cleanupPVPairs(varargin{:});
                        verifyPVPairSizes(block,pvpairs);

                        syntax=models(1).getDiagramSyntax;
                        syntax.modify(@(operations)configureCloneBlockPropertiesOperations(operations,models(1),obj,block,pvpairs));


                        function configureCloneBlockPropertiesOperations(operations,model,obj,block,pvpairs)

                            allBlocks=model.getEntitiesInMap(obj.SessionID);
                            showWarning=false;
                            propsToWarn={};
                            evt.pvpairs=struct;
                            propList={};
                            oldValues={};

                            currentValues={};
                            newValues={};
                            transaction=SimBiology.Transaction.create(model);



                            for i=1:length(allBlocks)
                                oldValueProps=struct;
                                newValueProps=struct;

                                for j=1:2:length(pvpairs)
                                    prop=pvpairs{j};
                                    if~strcmp(prop,{'position','pin','visible'})
                                        value=pvpairs{j+1};
                                        value=getPropertyValueFromList(value,1);
                                        oldValueProps.(prop)=allBlocks(i).getAttribute(prop).value;
                                        newValueProps.(prop)=value;
                                    end
                                end


                                currentValue=struct;
                                currentValue.sessionID=obj.SessionID;
                                currentValue.diagramUUID=allBlocks(i).uuid;
                                currentValue.values=oldValueProps;

                                newValue=struct;
                                newValue.sessionID=obj.SessionID;
                                newValue.diagramUUID=allBlocks(i).uuid;
                                newValue.values=newValueProps;

                                currentValues{end+1}=currentValue;%#ok<AGROW>
                                newValues{end+1}=newValue;%#ok<AGROW>
                            end




                            for i=1:2:length(pvpairs)
                                prop=pvpairs{i};
                                value=pvpairs{i+1};
                                value=getPropertyValueFromList(value,1);

                                if strcmp(prop,'position')
                                    pos=SimBiology.web.diagram.placementhandler('getBlockAbsolutePosition',model,block);
                                    bsize=block.getSize;
                                    oldValue=[pos.x,pos.y,bsize.width,bsize.height];
                                else
                                    oldValue=block.getAttribute(prop).value;
                                end

                                if strcmp(prop,'position')
                                    setPosition(operations,model,block,value);
                                elseif strcmp(prop,'visible')
                                    setVisible(operations,block,obj,value);
                                elseif strcmp(prop,'pin')
                                    operations.setAttributeValue(block,prop,value);
                                else
                                    showWarning=true;
                                    propsToWarn{end+1}=prop;%#ok<AGROW>


                                    for j=1:numel(allBlocks)
                                        if strcmp(prop,'shape')
                                            setShape(operations,allBlocks(j),obj,value);
                                        else
                                            operations.setAttributeValue(allBlocks(j),prop,value);
                                        end
                                    end
                                end

                                includeProp=true;
                                if strcmp(prop,'position')
                                    pin=block.getAttribute('pin').value;
                                    includeProp=strcmp(pin,'false');
                                end

                                if includeProp
                                    propList{end+1}=prop;%#ok<AGROW>
                                    propList{end+1}=value;%#ok<AGROW>
                                    oldValues{end+1}=prop;%#ok<AGROW>
                                    oldValues{end+1}=oldValue;%#ok<AGROW>
                                end
                            end


                            evt.pvpairs(i).sessionID=obj.SessionID;
                            evt.pvpairs(i).pvpairs=propList;
                            evt.pvpairs(i).uuid=block.uuid;

                            postEvent(evt,model,obj);

                            if showWarning
                                propsToWarn=unique(propsToWarn);
                                displayProps=getDisplayProperties;
                                props=getProperties;
                                for i=1:length(propsToWarn)
                                    idx=strcmp(propsToWarn{i},props);
                                    prop=displayProps(idx);
                                    warning('SimBiology:DIAGRAM_SET_CLONE','Specified properties %s have been applied to all cloned species blocks. The only properties that can be different among cloned species are Pin, Position, and Visible.',prop{1});
                                end
                            end


                            currentValue=struct;
                            currentValue.sessionID=obj.SessionID;
                            currentValue.diagramUUID=block.uuid;
                            currentValue.values=createUndoStruct(oldValues);

                            newValue=struct;
                            newValue.sessionID=obj.SessionID;
                            newValue.diagramUUID=block.uuid;
                            newValue.values=createUndoStruct(propList);

                            currentValues{end+1}=currentValue;
                            newValues{end+1}=newValue;

                            currentValues=[currentValues{:}];
                            newValues=[newValues{:}];

                            transaction.push(@()SimBiology.web.diagram.undo.blockAttributeLambda(model,currentValues,newValues));
                            transaction.commit();


                            function value=getPropertyValueFromList(value,index)

                                if numel(value)>1
                                    value=value{index};
                                else
                                    value=value{1};
                                end



                                function pvpairs=cleanupPVPairs(varargin)

                                    pvpairs=simbio.diagram.internal.utilhandler('cleanupPVPairs',getDisplayProperties,getProperties,varargin{:});


                                    for i=1:2:numel(pvpairs)
                                        prop=pvpairs{i};

                                        switch(prop)
                                        case 'textcolor'
                                            pvpairs{i+1}=updateColor('TextColor',pvpairs{i+1});
                                        case 'facecolor'
                                            pvpairs{i+1}=updateColor('FaceColor',pvpairs{i+1});
                                        case 'edgecolor'
                                            pvpairs{i+1}=updateColor('EdgeColor',pvpairs{i+1});
                                        case 'fontFamily'
                                            pvpairs{i+1}=updateFontFamily(pvpairs{i+1});
                                        case 'fontSize'
                                            pvpairs{i+1}=updateFontSize(pvpairs{i+1});
                                        case 'fontWeight'
                                            pvpairs{i+1}=updateFontWeight(pvpairs{i+1});
                                        case 'lines'
                                            pvpairs{i+1}=updateExpressionLines(pvpairs{i+1});
                                        case 'pin'
                                            pvpairs{i+1}=updatePin(pvpairs{i+1});
                                        case 'position'
                                            pvpairs{i+1}=updatePosition(pvpairs{i+1});
                                        case 'rotate'
                                            pvpairs{i+1}=updateRotate(pvpairs{i+1});
                                        case 'shape'
                                            pvpairs{i+1}=updateShape(pvpairs{i+1});
                                        case 'textLocation'
                                            pvpairs{i+1}=updateTextLocation(pvpairs{i+1});
                                        case 'visible'
                                            pvpairs{i+1}=updateVisible(pvpairs{i+1});
                                        case{'object','connections','cloned'}
                                            updateReadOnlyProperty(prop);
                                        end
                                    end


                                    function verifyPVPairSizes(blockList,pvpairs)

                                        simbio.diagram.internal.utilhandler('verifyPVPairSizes',blockList,pvpairs);


                                        function props=getDisplayProperties

                                            props={'Connections','Cloned','EdgeColor','ExpressionLines','FaceColor','FontName',...
                                            'FontSize','FontWeight','Object','Pin','Position','Rotate',...
                                            'Shape','TextColor','TextLocation','Visible'};


                                            function props=getProperties

                                                props={'connections','cloned','edgecolor','lines','facecolor','fontFamily',...
                                                'fontSize','fontWeight','object','pin','position','rotate',...
                                                'shape','textcolor','textLocation','visible'};


                                                function out=isSettable(prop)

                                                    out=~any(strcmpi(prop,{'connections','cloned','object'}));


                                                    function value=updateColor(prop,value)

                                                        value=simbio.diagram.internal.utilhandler('updateColorValueForSet',prop,value);


                                                        function value=updateExpressionLines(value)

                                                            options=getOptions('lines');

                                                            for i=1:numel(value)
                                                                value{i}=matchValue(options,'ExpressionLines',value{i});
                                                            end


                                                            function value=updateFontFamily(value)

                                                                options=getOptions('fontFamily');

                                                                for i=1:numel(value)
                                                                    value{i}=matchValue(options,'FontName',value{i});
                                                                end


                                                                function value=updateFontSize(value)

                                                                    for i=1:numel(value)
                                                                        if~isnumeric(value{i})
                                                                            error('MATLAB:class:RequireNumeric','Unable to set the property ''FontSize''. Value must be numeric.');
                                                                        elseif value{i}<=0
                                                                            error('SimBiology:INVALID_FONTSIZE_VALUE','Unable to set the property ''FontSize''. Value must be greater than or equal to zero.');
                                                                        end
                                                                    end


                                                                    function value=updateFontWeight(value)

                                                                        options=getOptions('fontWeight');

                                                                        for i=1:numel(value)
                                                                            value{i}=matchValue(options,'FontWeight',value{i});
                                                                        end


                                                                        function value=updatePin(value)

                                                                            for i=1:numel(value)
                                                                                if~islogical(value{i})
                                                                                    error('MATLAB:class:RequireLogical','Unable to set the property ''Pin''. Value must be logical (true or false).');
                                                                                end

                                                                                value{i}=logicalToString(value{i});
                                                                            end


                                                                            function value=updatePosition(value)

                                                                                id='MATLAB:class:RequireNumeric';
                                                                                msg='Invalid position value. Specify a four-element vector of [x y width height].';

                                                                                for i=1:numel(value)
                                                                                    next=value{i};
                                                                                    if~isnumeric(next)
                                                                                        error(id,msg);
                                                                                    elseif numel(next)~=4
                                                                                        error(id,msg);
                                                                                    elseif next(3)<0||next(4)<0
                                                                                        error(id,msg);
                                                                                    else
                                                                                        for j=1:numel(next)
                                                                                            if isinf(next(j))
                                                                                                error(id,msg);
                                                                                            end
                                                                                        end
                                                                                    end
                                                                                end


                                                                                function updateReadOnlyProperty(property)

                                                                                    simbio.diagram.internal.utilhandler('updateReadOnlyProperty',property,getDisplayProperties,getProperties);


                                                                                    function value=updateRotate(value)

                                                                                        for i=1:numel(value)
                                                                                            if~isnumeric(value{i})
                                                                                                error('MATLAB:class:RequireNumeric','Unable to set the property ''Rotate''. Value must be numeric.');
                                                                                            elseif value{i}<0||value{i}>360
                                                                                                error('SimBiology:INVALID_ROTATE_VALUE','Unable to set the property ''Rotate''. Value must be greater than or equal to zero and less than 360.');
                                                                                            end
                                                                                        end


                                                                                        function value=updateShape(value)

                                                                                            options=getOptions('shape');

                                                                                            for i=1:numel(value)
                                                                                                value{i}=matchValue(options,'Shape',value{i});
                                                                                            end


                                                                                            function value=updateTextLocation(value)

                                                                                                options=getOptions('textLocation');

                                                                                                for i=1:numel(value)
                                                                                                    value{i}=matchValue(options,'TextLocation',value{i});
                                                                                                end


                                                                                                function value=updateVisible(value)

                                                                                                    for i=1:numel(value)
                                                                                                        if~islogical(value{i})
                                                                                                            error('MATLAB:class:RequireLogical','Unable to set the property ''Visible''. Value must be logical (true or false).');
                                                                                                        end

                                                                                                        value{i}=logicalToString(value{i});
                                                                                                    end


                                                                                                    function options=getOptions(prop)

                                                                                                        switch(prop)
                                                                                                        case 'fontWeight'
                                                                                                            options={'plain';'bold';'italic';'bold italic'};
                                                                                                        case 'shape'
                                                                                                            options={'rounded rectangle';'rectangle';'oval';'triangle';'hexagon';'chevron';'parallelogram';'diamond'};
                                                                                                        case 'textLocation'
                                                                                                            options={'top';'left';'bottom';'right';'center';'none'};
                                                                                                        case 'fontFamily'
                                                                                                            options={'Arial';'Arial Black';'Arial Narrow';'Comic Sans MS';'Courier';'Courier New';...
                                                                                                            'Georgia';'Helvetica';'Impact';'Times New Roman';'Trebuchet MS';'Verdana'};
                                                                                                        case 'lines'
                                                                                                            options={'hide';'show'};
                                                                                                        case{'pin','visible'}
                                                                                                            options={true;false};
                                                                                                        otherwise
                                                                                                            options={};
                                                                                                        end


                                                                                                        function options=getShapeOptions(obj)

                                                                                                            if isa(obj,'SimBiology.Compartment')
                                                                                                                options={'rounded rectangle';'rectangle'};
                                                                                                            else
                                                                                                                options=getOptions('shape');
                                                                                                            end


                                                                                                            function value=matchValue(options,property,value)

                                                                                                                if~ischar(value)&&~isstring(value)
                                                                                                                    error('MATLAB:class:RequireString',['Unable to set the property ''',property,'''. Value must be a character vector or string scalar.']);
                                                                                                                end

                                                                                                                idx=find(startsWith(options,value,'IgnoreCase',true));

                                                                                                                if numel(idx)>1
                                                                                                                    idx=find(strcmpi(options,value));
                                                                                                                    if numel(idx)>1
                                                                                                                        error('MATLAB:class:InvalidEnumValue',['Unable to set the property ''',property,'''. There is no enumerated value named ''',char(value),'''.']);
                                                                                                                    else
                                                                                                                        value=options{idx};
                                                                                                                    end
                                                                                                                elseif isempty(idx)
                                                                                                                    error('MATLAB:class:InvalidEnumValue',['Unable to set the property ''',property,'''. There is no enumerated value named ''',char(value),'''.']);
                                                                                                                else
                                                                                                                    value=options{idx};
                                                                                                                end


                                                                                                                function value=matchProperty(value)

                                                                                                                    value=simbio.diagram.internal.utilhandler('matchProperty',value,getDisplayProperties,getProperties);


                                                                                                                    function setExpressionLines(operations,block,obj,value)

                                                                                                                        if isa(obj,'SimBiology.Compartment')||isa(obj,'SimBiology.Species')||isa(obj,'SimBiology.Parameter')
                                                                                                                            error('SimBiology:DIAGRAM_SET_EXPRESSIONLINES','Expression lines cannot be set on compartments, species or parameters.');
                                                                                                                        else
                                                                                                                            model=obj.Parent;

                                                                                                                            selection=struct;
                                                                                                                            selection.diagramUUID=block.uuid;
                                                                                                                            selection.sessionID=obj.SessionID;
                                                                                                                            selection.type=obj.Type;

                                                                                                                            inputs=struct;
                                                                                                                            inputs.modelSessionID=model.SessionID;
                                                                                                                            inputs.property='lines';
                                                                                                                            inputs.selection=selection;
                                                                                                                            inputs.value=value;

                                                                                                                            for i=1:numel(inputs.selection)
                                                                                                                                inputs.selection(i).value=value;
                                                                                                                            end

                                                                                                                            SimBiology.web.diagramhandler('configureLinePropertyOperations',operations,model,inputs);
                                                                                                                        end


                                                                                                                        function setShape(operations,block,obj,value)

                                                                                                                            if isa(obj,'SimBiology.Compartment')
                                                                                                                                if~strcmpi(value,{'rectangle','rounded rectangle'})
                                                                                                                                    error('MATLAB:class:InvalidEnumValue',['Unable to set the property ''Shape''. There is no enumerated value named ''',char(value),''' for compartment blocks.']);
                                                                                                                                end
                                                                                                                            end

                                                                                                                            operations.setAttributeValue(block,'shape',value);

                                                                                                                            if strcmp(value,'rectangle')
                                                                                                                                operations.setAttributeValue(block,'shapeRadius',0);
                                                                                                                            elseif strcmp(value,'rounded rectangle')
                                                                                                                                operations.setAttributeValue(block,'shapeRadius',30);
                                                                                                                            end


                                                                                                                            function setRotate(operations,block,obj,value)

                                                                                                                                if isa(obj,'SimBiology.Compartment')
                                                                                                                                    error('SimBiology:DIAGRAM_SET_ROTATE','Compartment blocks cannot be rotated.');
                                                                                                                                else
                                                                                                                                    operations.setAttributeValue(block,'rotate',value);
                                                                                                                                end


                                                                                                                                function setVisible(operations,block,obj,value)
                                                                                                                                    if isa(obj,'SimBiology.Compartment')
                                                                                                                                        error('SimBiology:DIAGRAM_SET_VISIBLE','Visibility cannot be set for compartment blocks.');
                                                                                                                                    end

                                                                                                                                    SimBiology.web.diagramhandler('configureVisiblePropertyOnBlock',operations,block,value);


                                                                                                                                    function setPosition(operations,model,block,value)

                                                                                                                                        pinned=getAttributeValue(block,'pin');
                                                                                                                                        if strcmp(pinned,'true')
                                                                                                                                            return;
                                                                                                                                        end

                                                                                                                                        x=value(1);
                                                                                                                                        y=value(2);
                                                                                                                                        width=value(3);
                                                                                                                                        height=value(4);

                                                                                                                                        if strcmp(block.type,'species')


                                                                                                                                            comp=block.diagram.parentEntity;


                                                                                                                                            if~isBlockContainedByParent(model,comp,x,y,width,height)
                                                                                                                                                error('SimBiology:DIAGRAM_SET_INVALID_POSITION','Invalid position value. Species cannot be moved outside of its compartment.');
                                                                                                                                            end



                                                                                                                                            if doesSpeciesOverlapOtherBlocksWithinParent(model,comp,block,x,y,width,height)
                                                                                                                                                error('SimBiology:DIAGRAM_SET_INVALID_POSITION','Invalid position value. Species cannot overlap other compartments.');
                                                                                                                                            end
                                                                                                                                        elseif strcmp(block.type,'compartment')
                                                                                                                                            comp=block.diagram.parentEntity;

                                                                                                                                            if comp.isValid


                                                                                                                                                if~isBlockContainedByParent(model,comp,x,y,width,height)
                                                                                                                                                    error('SimBiology:DIAGRAM_SET_INVALID_POSITION','Invalid position value. Compartment cannot be moved outside of its compartment.');
                                                                                                                                                end



                                                                                                                                                if doesCompartmentOverlapOtherBlocksWithinParent(model,comp,block,x,y,width,height)
                                                                                                                                                    error('SimBiology:DIAGRAM_SET_INVALID_POSITION','Invalid position value. Compartment cannot overlap other compartments or species.');
                                                                                                                                                end
                                                                                                                                            else

                                                                                                                                                if doesCompartmentOverlapTopLevelCompartments(model,block,x,y,width,height)
                                                                                                                                                    error('SimBiology:DIAGRAM_SET_INVALID_POSITION','Invalid position value. Compartment blocks cannot overlap other compartments.');
                                                                                                                                                end
                                                                                                                                            end
                                                                                                                                        end

                                                                                                                                        operations.setSize(block,width,height);

                                                                                                                                        syntax=model.getDiagramSyntax;
                                                                                                                                        operations.setPosition(block,x,y);
                                                                                                                                        operations.setParent(block,syntax.root);
                                                                                                                                        SimBiology.web.diagram.layouthandler('reparentBlocks',operations,model,[],block);


                                                                                                                                        function out=isBlockContainedByParent(model,parentBlock,x,y,width,height)

                                                                                                                                            pos=SimBiology.web.diagram.placementhandler('getBlockAbsolutePosition',model,parentBlock);
                                                                                                                                            csize=parentBlock.getSize;

                                                                                                                                            c.top=pos.y;
                                                                                                                                            c.left=pos.x;
                                                                                                                                            c.right=c.left+csize.width;
                                                                                                                                            c.bottom=c.top+csize.height;

                                                                                                                                            s.top=y;
                                                                                                                                            s.left=x;
                                                                                                                                            s.right=x+width;
                                                                                                                                            s.bottom=y+height;

                                                                                                                                            out=rectContains(c,s);


                                                                                                                                            function out=doesCompartmentOverlapTopLevelCompartments(model,block,x,y,width,height)

                                                                                                                                                objs=sbioselect(model.Compartments,'Owner',[]);
                                                                                                                                                out=doBlocksOverlap(model,block,objs,x,y,width,height);


                                                                                                                                                function out=doesCompartmentOverlapOtherBlocksWithinParent(model,parentBlock,block,x,y,width,height)

                                                                                                                                                    pSessionID=getAttributeValue(parentBlock,'sessionID');
                                                                                                                                                    parent=sbioselect(model.Compartments,'SessionID',pSessionID);
                                                                                                                                                    comps=sbioselect(model.Compartments,'Owner',parent);
                                                                                                                                                    species=parent.Species;
                                                                                                                                                    objs=vertcat(comps,species);
                                                                                                                                                    out=doBlocksOverlap(model,block,objs,x,y,width,height);


                                                                                                                                                    function out=doesSpeciesOverlapOtherBlocksWithinParent(model,parentBlock,block,x,y,width,height)

                                                                                                                                                        pSessionID=getAttributeValue(parentBlock,'sessionID');
                                                                                                                                                        parent=sbioselect(model.Compartments,'SessionID',pSessionID);
                                                                                                                                                        objs=sbioselect(model.Compartments,'Owner',parent);
                                                                                                                                                        out=doBlocksOverlap(model,block,objs,x,y,width,height);


                                                                                                                                                        function out=doBlocksOverlap(model,block,objs,x,y,width,height)

                                                                                                                                                            out=false;
                                                                                                                                                            c.top=y;
                                                                                                                                                            c.left=x;
                                                                                                                                                            c.right=x+width;
                                                                                                                                                            c.bottom=y+height;

                                                                                                                                                            for i=1:numel(objs)
                                                                                                                                                                nextBlocks=model.getEntitiesInMap(objs(i).SessionID);
                                                                                                                                                                for j=1:numel(nextBlocks)
                                                                                                                                                                    if~strcmp(nextBlocks(j).uuid,block.uuid)
                                                                                                                                                                        pos=SimBiology.web.diagram.placementhandler('getBlockAbsolutePosition',model,nextBlocks(j));
                                                                                                                                                                        nsize=nextBlocks(j).getSize;

                                                                                                                                                                        n.top=pos.y;
                                                                                                                                                                        n.left=pos.x;
                                                                                                                                                                        n.right=n.left+nsize.width;
                                                                                                                                                                        n.bottom=n.top+nsize.height;

                                                                                                                                                                        if rectIntersects(c,n)
                                                                                                                                                                            out=true;
                                                                                                                                                                            return;
                                                                                                                                                                        end
                                                                                                                                                                    end
                                                                                                                                                                end
                                                                                                                                                            end


                                                                                                                                                            function out=createUndoStruct(pvpairs)

                                                                                                                                                                out=simbio.diagram.internal.utilhandler('createUndoStruct',pvpairs);


                                                                                                                                                                function out=getAttributeValue(blocks,property)

                                                                                                                                                                    out=SimBiology.web.diagramhandler('getAttributeValue',blocks,property);


                                                                                                                                                                    function out=rectContains(rect1,rect2)

                                                                                                                                                                        out=rect2.left>rect1.left&&rect2.top>rect1.top&&rect2.bottom<rect1.bottom&&rect2.right<rect1.right;


                                                                                                                                                                        function out=rectIntersects(rect1,rect2)

                                                                                                                                                                            out=~(rect1.right<rect2.left||rect2.right<rect1.left||rect1.bottom<rect2.top||rect2.bottom<rect1.top);


                                                                                                                                                                            function out=getModelFromSessionID(sessionID)

                                                                                                                                                                                out=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);


                                                                                                                                                                                function out=logicalToString(value)

                                                                                                                                                                                    if value
                                                                                                                                                                                        out='true';
                                                                                                                                                                                    else
                                                                                                                                                                                        out='false';
                                                                                                                                                                                    end


                                                                                                                                                                                    function postEvent(evt,model,objs)

                                                                                                                                                                                        evt.type='blockPropertyChangedMATLAB';
                                                                                                                                                                                        evt.modelSessionID=model.SessionID;
                                                                                                                                                                                        evt.sessionID=[objs.SessionID];

                                                                                                                                                                                        message.publish('/SimBiology/blockPropertyChanged',evt);
