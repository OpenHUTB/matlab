classdef DoorsModuleChecker<slreq.backlinks.Checker



    methods

        function this=DoorsModuleChecker(documentId)
            this@slreq.backlinks.Checker();
            this.domain='linktype_rmi_doors';
            this.document=documentId;
        end

        function initialize(this)%#ok<MANU>




        end

        function canonicalId=getCanonicalId(this,storedId)





            canonicalId=rmidoors.getNumericStr(storedId,this.document);
        end

        function[countUnmatched,countChecked]=countUnmatchedLinks(this)
            if isempty(this.mwSource)
                error('need to assign SOURCE before checking backlinks');
            end
            if isempty(this.mwLinksMap)
                error('need to populate mwLinksMap before checking backlinks');
            end

            refObjLinks=this.findRefObjectsBySource();
            checked1=numel(refObjLinks);
            if checked1==0
                unmatched1=0;
            else
                unmatched1=this.registerIfUnmatched(refObjLinks);
            end

            refExtLinks=this.findRefLinksBySource();
            checked2=numel(refExtLinks);
            if checked2==0
                unmatched2=0;
            else
                unmatched2=this.registerIfUnmatched(refExtLinks);
            end

            countUnmatched=unmatched1+unmatched2;
            countChecked=checked1+checked2;
        end

        function count=deleteUnmatchedLinks(this)


            if this.lastChecked<this.lastRefreshed
                error(message('Slvnv:slreq_backlinks:StaleDataNeedToRerun','DoorsModuleChecker'));
            else
                count=this.doDeleteUnmatched();
            end
        end

        function tf=isFile(~)
            tf=false;
        end

    end

    methods(Access=private)

        function refObjects=findRefObjectsBySource(this)

            allRefObjects=rmidoors.getModuleAttribute(this.document,'slrefobjects');
            if isempty(allRefObjects)
                refObjects=[];
            else
                refObjects=this.filterByLinkedArtifact(allRefObjects);
            end
        end

        function refLinks=findRefLinksBySource(this)

            allRefLinks=rmidoors.getModuleAttribute(this.document,'slreflinks');
            if isempty(allRefLinks)
                refLinks=[];
            else
                refLinks=this.filterByLinkedArtifact(allRefLinks);
            end
        end

        function filtered=filterByLinkedArtifact(this,unfiltered)
            isWantedSource=false(size(unfiltered,1),1);
            [~,wantedName,wantedExt]=fileparts(this.mwSource);
            for i=1:size(unfiltered,1)
                [~,linkedName,linkedExt]=fileparts(unfiltered{i,2});
                if strcmp(linkedName,wantedName)
                    if isempty(linkedExt)||strcmp(linkedExt,wantedExt)





                        isWantedSource(i)=true;
                    end
                end
            end
            filtered=unfiltered(isWantedSource,:);
        end

        function count=registerIfUnmatched(this,documentLinks)
            count=0;


            definedDomainType=rmi.linktype_mgr('resolveByRegName',this.domain);
            if isempty(definedDomainType)
                return;
            end
            if isempty(definedDomainType.BacklinkDeleteFcn)
                return;
            end
            totalLinks=size(documentLinks,1);
            for i=1:totalLinks
                mwItemId=documentLinks{i,3};
                docItemId=documentLinks{i,1};
                if isKey(this.mwLinksMap,docItemId)
                    linkedSourceIds=this.mwLinksMap(docItemId);

                    keep=any(strcmp(linkedSourceIds,mwItemId));
                else

                    keep=false;
                end
                if~keep
                    this.registerUnmatchedLink(docItemId,mwItemId);
                    count=count+1;
                end
            end
            this.lastChecked=now;
        end

        function count=doDeleteUnmatched(this)
            count=0;
            docIds=keys(this.unmatchedMap);
            mwArtifactName=slreq.uri.getShortNameExt(this.mwSource);
            definedDomainType=rmi.linktype_mgr('resolveByRegName',this.domain);
            for i=1:length(docIds)
                docId=docIds{i};
                mwIds=this.unmatchedMap(docId);
                for j=1:length(mwIds)
                    count=count+definedDomainType.BacklinkDeleteFcn(...
                    this.document,docId,mwArtifactName,mwIds{j});
                end
            end
        end

    end

end



