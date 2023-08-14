function compiledRMData=genCompiledRemovalData(reps,rmdata)


    nreps=numel(reps);
    compiledRMData=struct(...
    'BlockReplacements',{},...
    'BlockRemovalData',{},...
    'OutputInfo',{},...
    'InputInfo',{});
    for i=nreps:-1:1
        rmd=rmdata(i);
        rep=reps(i);

        blkh=rmd.Block;

        compiledRMData(i).BlockReplacements=rep;
        compiledRMData(i).BlockRemovalData=rmd;

        compiledRMData(i).OutputInfo=LocalGetChnlPortMap(blkh,'outport');
        compiledRMData(i).InputInfo=LocalGetChnlPortMap(blkh,'inport');
    end

    function info=LocalGetChnlPortMap(blk,type)

        ports=linearize.advisor.graph.getBlockPorts(blk,type);
        portmap=[];
        for i=1:numel(ports)
            p=ports(i);
            w=get_param(p,'CompiledPortWidth');
            portnum=[];
            portnum(1:w)=i;
            portmap=[portmap,portnum];%#ok<AGROW>
        end
        portmap=portmap(:);
        n=numel(portmap);
        channels=(1:n)';
        blockvec(1:n,1)=blk;
        info=[blockvec,channels,portmap];