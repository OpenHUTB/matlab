function copyCosimDemoFiles(demoname)





    narginchk(1,1);
    demo_set={'cruise_control','tutorial'};

    matched_name=validatestring(demoname,demo_set);

    srcdir=fullfile(matlabroot,'toolbox','edalink','foundation','hdllink','demo_src',matched_name);
    copyfile(fullfile(srcdir,'*'),pwd);


