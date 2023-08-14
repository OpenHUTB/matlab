function addLine(graph,srcPort,dstPorts,varargin)








    if(numel(srcPort)==1)
        srcports=repmat(srcPort,numel(dstPorts),1);
    else
        srcports=srcPort;
    end


    Simulink.variant.reducer.utils.assert(numel(srcports)==numel(dstPorts),...
    'Number of source and destination ports should be same when adding lines');


    add_line(graph,srcports(:),dstPorts(:),varargin{:});
end
