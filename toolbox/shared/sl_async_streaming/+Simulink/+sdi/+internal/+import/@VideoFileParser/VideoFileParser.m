classdef VideoFileParser<Simulink.sdi.internal.import.FileParser





    methods

        function runID=import(this,varParser,repo,addToRunID,varargin)
            runID=importFromMP4(this,repo,this.Filename,this.RunName,addToRunID,varParser{1}.VariableName);
        end


        function extension=getFileExtension(~)
            extension=[{'.mp4'},{'.webm'}];
        end


        function runID=importFromMP4(~,repo,filename,runName,addToRunID,signalName)
            if(addToRunID<=0)

                runID=repo.createEmptyRun(runName,0,'sdi',true);
            else

                runID=addToRunID;
            end
            fw=Simulink.sdi.internal.AppFramework.getSetFramework();
            fw.createVideoSignal(runID,signalName,'FromFile',filename);
        end


        function varParsers=getVarParser(~,wksParser,fileName,varargin)
            varParsers={};

            [~,name,ext]=fileparts(fileName);
            signalName=[name,ext];
            varParser=Simulink.sdi.internal.import.TimeseriesParser;
            varParser.VariableName=signalName;
            varParser.VariableValue=timeseries(0,'name',signalName);
            varParser.TimeSourceRule='';
            varParser.WorkspaceParser=wksParser;
            varParsers{1}=varParser;
        end
    end
end
