classdef TextItemIDData<slreq.report.rtmx.utils.ItemIDData
    properties
Range
StartPos
EndPos
StartLine
EndLine
Arguments
Attribute
Snippet
HasID


TextIDList
    end

    methods
        function this=TextItemIDData(id)
            this@slreq.report.rtmx.utils.ItemIDData(id);
            this.Domain='matlabcode';
            this.IconType='linktype-rmi-matlab';
        end


        function updateLinkInfo(this,incomingLinks,outgoingLinks)


            dataExporter=slreq.report.rtmx.utils.RTMXReqDataExporter.getInstance();
            for index=1:length(incomingLinks)

                cLink=incomingLinks(index);
                linkData=dataExporter.getOrCreateLinkData(cLink);
                linkData.IsDestinationResolved=true;
                linkData.DstArtifact=this.ArtifactID;
                linkData.DstDomain=cLink.dest.domain;

                linkData.DstID=[this.ArtifactID,'#:#',this.ItemID];






                linkData.DstTextLines{end+1}=[this.StartLine,this.EndLine];

                dataExporter.addLinkToDstArtifact(this.ArtifactID,cLink.getFullID)

                this.addLinkItemAsDst(linkData);

                this.StatsAsDst.(cLink.type)=this.StatsAsDst.(cLink.type)+1;

                this.StatsAsDst_Total=this.StatsAsDst_Total+1;
                this.StatsAsDst.Total=this.StatsAsDst.Total+1;
            end

            for index=1:length(outgoingLinks)
                cLink=outgoingLinks(index);
                linkData=dataExporter.getOrCreateLinkData(cLink);
                linkData.IsSourceResolved=true;
                linkData.SrcArtifact=this.ArtifactID;
                linkData.SrcDomain=cLink.source.domain;
                linkData.SrcID=[this.ArtifactID,'#:#',this.ItemID];








                dataExporter.addLinkToSrcArtifact(this.ArtifactID,cLink.getFullID);
                this.addLinkItemAsSrc(linkData);
                linkData.SrcTextLines{end+1}=[this.StartLine,this.EndLine];

                this.StatsAsSrc.(cLink.type)=this.StatsAsSrc.(cLink.type)+1;
                this.(['StatsAsSrc_',cLink.type])=this.(['StatsAsSrc_',cLink.type])+1;
                this.StatsAsSrc_Total=this.StatsAsSrc_Total+1;
                this.StatsAsSrc.Total=this.StatsAsSrc.Total+1;
            end

        end
    end
end

