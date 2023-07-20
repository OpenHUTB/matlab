classdef RootNodeSectionsFactory<handle




    properties(Access=private)
MCOSView
ReportTempDir
Sources
SectionFactories
    end


    methods(Access=public)

        function obj=RootNodeSectionsFactory(mcosView,sources,reportTempDir,sectionFactories)
            obj.MCOSView=mcosView;
            obj.Sources=sources;
            obj.ReportTempDir=reportTempDir;
            obj.SectionFactories=sectionFactories;
        end

        function sections=create(obj,rptConfig)
            import comparisons.internal.tree.TreeReader.getRootEntries
            rootEntries=getRootEntries(obj.MCOSView);
            if isempty(rootEntries)
                sections={};
                return
            end

            sections={};
            priorities=[];

            for rootEntry=rootEntries
                applicableFactory=false;

                for factoryIndex=1:numel(obj.SectionFactories)
                    factory=obj.SectionFactories{factoryIndex};
                    if factory.appliesToDiff(obj.MCOSView,rootEntry)
                        sections{end+1}=factory.create(...
                        obj.MCOSView,...
                        obj.Sources,...
                        rootEntry,...
                        rptConfig,...
                        obj.ReportTempDir...
                        );%#ok<*AGROW>
                        priorities(end+1)=factory.getPriority();
                        applicableFactory=true;
                        break
                    end
                end

                if~applicableFactory
                    error("No recognized section factory for this entry")
                end

            end

            [~,sortedIndices]=sort(priorities);
            sections=sections(sortedIndices);
        end
    end

end
