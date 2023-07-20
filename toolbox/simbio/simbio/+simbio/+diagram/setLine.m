function varargout=setLine(obj1,varargin)











































































    if isempty(obj1)
        error('SimBiology:DIAGRAM_SETLINE_INVALID_OBJECT','Invalid syntax. The input object must be a SimBiology object.');
    end


    for i=1:numel(obj1)
        if isempty(regexp(class(obj1(i)),'^SimBiology\.','once'))
            error('SimBiology:DIAGRAM_SETLINE_INVALID_OBJECT','Invalid syntax. The input object must be a SimBiology object.');
        end
    end


    models=cell(1,length(obj1));
    for i=1:length(obj1)
        models{i}=getModelFromSessionID(obj1(i).ParentModelSessionID);
        if~models{i}.hasDiagramSyntax
            error('SimBiology:DIAGRAM_SETLINE_INVALID_DIAGRAM','Model does not have a diagram. Add the model to the SimBiology Model Builder app to create the diagram.');
        end
    end
    models=[models{:}];


    lines=[];
    pvpairs={};


    switch(nargin)
    case 1

        if numel(obj1)>1
            error('SimBiology:DIAGRAM_SETLINE_INVALID_OBJECT','Input object must be scalar.');
        end
    case 2

        if~isempty(regexp(class(varargin{1}),'^SimBiology\.','once'))

            obj2=varargin{1};


            if numel(obj1)>1
                error('SimBiology:DIAGRAM_SETLINE_INVALID_SYNTAX','First input object must be a scalar SimBiology object.');
            end


            if numel(obj2)>1
                error('SimBiology:DIAGRAM_SETLINE_INVALID_SYNTAX','Second input object must be a scalar SimBiology object.');
            end


            lines=SimBiology.web.diagram.linehandler('getLineBetweenBlocksUsingSessionID',models(1),obj1.SessionID,obj2.SessionID);
            if isempty(lines)
                error('SimBiology:DIAGRAM_GET_INVALID_SYNTAX','No line is connected between input objects.');
            end
        elseif(ischar(varargin{1})||isstring(varargin{1}))

            pvpairs=varargin;
            if numel(obj1)>1
                error('SimBiology:DIAGRAM_SETLINE_INVALID_OBJECT','Input object must be scalar.');
            end
        elseif isstruct(varargin{1})

            pvpairs=varargin;
        else
            error('SimBiology:DIAGRAM_SETLINE_INVALID_ARGUMENT','Invalid input argument for simbio.diagram.setLine.  Type ''help simbio.diagram.setLine'' for options.');
        end
    otherwise

        if~isempty(regexp(class(varargin{1}),'^SimBiology\.','once'))

            obj2=varargin{1};


            if numel(obj1)>1
                error('SimBiology:DIAGRAM_SETLINE_INVALID_SYNTAX','First input object must be a scalar SimBiology object.');
            end


            if numel(obj2)>1
                error('SimBiology:DIAGRAM_SETLINE_INVALID_SYNTAX','Second input object must be a scalar SimBiology object.');
            end


            lines=SimBiology.web.diagram.linehandler('getLineBetweenBlocksUsingSessionID',models(1),obj1.SessionID,obj2.SessionID);
            if isempty(lines)
                error('SimBiology:DIAGRAM_SETLINE_INVALID_SYNTAX','No line is connected between input objects.');
            end
            pvpairs=varargin(2:end);
        else
            pvpairs=varargin;
        end
    end


    if isempty(lines)
        lines={};
        newModelList={};
        for i=1:length(obj1)

            blockList=models(i).getEntitiesInMap(obj1(i).SessionID);
            if isempty(blockList)
                error('SimBiology:DIAGRAM_SETLINE_INVALID_OBJECT','Object does not have a block associated with it in the model diagram.');
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

    if isempty(pvpairs)

        if numel(lines)>1
            error('SimBiology:DIAGRAM_SETLINE_INVALID_OBJECT','Input object must have only one line connected to it.');
        end

        out=getSetDisplay;
        if nargout==0
            disp(out);
        else
            varargout={out};
        end
    else
        try
            if numel(pvpairs)==1&&~isstruct(pvpairs{1})
                out=getSetPropertyDisplay(pvpairs{:});
                varargout={out};
            else

                configureLineProperties(models,lines,pvpairs{:});
            end
        catch ex
            error(ex.identifier,ex.message);
        end
    end


    function out=getSetDisplay

        out=struct;
        props=getProperties;
        displayProps=getDisplayProperties;

        for i=1:length(props)
            if isSettable(props{i})
                out.(displayProps{i})=getOptions(props{i});
            end
        end


        function out=getSetPropertyDisplay(property)

            property=matchProperty(property);
            if isSettable(property)
                out=getOptions(property);
            else
                updateReadOnlyProperty(property);
            end


            function configureLineProperties(modelList,lineList,varargin)

                pvpairs=cleanupPVPairs(varargin{:});
                verifyPVPairSizes(lineList,pvpairs);

                models=unique(modelList);
                for i=1:numel(models)
                    model=models(i);
                    lines=lineList((modelList==model));

                    syntax=model.getDiagramSyntax;
                    syntax.modify(@(operations)configureLinePropertiesOperations(operations,model,lines,pvpairs));
                end


                function configureLinePropertiesOperations(operations,model,lines,pvpairs)

                    evt.pvpairs=struct;
                    transaction=SimBiology.Transaction.create(model);
                    currentValues={};
                    newValues={};

                    for i=1:numel(lines)
                        if lines(i).isValid
                            propNewList=cell(1,numel(pvpairs));
                            propOldList=cell(1,numel(pvpairs));

                            for j=1:2:length(pvpairs)
                                prop=pvpairs{j};
                                value=pvpairs{j+1};
                                nextValue=getPropertyValueFromList(value,i);
                                oldValue=lines(i).getAttribute(prop).value;

                                operations.setAttributeValue(lines(i),prop,nextValue);

                                propNewList{j}=prop;
                                propNewList{j+1}=nextValue;

                                propOldList{j}=prop;
                                propOldList{j+1}=oldValue;
                            end

                            evt.pvpairs(i).pvpairs=propNewList;
                            evt.pvpairs(i).uuid=lines(i).uuid;


                            sessionIDs=SimBiology.web.diagram.utilhandler('getLineSessionIDs',lines(i));
                            currentValue=struct;
                            currentValue.sessionID=sessionIDs;
                            currentValue.values=createUndoStruct(propOldList);

                            newValue=struct;
                            newValue.sessionID=sessionIDs;
                            newValue.values=createUndoStruct(propNewList);

                            currentValues{end+1}=currentValue;%#ok<AGROW>
                            newValues{end+1}=newValue;%#ok<AGROW>
                        end
                    end

                    postEvent(evt,model);


                    currentValues=[currentValues{:}];
                    newValues=[newValues{:}];

                    transaction.push(@()SimBiology.web.diagram.undo.lineAttributeLambda(model,currentValues,newValues));
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
                                case 'linecolor'
                                    pvpairs{i+1}=updateColor('Color',pvpairs{i+1});
                                case 'linewidth'
                                    pvpairs{i+1}=updateWidth(pvpairs{i+1});
                                case{'connections'}
                                    updateReadOnlyProperty(prop);
                                end
                            end


                            function out=createUndoStruct(pvpairs)

                                out=simbio.diagram.internal.utilhandler('createUndoStruct',pvpairs);


                                function verifyPVPairSizes(lineList,pvpairs)

                                    simbio.diagram.internal.utilhandler('verifyPVPairSizes',lineList,pvpairs);


                                    function props=getDisplayProperties

                                        props={'Color','Connections','Width'};


                                        function props=getProperties

                                            props={'linecolor','connections','linewidth'};


                                            function out=isSettable(prop)

                                                out=~any(strcmpi(prop,{'connections'}));


                                                function value=updateColor(prop,value)

                                                    value=simbio.diagram.internal.utilhandler('updateColorValueForSet',prop,value);


                                                    function value=updateWidth(value)

                                                        for i=1:numel(value)
                                                            if~isnumeric(value{i})
                                                                error('MATLAB:class:RequireNumeric','Unable to set the property ''Width''. Value must be numeric.');
                                                            elseif value{i}<=0
                                                                error('MATLAB:class:RequireNumeric','Unable to set the property ''Width''. Value must be greater than zero.');
                                                            end
                                                        end


                                                        function updateReadOnlyProperty(property)

                                                            simbio.diagram.internal.utilhandler('updateReadOnlyProperty',property,getDisplayProperties,getProperties);


                                                            function options=getOptions(prop)

                                                                switch(prop)
                                                                otherwise
                                                                    options={};
                                                                end


                                                                function value=matchProperty(value)

                                                                    value=simbio.diagram.internal.utilhandler('matchProperty',value,getDisplayProperties,getProperties);


                                                                    function out=getModelFromSessionID(sessionID)

                                                                        out=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);


                                                                        function postEvent(evt,model)

                                                                            evt.type='linePropertyChangedMATLAB';
                                                                            evt.modelSessionID=model.SessionID;

                                                                            message.publish('/SimBiology/blockPropertyChanged',evt);
