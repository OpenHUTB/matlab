function plot(graph,varargin)





    [~,name,ext]=cellfun(@fileparts,graph.Nodes.Name,'UniformOutput',false);
    graph.Nodes.Name=strcat(name,ext);

    plot(graph,varargin{:});

end
