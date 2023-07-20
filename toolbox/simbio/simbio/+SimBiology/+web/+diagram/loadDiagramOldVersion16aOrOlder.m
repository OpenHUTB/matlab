function loadDiagramOldVersion16aOrOlder(operations,model,syntax,inputs)




    SimBiology.web.diagram.createDiagramFromModel(operations,model,syntax);

    try

        propertyInfo=SimBiology.web.diagram.convertDiagramViewFile(inputs.viewFile);


        imgFolder='';
        if~isempty(inputs.imageFile)
            imgFolder=tempname;


            unzip(inputs.imageFile,imgFolder);


            cleanupVar=onCleanup(@()rmdir(imgFolder,'s'));
        end

        configureDiagramFromViewFile(operations,model,syntax,propertyInfo,imgFolder);
    catch
    end

    reparentAllBlocks(operations,model)

end

function configureDiagramFromViewFile(operations,model,syntax,propertyInfo,imgFolder)

    configureObjectsFromViewFile(operations,model,syntax,model.Compartments,'compartment',propertyInfo,imgFolder);
    configureObjectsFromViewFile(operations,model,syntax,model.Species,'species',propertyInfo,imgFolder);
    configureObjectsFromViewFile(operations,model,syntax,model.Parameters,'parameter',propertyInfo,imgFolder);
    configureObjectsFromViewFile(operations,model,syntax,model.Reactions,'reaction',propertyInfo,imgFolder);
    configureObjectsFromViewFile(operations,model,syntax,model.Rules,'rule',propertyInfo,imgFolder);

end

function configureObjectsFromViewFile(operations,model,syntax,objects,type,propertyInfo,imgFolder)

    needToConfigure=[];

    for i=1:length(objects)
        okToConfigure=true;
        fieldName=[type,num2str(i-1)];
        if isfield(propertyInfo,fieldName)
            next=propertyInfo.(fieldName);
            sessionID=objects(i).SessionID;
            block=model.getEntitiesInMap(sessionID);

            if iscell(next)

                needToConfigure(end+1)=i;%#ok<AGROW>
                okToConfigure=false;


                inputs.modelSessionID=model.SessionID;
                inputs.property='cloned';
                inputs.value='split';
                inputs.selection.diagramUUID=block.uuid;
                inputs.selection.sessionID=sessionID;
                inputs.selection.type=objects(i).type;
                inputs.selection.value=inputs.value;
                SimBiology.web.diagram.clonehandler('splitInternal',operations,syntax.root,inputs);
            end

            if okToConfigure&&~isempty(block)
                props=fieldnames(next);

                for j=1:length(props)
                    try
                        inputs=[];
                        inputs.modelSessionID=model.SessionID;
                        inputs.property=props{j};
                        inputs.value=next.(props{j});
                        inputs.selection.diagramUUID=block.uuid;
                        inputs.selection.sessionID=sessionID;
                        inputs.selection.value=inputs.value;

                        if strcmp(inputs.property,'position')
                            inputs.property='positionOnLoad';
                            inputs.positionInfo.diagramUUID=inputs.selection.diagramUUID;
                            inputs.positionInfo.sessionID=inputs.selection.sessionID;
                            inputs.positionInfo.x=inputs.value(1);
                            inputs.positionInfo.y=inputs.value(2);
                        end

                        if strcmp(inputs.property,'size')
                            inputs.positionInfo.diagramUUID=inputs.selection.diagramUUID;
                            inputs.positionInfo.sessionID=inputs.selection.sessionID;
                            inputs.positionInfo.width=inputs.value(1);
                            inputs.positionInfo.height=inputs.value(2);
                        end

                        if strcmp(props{j},'imageString')


                            convertedPath=strrep(inputs.value,'\','/');
                            [~,filename,ext]=fileparts(convertedPath);
                            imagePath=fullfile(imgFolder,'images',[filename,ext]);


                            if exist(imagePath,'file')==2

                                inputs.property='shape';
                                inputs.value=imagePath;
                                inputs.selection.value=imagePath;
                            end
                        end


                        if strcmp(type,'compartment')&&strcmp(inputs.property,'visible')
                            inputs.value='true';
                            inputs.selection.value=inputs.value;
                        end

                        setProperty(operations,model,syntax.root,inputs);
                    catch
                    end
                end
            end
        else




            if isa(objects(i),'SimBiology.Species')
                sessionID=objects(i).SessionID;
                block=model.getEntitiesInMap(sessionID);
                parentBlock=model.getEntitiesInMap(objects(i).Parent.SessionID);
                parentPosition=parentBlock.getPosition;
                operations.setPosition(block,parentPosition.x,parentPosition.y);
            end
        end
    end


    for i=1:length(needToConfigure)
        index=needToConfigure(i);
        next=propertyInfo.([type,num2str(index-1)]);

        if~iscell(next)
            next={next};
        end

        sessionID=objects(index).SessionID;
        block=model.getEntitiesInMap(sessionID);


        if numel(block)>numel(next)
            startIndex=numel(next)+1;
            extraBlocks=block(startIndex:end);
            SimBiology.web.diagram.clonehandler('blockMergeHelper',operations,model,block(1),extraBlocks);
        end

        for k=1:length(next)
            props=fieldnames(next{k});
            for j=1:length(props)
                try
                    inputs=[];
                    inputs.modelSessionID=model.SessionID;
                    inputs.property=props{j};
                    inputs.value=next{k}.(props{j});
                    inputs.selection.diagramUUID=block(k).uuid;
                    inputs.selection.sessionID=sessionID;
                    inputs.selection.value=inputs.value;

                    if strcmp(inputs.property,'position')
                        inputs.property='positionOnLoad';
                        inputs.positionInfo.diagramUUID=inputs.selection.diagramUUID;
                        inputs.positionInfo.sessionID=inputs.selection.sessionID;
                        inputs.positionInfo.x=inputs.value(1);
                        inputs.positionInfo.y=inputs.value(2);
                    end

                    if strcmp(inputs.property,'size')
                        inputs.positionInfo.diagramUUID=inputs.selection.diagramUUID;
                        inputs.positionInfo.sessionID=inputs.selection.sessionID;
                        inputs.positionInfo.width=inputs.value(1);
                        inputs.positionInfo.height=inputs.value(2);
                    end

                    setProperty(operations,model,syntax.root,inputs);
                catch
                end
            end
        end
    end

end

function setProperty(operations,model,root,inputs)

    SimBiology.web.diagramhandler('setProperty',operations,model,root,inputs);

end

function reparentAllBlocks(operations,model)

    SimBiology.web.diagram.layouthandler('reparentAllBlocks',operations,model);
end
