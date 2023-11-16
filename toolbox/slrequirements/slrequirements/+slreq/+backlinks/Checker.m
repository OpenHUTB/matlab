classdef Checker<handle

    properties
domain
document
mwSource
mwLinksMap
lastRefreshed
unmatchedMap
lastChecked
    end

    methods

        function this=Checker()


        end

        function registerMwLinks(this,source,linksTable)
            this.mwSource=source;

            mwItemIds=keys(linksTable);
            this.mwLinksMap=containers.Map('KeyType','char','ValueType','any');
            for i=1:length(mwItemIds)
                mwItemId=mwItemIds{i};
                linksInfo=linksTable(mwItemId);
                isMatchingDoc=strcmp(linksInfo(:,1),this.document);
                if this.isFile()
                    relPath=rmiut.relative_path(this.document,fileparts(source));
                    isMatchingPath=strcmp(linksInfo(:,1),strrep(relPath,filesep,'/'));
                    shortName=slreq.uri.getShortNameExt(this.document);
                    isMatchingName=strcmp(linksInfo(:,1),shortName);
                    isMatchingDoc=(isMatchingDoc|isMatchingPath|isMatchingName);
                end
                docItemIds=linksInfo(isMatchingDoc,2);
                for j=1:length(docItemIds)
                    docItemId=this.getCanonicalId(docItemIds{j});
                    if isKey(this.mwLinksMap,docItemId)
                        this.mwLinksMap(docItemId)=[this.mwLinksMap(docItemId),{mwItemId}];
                    else
                        this.mwLinksMap(docItemId)={mwItemId};
                    end
                end
            end

            this.unmatchedMap=containers.Map('KeyType','char','ValueType','any');
            this.lastRefreshed=now;
        end

    end

    methods(Access=protected)

        function registerUnmatchedLink(this,docId,mwItemId)
            if isKey(this.unmatchedMap,docId)
                this.unmatchedMap(docId)=[this.unmatchedMap(docId),{mwItemId}];
            else
                this.unmatchedMap(docId)={mwItemId};
            end
        end





        function reqDocPath=getFullPathToDoc(this)




            if rmiut.isCompletePath(this.document)
                reqDocPath=this.document;
            elseif exist(this.document,'file')==2
                reqDocPath=rmiut.simplifypath(fullfile(pwd,this.document));
            else
                sourceLocation=fileparts(this.mwSource);
                constructedPath=fullfile(sourceLocation,this.document);
                reqDocPath=rmiut.simplifypath(constructedPath,filesep);
            end
        end

    end

    methods(Abstract)

        charStrOut=getCanonicalId(this,charStrStoredId)
        [countUnmatched,countChecked]=countUnmatchedLinks(this)
        [countDeleted,countChecked]=deleteUnmatchedLinks(this)

        initialize(this);

        tf=isFile(this);
    end

end

