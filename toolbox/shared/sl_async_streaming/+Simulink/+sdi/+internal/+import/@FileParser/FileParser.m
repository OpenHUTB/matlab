classdef FileParser<handle








    properties
        Filename='';
        RunName='';
        CmdLine=false;
ProgressTracker
    end


    methods


        function this=FileParser()
        end


        function signalIDs=doPostRunCreate(~,repo,runName,runID)
            signalIDs=int32.empty();
            if~isempty(runID)
                fw=Simulink.sdi.internal.AppFramework.getSetFramework();
                fw.onRunsCreated(runID,true,'sdi',runName);

                signalIDs=repo.getAllSignalIDs(runID,'leaf');
            end
        end

    end


    methods(Abstract)
        runID=import(this,varParser,repo,addToRunID,varargin)
        extension=getFileExtension(this)
        varParser=getVarParser(this,wksParser,fileName,varargin)
    end

end