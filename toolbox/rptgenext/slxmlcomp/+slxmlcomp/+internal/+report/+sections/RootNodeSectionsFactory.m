


classdef RootNodeSectionsFactory<slxmlcomp.internal.report.sections.SectionsFactory

    properties(Access=private)
        ComparisonSources;
        JDriverFacade;
        ReportTempDir;
        SectionFactories={...
        slxmlcomp.internal.report.sections.SimulinkSectionFactory(),...
        slxmlcomp.internal.report.sections.StateflowSectionFactory(),...
        slxmlcomp.internal.report.sections.ModelWorkspaceSectionFactory()...
        ,slxmlcomp.internal.report.sections.TestHarnessSectionFactory()...
        };
    end


    methods(Access=public)

        function obj=RootNodeSectionsFactory(jDriverFacade,reportTempDir,comparisonSources)
            obj.JDriverFacade=jDriverFacade;
            obj.ReportTempDir=reportTempDir;
            obj.ComparisonSources=comparisonSources;
        end

        function sections=create(obj,rptFormat)
            import slxmlcomp.internal.report.sections.RootNodeSection;

            rootNodes=obj.getGraphModel().getRoots();
            if(rootNodes.isEmpty())
                sections=[];
                return
            end

            slxRoot=rootNodes.iterator().next();
            rootNodes=obj.getGraphModel().getChildren(slxRoot).iterator();
            sections={};
            priorities=[];

            while(rootNodes.hasNext())
                diff=rootNodes.next();

                diffIsKnown=false;
                for factoryIndex=1:numel(obj.SectionFactories)
                    factory=obj.SectionFactories{factoryIndex};
                    if(factory.appliesToDiff(diff))
                        sections{end+1}=factory.create(...
                        obj.JDriverFacade,...
                        diff,...
                        rptFormat,...
                        obj.ReportTempDir,...
                        obj.ComparisonSources...
                        );%#ok<*AGROW>
                        priorities(end+1)=factory.getPriority();
                        diffIsKnown=true;
                        break;
                    end
                end

                if~diffIsKnown
                    sections{end+1}=RootNodeSection(...
                    obj.JDriverFacade,...
                    diff,...
rptFormat...
                    );
                    priorities(end+1)=100;
                end

            end

            [~,sortedIndices]=sort(priorities);
            sections=sections(sortedIndices);
        end
    end

    methods(Access=private)
        function graph=getGraphModel(obj)
            graph=obj.JDriverFacade.getResult().getDifferenceGraphModel();
        end
    end

end
