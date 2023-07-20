function pvs=getTransientCLI(system,param)



    hDriver=hdlmodeldriver(bdroot(system));
    hDI=hDriver.DownstreamIntegrationDriver;
    transientCLIMaps=hDI.transientCLIMaps;
    if(strcmpi(param,'all'))
        keys=transientCLIMaps.keys;
        pvs=cell(1,length(keys)*2);
        for i=1:length(keys)
            pvs{i*2-1}=keys{i};
            pvs{i*2}=transientCLIMaps(keys{i});
        end
    else
        assert(transientCLIMaps.isKey(param));
        pvs={param,transientCLIMaps(param)};
    end
end