classdef VariableManager<handle




    properties(Constant,Access=private)
        UID_MAP_TAG='UIDToVariable'
        VARIABLE_FRAME_MAP_TAG='VarIDToWSAndJFrame'
    end

    methods(Static)
        function id=storeVariable(editorId,variableName,variableValue)











            import matlab.internal.editor.*

            validateattributes(editorId,{'char'},{'nonempty'},'VariableManager.storeVariable','editorId',1);
            validateattributes(variableName,{'char'},{'nonempty'},'VariableManager.storeVariable','variableName',2);



            id=char(matlab.internal.editor.RandGeneratorUtilities.RandomGenerator.randi([97,122],1,15));


            uidMap=EODataStore.getEditorSubMap(editorId,VariableManager.UID_MAP_TAG);
            uidMap(id)=struct('Name',variableName,...
            'Value',variableValue);%#ok<NASGU>
        end

        function removeVariables(editorId,variableIds)






            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.VariableManager

            validateattributes(editorId,{'char'},{'nonempty'},'VariableManager.storeVariable','editorId',1);
            validateattributes(variableIds,{'cell'},{'nonempty'},'VariableManager.storeVariable','variableId',2);

            uidMap=EODataStore.getEditorSubMap(editorId,VariableManager.UID_MAP_TAG);


            positionsToRemove=isKey(uidMap,variableIds);

            remove(uidMap,variableIds(positionsToRemove));
        end

        function removeAllVariablesForEditor(editorId)
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.VariableManager

            validateattributes(editorId,{'char'},{'nonempty'},'VariableManager.storeVariable','editorId',1);

            EODataStore.removeEditorSubMap(editorId,VariableManager.UID_MAP_TAG)
        end

        function clearAll(editorId)
            import matlab.internal.editor.VariableManager

            VariableManager.removeAllVariablesForEditor(editorId);
        end

        function openVariableEditor(editorId,id)



























            import matlab.internal.editor.VariableManager
            import matlab.internal.editor.EODataStore

            validateattributes(editorId,{'char'},{'nonempty'},'VariableManager.storeVariable','editorId',1);
            validateattributes(id,{'char'},{'nonempty'},'VariableManager.storeVariable','id',2);

            uidMap=EODataStore.getEditorSubMap(editorId,VariableManager.UID_MAP_TAG);
            if isKey(uidMap,id)



                frameAndWSById=VariableManager.getVariableFrameMap();

                if VariableManager.variableIsOpen(id)
                    VariableManager.bringFrameToFront(frameAndWSById(id).jframe);
                else







                    variableName=uidMap(id).Name;
                    variableValue=uidMap(id).Value;
                    [variable,ws]=VariableManager.convertVariableToWorkspaceVariable(variableName,variableValue);

                    [rows,columns]=size(variableValue);
                    [filename,client]=VariableManager.getFilenameForEditor(editorId);



                    variableViewer=javaMethodEDT('createVariableViewer','com.mathworks.mde.embeddedoutputs.variables.VariableViewer',...
                    variable,variableName,rows,columns,class(variableValue),filename,id,client);

                    frameAndWSById(id)=struct('ws',ws,'jframe',variableViewer);%#ok<NASGU>
                    VariableManager.bringFrameToFront(variableViewer);
                end
            end
        end

        function summaryValue=getSummaryValue(value)
            summaryValue=workspacefunc('getshortvalueobjectj',value);
        end

    end


    methods(Static,Hidden)

        function open=variableIsOpen(id)
            import matlab.internal.editor.VariableManager

            frameAndWSById=VariableManager.getVariableFrameMap();
            open=isKey(frameAndWSById,id);
        end

        function bringFrameToFront(frame)
            javaMethodEDT('setVisible',frame,true);
            javaMethodEDT('toFront',frame);
        end

        function frameAndWSById=getVariableFrameMap






            import matlab.internal.editor.VariableManager
            import matlab.internal.editor.EODataStore

            frameAndWSById=EODataStore.getRootField(VariableManager.VARIABLE_FRAME_MAP_TAG);


            if builtin('isempty',frameAndWSById)
                frameAndWSById=containers.Map();
                EODataStore.setRootField(VariableManager.VARIABLE_FRAME_MAP_TAG,frameAndWSById);
            end
        end

        function[variable,ws]=convertVariableToWorkspaceVariable(variableName,variableValue)









            import matlab.internal.editor.EODataStore

            ws=toolpack.databrowser.LocalWorkspaceModel;
            ws.assignin(variableName,variableValue);
            workspaceID=workspacefunc('getworkspaceid',ws);
            variable=com.mathworks.mlservices.WorkspaceVariable(variableName,workspaceID);
        end

        function removeWorkspaceForId(id)




            import matlab.internal.editor.VariableManager
            import matlab.internal.editor.EODataStore
            validateattributes(id,{'char'},{'nonempty'},'VariableManager.removeWSForId','id',1);

            frameAndWSById=VariableManager.getVariableFrameMap();
            if~isempty(frameAndWSById)&&isKey(frameAndWSById,id)
                ws=frameAndWSById(id).ws;
                ws.clear();
                wsId=workspacefunc('getworkspaceid',ws);
                workspacefunc('clearstoredworkspace',wsId);
                remove(frameAndWSById,id);
            end
        end

        function[filename,client]=getFilenameForEditor(editorId)


            app=com.mathworks.mde.liveeditor.LiveEditorApplication.getInstance();
            client=app.findLiveEditorClient(editorId);
            filename='';
            if~isempty(client)
                filename=client.getLiveEditor().getShortName();
            end

        end
    end

end