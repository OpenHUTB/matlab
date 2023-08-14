function joinBlock(obj,varargin)




























    if~isa(obj,'SimBiology.Species')
        error('SimBiology:DIAGRAM_JOIN_INVALID_OBJECT','Invalid syntax. The input object must be a scalar SimBiology species object.');
    end

    if numel(obj)>1
        error('SimBiology:DIAGRAM_JOIN_INVALID_OBJECT','Invalid syntax. The input object must be a scalar SimBiology species object.');
    end

    model=getModelFromSessionID(obj.ParentModelSessionID);
    if~model.hasDiagramSyntax
        error('SimBiology:DIAGRAM_JOIN_INVALID_DIAGRAM','Model does not have a diagram. Add the model to the SimBiology Model Builder app to create the diagram.');
    end


    block1=[];%#ok<NASGU>
    block2=[];

    if nargin==1
        blocks=model.getEntitiesInMap(obj.SessionID);
        block1=blocks(1);
    elseif nargin==2
        exprObj=varargin{1};
        if isa(exprObj,'SimBiology.Reaction')||isa(exprObj,'SimBiology.Rule')
            if numel(exprObj)>1
                error('SimBiology:DIAGRAM_JOIN_INVALID_OBJECT','Invalid syntax. The expression object must be a scalar reaction, repeated assignment or rate rule.');
            end


            block1=getSplitBlock(model,obj,exprObj);
            if isempty(block1)
                error('SimBiology:DIAGRAM_JOIN_INVALID_OBJECT','Input object and expression object are not connected.');
            end
        else
            error('SimBiology:DIAGRAM_JOIN_INVALID_OBJECT','Invalid syntax. The expression object must be a scalar reaction, repeated assignment or rate rule.');
        end
    elseif nargin==3
        exprObj1=varargin{1};

        if isa(exprObj1,'SimBiology.Reaction')||isa(exprObj1,'SimBiology.Rule')
            if numel(exprObj1)>1
                error('SimBiology:DIAGRAM_JOIN_INVALID_OBJECT','Invalid syntax. The first expresion object must be a scalar reaction, repeated assignment or rate rule.');
            end


            block1=getSplitBlock(model,obj,exprObj1);
            if isempty(block1)
                error('SimBiology:DIAGRAM_JOIN_INVALID_OBJECT','The input object and the first expression object are not connected.');
            end
        else
            error('SimBiology:DIAGRAM_JOIN_INVALID_OBJECT','Invalid syntax. The first expression object must be a scalar reaction, repeated assignment or rate rule.');
        end

        exprObj2=varargin{2};
        if isa(exprObj2,'SimBiology.Reaction')||isa(exprObj2,'SimBiology.Rule')
            if numel(exprObj2)>1
                error('SimBiology:DIAGRAM_JOIN_INVALID_OBJECT','Invalid syntax. The second expression object must be a scalar reaction, repeated assignment or rate rule.');
            end


            block2=getSplitBlock(model,obj,exprObj2);
            if isempty(block2)
                error('SimBiology:DIAGRAM_JOIN_INVALID_OBJECT','The input object and second expression object are not connected.');
            end
        else
            error('SimBiology:DIAGRAM_JOIN_INVALID_OBJECT','Invalid syntax. The second expression object must be a scalar reaction, repeated assignment or rate rule.');
        end
    else
        error('SimBiology:DIAGRAM_JOIN_INVALID_SYNTAX','Invalid syntax. Refer to the help for more information.');
    end

    if nargin==1||nargin==2
        try
            joinBlocks(model,obj,block1);
        catch ex
            error(ex.identifier,ex.message);
        end
    else
        try
            mergeBlocks(model,obj,block1,block2);
        catch ex
            error(ex.identifier,ex.message);
        end
    end


    function joinBlocks(model,obj,blockToKeep)

        selection=struct;
        selection.sessionID=obj.SessionID;
        selection.diagramUUID=blockToKeep.uuid;
        selection.type=obj.Type;

        inputs.modelSessionID=model.SessionID;
        inputs.selection=selection;
        inputs.property='cloned';
        inputs.value='join';

        SimBiology.web.diagram.clonehandler('join',inputs);

        postEvent(model);


        function mergeBlocks(model,obj,block1,block2)

            mergeInfo.block=block2.uuid;
            mergeInfo.mergeIntoBlock=block1.uuid;
            mergeInfo.sessionID=obj.SessionID;
            mergeInfo.type='species';

            inputs.mergeInfo=mergeInfo;
            inputs.modelSessionID=model.SessionID;
            inputs.selection.sessionID=obj.SessionID;

            SimBiology.web.diagram.clonehandler('mergeWithUndo',model,inputs);

            postEvent(model);


            function block=getSplitBlock(model,species,expression)

                block=SimBiology.web.diagram.utilhandler('getSplitBlock',model,species,expression);


                function out=getModelFromSessionID(sessionID)

                    out=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);


                    function postEvent(model)

                        evt.type='blockSplitChangedMATLAB';
                        evt.modelSessionID=model.SessionID;

                        message.publish('/SimBiology/blockPropertyChanged',evt);