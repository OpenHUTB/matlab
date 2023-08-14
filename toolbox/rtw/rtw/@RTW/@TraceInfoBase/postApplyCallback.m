function[status,errMsg]=postApplyCallback(hSrc,hDlg)




    status=true;
    errMsg='';

    tag_BuildDir='Tag_TraceInfo_BuildDir';
    buildDir=getWidgetValue(hDlg,tag_BuildDir);
    try
        hSrc.setBuildDir(buildDir);
    catch me
        status=false;
        errMsg=me.message;
    end

