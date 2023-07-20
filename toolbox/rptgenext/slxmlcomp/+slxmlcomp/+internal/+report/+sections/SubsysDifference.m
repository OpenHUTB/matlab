classdef SubsysDifference<mlreportgen.dom.LockedDocumentPart



    properties(Access=private)
        JDriverFacade;
        JDifference;
        JSubsystemDifference;
ReportFormat
    end

    methods(Access=public)

        function difference=SubsysDifference(driverFacade,diff,subsystemNode,rptFormat)
            difference=difference@mlreportgen.dom.LockedDocumentPart(rptFormat.RPTGenType,rptFormat.RPTGenSubsysDiffTemplate,"SubsysDifference");
            difference.JDriverFacade=driverFacade;
            difference.JDifference=diff;
            difference.JSubsystemDifference=subsystemNode;
            difference.ReportFormat=rptFormat;
        end

        function fillLeftNodePath(diff)
            import com.mathworks.comparisons.util.Side;
            diff.appendNodePath(Side.LEFT);
        end

        function fillRightNodePath(diff)
            import com.mathworks.comparisons.util.Side;
            diff.appendNodePath(Side.RIGHT);
        end

        function fillLeftParameters(diff)
            import com.mathworks.comparisons.util.Side;
            diff.appendParameters(Side.LEFT);
        end

        function fillRightParameters(diff)
            import com.mathworks.comparisons.util.Side;
            diff.appendParameters(Side.RIGHT);
        end

    end


    methods(Access=private)

        function appendNodePath(diff,side)
            node=diff.JDifference.getSnippet(side);

            if isempty(node)
                text='';
            else
                text=diff.generateNodePath(...
                diff.JSubsystemDifference.getSnippet(side),...
node...
                );
            end
            diff.append(text);
        end

        function slPath=generateNodePath(~,baseNode,node)
            import com.mathworks.toolbox.rptgenslxmlcomp.report.ReportUtils;
            import com.mathworks.toolbox.rptgenslxmlcomp.gui.printable.SLXMLNodePathGenerator;

            if(~isempty(baseNode)&&baseNode.equals(node))
                slPath=char(node.getName());
                return;
            end

            slPath=char(ReportUtils.getSubsystemSectionRelativeNodePath(baseNode,node));

            if(isempty(slPath))

                gen=SLXMLNodePathGenerator;
                slPath=char(gen.getNodePath(node));
            end
        end

        function appendParameters(diff,jSide)
            import slxmlcomp.internal.report.sections.ParameterSubSection;

            section=ParameterSubSection(...
            diff.JDifference,...
            diff.JDriverFacade,...
jSide...
            );
            section.fill(diff);
        end

    end

end
