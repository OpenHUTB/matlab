








function isValid=canCompileNet(net,checkDeep,flagError)
    if nargin<2
        checkDeep=true;
    end
    if nargin<3
        flagError=true;
    end
    isValid=true;
    if(checkDeep&&isa(net,'DAGNetwork'))
        sources=net.Connections.Source;
        [unique_sources,ind]=unique(sources);
        if length(sources)~=length(unique_sources)

            names=setdiff(1:size(sources),ind);
            if(flagError)
                cell=sources(names(1));
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerMultipleOutputs',cell{1});
                error(msg);
            end
            isValid=false;
        end
    end
    isValid=isValid&&(...
    isa(net,'SeriesNetwork')||...
    isa(net,'DAGNetwork')||...
    isa(net,'dlnetwork'));
end
