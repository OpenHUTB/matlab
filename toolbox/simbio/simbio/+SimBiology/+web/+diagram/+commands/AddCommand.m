classdef AddCommand<diagram.editor.Command
    properties
        uuid={};
        sessionID=-1;
        lhsInfo=[];
    end

    methods(Access=protected)
        function execute(obj)
            input=obj.data;
            model=input.model;
            syntax=model.getDiagramSyntax;


            syntax.modify(@(operations)input.objectAddedOperationsFcn(operations,model,syntax,input.blocksNeedingConfiguration,input.input));


            obj.sessionID=input.input.info.SessionID;
            block=model.getEntitiesInMap(obj.sessionID);
            if~isempty(block)
                obj.uuid=block.uuid;
            end





            sobj=sbioselect(model,'SessionID',obj.sessionID);
            if isa(sobj,'SimBiology.Rule')


                obj.lhsInfo=obj.getLHSParametersForRule(model,sobj);
            elseif isa(sobj,'SimBiology.Event')
                obj.lhsInfo=obj.getLHSParametersForEvent(model,sobj);
            end


            transaction=SimBiology.Transaction.create(input.model);
            transaction.push(@()obj.addCommandUndoLambda());
            transaction.commit();
        end

        function state=getLHSParametersForRule(~,model,rule)
            state=[];
            lhsObj=parserule(rule);

            if~isempty(lhsObj)
                lhsObj=resolveobject(rule,lhsObj{1});
            end



            if~isempty(lhsObj)&&isa(lhsObj,'SimBiology.Parameter')
                block=model.getEntitiesInMap(lhsObj.SessionID);
                state.sessionID=lhsObj.SessionID;
                state.uuid='';
                if~isempty(block)
                    state.uuid=block.uuid;
                end
            end
        end

        function state=getLHSParametersForEvent(~,model,evt)
            state=[];
            lhsObj=parseeventfcns(evt);
            count=1;




            for i=1:length(lhsObj)
                lhsToken=lhsObj{i};
                if~isempty(lhsToken)
                    lhsToken=lhsToken{1};
                else
                    lhsToken='';
                end

                nextObj=resolveobject(evt,lhsToken);
                if~isempty(nextObj)&&isa(nextObj,'SimBiology.Parameter')
                    block=model.getEntitiesInMap(nextObj.SessionID);
                    state(count).sessionID=nextObj.SessionID;%#ok<*AGROW>
                    state(count).uuid='';
                    if~isempty(block)
                        state(count).uuid=block.uuid;
                    end
                    count=count+1;
                end
            end
        end
    end

    methods
        function cmd=AddCommand(data,syntax)
            cmd@diagram.editor.Command(data,syntax);
        end

        function addCommandUndoLambda(obj)
            try
                obj.data.commandProcessor.undo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.addCommandRedoLambda());
                transaction.commit();
            catch

            end
        end

        function addCommandRedoLambda(obj)
            try
                obj.data.commandProcessor.redo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.addCommandUndoLambda());
                transaction.commit();
            catch

            end
        end
    end

    methods(Access=protected)
        function undo(obj)


            blocks=obj.data.model.getEntitiesInMap(obj.sessionID);
            for i=1:numel(blocks)
                obj.data.model.deleteEntitiesInMap(obj.sessionID,blocks(i));
            end



            expressionObj=sbioselect(obj.data.model,'SessionID',obj.sessionID);



            for i=1:numel(obj.lhsInfo)
                if~isempty(obj.lhsInfo(i).uuid)
                    param=sbioselect(obj.data.model,'SessionID',obj.lhsInfo(i).sessionID);
                    block=obj.syntax.findElement(obj.lhsInfo(i).uuid);
                    if~SimBiology.web.diagram.utilhandler('keepParameterBlock',param,expressionObj)
                        obj.data.model.deleteEntitiesInMap(obj.lhsInfo(i).sessionID,block);
                    end
                end
            end


            obj.undoDefault();
        end

        function redo(obj)


            obj.redoDefault();


            if~isempty(obj.uuid)
                blockToAdd=obj.syntax.findElement(obj.uuid);
                obj.data.model.addEntitiesToMap(obj.sessionID,blockToAdd);
            end



            for i=1:numel(obj.lhsInfo)
                if~isempty(obj.lhsInfo(i).uuid)
                    existingBlock=obj.data.model.getEntitiesInMap(obj.lhsInfo(i).sessionID);
                    if isempty(existingBlock)
                        block=obj.syntax.findElement(obj.lhsInfo(i).uuid);
                        obj.data.model.addEntitiesToMap(obj.lhsInfo(i).sessionID,block);
                    end
                end
            end
        end
    end
end