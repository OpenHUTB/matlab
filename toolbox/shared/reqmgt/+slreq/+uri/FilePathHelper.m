classdef FilePathHelper<handle
    properties(Access=private)
        InputPath;
        FullPath;
        Folder;
        ShortName;
        Ext;
        Name;
        CanonicalPath;
Domain
        ExtToDomain=setExtToDomain;
    end

    methods
        function this=FilePathHelper(filePath,refPath)
            if isempty(filePath)
                error('no file path is given');
            end

            this.InputPath=filePath;

            if rmiut.isCompletePath(filePath)















                fullPath=whichWithoutError(filePath);
                if isempty(fullPath)
                    fullPath=filePath;
                end
            elseif nargin>2
                fullPath=fullfile(refPath,filePath);
            else

                [~,filename,fileext]=fileparts(filePath);

                fullPathFromMATLAB=whichWithoutError(filename);

                if contains(fullPathFromMATLAB,filePath)
                    fullPath=fullPathFromMATLAB;
                else
                    fullPath='';
                end
                if isempty(fullPath)
                    reqData=slreq.data.ReqData.getInstance(false);
                    if~isempty(reqData)
                        if strcmpi(fileext,'.slreqx')
                            dataArtifact=reqData.getReqSet(filePath);
                            if~isempty(dataArtifact)
                                fullPath=dataArtifact.filepath;
                            end
                        else
                            dataArtifact=reqData.getLinkSet(filePath);

                            if~isempty(dataArtifact)
                                if strcmpi(fileext,'.slmx')
                                    fullPath=dataArtifact.filepath;
                                else
                                    fullPath=dataArtifact.artifact;
                                end
                            end
                        end

                    end

                    if isempty(fullPath)
                        fullPath=whichWithoutError(filePath);
                        if isempty(fullPath)
                            fullPath=filePath;
                        end
                    end
                end
            end

            slreq.datamodel.RequirementData.StaticMetaClass;
            this.FullPath=slreq.cpputils.getCanonicalPath(fullPath);
        end

        function out=getFullPath(this)
            out=this.FullPath;
        end

        function out=getDomain(this)
            ext=this.getExt;
            lowerExt=lower(ext);
            if isKey(this.ExtToDomain,lowerExt)
                out=this.ExtToDomain(lowerExt);
            else
                out='Unknown';
            end
        end

        function out=getFolder(this)
            if isempty(this.Folder)
                this.parsingPath();
            end
            out=this.Folder;
        end
        function out=getShortName(this)
            if isempty(this.ShortName)
                this.parsingPath();
            end
            out=this.ShortName;
        end

        function out=getExt(this)
            if isempty(this.Ext)
                this.parsingPath();
            end
            out=this.Ext;
        end

        function out=getName(this)
            if isempty(this.Name)
                this.parsingPath();
            end
            out=this.Name;
        end


        function out=doesExist(this)
            doesExist=exist(this.getFullPath,'file');
            out=doesExist==2||doesExist==4;
        end

        function out=isInMATLABPath(this)
            actPath=which(this.getShortName);
            out=false;
            if strcmp(actPath,this.getFullPath)
                out=true;
            end
        end
    end

    methods(Access=private)
        function parsingPath(this)
            if isempty(this.FullPath)
                [filepath,filename,fileext]=fileparts(this.InputPath);
            else
                [filepath,filename,fileext]=fileparts(this.FullPath);
            end

            if isempty(fileext)
                fileext=this.Ext;
            end

            this.ShortName=fullfile([filename,fileext]);
            this.Ext=fileext;
            this.Name=filename;
            this.Folder=filepath;
        end


    end

    methods(Static)
        function ext=getExtensionForDomain(domain)
            persistent ARTIFACT_EXTERSION_MAP;

            if isempty(ARTIFACT_EXTERSION_MAP)



                ARTIFACT_EXTERSION_MAP=containers.Map(...
                {'linktype_rmi_data','linktype_rmi_simulink','linktype_rmi_matlab','linktype_rmi_testmgr','linktype_rmi_slreq'},...
                {'.sldd','.slx','.m','.mldatx','.slreqx'});
            end
            ext='';
            if ARTIFACT_EXTERSION_MAP.isKey(domain)
                ext=ARTIFACT_EXTERSION_MAP(domain);
            end
        end
    end
end


function out=setExtToDomain()



    out=containers.Map('keytype','char','valuetype','char');
    out('.slx')='linktype_rmi_simulink';
    out('.mdl')='linktype_rmi_simulink';
    out('.sldd')='linktype_rmi_data';
    out('.m')='linktype_rmi_matlab';
    out('.mldatx')='linktype_rmi_testmgr';
    out('.txt')='linktype_rmi_text';
    out('.html')='linktype_rmi_html';
    out('.htm')='linktype_rmi_html';
    out('.slreqx')='linktype_rmi_slreq';
    out('.xlsx')='linktype_rmi_excel';
    out('.xls')='linktype_rmi_excel';
    out('.doc')='linktype_rmi_word';
    out('.docx')='linktype_rmi_word';
    out('.pdf')='linktype_rmi_pdf';
    out('.slmx')='linkset';
end

function out=whichWithoutError(filePath)
    out='';
    try
        out=which(filePath);
    catch ex %#ok<NASGU> 






    end
end

