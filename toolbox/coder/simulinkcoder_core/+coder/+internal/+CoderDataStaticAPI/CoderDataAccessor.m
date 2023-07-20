classdef CoderDataAccessor





    properties(Access=private)
source
    end

    methods(Access={?coder.internal.CoderDataStaticAPI.MF0_IF})
        function obj=CoderDataAccessor(source)






            obj.source=source;
        end

        function[definitions,fPath,container]=getCoderSpecifications(obj,dictionaryType,needLocal)


            if isa(obj.source,'Simulink.data.Dictionary')
                ddFilePath=obj.source.filepath;
                [inProject,~]=getProjectForArtifact(ddFilePath);
                if~needLocal&&inProject
                    [definitions,fPath,container]=getCoderSpec(ddFilePath,dictionaryType);
                else
                    [definitions,fPath,container]=getLocalSpecs(obj.source,dictionaryType);
                end
            elseif isa(obj.source,'matlab.project.Project')
                [toolsProj,ddObj]=getToolsFromProj(obj.source);
                if isempty(toolsProj)||isempty(ddObj)
                    DAStudio.error('SimulinkCoderApp:core:ToolsDataNotFoundInProjects');
                end
                [definitions,fPath,container]=getLocalSpecs(ddObj,dictionaryType);
            else

                if ischar(obj.source)||isstring(obj.source)


                    [~,~,ext]=fileparts(obj.source);
                    if strcmp(ext,'.sldd')

                        ddObj=Simulink.data.dictionary.open(obj.source);
                        if isempty(ddObj)
                            DAStudio.error('SimulinkCoderApp:core:DictionaryNotFound',obj.source);
                        end
                        ddFilePath=ddObj.filepath();
                        [inProject,~]=getProjectForArtifact(ddFilePath);


                        if~needLocal&&inProject
                            [definitions,fPath,container]=getCoderSpec(ddFilePath,dictionaryType);
                        else
                            [definitions,fPath,container]=getLocalSpecs(ddObj,dictionaryType);
                        end
                    else

                        modelFullPath=get_param(obj.source,'FileName');
                        [inProject,~]=getProjectForArtifact(modelFullPath);

                        if~needLocal&&inProject
                            [definitions,fPath,container]=getCoderSpec(modelFullPath,dictionaryType);
                        else
                            container=get_param(obj.source,'CoderDictionary');
                            definitions=coder.internal.CoderDataStaticAPI.MF0_IF.getDefinitions(container,dictionaryType);
                            fPath=get_param(obj.source,'FileName');
                        end
                    end
                else

                    assert(isfloat(obj.source),'Unrecognized dictionary container');















                    modelFullPath=get_param(obj.source,'FileName');
                    [inProject,~]=getProjectForArtifact(modelFullPath);
                    hasShared=~isempty(coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(get_param(obj.source,'Handle')));
                    container=get_param(obj.source,'CoderDictionary');
                    hasLocal=~container.isEmpty;

                    if hasLocal||needLocal

                        definitions=coder.internal.CoderDataStaticAPI.MF0_IF.getDefinitions(container,dictionaryType);
                        fPath=get_param(obj.source,'FileName');





                    elseif hasShared

                        ddStr=get_param(obj.source,'DataDictionary');
                        dd=Simulink.data.dictionary.open(ddStr);



                        [definitions,fPath,container]=getLocalSpecs(dd,dictionaryType);





                    elseif~needLocal&&inProject


                        [definitions,fPath,container]=getCoderSpec(modelFullPath,dictionaryType);
                    else


                        definitions=coder.internal.CoderDataStaticAPI.MF0_IF.getDefinitions(container,dictionaryType);
                        fPath=get_param(obj.source,'FileName');
                    end
                end
            end
        end
    end

    methods(Static)


        function out=getToolsDictNameFromProjectClosure(source)
            out=[];
            if isempty(source)
                return;
            end
            valid=coder.dictionary.internal.isValidSource(source);
            if~valid
                return;
            end
            filePath=[];
            if isa(source,'Simulink.data.Dictionary')

                filePath=source.filepath;
            elseif ischar(source)||isstring(source)
                [~,~,ext]=fileparts(source);
                if strcmp(ext,'.sldd')

                    ddObj=Simulink.data.dictionary.open(source);
                    if isempty(ddObj)
                        DAStudio.error('SimulinkCoderApp:core:DictionaryNotFound',source);
                    end
                    filePath=ddObj.filepath();
                else


                    if bdIsLoaded(source)
                        filePath=get_param(source,'FileName');
                    end
                end
            end

            [~,fPath,~]=getCoderSpec(filePath,'C');
            [~,name,ext]=fileparts(fPath);
            out=[name,ext];
        end
    end
end


function[definitions,fPath,container]=getCoderSpec(filePath,dictionaryType)
    [~,p]=getProjectForArtifact(filePath);



    [toolsProj,ddObj]=getToolsFromProj(p);
    if isempty(toolsProj)||isempty(ddObj)
        DAStudio.error('SimulinkCoderApp:core:ToolsDataNotFoundInProjects');
    end


    [definitions,fPath,container]=getLocalSpecs(ddObj,dictionaryType);
end

function[isProject,p]=getProjectForArtifact(item)


    p={};

    [isProject,root]=matlab.internal.project.util.isFileInProject(item);
    if isProject
        p=matlab.internal.project.api.makeProjectAvailable(root);
    end
end

function[toolsProj,ddWithCD]=getToolsFromProj(proj)




    toolsProj={};
    toolsProjs={};
    ddWithCD={};
    toolsProjs=getToolsFromAllProjects(proj,toolsProjs);

    if~isempty(toolsProjs)
        if(length(toolsProjs)>1)


            DAStudio.error('SimulinkCoderApp:core:MultipleToolsInProjectHierarchy');
        end
        toolsProj=toolsProjs{1};
        [~,dds]=getSLDDWithCDFromProj(toolsProj);
        if length(dds)>1


            DAStudio.error('SimulinkCoderApp:data:OneDictionaryPerClosure',dds{1}.filepath,dds{2}.filepath);
        end
        ddWithCD=dds{1};
    end
end

function[allToolsProjs]=getToolsFromAllProjects(proj,currentToolsProjs)
    [containsSLDDwithCD,dds]=getSLDDWithCDFromProj(proj);
    if containsSLDDwithCD
        if(length(dds)>1)



            DAStudio.error('SimulinkCoderApp:data:OneDictionaryPerClosure',dds{1}.filepath,dds{2}.filepath);
        end
        currentToolsProjs{end+1}=proj;



        allToolsProjs=getAllToolsFromProjRefs(proj,currentToolsProjs);
    else
        allToolsProjs=getAllToolsFromProjRefs(proj,currentToolsProjs);
    end
end

function allToolsProjs=getAllToolsFromProjRefs(proj,currentToolsProjs)
    projRefs=proj.ProjectReferences;
    if~isempty(projRefs)
        for i=1:length(projRefs)
            rProj=projRefs(i).Project;
            currentToolsProjs=getToolsFromAllProjects(rProj,currentToolsProjs);
            if~isempty(currentToolsProjs)

                allToolsProjs=currentToolsProjs;

            end
        end
    else
        allToolsProjs=currentToolsProjs;
    end
end



function[bool,out]=getSLDDWithCDFromProj(proj)


    bool=false;
    out={};
    allFiles=proj.Files;
    for i=1:length(allFiles)
        [~,name,ext]=fileparts(allFiles(i).Path);
        if strcmp(ext,'.sldd')
            slddName=[char(name),char(ext)];
            [hasCD,ddObj]=checkLocalForCoderDict(slddName);
            if hasCD
                out{end+1}=ddObj;
                bool=true;
            end
        end
    end
end

function[bool,out]=checkLocalForCoderDict(slddName)
    out={};
    bool=false;
    if coderdictionary.data.api.hasDictionary(slddName)
        out=Simulink.data.dictionary.open(slddName);
        bool=true;
    end
end

function[definitions,fPath,container]=getLocalSpecs(ddObj,dictionaryType)


    container=coderdictionary.data.api.getDictionary(ddObj.filepath);
    definitions=coder.internal.CoderDataStaticAPI.MF0_IF.getDefinitions(container,dictionaryType);
    fPath=ddObj.filepath;
end



