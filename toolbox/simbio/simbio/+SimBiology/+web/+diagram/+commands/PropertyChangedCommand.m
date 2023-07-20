classdef PropertyChangedCommand<diagram.editor.Command
    properties
        sessionID=-1;
        undoInfo=[];
        redoInfo=[];
        lhsUndoInfo=[];
        lhsRedoInfo=[];
    end

    methods(Access=protected)
        function execute(obj)
            input=obj.data;
            model=input.model;
            syntax=model.getDiagramSyntax;
            sobj=sbioselect(model,'SessionID',input.obj);
            obj.sessionID=input.obj;



            isRuleTypeProp=strcmp(input.objType,'rule')&&strcmp(input.property,'RuleType');



            if isRuleTypeProp
                block=model.getEntitiesInMap(sobj.SessionID);
                obj.lhsUndoInfo=obj.getLHSParametersForRuleFromDiagram(model,sobj);
                obj.undoInfo.sessionID=sobj.SessionID;
                if~isempty(block)
                    obj.undoInfo.uuid=block.uuid;
                else
                    obj.undoInfo.uuid='';
                end
            end




            syntax.modify(@(operations)input.propertyChangedOperationsFcn(operations,model,syntax,sobj,input));



            if isRuleTypeProp
                block=model.getEntitiesInMap(sobj.SessionID);
                obj.lhsRedoInfo=obj.getLHSParametersForRuleFromObject(model,sobj);
                obj.redoInfo.sessionID=sobj.SessionID;
                if~isempty(block)
                    obj.redoInfo.uuid=block.uuid;
                else
                    obj.redoInfo.uuid='';
                end
            end


            transaction=SimBiology.Transaction.create(input.model);
            transaction.push(@()obj.propertyChangedCommandUndoLambda());
            transaction.commit();
        end

        function state=getLHSParametersForRuleFromDiagram(~,model,rule)
            state=[];
            block=model.getEntitiesInMap(rule.SessionID);
            if isempty(block)


                return;
            end

            lhsLine=SimBiology.web.diagram.linehandler('getLHSLines',block);

            if~isempty(lhsLine)
                lhsBlock=lhsLine{1}.destination;
                if~isequal(lhsLine{1}.source.uuid,block.uuid)
                    lhsBlock=lhsLine{1}.source;
                end

                lhsSessionID=lhsBlock.getAttribute('sessionID').value;
                lhsObj=sbioselect(model,'SessionID',lhsSessionID);
                if isa(lhsObj,'SimBiology.Parameter')
                    state.sessionID=lhsSessionID;
                    state.uuid=lhsBlock.uuid;
                end
            end
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
    end

    methods
        function cmd=PropertyChangedCommand(data,syntax)
            cmd@diagram.editor.Command(data,syntax);
        end

        function propertyChangedCommandUndoLambda(obj)
            try
                obj.data.commandProcessor.undo();
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





            for i=1:numel(obj.lhsRedoInfo)
                block=obj.data.model.getEntitiesInMap(obj.lhsRedoInfo(i).sessionID);
                if~isempty(block)
                    obj.data.model.deleteEntitiesInMap(obj.lhsRedoInfo(i).sessionID,block);
                end
            end


            if~isempty(obj.redoInfo)
                block=obj.data.model.getEntitiesInMap(obj.redoInfo.sessionID);
                if~isempty(block)
                    obj.data.model.deleteEntitiesInMap(obj.redoInfo.sessionID,block);
                end
            end


            obj.undoDefault();



            for i=1:numel(obj.lhsUndoInfo)
                existingBlock=obj.data.model.getEntitiesInMap(obj.lhsUndoInfo(i).sessionID);
                if isempty(existingBlock)
                    if~isempty(obj.lhsUndoInfo(i).uuid)
                        block=obj.syntax.findElement(obj.lhsUndoInfo(i).uuid);
                        obj.data.model.addEntitiesToMap(obj.lhsUndoInfo(i).sessionID,block);
                    end
                end
            end


            if~isempty(obj.undoInfo)
                existingBlock=obj.data.model.getEntitiesInMap(obj.undoInfo.sessionID);
                if isempty(existingBlock)&&~isempty(obj.undoInfo.uuid)
                    block=obj.syntax.findElement(obj.undoInfo.uuid);
                    if~isempty(block)
                        obj.data.model.addEntitiesToMap(obj.undoInfo.sessionID,block);
                    end
                end
            end
        end

        function redo(obj)





            for i=1:numel(obj.lhsUndoInfo)
                block=obj.data.model.getEntitiesInMap(obj.lhsUndoInfo(i).sessionID);
                if~isempty(block)
                    obj.data.model.deleteEntitiesInMap(obj.lhsUndoInfo(i).sessionID,block);
                end
            end


            if~isempty(obj.undoInfo)
                block=obj.data.model.getEntitiesInMap(obj.undoInfo.sessionID);
                if~isempty(block)
                    obj.data.model.deleteEntitiesInMap(obj.undoInfo.sessionID,block);
                end
            end

            obj.redoDefault();



            for i=1:numel(obj.lhsRedoInfo)
                existingBlock=obj.data.model.getEntitiesInMap(obj.lhsRedoInfo(i).sessionID);
                if isempty(existingBlock)&&~isempty(obj.lhsRedoInfo(i).uuid)
                    block=obj.syntax.findElement(obj.lhsRedoInfo(i).uuid);
                    obj.data.model.addEntitiesToMap(obj.lhsRedoInfo(i).sessionID,block);
                end
            end


            if~isempty(obj.redoInfo)
                existingBlock=obj.data.model.getEntitiesInMap(obj.redoInfo.sessionID);
                if isempty(existingBlock)&&~isempty(obj.redoInfo.uuid)
                    block=obj.syntax.findElement(obj.redoInfo.uuid);
                    if~isempty(block)
                        obj.data.model.addEntitiesToMap(obj.redoInfo.sessionID,block);
                    end
                end
            end
        end
    end
end