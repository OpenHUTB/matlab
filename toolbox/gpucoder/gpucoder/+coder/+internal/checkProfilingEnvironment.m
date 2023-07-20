function[profilingStatus,msg]=checkProfilingEnvironment




    profilingStatus=false;
    msg='';


    if ispc
        [returnStatus,~]=system('where nsys.exe');
        [~,programOutput]=system('nsys.exe');
    else


        [returnStatus,~]=system('which nsys');

        [~,programOutput]=system('nsys');
    end
    nsysExists=returnStatus==0;
    if~nsysExists||contains(programOutput,'Error:')
        msg=message('gpucoder:system:no_nsight_systems_on_path');
        return;
    end




    if ispc
        winLib='nvToolsExt64_1';
        nvtxPath=getenv('NVTOOLSEXT_PATH');
        if isempty(nvtxPath)
            msg=message('gpucoder:system:no_nvtx_env_var');
        else
            libPath=fullfile(nvtxPath,'lib','x64');
            libListing=dir(libPath);
            libName=[winLib,'.lib'];
            foundLib=false;
            for idx=1:numel(libListing)
                if contains(libListing(idx).name,libName)
                    foundLib=true;
                    break;
                end
            end
            if~foundLib
                msg=message('gpucoder:system:no_nvtx_lib',libName);
            else
                dllPath=fullfile(nvtxPath,'bin','x64');
                dllListing=dir(dllPath);
                dllName=[winLib,'.dll'];
                foundDll=false;
                for idx=1:numel(dllListing)
                    if contains(dllListing(idx).name,dllName)
                        foundDll=true;
                        break;
                    end
                end
                if~foundDll
                    msg=message('gpucoder:system:no_nvtx_lib',dllName);
                else
                    profilingStatus=true;
                end
            end
        end

    else
        lnxLib='nvToolsExt';
        llp=getenv('LD_LIBRARY_PATH');
        libName=[lnxLib,'.so'];
        libPaths=strsplit(llp,':');
        found=false;
        for idx=1:numel(libPaths)
            if found
                break;
            end
            listing=dir(libPaths{idx});
            for jdx=1:numel(listing)
                if contains(listing(jdx).name,libName)
                    found=true;
                    break;
                end
            end
        end
        if~found
            msg=message('gpucoder:system:no_nvtx_lib',libName);
        else
            profilingStatus=true;
        end
    end

end
