classdef LibraryBuildingVisitor<pm.util.Visitor















































    properties
SLHandle
ForwardingTableEntries
    end

    methods
        function libBldVis=LibraryBuildingVisitor()
            libBldVis.SLHandle=containers.Map;
            libBldVis.ForwardingTableEntries=...
            simmechanics.sli.internal.ForwardingTableEntry.empty;
        end

        function set.SLHandle(thisVis,slHCont)
            if isa(slHCont,'containers.Map')
                thisVis.SLHandle=slHCont;
            else
                pm_error('sm:sli:librarybuildingvisitor:InvalidPropValue',...
                'SLHandle','Map of Node Id vs Block Handle');
            end
        end

        function set.ForwardingTableEntries(thisVis,ftEntries)
            if isa(ftEntries,'simmechanics.sli.internal.ForwardingTableEntry')
                thisVis.ForwardingTableEntries=ftEntries;
            else
                pm_error('sm:sli:librarybuildingvisitor:InvalidPropValue',...
                'ForwardingTableEntries','array of ForwardingTableEntry objects');
            end
        end
    end

    methods(Access=protected)

        visit_compoundnode_implementation(thisVisitor,aVisitableNode)

        visit_simplenode_implementation(thisVisitor,aVisitableNode)

    end
end


