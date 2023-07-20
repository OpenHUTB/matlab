function[command,args,classpath]=launchCommand(product)






    product=validatestring(product,["parallelLinkDesigner",...
    "serialLinkDesigner",...
    "siViewer",...
    "ssr2xls"]);
    arch=computer('arch');

    javaPath=si.utilities.javaPath;
    if isempty(javaPath)||~isfolder(javaPath)
        error(message('si:apps:JavaRequired'))
    end
    command=fullfile(javaPath,"bin","java");
    if ispc
        command=command+".exe";
    end

    toolboxRoot=fullfile(matlabroot,"toolbox","si");
    installDir=fullfile(toolboxRoot,"apps",arch);
    if exist(installDir,'dir')~=7
        installDir=fullfile(toolboxRoot,"apps");
    end
    setenv("SIA_INSTALL_DIR",installDir)
    globalLogDir=string(getenv("SIA_GLOBAL_LOG_DIR"));
    siteConfigDir=string(getenv("SIA_SITE_CONFIG_DIR"));
    if ispc
        [~,sysMem]=memory;
        memoryBytes=sysMem.PhysicalMemory.Total;
    else
        [~,kBytes]=system("cat /proc/meminfo | grep ^MemTotal | awk '{print $2}'");
        memoryBytes=str2double(kBytes)*1024;
    end
    mBytes=num2str(round(memoryBytes/1024/1024));
    if strcmpi(product,"parallelLinkDesigner")||strcmpi(product,"ssr2xls")
        heapSize=getenv("QSI_MAX_HEAP_SIZE");
    elseif strcmpi(product,"serialLinkDesigner")
        heapSize=getenv("QCD_MAX_HEAP_SIZE");
    elseif strcmpi(product,"siViewer")
        heapSize=getenv("SIVIEWER_MAX_HEAP_SIZE");
    else
        heapSize='';
    end
    if isempty(heapSize)
        heapSize=getenv("SI_TOOLBOX_MAX_HEAP_SIZE");
    end
    if isempty(heapSize)

        if memoryBytes>=2^34

            heapSize="8192";
        else

            heapSize="4096";
        end
    end
    args="-Xmx"+heapSize+"m";
    args(end+1)="-Dswing.metalTheme=steel";
    args(end+1)="-Djava.util.prefs.systemRoot="+fullfile(installDir,"etc");
    args(end+1)="-Dcom.sisoft.siAInstallDir="+installDir;
    args(end+1)="-Dcom.sisoft.siAGlobalLogDir="+globalLogDir;
    args(end+1)="-Dcom.sisoft.siASiteConfigDir="+siteConfigDir;

    if strcmpi(product,"ssr2xls")
        args(end+1)="com.mathworks.sitoolbox.siutilities.csv.SsrToXls";
    else

        args(end+1)="-Dcom.sisoft.os.arch="+arch;
        args(end+1)="-Dcom.sisoft.runtime.getphysicalmemory="+mBytes;
        if strcmpi(product,"siViewer")
            args(end+1)="com.mathworks.sitoolbox.siwave.SiViewer";
        else
            args(end+1)="-Dcom.sisoft.configuration="+si.utilities.mw2ss(product);
            args(end+1)="com.mathworks.sitoolbox.siauditor.SiAuditor";
        end
    end


    if ispc
        classpathSeparator=";";
    else
        classpathSeparator=":";
    end
    sisoftClasspath=fullfile(installDir,"lib","java","SignalIntegrity.jar");
    javaHelpClassPath=fullfile(matlabroot,"java","jarext","jh.jar");
    mwEngineClassPath=fullfile(matlabroot,"java","jar","*");
    poiClassPath=fullfile(matlabroot,"java","jarext","poi","*")+classpathSeparator+...
    fullfile(matlabroot,"java","jarext","poi","lib","*")+classpathSeparator+...
    fullfile(matlabroot,"java","jarext","poi","ooxml-lib","*");

    classpath=sisoftClasspath+classpathSeparator+...
    javaHelpClassPath+classpathSeparator+...
    poiClassPath+classpathSeparator+...
    mwEngineClassPath;





    binPath=string(fullfile(matlabroot,'bin',arch));
    pathElems=strsplit(string(getenv("PATH")),pathsep);
    if length(pathElems)<1||~isequal(pathElems(1),binPath)
        newPathElems=[binPath,pathElems];
        setenv("PATH",strjoin(newPathElems,pathsep));
    end
end


