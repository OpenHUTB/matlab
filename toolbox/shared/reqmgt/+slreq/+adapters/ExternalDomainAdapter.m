classdef ExternalDomainAdapter<slreq.adapters.BaseAdapter



    properties
        icon;
        registration;
    end

    methods
        function this=ExternalDomainAdapter(domain)
            this.domain=domain;
            this.registration=rmi.linktype_mgr('resolveByRegName',this.domain);
            if~isempty(this.registration)&&~isempty(this.registration.Icon)&&isfile(this.registration.Icon)
                this.icon=this.registration.Icon;
            else
                this.icon=slreq.gui.IconRegistry.instance.externalReq;
            end
        end


        function icon=getIcon(this,~,~)
            icon=this.icon;
        end

        function tf=isResolved(this,artifact,id)%#ok<*INUSD>
            tf=true;



        end

        function success=select(this,artifact,id,caller)
            if nargin<4
                caller='';
            end
            success=false;
            rmi.navigate(this.domain,artifact,id,caller);
        end

        function success=highlight(this,artifact,id,caller)
            success=false;
            if nargin<4
                caller='';
            end
            this.select(artifact,id,caller);
        end

        function str=getSummary(this,artifact,id)%#ok<INUSL>



            str=id;
        end

        function tooltip=getTooltip(this,artifact,id)%#ok<INUSL>
            tooltip=artifact;
        end

        function src=getSourceObject(this,artifact,id)%#ok<INUSL>
            src=struct('artifact',artifact,'id',id);
        end

        function success=onClickHyperlink(this,artifact,id,caller)
            if nargin<4
                caller='';
            end
            this.select(artifact,id,caller);
            success=true;
        end

        function cmdStr=getClickActionCommandString(this,artifact,id,~)



            cmdStr=sprintf('rmi.navigate(''%s'',''%s'',''%s'','''');',this.domain,artifact,id);
        end

        function fullPath=getFullPathToArtifact(~,artifact,varargin)
            if rmiut.isCompletePath(artifact)
                fullPath=artifact;
            else
                fullPath=rmi.locateFile(artifact,varargin{:});
                if isempty(fullPath)
                    fullPath=artifact;
                end
            end
        end

        function status=checkAvailableUpdate(this,dataReq)
            status=slreq.dataexchange.UpdateDetectionStatus.UnableToAccess;

            if isempty(dataReq)

                return;
            end

            if this.isUpdateNotificationAvailable(dataReq)
                status=this.checkAvailableUpdateForFileBase(dataReq);
            else
                status=this.checkAvailableUpdateForNonFileBase(dataReq);
            end
        end

        function tf=isUpdateNotificationAvailable(this,dataReq)


            tf=dataReq.isReqIF||(~isempty(this.registration)&&this.registration.IsFile);
        end
    end
    methods(Access=private)

        function status=checkAvailableUpdateForFileBase(~,dataReq)


            storedUri=dataReq.artifactUri;
            reqSetFilePath=dataReq.getReqSet.filepath;
            artifactUri=slreq.uri.ResourcePathHandler.getFullPath(storedUri,reqSetFilePath);

            status=slreq.dataexchange.UpdateDetectionStatus.UnableToAccess;
            if isfile(artifactUri)
                file=dir(artifactUri);
                if~isempty(file)
                    fileDateTime=datetime(file.datenum,'ConvertFrom','datenum','TimeZone','Local');
                    if fileDateTime>dataReq.synchronizedOn
                        status=slreq.dataexchange.UpdateDetectionStatus.Detected;
                    else
                        status=slreq.dataexchange.UpdateDetectionStatus.UpToDate;
                    end
                end
            end
        end

        function status=checkAvailableUpdateForNonFileBase(this,dataReq)


            status=slreq.dataexchange.UpdateDetectionStatus.Unknown;




        end
    end
end
