function list=getReferencedModelLib(h,buildInfo)




    list='';
    for i=1:length(buildInfo.ModelRefs)
        list{i}=getFullName(h,buildInfo.ModelRefs(i).Path,buildInfo.ModelRefs(i).Name);
    end


    function fullLibPath=getFullName(h,LibPath,LibName)
        [fpath,basename,ext]=fileparts(LibName);%#ok<NASGU>
        libname=strrep(basename,'_rtwlib',h.getLibExt);
        fullLibPath=fullfile(pwd,LibPath,[h.getProjectOptions,'MW'],libname);
