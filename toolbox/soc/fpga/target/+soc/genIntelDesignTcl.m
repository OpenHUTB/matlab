function genIntelDesignTcl(hbuild)
    fprintf('---------- Generating Intel Design Tcl File ----------\n');
    NumJobs=hbuild.NumJobs;
    prj_dir=hbuild.ProjectDir;
    DesignTclFile=hbuild.DesignTclFile;

    if~isfolder(prj_dir)
        mkdir(prj_dir);
    end



    soc.inteltcl.createQuartus(hbuild,NumJobs);


    fid=fopen(fullfile(prj_dir,DesignTclFile.qsys),'w');


    soc.inteltcl.createQsys(fid,hbuild);


    soc.inteltcl.addInputClkRst(fid,hbuild);


    soc.inteltcl.addMem(fid,hbuild);


    soc.inteltcl.addPLL(fid,hbuild);


    soc.inteltcl.addHPS(fid,hbuild);


    soc.inteltcl.addComponent(fid,hbuild);


    soc.inteltcl.addInterconnect(fid,hbuild);


    soc.inteltcl.addExternalIO(fid,hbuild);


    soc.inteltcl.addConnections(fid,hbuild);


    soc.inteltcl.addInterrupt(fid,hbuild);


    soc.inteltcl.addPostTcl(fid,hbuild);

    fclose(fid);
