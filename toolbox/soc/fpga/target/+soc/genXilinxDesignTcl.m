function genXilinxDesignTcl(hbuild)
    fprintf('---------- Generating Xilinx Design Tcl File ----------\n');
    prj_dir=hbuild.ProjectDir;
    bd_tcl=hbuild.DesignTclFile;

    if~isfolder(prj_dir)
        mkdir(prj_dir);
    end


    fid=fopen(fullfile(prj_dir,bd_tcl),'w');


    soc.xiltcl.addPreTcl(fid,hbuild.PreTclFile);


    soc.xiltcl.addInputClkRst(fid,hbuild);


    soc.xiltcl.addExternalIO(fid,hbuild);


    soc.xiltcl.addPS7(fid,hbuild);


    soc.xiltcl.addCustomIP(fid,hbuild);


    soc.xiltcl.addFMCIO(fid,hbuild);


    soc.xiltcl.addMem(fid,hbuild);


    soc.xiltcl.addClkGen(fid,hbuild);


    soc.xiltcl.addRstGen(fid,hbuild);


    soc.xiltcl.addComponent(fid,hbuild);


    soc.xiltcl.addComponentClkRst(fid,hbuild);


    soc.xiltcl.addInterconnect(fid,hbuild);


    soc.xiltcl.addInterrupt(fid,hbuild);


    soc.xiltcl.addConnections(fid,hbuild.Connections)


    soc.xiltcl.addPostTcl(fid,hbuild);

    fclose(fid);