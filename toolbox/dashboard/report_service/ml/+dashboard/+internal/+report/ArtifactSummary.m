classdef ArtifactSummary<dashboard.internal.report.WidgetReportBase
    properties(Access=private)
ArtifactTreeGraph
    end

    properties(Constant,Access=private)
        DummyRootID="DUMMYROOT";
    end

    methods
        function addToReport(this,parent,scopeArtifact)
            this.createArtifactTreeGraph(scopeArtifact);

            out=mlreportgen.report.Section;
            out.Title=message("dashboard:report:ArtifactSummary").getString();

            artsTableHeader={
            message("dashboard:report:ArtifactGroup").getString(),...
            message("dashboard:report:ArtifactType").getString(),...
            message("dashboard:report:ArtifactCount").getString()
            };
            artsTableBody=this.createArtifactsSummaryMatrix();

            ftArts=dashboard.internal.report.createFormalTable(artsTableHeader,artsTableBody);
            ftArts.Width="500px";
            ftArts=this.removeArtifactGroupColBottomBorderLines(ftArts);



            if this.Report.Report.Debug
                p=mlreportgen.dom.Paragraph('widgetReporter=ArtifactSummary');
                out.append(p);
            end
            out.add(ftArts);

            parent.append(out);
        end
    end

    methods(Access=private)
        function createArtifactTreeGraph(this,scopeArtifact)
            as=alm.internal.ArtifactService.get(this.Report.Project.RootFolder);



            tttResult=jsondecode(as.serviceCall('transformToTree',jsonencode(struct(...
            'projectPath',this.Report.Project.RootFolder,...
            'treetype','unit-testing',...
            'uuid',scopeArtifact.UUID...
            ))));
            data=tttResult.result;
            if ischar(data)
                if data=="[]"
                    return
                else
                    data=jsondecode(data);
                end
            end

            if~iscell(data)
                data=num2cell(data);
            end

            dg=digraph;
            n=numel(data);
            ids=strings(n,1);
            parentIds=strings(n,1);
            for i=1:n
                x=data{i};
                ids(i)=x.x_Id;
                if isempty(x.x_Parent)
                    parentIds(i)=this.DummyRootID;
                else
                    parentIds(i)=string(x.x_Parent);
                end
            end

            nodeData=table([ids;this.DummyRootID],[data;{{}}],...
            'VariableNames',{'Name','Node'});

            dg=dg.addnode(nodeData);
            if~isempty(parentIds)
                dg=dg.addedge(parentIds,ids);
            end
            this.ArtifactTreeGraph=dg;
        end

        function mtrx=generateMatrixForFolder(this,folderId)
            nodeIdx=this.ArtifactTreeGraph.findnode(folderId);
            tln=this.ArtifactTreeGraph.Nodes(nodeIdx,:);
            allChilds=this.ArtifactTreeGraph.dfsearch(nodeIdx);
            treeNodes=this.ArtifactTreeGraph.Nodes(allChilds,:).Node;
            artTypes={};
            for j=1:numel(treeNodes)
                art=treeNodes{j};
                if strcmp(art.PayloadType,'artifact')&&isfield(art.Payload,'Type')
                    artTypes{end+1}=art.Payload.Type;%#ok<AGROW>
                end
            end
            [counts,types]=groupcounts(categorical(artTypes'));

            if~isempty(types)

                [types,order]=sort(types);
                counts=counts(order);
                mtrx=strings(numel(counts),3);
                mtrx(1,1)=string(tln.Node{1}.Label);
                mtrx(:,2)=this.getLocalizedArtifactTypes(types);
                mtrx(:,3)=string(counts);
            else
                mtrx=[string(tln.Node{1}.Label),"",""];
            end
        end

        function summaryMatrix=createArtifactsSummaryMatrix(this)
            prjRoot=this.ArtifactTreeGraph.successors(this.DummyRootID);
            topLevelFolders=this.ArtifactTreeGraph.successors(prjRoot);
            summaryMatrices=cell(numel(topLevelFolders),1);
            groupNames=strings(numel(topLevelFolders),1);
            for i=1:numel(topLevelFolders)
                summaryMatrices{i}=this.generateMatrixForFolder(topLevelFolders{i});
                groupNames(i)=summaryMatrices{i}(1,1);
            end


            [~,order]=sort(groupNames);
            summaryMatrices=summaryMatrices(order);
            summaryMatrix=vertcat(summaryMatrices{:});
        end

...
...
...
...
...
        function artsTable=removeArtifactGroupColBottomBorderLines(~,artsTable)
            noBottomBorder=mlreportgen.dom.Border();
            noBottomBorder.BottomWidth="0";

            tableBody=artsTable.Children(2);
            rows=tableBody.Children;

            for r=1:numel(rows)-1
                currRowHasGroupText=~isempty(strtrim(rows(r).Children(1).Children.Content));
                belowRowHasGroupText=~isempty(strtrim(rows(r+1).Children(1).Children.Content));

                if(currRowHasGroupText&&~belowRowHasGroupText)||(~currRowHasGroupText&&~belowRowHasGroupText)
                    rows(r).Children(1).Style={noBottomBorder};
                end
            end
        end

        function localizedTypes=getLocalizedArtifactTypes(~,types)
            localizedTypes="";
            for n=1:numel(types)
                localizedTypes(n)=message("alm:artifacts:"+string(types(n))).getString();
            end
        end
    end
end

