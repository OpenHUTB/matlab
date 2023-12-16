function[installed,prodId]=actx_installed(buttonName)

    persistent buttons installok;

    if isempty(installok)
        installok.SLRefButton=0;
        buttons.SLRefButton={'mwSimulink1','mwSimulink'};

        installok.SLRefButtonA=0;
        buttons.SLRefButtonA={'mwSimulink2'};

    end

    if nargin==0

        installok.SLRefButton=0;
        buttonName='SLRefButton';
    elseif~isfield(buttons,buttonName)
        error(message('Slvnv:reqmgt:actx_installed:actx_installed',buttonName));
    end

    filenames=buttons.(buttonName);
    prodId=[filenames{1},'.',buttonName];

    if installok.(buttonName)>0
        installed=true;
    elseif installok.(buttonName)<0
        installed=false;
    else
        installed=actx_check(filenames,buttonName);
        if installed
            installok.(buttonName)=1;
        else
            installed=actx_install(filenames);
            if installed
                installok.(buttonName)=rmicom.actxcheck(filenames,buttonName);
            else
                installok.(buttonName)=-1;
            end
        end
    end
end

function result=actx_check(filenames,buttonName)
    result=false;
    for i=1:length(filenames)
        ProgID=[filenames{i},'.',buttonName];


        try
            winqueryreg('HKEY_CLASSES_ROOT',ProgID);
            result=true;
            return;
        catch Mex %#ok<NASGU>
            continue;
        end
    end
end


function result=actx_install(filenames)

    for i=1:length(filenames)
        filename=filenames{i};
       cntrlDir=fullfile(matlabroot,'toolbox','shared','reqmgt','icons');
        ocxFile=fullfile(cntrlDir,[filename,'.ocx']);

        [~,systemRoot]=dos('echo %SystemRoot%');
        systemRoot=systemRoot(1:end-1);
        if strncmpi(computer,'pcwin64',7)
            sysdir=[systemRoot,'\syswow64'];

            returnHere=pwd;
            cd('c:\');
            cd(sysdir);
        else
            sysdir=[systemRoot,'\system32'];
            returnHere='';
        end
        [cmdStatus,messg]=copyfile(ocxFile,sysdir,'f');
        if cmdStatus==1
            ocxToRegister=[sysdir,'\',filename,'.ocx'];
        else
            warning(message('Slvnv:reqmgt:actx_installed:CopyOCXFileFailed',sysdir,messg));
            ocxToRegister=ocxFile;
        end

        regcmd=['regsvr32 /c /s "',ocxToRegister,'"'];

        [cmdStatus,messg]=dos(regcmd);

        if~isempty(returnHere)
            cd(returnHere);
        end

        if cmdStatus==0
            result=true;
            disp(['Successfully registered ActiveX control ',filename]);
        else
            result=false;
            disp(['ActiveX registration failed for ',filename,': ',messg]);
            break;
        end
    end
end

