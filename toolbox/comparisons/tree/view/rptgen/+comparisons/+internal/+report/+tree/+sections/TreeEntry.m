classdef TreeEntry<mlreportgen.dom.LockedDocumentPart




    properties(Access=private)
MCOSView
RootEntry
Entry
ReportFormat
SectionConfig
    end

    methods(Access=public)

        function obj=TreeEntry(mcosView,rootEntry,entry,rptFormat,sectionConfig,template)
            obj=obj@mlreportgen.dom.LockedDocumentPart(...
            rptFormat.RPTGenType,...
            template,...
            "SubsectionDifference");
            obj.MCOSView=mcosView;
            obj.RootEntry=rootEntry;
            obj.Entry=entry;
            obj.ReportFormat=rptFormat;
            obj.SectionConfig=sectionConfig;

            obj.SectionConfig.ContainsDiffs=true;
        end

        function fillLeftNodePath(treeEntry)
            left=comparisons.internal.Side2.Left;
            treeEntry.appendNodeName(left);
        end

        function fillRightNodePath(treeEntry)
            right=comparisons.internal.Side2.Right;
            treeEntry.appendNodeName(right);
        end

        function fillLeftParameters(treeEntry)
            left=comparisons.internal.Side2.Left;
            treeEntry.appendSubcomparison(left);
        end

        function fillRightParameters(treeEntry)
            right=comparisons.internal.Side2.Right;
            treeEntry.appendSubcomparison(right);
        end

    end


    methods(Access=private)

        function appendNodeName(treeEntry,side)
            import comparisons.internal.tree.TreeReader.getPathOnSide

            formatPathAsString=true;
            delimiter=treeEntry.SectionConfig.NodeDelimiter;
            nodePath=getPathOnSide(treeEntry.Entry,side,formatPathAsString,delimiter);
            rootNodePath=getPathOnSide(treeEntry.RootEntry,side);
            text=strrep(nodePath,[rootNodePath,delimiter],'');

            treeEntry.append(text);
        end

        function appendSubcomparison(treeEntry,side)
            import comparisons.internal.report.tree.sections.SubcomparisonSection
            section=SubcomparisonSection(...
            treeEntry.MCOSView,...
            treeEntry.Entry,...
            side,...
            treeEntry.ReportFormat...
            );
            section.fill(treeEntry);
        end

    end

end
