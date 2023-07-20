classdef GraphFactory<handle




    properties(GetAccess=public,SetAccess=immutable)
        Builder;
        Filter;
    end

    methods

        function this=GraphFactory()
            import dependencies.internal.graph.DependencyFilter.*;
            this.Builder=com.mathworks.toolbox.slproject.extensions.dependency.graph.DependencyGraphBuilder();
            this.Filter=any(~dependencyType("TestHarness"),hasRelationship(["Toolbox","Bus"]));
        end

        function addNode(this,nodes)
            for n=1:length(nodes)
                node=nodes(n);
                this.Builder.addVertex(node.Location,node.Type.ID);
            end
        end

        function addDependency(this,deps)
            filtered=deps(this.Filter.apply(deps));
            [~,idx]=unique({filtered.ID});

            for dependency=filtered(:,idx)
                if dependency.UpstreamNode.Type==dependencies.internal.graph.Type.TEST_HARNESS
                    location=dependency.UpstreamComponent.Path;
                    if ""==location
                        location=dependency.UpstreamNode.Location{3};
                        upCompType=dependencies.internal.graph.Type.TEST_HARNESS.ID;
                    else
                        upCompType=dependency.UpstreamComponent.Type.ID;
                    end

                    newLocation=string(dependency.UpstreamNode.Location{2})+...
                    dependencies.testHarnessDelimiter+location;
                    this.Builder.addDependency(...
                    dependency.UpstreamNode.Location(1),...
                    'File',...
                    newLocation,...
                    upCompType,...
                    int32(dependency.UpstreamComponent.LineNumber),...
                    dependency.UpstreamComponent.EnclosingFunction,...
                    dependency.UpstreamComponent.BlockPath,...
                    dependency.UpstreamComponent.SID,...
                    dependency.DownstreamNode.Location,...
                    dependency.DownstreamNode.Type.ID,...
                    dependency.DownstreamComponent.Path,...
                    dependency.DownstreamComponent.Type.ID,...
                    int32(dependency.DownstreamComponent.LineNumber),...
                    dependency.DownstreamComponent.EnclosingFunction,...
                    dependency.DownstreamComponent.BlockPath,...
                    dependency.DownstreamComponent.SID,...
                    dependency.Relationship.ID,...
                    dependency.Type.ID);
                else
                    this.Builder.addDependency(...
                    dependency.UpstreamNode.Location,...
                    dependency.UpstreamNode.Type.ID,...
                    dependency.UpstreamComponent.Path,...
                    dependency.UpstreamComponent.Type.ID,...
                    int32(dependency.UpstreamComponent.LineNumber),...
                    dependency.UpstreamComponent.EnclosingFunction,...
                    dependency.UpstreamComponent.BlockPath,...
                    dependency.UpstreamComponent.SID,...
                    dependency.DownstreamNode.Location,...
                    dependency.DownstreamNode.Type.ID,...
                    dependency.DownstreamComponent.Path,...
                    dependency.DownstreamComponent.Type.ID,...
                    int32(dependency.DownstreamComponent.LineNumber),...
                    dependency.DownstreamComponent.EnclosingFunction,...
                    dependency.DownstreamComponent.BlockPath,...
                    dependency.DownstreamComponent.SID,...
                    dependency.Relationship.ID,...
                    dependency.Type.ID);
                end
            end
        end

        function container=create(this)
            container=com.mathworks.toolbox.slproject.extensions.dependency.graph.SimpleGraphContainer(this.Builder.build);
        end

    end

end
