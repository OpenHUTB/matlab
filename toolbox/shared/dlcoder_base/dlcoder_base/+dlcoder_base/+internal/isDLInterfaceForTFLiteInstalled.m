function[flag,rootDir]=isDLInterfaceForTFLiteInstalled




    crumbFile='dlcoder_base.dl_tensorflow_lite_spkg_crumb';
    fullPath=which(crumbFile);

    if(isempty(fullPath))
        flag=false;
        rootDir='';
    else
        flag=true;
        rootDir=dlcoder_base.dl_tensorflow_lite_spkg_crumb;
    end

end
