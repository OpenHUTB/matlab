classdef ULGFileParser<Simulink.sdi.internal.import.FileParser





    methods


        function runIDs=import(this,varParsers,repo,addToRunID,varargin)
            wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
            wksParser.ProgressTracker=this.ProgressTracker;
            tmp=onCleanup(@()locCleanup());

            if addToRunID~=0
                runIDs=addToRunID;
                addToRun(wksParser,repo,runIDs,varParsers);
            else
                runIDs=createRun(wksParser,repo,varParsers,this.RunName);
            end
        end


        function ext=getFileExtension(~)
            ext={'.ulg'};
        end


        function ret=getVarParser(~,wksParser,fileName,varargin)


            try
                ul=eval('ulogreader(fileName)');
            catch me
                switch me.identifier
                case{'MATLAB:license:NoFeature','MATLAB:UndefinedFunction'}
                    error(message('SDI:sdi:ULGImportWithoutUAV'));
                otherwise
                    throwAsCaller(me);
                end
            end


            var.VarName=fileName;
            var.VarValue=ul;
            ret=parseVariables(wksParser,var);
        end
    end

end


function locCleanup()
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    wksParser.ProgressTracker=[];
end
