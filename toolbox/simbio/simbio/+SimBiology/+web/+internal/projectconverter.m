classdef projectconverter<SimBiology.web.internal.abstractProjectHelper











    properties
        project=struct;
        filename='';
        plotIndex=0;
        projectVersion='';
        initDiagramSyntax=false;
        isLoadModelsOnly=false;
        modelsToLoad={};
    end

    methods
        function convertProjects(obj,projectPath)
            try
                obj.filename=projectPath;


                externalData=struct('matfile','','data',[]);
                programDataInfo.data=[];
                programMATFileNames={};
                programs={};
                projectDescription='';
                modelInfo=[];
                plotDocuments=[];

                if~isequal(exist(projectPath,'file'),2)
                    obj.addError(sprintf('File %s does not exist',projectPath));
                    return;
                end


                convertedPath=strrep(projectPath,'\','/');
                [~,projectName]=fileparts(convertedPath);


                outputDir=fullfile(tempname,projectName);
                cleanupVar=onCleanup(@()cleanup(outputDir));


                fileNames=unzip(convertedPath,outputDir);


                idx=contains(fileNames,'.xml');

                if any(idx)

                    try
                        projectXML=fileNames{idx};
                        nodeStruct=readstruct(projectXML);
                    catch ex
                        obj.addError('Unable to parse the project XML.',ex);
                        return;
                    end

                    projectNodeStruct=nodeStruct.Project;
                    version=getAttribute(projectNodeStruct,'Version');
                    version=convertVersion(version);
                    obj.projectVersion=num2str(version);



                    matlabRelease=mapVersionToRelease(obj.projectVersion);

                    if any(ismember({'14SP3+','2006a','2006a+','2006b','2007a','2007b','2007b+','2008a','2008b','2009a','2009b','2010a','2010b','20011a','2011b'},matlabRelease))
                        obj.addError(sprintf('This version of SimBiology only supports projects saved in or after R2012a. The current project appears to have been saved with SimBiology version R%s',matlabRelease));
                    elseif obj.isLoadModelsOnly

                        modelInfo=loadModels(obj,fileNames,projectXML,projectNodeStruct);
                    else

                        [modelInfo,sessionIDs]=loadModels(obj,fileNames,projectXML,projectNodeStruct);



                        projectDescription=loadProjectDescriptionAndLicense(obj,projectNodeStruct);



                        externalData=loadExternalData(obj,fileNames,projectNodeStruct);


                        [programs,programData,programPlots]=loadPrograms(obj,fileNames,sessionIDs,projectNodeStruct,externalData);
                        programs=loadNCAProgram(obj,projectNodeStruct,externalData,programs);
                        programDataInfo.data=programData;



                        programMATFileNames=cell(1,length(programs));
                        for i=1:length(programs)
                            programMATFileNames{i}=sprintf('%s.mat',SimBiology.web.internal.desktopTempname());
                        end


                        plotDocuments=vertcat(plotDocuments,programPlots);




                        externalData=loadOrphanTaskData(obj,projectNodeStruct,fileNames,externalData);



                        backupProject(obj,projectPath,matlabRelease);
                    end
                else


                    [modelInfo,~]=loadModelsOnly(obj,fileNames);
                end
            catch ex
                obj.addError('Unable to convert project to new format',ex);
            end


            obj.project.ProjectName=projectPath;
            obj.project.ProjectDescription=projectDescription;
            obj.project.ProjectNameNoPath=projectName;
            obj.project.Models=modelInfo;
            obj.project.Programs=programs;
            obj.project.ProgramMATFileNames=programMATFileNames;
            obj.project.ExternalData=externalData;
            obj.project.ProgramData=programDataInfo;
            obj.project.PlotDocuments=plotDocuments;
            obj.project.DataSheets={};
            obj.project.PackageAppInfo=[];
        end


        function out=getPlotIndex(obj)
            obj.plotIndex=obj.plotIndex+1;
            out=obj.plotIndex;
        end
    end
end


function backupProject(projectConverter,projectPath,matlabRelease)

    try

        [path,projectName,ext]=fileparts(projectPath);



        backupProjectName=sprintf('%s_R%s%s.backup',projectName,matlabRelease,ext);
        backupFilePath=[path,filesep,backupProjectName];









        [fid,errmsg]=fopen(backupFilePath,'w');
        if~isempty(errmsg)&&fid==-1
            projectConverter.addWarning(sprintf('Unable to back up the project in %s because the folder is read-only. Create a backup of the project file manually before saving the project in the app.',path));
        else
            success=copyfile(projectPath,backupFilePath,'f');
            if~success
                projectConverter.addWarning(sprintf('Unable to back up the project in %s because the folder is read-only. Create a backup of the project file manually before saving the project in the app.',path));
            elseif~isempty(projectConverter.warnings)||~isempty(projectConverter.errors)
                projectConverter.addInfo(sprintf('SimBiology converted the project into the new project format for R%s and saved a backup of the original project in %s.',version('-release'),backupFilePath));
            end

            fclose(fid);
        end
    catch
        projectConverter.addWarning('Unable to back up the project due to an exception\n. Create a backup of the project file manually before saving the project in the app.');
    end

end


function out=loadProjectDescriptionAndLicense(projectConverter,node)

    out=struct;
    out.projectDescription='';
    out.projectLicense='';
    out.type='Project';
    out.version=1;
    out.internal='';


    out.internal=getInternalStructTemplate;
    out.internal.isSetup=true;

    try


        out.projectDescription=getAttribute(node,'ProjectDescription','');
        out.projectLicense=getAttribute(node,'ProjectLicense','');
    catch
        projectConverter.addError('Unable to load project description',e);
    end

end


function[modelInfo,sessionIDs]=loadModels(projectConverter,fileNames,projectXML,projectNodeStruct)

    out=SimBiology.web.internal.converter.modelhandler('loadModel',projectConverter,fileNames,projectXML,projectNodeStruct);
    modelInfo=out.modelInfo;
    sessionIDs=out.sessionIDs;

end


function[modelInfo,sessionIDs]=loadModelsOnly(projectConverter,fileNames)

    out=SimBiology.web.internal.converter.modelhandler('loadModelsOnly',projectConverter,fileNames);
    modelInfo=out.modelInfo;
    sessionIDs=out.sessionIDs;

end


function[programs,programResults,programPlots]=loadPrograms(projectConverter,fileNames,sessionIDs,projectNode,externalDataInfo)


    tasksNode=getField(projectNode,'Tasks');

    if isempty(tasksNode)||~isfield(tasksNode,'Task')
        programs={};
        programResults={};
        programPlots={};
        return;
    else
        tasksNode=tasksNode.Task;
    end


    programs={};
    programResults={};
    programPlots=[];
    projectVersion=projectConverter.projectVersion;

    for i=1:numel(tasksNode)
        taskNode=tasksNode(i);
        [program,results,plots]=getProgramInfo(projectConverter,taskNode,fileNames,sessionIDs,externalDataInfo,projectNode,projectVersion);


        if~isempty(program)
            programs=vertcat(programs,program);%#ok<AGROW>

            if~isempty(results)
                programResults=[programResults,results{:}];%#ok<AGROW>
            end

            if~isempty(plots)
                programPlots=vertcat(programPlots,plots);%#ok<AGROW>
            end
        end
    end

end


function[program,results,plots]=getProgramInfo(obj,taskNode,fileNames,sessionIDs,externalDataInfo,projectDetailNode,projectVersion)


    modelSessionID=-1;

    if~isempty(sessionIDs)
        modelIndex=getAttribute(taskNode,'ModelIndex');
        if modelIndex>-1
            modelSessionID=sessionIDs(modelIndex+1);
        end
    end


    try
        program=buildProgramObject(obj,taskNode,modelSessionID,externalDataInfo,projectVersion);
    catch e
        program=[];
        obj.addError('Unable to convert program to new format for SimBiology Model Analyzer',e);
    end



    if isempty(program)
        results=[];
        plots=[];
        return;
    end


    try
        results=buildResultObject(obj,taskNode,projectDetailNode,program,fileNames);
    catch e
        results=[];
        obj.addError('Unable to convert result object to new format for SimBiology Model Analyzer',e);
    end


    try
        plots=buildPlotObject(obj,taskNode,modelSessionID,results,externalDataInfo,projectVersion);
    catch e
        plots=[];
        obj.addError('Unable to convert plot to new format for SimBiology Model Analyzer',e);
    end

end


function program=buildProgramObject(projectConverter,node,modelSessionID,externalDataInfo,projectVersion)


    type=SimBiology.web.internal.converter.programHandler('getProgramType',node);

    switch type
    case 'Ensemble Run'
        program=SimBiology.web.internal.converter.programHandler('defineEnsembleRunProgram',node,modelSessionID,projectVersion);
    case 'Simulation'
        program=SimBiology.web.internal.converter.programHandler('defineSimulationProgram',node,modelSessionID,projectVersion);
    case 'Scan'
        program=SimBiology.web.internal.converter.programHandler('defineScanProgram',projectConverter,node,modelSessionID,projectVersion);
    case 'Scan with Sensitivities'
        program=SimBiology.web.internal.converter.programHandler('defineScanWithSensitivitiesProgram',projectConverter,node,modelSessionID,projectVersion);
    case 'Group Simulation'
        program=SimBiology.web.internal.converter.programHandler('defineGroupSimulationProgram',node,modelSessionID,externalDataInfo,projectVersion);
    case 'Sensitivity Analysis'
        program=SimBiology.web.internal.converter.programHandler('defineSensitivityProgram',node,modelSessionID,projectVersion);
    case{'Fit Data','Parameter Fit'}
        program=SimBiology.web.internal.converter.programHandler('defineFitProgram',projectConverter,node,modelSessionID,projectVersion,externalDataInfo);
    case 'Custom'
        program=SimBiology.web.internal.converter.programHandler('defineCustomProgram',projectConverter,node,modelSessionID,projectVersion);
    otherwise
        programName=getAttribute(node,'Name');
        warningMessage=sprintf('Task: %s, its results, and plots were not added to the project because they are no longer supported.',programName);
        projectConverter.addWarning(warningMessage);
        program=[];
    end

end


function out=buildResultObject(projectConverter,taskNode,projectDetailNode,taskStruct,fileNames)

    out=SimBiology.web.internal.converter.resultsHandler('readResults',projectConverter,taskNode,projectDetailNode,taskStruct,fileNames);

end


function plots=buildPlotObject(projectConverter,taskNode,modelSessionID,results,externalDataInfo,projectVersion)

    plots=SimBiology.web.internal.converter.plotHandler('buildPlotObject',projectConverter,taskNode,modelSessionID,results,externalDataInfo,projectVersion);

end


function programs=loadNCAProgram(projectConverter,projectNode,externalDataInfo,programs)



    externalDataNodes=getField(projectNode,'ExternalData');
    externalDataNodes=getField(externalDataNodes,'IndData');

    for i=1:numel(externalDataNodes)
        try

            externalDataNode=externalDataNodes(i);
            isNCATabOpen=false;


            openDocumentsCount=getAttribute(externalDataNode,'OpenDocumentsCount');
            if~isempty(openDocumentsCount)
                for j=1:openDocumentsCount
                    openDocumentName=getAttribute(externalDataNode,sprintf('OpenDocuments%d',(j-1)));
                    if strcmp(openDocumentName,'NCA')
                        isNCATabOpen=true;
                        break;
                    end
                end
            end

            if isNCATabOpen
                program=SimBiology.web.internal.converter.programHandler('defineNCAProgram',externalDataNode,externalDataInfo.data(i),projectConverter.projectVersion);
                programs{end+1}=program;%#ok<AGROW>
            end
        catch e
            projectConverter.addError('Unable to load NCA program',e);
        end
    end

end




function externalData=loadOrphanTaskData(obj,projectNode,fileNames,externalData)

    externalData=SimBiology.web.internal.converter.orphanTaskDataHandler('loadOrphanTaskData',obj,projectNode,fileNames,externalData);

end


function externalData=loadExternalData(obj,fileNames,projectNode)

    externalData=SimBiology.web.internal.converter.externaldatahandler('loadExternalData',obj,fileNames,projectNode);

end


function message=cleanup(dirName)

    [~,message,~]=rmdir(dirName,'s');

end


function out=getInternalStructTemplate

    out=SimBiology.web.internal.converter.utilhandler('getInternalStructTemplate');

end


function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});
    if isstring(out)
        out=char(out);
    end

end


function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);

end


function out=convertVersion(verString)

    out=verString;
    if isa(verString,'datetime')
        d=num2str(day(verString));
        m=num2str(month(verString));
        y=num2str(year(verString));

        out=[d,'.',m,'.',y];
    end

end


function out=mapVersionToRelease(version)
    switch version
    case '1'
        out='14SP3+';
    case '1.0.1'
        out='2006a';
    case '2'
        out='2006a+';
    case '2.0.1'
        out='2006b';
    case '2.1.1'
        out='2007a';
    case '2.1.2'
        out='2007b';
    case '2.2'
        out='2007b+';
    case '2.3'
        out='2008a';
    case '2.4'
        out='2008b';
    case '3'
        out='2009a';
    case '3.1'
        out='2009b';
    case '3.2'
        out='2010a';
    case '3.3'
        out='2010b';
    case '3.4'
        out='2011a';
    case '4'
        out='2011b';
    case '4.1'
        out='2012a';
    case '4.2'
        out='2012b';
    case '4.3'
        out='2013a';
    case '4.3.1'
        out='2013b';
    case '5'
        out='2014a';
    case '5.1'
        out='2014b';
    case '5.2'
        out='2015a';
    case '5.3'
        out='2015b';
    case '5.4'
        out='2016a';
    case '5.5'
        out='2016b';
    case '5.6'
        out='2017a';
    case '5.7'
        out='2017b';
    case '5.8'
        out='2018a';
    case '5.8.1'
        out='2018b';
    case '5.8.2'
        out='2019a';
    otherwise
        out='';
    end
end