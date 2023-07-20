function out=modelhandler(action,varargin)

    switch(action)
    case 'loadModel'
        out=loadModel(varargin{:});
    case 'loadModelsOnly'
        out=loadModelsOnly(varargin{:});
    end


    function out=loadModel(projectConverter,fileNames,projectXML,node)

        out.modelInfo=[];
        out.sessionIDs=[];

        models=getModelObjects(projectConverter,fileNames);
        if isempty(models)
            out.modelInfo=[];
            out.sessionIDs=[];
            return;
        end


        try
            tempModelFileName=[SimBiology.web.internal.desktopTempname(),'.xml'];
            [success,msg]=copyfile(projectXML,tempModelFileName,'f');

            if~success
                projectConverter.addWarning(msg);
            end
        catch ex
            projectConverter.addError('Unable to load models from project',ex);
        end


        modelInfo=struct('name','','obj',-1,'diagramView','','imageFileName','','modelFileName','','info',struct);
        modelInfo=repmat(modelInfo,length(models),1);
        sessionIDs=zeros(1,length(models));
        modelNode=getField(node,'ProjectModels');
        modelNodes=getField(modelNode,'Model');

        if numel(modelNodes)~=length(models)
            projectConverter.addWarning('Unable to find the model definition file in the project. The Diagram layout might be lost.');
        end


        idx=true(size(models));
        for i=length(models):-1:1
            try
                nextModelObj=models(i);
                if okToLoadModel(projectConverter,nextModelObj)

                    if numel(modelNodes)>=i



                        tempViewFileName=getViewFileName(projectConverter,modelNodes(i),fileNames);


                        tempImageFileName=getImageFileName(projectConverter,modelNodes(i),fileNames);
                    end


                    modelInfo(i).name=nextModelObj.Name;
                    modelInfo(i).obj=nextModelObj.SessionID;
                    modelInfo(i).diagramView=tempViewFileName;
                    modelInfo(i).imageFileName=tempImageFileName;
                    modelInfo(i).modelFileName=tempModelFileName;



                    if~isempty(tempViewFileName)||projectConverter.initDiagramSyntax
                        diagramInputs=struct;
                        diagramInputs.model=nextModelObj;
                        diagramInputs.viewFile=tempViewFileName;
                        diagramInputs.imageFile=tempImageFileName;
                        diagramInputs.projectVersion=projectConverter.projectVersion;
                        SimBiology.web.diagramhandler('initDiagramSyntax',diagramInputs);
                    end


                    sessionIDs(i)=nextModelObj.SessionID;


                    input.sessionID=nextModelObj.SessionID;
                    input.usedComponents=[];
                    tempOut=SimBiology.web.modelhandler('getModelInfo',input);
                    modelInfo(i).info=tempOut{2};
                else
                    idx(i)=false;
                    delete(nextModelObj);
                end
            catch ex
                idx(i)=false;
                modelInfo(i).obj=-1;
                delete(nextModelObj);
                projectConverter.addError('Unable to build model structure for SimBiology Model Analyzer.',ex);
            end
        end

        out.modelInfo=modelInfo(idx);
        out.sessionIDs=sessionIDs(idx);


        function out=loadModelsOnly(projectConverter,fileNames)

            models=getModelObjects(projectConverter,fileNames);
            if isempty(models)
                out.modelInfo=[];
                out.sessionIDs=[];
                return;
            end


            modelInfo=struct('name','','obj',-1,'diagramView','','imageFileName','','modelFileName','','info',struct);
            modelInfo=repmat(modelInfo,length(models),1);
            sessionIDs=zeros(1,length(models));
            idx=true(size(models));


            modelNames={};
            for i=1:length(models)
                try
                    nextModelObj=models(i);
                    nextModelName=findUniqueName(modelNames,nextModelObj.Name);
                    set(nextModelObj,'Name',nextModelName);
                    modelNames{end+1}=nextModelName;%#ok<AGROW> 

                    if okToLoadModel(projectConverter,nextModelObj)

                        modelInfo(i).name=nextModelObj.Name;
                        modelInfo(i).obj=nextModelObj.SessionID;
                        modelInfo(i).diagramView='';
                        modelInfo(i).imageFileName='';
                        modelInfo(i).modelFileName='';


                        sessionIDs(i)=nextModelObj.SessionID;


                        input.sessionID=nextModelObj.SessionID;
                        input.usedComponents=[];
                        tempOut=SimBiology.web.modelhandler('getModelInfo',input);
                        modelInfo(i).info=tempOut{2};

                        if projectConverter.initDiagramSyntax
                            args=struct('model',nextModelObj,'viewFile','','projectVersion','');
                            SimBiology.web.diagramhandler('initDiagramSyntax',args);
                        end
                    else
                        idx(i)=false;
                        delete(nextModelObj);
                    end
                catch ex
                    idx(i)=false;
                    delete(nextModelObj);
                    projectConverter.addError('Unable to build model structure for SimBiology Model Analyzer',ex);
                end
            end

            out.modelInfo=modelInfo(idx);
            out.sessionIDs=sessionIDs(idx);


            function models=getModelObjects(projectConverter,fileNames)

                models=[];

                try
                    location=cellfun(@(x)~isempty(x),strfind(fileNames,'simbiodata.mat'));
                    modelFile=fileNames{location};


                    if isempty(modelFile)
                        return;
                    end


                    models=load(modelFile);

                    if isempty(models)
                        return;
                    end


                    models=struct2cell(models);


                    idx=cellfun(@(x)isa(x,'SimBiology.Model'),models);
                    models=[models{idx}];
                catch e
                    projectConverter.addError('Unable to load models from project.',e);
                end


                function tempViewFileName=getViewFileName(projectConverter,node,fileNames)

                    viewFile=getAttribute(node,'ViewFile');
                    viewFile=strrep(viewFile,'\','/');
                    [~,name,ext]=fileparts(viewFile);




                    viewFile=sprintf('%s%s',name,ext);
                    location=cellfun(@(x)~isempty(x),strfind(fileNames,viewFile));

                    if any(location)
                        viewFile=fileNames{location};
                        tempViewFileName=[SimBiology.web.internal.desktopTempname(),'.view'];
                        [success,msg]=copyfile(viewFile,tempViewFileName,'f');


                        if~success
                            projectConverter.addError('Unable to copy diagram viewfile',msg);
                        end
                    else
                        tempViewFileName='';
                    end


                    function tempImageFileName=getImageFileName(projectConverter,node,fileNames)


                        imageFile=getAttribute(node,'ImageFile');
                        imageFile=strrep(imageFile,'\','/');
                        [~,name,ext]=fileparts(imageFile);




                        imageFile=sprintf('%s%s',name,ext);
                        location=cellfun(@(x)~isempty(x),strfind(fileNames,imageFile));

                        if any(location)
                            imageFile=fileNames{location};
                            tempImageFileName=[SimBiology.web.internal.desktopTempname(),'.images'];
                            [success,msg]=copyfile(imageFile,tempImageFileName,'f');


                            if~success
                                projectConverter.addError('Unable to copy imagefile',msg);
                            end
                        else
                            tempImageFileName='';
                        end


                        function out=okToLoadModel(projectConverter,model)

                            if isempty(projectConverter.modelsToLoad)

                                out=true;
                            else
                                out=any(strcmp(model.Name,projectConverter.modelsToLoad));
                            end


                            function name=findUniqueName(allNames,nameIn)

                                if isempty(allNames)||~any(strcmp(allNames,nameIn))
                                    name=nameIn;
                                    return;
                                end

                                index=1;
                                newName=[nameIn,'_',num2str(index)];
                                while any(strcmp(allNames,newName))
                                    index=index+1;
                                    newName=[nameIn,'_',num2str(index)];
                                end

                                name=newName;


                                function out=getAttribute(node,attribute,varargin)

                                    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});


                                    function out=getField(node,field)

                                        out=SimBiology.web.internal.converter.utilhandler('getField',node,field);