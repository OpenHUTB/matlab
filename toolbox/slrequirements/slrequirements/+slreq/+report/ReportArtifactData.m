classdef ReportArtifactData<handle
    properties(Constant)

        ARTIFACT_DOMAIN_LIST={
        'slreq',...
        'slmodel',...
        'sltest',...
        'sldata',...
        'other',...
        };
    end

    properties
Domain
FullPath
ShortName
ExtName
Folder
Name
DoesExist

IsLoaded

ExtraInfo
        InputPath;
    end

    methods

        function this=ReportArtifactData(inputPath)
            this.InputPath=inputPath;
        end


        function out=getExtraInfoForArtifactListBody(this)
            if this.DoesExist
                switch this.Domain
                case 'slreq'
                    if this.IsLoaded
                        out=this.ExtraInfo.revision;
                    else
                        out=getString(message('Slvnv:slreq:ReportContentArtifactListBodyUnknown'));
                    end
                case 'slmodel'
                    if this.IsLoaded
                        out=this.ExtraInfo.version;
                    else
                        out=getString(message('Slvnv:slreq:ReportContentArtifactListBodyUnloaded'));
                    end
                otherwise
                    out=this.ExtraInfo.fileTimestamp;
                end
            else
                out=getString(message('Slvnv:slreq:ReportContentArtifactListBodyUnknown'));
            end
        end


        function tf=isMATLABBuiltIn(this)
            tf=~strcmpi(this.Domain,'other');
        end


        function out=isSLReqFile(this)
            out=strcmp(this.ExtName,'.slreqx');
        end


        function out=isSLModelFile(this)
            out=strcmpi(this.ExtName,'.slx')||strcmpi(this.ExtName,'.mdl');
        end


        function out=isSLTestFile(this)
            out=strcmpi(this.ExtName,'.mldatx');
        end


        function out=isSLDataFile(this)
            out=strcmpi(this.ExtName,'.sldd');
        end


        function updateFileUri(this)
            fh=slreq.uri.FilePathHelper(this.InputPath);
            this.FullPath=fh.getFullPath;
            this.ShortName=fh.getShortName;
            this.ExtName=fh.getExt;
            this.Name=fh.getName;
        end


        function updateDomain(this)
            this.Domain='other';
            if this.isSLReqFile
                this.Domain='slreq';
            end

            if this.isSLModelFile
                this.Domain='slmodel';
            end

            if this.isSLTestFile
                this.Domain='sltest';
            end

            if this.isSLDataFile
                this.Domain='sldata';
            end
        end


        function refreshArtiInfo(this)
            dirinfo=dir(this.FullPath);
            if isempty(dirinfo)
                this.ShortName=this.ShortName;
                this.Name=this.Name;
                this.Folder=[];
                this.DoesExist=false;
            else
                this.ShortName=dirinfo.name;
                this.Folder=dirinfo.folder;
                this.DoesExist=true;
            end
            this.updateDomain();
            if this.DoesExist
                switch this.Domain
                case 'slreq'
                    reqData=slreq.data.ReqData.getInstance();
                    if isempty(this.Folder)
                        reqSetDetails=reqData.getReqSet(this.ShortName);
                    else
                        reqSetDetails=reqData.getReqSet(this.FullPath);
                    end

                    if isempty(reqSetDetails)
                        this.IsLoaded=false;
                    else
                        this.Folder=fileparts(reqSetDetails.filepath);
                        this.IsLoaded=true;
                        this.ExtraInfo.revision=num2str(reqSetDetails.revision);
                        this.ExtraInfo.MATLABVersion=reqSetDetails.MATLABVersion;
                        this.ExtraInfo.modifiedOn=datestr(reqSetDetails.modifiedOn);
                        this.ExtraInfo.createdOn=datestr(reqSetDetails.createdOn);
                    end
                case 'slmodel'
                    mdlName=this.Name;
                    if dig.isProductInstalled('Simulink')&&bdIsLoaded(mdlName)
                        this.IsLoaded=true;
                        this.ExtraInfo.version=get_param(mdlName,'ModelVersion');
                        this.ExtraInfo.modifiedOn=get_param(mdlName,'LastModifiedDate');
                        this.ExtraInfo.createdOn=get_param(mdlName,'Created');
                    else
                        this.IsLoaded=false;
                    end
                case{'sltest','sldata','other'}

                    this.IsLoaded=false;
                    this.ExtraInfo.fileTimestamp=dirinfo.date;
                otherwise

                    error('invalid type');
                end
            end
        end
    end
end