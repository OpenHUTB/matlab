function varargout=splitBlock(obj)





















    if~isa(obj,'SimBiology.Species')
        error('SimBiology:DIAGRAM_SPLIT_INVALID_OBJECT','Invalid syntax. Input object must be a scalar SimBiology species object.');
    end

    if numel(obj)>1
        error('SimBiology:DIAGRAM_SPLIT_INVALID_OBJECT','Invalid syntax. Input object must be a scalar SimBiology species object.');
    end

    model=getModelFromSessionID(obj(1).ParentModelSessionID);
    if~model.hasDiagramSyntax
        error('SimBiology:DIAGRAM_SPLIT_INVALID_DIAGRAM','Model does not have a diagram. Add the model to the SimBiology Model Builder app to create the diagram.');
    end

    syntax=model.getDiagramSyntax;
    splitOperations(model,syntax.root,obj);


    if nargout==1
        expr=getConnections(model,obj);
        varargout={expr};
    end


    function splitOperations(model,root,obj)

        selection=struct('sessionID',-1,'diagramUUID','','type','species');
        count=1;



        blocks=model.getEntitiesInMap(obj.SessionID);
        for i=1:numel(blocks)
            selection(count).sessionID=obj.SessionID;
            selection(count).diagramUUID=blocks(i).uuid;
            selection(count).type=obj.Type;
            count=count+1;
        end

        inputs.modelSessionID=model.SessionID;
        inputs.selection=selection;
        inputs.property='cloned';
        inputs.value='split';

        SimBiology.web.diagram.clonehandler('split',root,inputs);

        postEvent(model);


        function out=getConnections(model,obj)

            blocks=model.getEntitiesInMap(obj.SessionID);
            out=SimBiology.web.diagram.utilhandler('getConnections',model,blocks);


            function out=getModelFromSessionID(sessionID)

                out=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);


                function postEvent(model)

                    evt.type='blockSplitChangedMATLAB';
                    evt.modelSessionID=model.SessionID;

                    message.publish('/SimBiology/blockPropertyChanged',evt);