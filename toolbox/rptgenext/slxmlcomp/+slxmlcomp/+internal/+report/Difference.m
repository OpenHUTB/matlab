classdef Difference<mlreportgen.dom.LockedDocumentPart



    properties(Access=private)
        JDriverFacade;
        JDiff;
        ReportFormat;
    end

    methods(Access=public)

        function difference=Difference(jDiff,jDriverFacade,rptFormat)
            difference=difference@mlreportgen.dom.LockedDocumentPart(rptFormat.RPTGenType,rptFormat.RPTGenDiffTemplate,"Difference");
            difference.JDiff=jDiff;
            difference.JDriverFacade=jDriverFacade;
            difference.ReportFormat=rptFormat;
        end

        function fillLeftNode(diff)
            diff.appendNodeFunction(...
            diff.getJSideLeft(),...
            @(node)char(node.getName())...
            );
        end

        function fillRightNode(diff)
            diff.appendNodeFunction(...
            diff.getJSideRight(),...
            @(node)char(node.getName())...
            );
        end

        function fillLeftNodePath(diff)
            diff.appendNodeFunction(...
            diff.getJSideLeft(),...
            @(node)diff.generateNodePath(node)...
            );
        end

        function fillRightNodePath(diff)
            diff.appendNodeFunction(...
            diff.getJSideRight(),...
            @(node)diff.generateNodePath(node)...
            );
        end

        function fillLeftParameters(diff)
            diff.appendParameters(diff.getJSideLeft());
        end

        function fillRightParameters(diff)
            diff.appendParameters(diff.getJSideRight());
        end

    end


    methods(Access=private)

        function appendNodeFunction(diff,jSide,textFunction)
            node=diff.JDiff.getSnippet(jSide);

            if isempty(node)
                text='';
            else
                text=textFunction(node);
            end
            diff.append(text);
        end

        function slPath=generateNodePath(~,node)

            import com.mathworks.toolbox.rptgenslxmlcomp.report.ReportUtils;
            slPath=char(ReportUtils.getSimulinkPath(node));

            if(isempty(slPath))
                import com.mathworks.toolbox.rptgenslxmlcomp.gui.printable.SLXMLNodePathGenerator;
                gen=SLXMLNodePathGenerator;
                slPath=char(gen.getNodePath(node));
            end
        end

        function appendParameters(diff,jSide)
            import slxmlcomp.internal.report.sections.ParameterSubSection;

            section=ParameterSubSection(...
            diff.JDiff,...
            diff.JDriverFacade,...
jSide...
            );
            section.fill(diff);
        end

    end

    methods(Access=private)
        function side=getJSideLeft(~)
            side=slxmlcomp.internal.report.sections.Util.JSideLeft;
        end

        function side=getJSideRight(~)
            side=slxmlcomp.internal.report.sections.Util.JSideRight;
        end

    end

end
