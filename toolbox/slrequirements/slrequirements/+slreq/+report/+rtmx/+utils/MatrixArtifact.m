classdef MatrixArtifact<handle





    properties(Constant,Hidden=true)
        DOMAIN_LIST={'slreq','simulink','sltest','other'};
        SUPPORTED_RMI_DOMAIN_TYPES=containers.Map({'linktype_rmi_slreq',...
        'linktype_rmi_simulink',...
        'linktype_rmi_testmgr',...
        'linktype_rmi_data',...
        'linktype_rmi_matlab'},ones(1,5));
        SUPPORTED_ARTIFACT_EXT=containers.Map({'.m','.slreqx','.slx','.mdl','.sldd','.mldatx'},ones(1,6));

        EXT_TO_RMI_DOMAIN=containers.Map({'.m','.slreqx',...
        '.slx','.mdl',...
        '.sldd','.mldatx'},...
        {'linktype_rmi_matlab','linktype_rmi_slreq',...
        'linktype_rmi_simulink','linktype_rmi_simulink',...
        'linktype_rmi_data','linktype_rmi_testmgr'});
        EXT_TO_DOMAIN=containers.Map({'.m','.slreqx',...
        '.slx','.mdl',...
        '.sldd','.mldatx'},...
        {'matlabcode','slreq',...
        'simulink','simulink',...
        'sldd','sltest'});
    end


    properties(GetAccess=public,SetAccess=private)


RmiDomain
Domain

ShortName

Name
Ext
FullPath
ArtifactID
Folder
        Location='top'
        TreatAsSource=true;

        TreatAsDestination=true;
    end


    methods
        function this=MatrixArtifact(artifactPath,refPath)

            if nargin<2
                refPath='';
            end
            filePathHelper=slreq.uri.FilePathHelper(artifactPath,refPath);
            fileExt=filePathHelper.getExt;

            if~isKey(this.SUPPORTED_ARTIFACT_EXT,lower(fileExt))
                error(message('Slvnv:slreq_rtmx:ErrorUnsupportedArtifact',fileExt));
            end

            this.Ext=filePathHelper.getExt();
            this.Name=filePathHelper.getName();
            this.ShortName=filePathHelper.getShortName();
            this.FullPath=filePathHelper.getFullPath();
            this.Folder=filePathHelper.getFolder();
            this.ArtifactID=this.FullPath;
            this.Domain=this.EXT_TO_DOMAIN(lower(fileExt));
            this.RmiDomain=this.EXT_TO_RMI_DOMAIN(lower(fileExt));
        end

        function out=getShortName(this)
            out=this.ShortName;
        end

        function out=getFullPath(this)
            out=this.FullPath;
        end

        function out=getArtifactID(this)
            out=this.ArtifactID;
        end

        function out=getDomain(this)
            out=this.Domain;
        end

        function out=getRMIDomain(this)
            out=this.RmiDomain;
        end

        function out=getName(this)
            out=this.Name;
        end

        function out=getFolder(this)
            out=this.Folder;
        end

        function setLocation(this,value)

            this.Location=value;
        end

        function out=getLocation(this)
            out=this.Location;
        end
    end

    methods(Static)
        function out=isSupportedArtifact(artifactPath)


            filePathHelper=slreq.uri.FilePathHelper(artifactPath,'');
            fileExt=filePathHelper.getExt;

            out=isKey(slreq.report.rtmx.utils.MatrixArtifact.SUPPORTED_ARTIFACT_EXT,lower(fileExt));


            if out
                switch lower(fileExt)
                case{'.slx','mld','.sldd'}

                    if~dig.isProductInstalled('Simulink')


                        out=false;
                    end
                    return;
                case{'.mldatx'}
                    if~dig.isProductInstalled('Simulink')||~dig.isProductInstalled('Simulink Test')



                        out=false;
                    end
                    return;
                otherwise
                    return;
                end
            end
        end

    end
end