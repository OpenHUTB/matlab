function fop=createFOPObject()








    persistent INITIALIZED

    if isempty(INITIALIZED)
        scopedCleanup=setupEnvironment();%#ok
        INITIALIZED=true;
    end

    fop=eval("mlreportgen.internal.fop.FOPObject");%#ok Do NOT let JIT preload AHFormatter libraries
    fop.OptionFileURI=...
    fullfile(resourceDir(),"ahf-settings.xml");
    fop.ExitLevel="FATAL";
end

function scopedCleanup=setupEnvironment()








    scopedCleanup=onCleanup.empty();

    licensePath=fullfile(matlabroot,"bin",computer("arch"));
    setenv('AHF72_64_LIC_PATH',licensePath);

    fontConfigFile=getenv('AHF72_64_FONT_CONFIGFILE');
    if~isfile(fontConfigFile)
        fontConfigFile=createFontConfigFile();
        setenv('AHF72_64_FONT_CONFIGFILE',fontConfigFile);
        scopedCleanup(end+1)=onCleanup(@()delete(fontConfigFile));
    end

    if isempty(getenv('AHF72_64_HYPDIC_PATH'))
        hyphPath=fullfile(matlabroot,"sys/ahformatter","hyphenation");
        setenv('AHF72_64_HYPDIC_PATH',hyphPath);
    end



    for imgType=["png","jpg","tiff"]
        loadImgLibraries(imgType);
    end
end

function loadImgLibraries(imgType)
    tmpImgFile=tempname+"."+imgType;
    imwrite(rand(4),tmpImgFile);
    scopeDelete=onCleanup(@()delete(tmpImgFile));
    imfinfo(tmpImgFile);
    imread(tmpImgFile);
    imds=imageDatastore(tmpImgFile);
    readall(imds);
end

function fontConfigFile=createFontConfigFile()











    arch=computer("arch");
    fontConfig=fullfile(resourceDir(),compose("font-config-%s.xml",arch));

    content=fileread(fontConfig);
    content=strrep(content,"$matlabroot",matlabroot());
    content=strrep(content,"$toolboxdir",toolboxdir(''));

    if~ispc()
        userhome=mlreportgen.utils.internal.canonicalPath("~");
        content=strrep(content,"$user.home",userhome);
    end

    fontConfigFile=tempname()+"-font-config.xml";
    fid=fopen(fontConfigFile,"w","n","utf-8");
    fprintf(fid,"%s",content);
    fclose(fid);
end

function rdir=resourceDir()
    rdir=toolboxdir("shared/mlreportgen/fop/resources");
end