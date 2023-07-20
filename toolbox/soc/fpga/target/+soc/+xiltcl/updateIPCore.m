function updateIPCore(buildinfo)
    restore.path=pwd;

    hsb_hw_dir=fullfile(matlabroot,'toolbox/soc/fpga/target/hw');

    duts=[];
    for ii=1:numel(buildinfo.ComponentList)
        if isa(buildinfo.ComponentList{ii},'soc.xilcomp.DUT')
            duts{end+1}=buildinfo.ComponentList{ii};
        end
    end

    for ii=1:numel(duts)

        rev=regexp(duts{ii}.Version,'[^.]\d*','match');
        revStr=['v',rev{1},'_',rev{2}];

        myipcoreDir=fullfile(buildinfo.ProjectDir,'ipcore',[duts{ii}.Name,'_',revStr]);

        copyfile(fullfile(hsb_hw_dir,'script','xilinx','ip_update.tcl'),myipcoreDir,'f');

        cd(myipcoreDir);


        vivadoToolExe=soc.util.getVivadoPath();
        [err,~]=system([vivadoToolExe,' -mode batch -source ip_update.tcl -tclargs ',revStr]);


        artifacts={'ip_update.tcl','vivado*.log','vivado*.jou'};

        for jj=1:numel(artifacts)
            delete(artifacts{jj});
        end

        if err
            error(message('soc:msgs:vivadoUpdateIPError'));
        end
    end
    cd(restore.path);

end

