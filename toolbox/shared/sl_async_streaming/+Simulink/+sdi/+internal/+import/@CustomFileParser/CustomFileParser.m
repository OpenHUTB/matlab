classdef CustomFileParser<Simulink.sdi.internal.import.FileParser






    properties
CustomImporter
    end


    methods


        function runID=import(this,varParser,repo,addToRunID,varargin)

            if addToRunID
                runID=addToRunID;
            else
                runID=repo.createEmptyRun(this.RunName,0);
            end


            parser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
            parser.addToRun(repo,runID,varParser);
        end


        function extension=getFileExtension(~)
            extension={};
        end


        function varParsers=getVarParser(this,wksParser,fname,varargin)
            if nargin>2&&~isempty(fname)&&isempty(this.Filename)
                this.Filename=fname;
            end


            if~exist(this.Filename,'file')
                msgID='SDIImport:Cancelled';
                msg='File not found';
                me=MException(msgID,msg);
                throw(me);
            end


            this.CustomImporter.FileName=this.Filename;
            this.CustomImporter.VariableName='';
            this.CustomImporter.VariableValue=[];


            varParsers={};
            varParsers{1}=Simulink.sdi.internal.import.CustomWorkspaceVariableParser;
            varParsers{1}.CustomImporter=this.CustomImporter;
            varParsers{1}.WorkspaceParser=wksParser;
        end

    end

end
