classdef DummyTraverser<slreq.report.rtmx.utils.ArtifactTraverser



    methods(Access=private)
        function this=DummyTraverser()

            this@slreq.report.rtmx.utils.ArtifactTraverser()
        end
    end

    methods(Static)
        function obj=getInstance()


            persistent cachedObj
            if isempty(cachedObj)
                cachedObj=slreq.report.rtmx.utils.DummyTraverser;
            end
            obj=cachedObj;
        end
    end
    methods
        function[out,orderToIdMap]=traverse(this,artifactPath)

            import slreq.report.rtmx.utils.*
            dataMgr=RTMXReqDataExporter.getInstance();
            orderToIdMap=containers.Map;

            out=containers.Map;
            idDetails=containers.Map;


            allIds=dataMgr.AllArtifactIds(artifactPath);

            currentOrder=0;
            domain='';
            navCmd='';
            for index=1:length(allIds)
                cID=allIds{index};
                currentOrder=currentOrder+1;
                orderToIdMap(num2str(currentOrder))=cID;
                cInfo=dataMgr.ItemIdToDetails(cID);

                if isempty(domain)
                    domain=cInfo.Domain;
                end
                if isempty(navCmd)
                    navCmd.function=cInfo.NavCmd.function;

                    navCmd.inputs={};
                end


                if cInfo.IsResolved
                    cInfo.Level=1;
                    cInfo.ParentID=artifactPath;
                    cInfo.RealParentID=artifactPath;
                else
                    if isempty(cInfo.ParentID)||isempty(cInfo.RealParentID)
                        disp('somethihng wrong')
                    end

                    cInfo.Level=2;
                end

                idDetails(cID)=cInfo;
                dataMgr.ItemIdToDetails(cID)=cInfo;
            end

            orderToIdMap('0')=artifactPath;

            if isItemDataIn(dataMgr,artifactPath)
                cArtiInfo=dataMgr.ItemIdToDetails(artifactPath);
            else
                dataMgr.createItemData(artifactPath);
                cArtiInfo=dataMgr.getItemData(artifactPath);
                [~,artifactName]=fileparts(artifactPath);
                cArtiInfo.Desc=artifactName;

                navActStruct.function=navCmd.function;
                navActStruct.inputs=navCmd.inputs;
                cArtiInfo.NavCmd=navActStruct;
                cArtiInfo.Domain=domain;
                cArtiInfo.LinkTargetsAsSrc={};
                cArtiInfo.LinkTargetsAsDst={};
            end
            cArtiInfo.ParentID='';
            cArtiInfo.RealParentID='';
            cArtiInfo.Level=0;
            cArtiInfo.ChildrenIDs=setdiff(allIds,artifactPath);


            idDetails(artifactPath)=cArtiInfo;

            out(artifactPath)=idDetails;

            out=out(artifactPath);
        end

        function loadArtifact(this,artifactName)

        end
    end

end