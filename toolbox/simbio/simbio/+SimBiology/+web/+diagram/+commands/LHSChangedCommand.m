classdef LHSChangedCommand<diagram.editor.Command
    properties
        sessionID=-1;
        undoInfo=[];
        redoInfo=[];
    end

    methods(Access=protected)
        function execute(obj)
            input=obj.data;
            model=input.model;
            syntax=model.getDiagramSyntax;
            obj.sessionID=input.sessionID;
            obj.undoInfo=input.undoInfo;




            syntax.modify(@(operations)input.lhsChangedOperationsFcn(operations,model,syntax,input));



            obj.redoInfo=cell(1,numel(input.sessionID));
            for i=1:numel(input.sessionID)
                sobj=sbioselect(model,'SessionID',input.sessionID(i));
                if isa(sobj,'SimBiology.Event')
                    obj.redoInfo{i}=obj.getLHSParametersForEventFromObject(model,sobj);
                elseif isa(sobj,'SimBiology.Rule')
                    obj.redoInfo{i}=obj.getLHSParametersForRuleFromObject(model,sobj);
                end
            end


            transaction=SimBiology.Transaction.create(input.model);
            transaction.push(@()obj.propertyChangedCommandUndoLambda());
            transaction.commit();
        end

        function state=getLHSParametersForRuleFromObject(~,model,rule)
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

        function state=getLHSParametersForEventFromObject(~,model,evt)
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
        function cmd=LHSChangedCommand(data,syntax)
            cmd@diagram.editor.Command(data,syntax);
        end

        function propertyChangedCommandUndoLambda(obj)
            try
                obj.data.commandProcessor.undo()
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.propertyChangedCommandRedoLambda());
                transaction.commit();
            catch

            end
        end

        function propertyChangedCommandRedoLambda(obj)
            try
                obj.data.commandProcessor.redo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.propertyChangedCommandUndoLambda());
                transaction.commit();
            catch

            end
        end
    end

    methods(Access=protected)
        function undo(obj)





            for i=1:numel(obj.redoInfo)
                next=obj.redoInfo{i};
                for j=1:numel(next)
                    block=obj.data.model.getEntitiesInMap(next(j).sessionID);
                    obj.data.model.deleteEntitiesInMap(next(j).sessionID,block);
                end
            end


            obj.undoDefault();



            for i=1:numel(obj.undoInfo)
                next=obj.undoInfo{i};
                for j=1:numel(next)
                    existingBlock=obj.data.model.getEntitiesInMap(next(j).sessionID);
                    if isempty(existingBlock)
                        block=obj.syntax.findElement(next(j).uuid);
                        obj.data.model.addEntitiesToMap(next(j).sessionID,block);
                    end
                end
            end
        end

        function redo(obj)





            for i=1:numel(obj.undoInfo)
                next=obj.undoInfo{i};
                for j=1:numel(next)
                    block=obj.data.model.getEntitiesInMap(next(j).sessionID);
                    obj.data.model.deleteEntitiesInMap(next(j).sessionID,block);
                end
            end

            obj.redoDefault();



            for i=1:numel(obj.redoInfo)
                next=obj.redoInfo{i};
                for j=1:numel(next)
                    existingBlock=obj.data.model.getEntitiesInMap(next(j).sessionID);
                    if isempty(existingBlock)
                        block=obj.syntax.findElement(next(j).uuid);
                        obj.data.model.addEntitiesToMap(next(j).sessionID,block);
                    end
                end
            end
        end
    end
end