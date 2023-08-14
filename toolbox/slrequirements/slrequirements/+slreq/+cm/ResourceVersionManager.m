classdef ResourceVersionManager<handle











    properties(Access=private)
artifactVersions
    end

    properties(Constant,Hidden)
        userfile=fullfile(prefdir,'rmi_cmdata.mat');
    end

    methods(Access=private)

        function this=ResourceVersionManager()

            this.loadFromFile();
        end

        function versionStr=getMappedVersion(this,docIdStr)
            if isKey(this.artifactVersions,docIdStr)
                versionStr=this.artifactVersions(docIdStr);
            else
                versionStr='';
            end
        end

        function setMappedVersion(this,docIdStr,version)

            this.artifactVersions(docIdStr)=version;

            this.writeToFile(this.artifactVersions);
        end

        function loadFromFile(this)
            if exist(this.userfile,'file')==2

                loaded=load(this.userfile);
                this.artifactVersions=loaded.cmMap;
            else

                this.artifactVersions=containers.Map('KeyType','char','ValueType','char');
            end
        end

        function writeToFile(this,cmMap)
            save(this.userfile,'cmMap');
        end
    end

    methods(Static,Access=private)

        function obj=getInstance()
            persistent myObj
            if isempty(myObj)
                myObj=slreq.cm.ResourceVersionManager();
            end
            obj=myObj;
        end

        function versionForSource=getVersionForSource(domainLabel,docId,sourceInfo)

            [linkSet,sourceName]=slreq.cm.ResourceVersionManager.getLinkSet(sourceInfo);%#ok<ASGLU>
            if~isempty(linkSet)
                docIdStr=slreq.cm.ResourceVersionManager.getMappingKey(domainLabel,docId);
                versionForSource=linkSet.getProperty(docIdStr);
            else



                versionForSource='';
            end
        end

        function[dataLinkSet,sourceInfo]=getLinkSet(sourceInfo)


            dataLinkSet=[];
            artifactPath=local_getArtifactPath();
            if~isempty(artifactPath)
                dataLinkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactPath);
            end

            function artifactUri=local_getArtifactPath()
                if ischar(sourceInfo)
                    if rmiut.isCompletePath(sourceInfo)
                        artifactUri=sourceInfo;
                    else
                        artifactUri=strtok(sourceInfo,'/');
                    end
                else

                    try
                        artifactUri=get_param(bdroot(sourceInfo),'FileName');
                        sourceInfo=slreq.uri.getShortNameExt(artifactUri);
                    catch
                        sourceInfo=num2str(sourceInfo);
                        artifactUri=[];
                    end
                end
            end
        end

        function key=getMappingKey(domainLabel,docName)





            key=[domainLabel,'_',strtok(docName),'_version'];
        end

    end

    methods(Static)

        function configuredVersion=getVersion(domainLabel,docId,sourceInfo)
            configuredVersion='';






            if~isempty(sourceInfo)
                configuredVersion=slreq.cm.ResourceVersionManager.getVersionForSource(domainLabel,docId,sourceInfo);
            end


            if isempty(configuredVersion)
                docIdStr=slreq.cm.ResourceVersionManager.getMappingKey(domainLabel,docId);
                configuredVersion=slreq.cm.ResourceVersionManager.getInstance.getMappedVersion(docIdStr);
            end
        end

        function origVersion=setVersion(domainLabel,docId,version)
            origVersion=slreq.cm.ResourceVersionManager.getVersion(domainLabel,docId,'');
            docIdStr=slreq.cm.ResourceVersionManager.getMappingKey(domainLabel,docId);
            slreq.cm.ResourceVersionManager.getInstance.setMappedVersion(docIdStr,version);
        end

        function origVersion=setVersionForSource(source,domainLabel,docId,version)
            [linkSet,sourceName]=slreq.cm.ResourceVersionManager.getLinkSet(source);
            if~isempty(linkSet)
                docIdStr=slreq.cm.ResourceVersionManager.getMappingKey(domainLabel,docId);
                origVersion=linkSet.getProperty(docIdStr);
                linkSet.setProperty(docIdStr,version);
            else
                rmiut.warnNoBacktrace('Slvnv:slreq:NoLinkSetFor',sourceName);
                origVersion='';
            end
        end

    end

    methods(Static=true,Hidden=true)

        function clearAll()
            storedMap=slreq.cm.ResourceVersionManager.userfile;
            if exist(storedMap,'file')
                delete(storedMap);
            end
            slreq.cm.ResourceVersionManager.getInstance.loadFromFile();
        end

        function import(mapFile)
            if exist(mapFile,'file')
                copyfile(mapFile,slreq.cm.ResourceVersionManager.userfile);
                slreq.cm.ResourceVersionManager.getInstance.loadFromFile();
            else
                error('%s does not exist',mapFile);
            end
        end

    end

end


