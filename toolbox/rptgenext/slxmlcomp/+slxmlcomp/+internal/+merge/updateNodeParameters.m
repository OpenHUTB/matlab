function updateNodeParameters(nodeUpdater,node,parameters,varargin)



















    for i=1:size(parameters,1)
        slxmlcomp.internal.merge.updateNodeParameter(nodeUpdater,node,parameters{i,1},parameters{i,2},varargin{:});
    end
end
