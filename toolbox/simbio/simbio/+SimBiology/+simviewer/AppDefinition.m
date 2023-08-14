










classdef AppDefinition<matlab.mixin.SetGet

    properties(Access=public)
        Doses=[];
        Model=[];
        Name='';
        Plots=[];
        Sliders=[];
        Statistics=[];
        ModelDocument='';
        Title='';

        ConfigureRanges=true;
        Accelerated=false;
        DosesToApply=[];
        StatesToLog=[];
        StopTime=[];
        StopTimeUnits='';
        VariantsToApply=[];
    end

    methods
        function obj=AppDefinition(model)
            obj.Model=model;
            obj.Name=model.Name;
        end

        function p=addSlider(obj,name)
            p=SimBiology.simviewer.AppSlider(name);

            if isempty(obj.Sliders)
                obj.Sliders=p;
            else
                obj.Sliders(end+1)=p;
            end
        end

        function p=addPlot(obj,name)
            p=SimBiology.simviewer.AppPlot(name);

            if isempty(obj.Plots)
                obj.Plots=p;
            else
                obj.Plots(end+1)=p;
            end
        end

        function s=addStatistic(obj,name,expression)
            s=SimBiology.simviewer.AppStatistic(name,expression);

            if isempty(obj.Statistics)
                obj.Statistics=s;
            else
                obj.Statistics(end+1)=s;
            end
        end

        function d=addDose(obj,name)
            d=SimBiology.simviewer.AppDose(name);

            if isempty(obj.Doses)
                obj.Doses=d;
            else
                obj.Doses(end+1)=d;
            end
        end

        function createUI(obj)
            exportedDef=SimBiology.simviewer.ExportedAppDefinition(obj);
            SimBiology.simviewer.UserInterface(exportedDef);
        end

        function deployUI(obj,fileName)
            [folder,name]=fileparts(fileName);

            if isempty(folder)
                folder=pwd;
            end






            absPath=obj.ModelDocument;
            if~isempty(absPath)&&strncmp(matlabroot,absPath,numel(matlabroot))
                obj.ModelDocument=absPath(numel(matlabroot)+1:numel(absPath));
            end

            exportedDef=SimBiology.simviewer.ExportedAppDefinition(obj);
            r=sbioroot;
            matFileName=fullfile(r.Tempdir,'ExportedDefFile.mat');
            cleanupFile2=onCleanup(@()delete(matFileName));
            save(matFileName,'exportedDef')

            path=fullfile(matlabroot,'toolbox','simbio','simbio','+SimBiology','+simviewer');
            fileBaseName='DeployedUI.p';
            srcFile=fullfile(matlabroot,'toolbox','simbio','simbio','private',fileBaseName);
            fileToBeDeployedPath=r.Tempdir;


            fileToBeDeployed=fullfile(fileToBeDeployedPath,'DeployedUI.p');
            copyfile(srcFile,fileToBeDeployed);
            cleanupFile1=onCleanup(@()delete(fileToBeDeployed));

            cleanup=sbiogate('safecd',fileToBeDeployedPath);%#ok<NASGU>



            dependentFiles=matlab.codetools.requiredFilesAndProducts(exportedDef.Model.DependentFiles);



            if~isempty(absPath)
                mcc('-m',fileToBeDeployed,'-a',matFileName,'-a',absPath,'-a',path,'-o',name,'-d',folder,'-a',dependentFiles{:});
            else
                mcc('-m',fileToBeDeployed,'-a',matFileName,'-a',path,'-o',name,'-d',folder,'-a',dependentFiles{:});
            end
        end
    end
end