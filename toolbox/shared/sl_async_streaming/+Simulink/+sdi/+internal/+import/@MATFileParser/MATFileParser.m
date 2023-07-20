classdef MATFileParser<Simulink.sdi.internal.import.FileParser





    methods


        function runIDs=import(this,varParsers,repo,addToRunID,varargin)
            wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
            if addToRunID~=0
                runIDs=addToRunID;
                mdlName='';
                overwrittenRunID=0;
                parentRunID=int32.empty;
                addToRun(wksParser,repo,runIDs,varParsers,mdlName,...
                overwrittenRunID,parentRunID,varargin{:});
            else
                runIDs=createRun(wksParser,repo,varParsers,this.RunName);
            end
        end


        function extension=getFileExtension(~)
            extension={'.mat'};
        end


        function varParser=getVarParser(~,wksParser,fileName,varargin)
            varParser=parseMATFile(wksParser,fileName,'');
        end

    end

end