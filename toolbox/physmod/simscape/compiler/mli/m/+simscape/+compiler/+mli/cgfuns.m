function files=cgfuns(tpath,finfos,isCppModelRefSimTarget)







    if isCppModelRefSimTarget&&~isempty(finfos)
        pm_error('physmod:simscape:compiler:mli:support:UnsupportedSimTargetLang');
    end

    cgInfo.dir=tpath;

    files={};


    hName=add_matlab_fun_header(finfos,cgInfo);
    files=[files,hName];


    for i=1:length(finfos)

        curInfo=finfos(i);
        tmpDir=tempname;


        try
            nfiles=simscape.compiler.mli.cgfun(tmpDir,curInfo,cgInfo);
        catch
            pm_error('physmod:simscape:compiler:mli:support:FailedToGenerateCode',...
            curInfo.name);
        end

        files=[files,nfiles];%#ok
    end
end

function hName=add_matlab_fun_header(funInfos,cgInfo)
    targetDir=cgInfo.dir;
    fName='ssc_ml_fun.h';
    hName=fullfile(targetDir,fName);
    fid=simscape.compiler.support.open_file_for_write(hName);

    fprintf(fid,'#ifdef __cplusplus\n');
    fprintf(fid,'extern "C" {\n');
    fprintf(fid,'#endif\n');

    fprintf(fid,"#ifndef SSC_ML_FUN_H\n");
    fprintf(fid,"#define SSC_ML_FUN_H    1\n");

    for i=1:length(funInfos)
        curInfo=funInfos(i);
        fprintf(fid,'   #include "%s.h"\n',curInfo.idxstr);
    end

    fprintf(fid,"#endif\n");

    fprintf(fid,'#ifdef __cplusplus\n');
    fprintf(fid,'};\n');
    fprintf(fid,'#endif\n');

    fclose(fid);
end
