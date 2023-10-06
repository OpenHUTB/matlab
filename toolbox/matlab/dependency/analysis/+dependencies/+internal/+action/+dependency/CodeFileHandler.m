classdef CodeFileHandler<dependencies.internal.action.DependencyHandler

    properties(Constant)
        Types=["MATLABFile","MATLABFileLine","CSource"]
    end

    methods
        function unhilite=openUpstream(~,dependency)
            unhilite=@()[];
            file=dependency.UpstreamNode.Location{1};
            line=str2double(dependency.UpstreamComponent.Path);
            if~isnan(line)
                opentoline(file,line);
            end
        end
    end
end


