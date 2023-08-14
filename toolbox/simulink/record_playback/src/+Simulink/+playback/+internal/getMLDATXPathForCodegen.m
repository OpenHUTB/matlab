function[fullPath,relPath]=getMLDATXPathForCodegen(bpath)
















    fgc=Simulink.fileGenControl('getConfig');
    startDir=fgc.CacheFolder;


    mdl=bdroot(bpath);


    if locIsRapidAccel(mdl)
        midDir='raccel';
    else
        midDir='sim';
    end







    fname=[strrep(Simulink.ID.getSID(bpath),':','_'),'.mldatx'];


    relPath=fullfile('slprj',midDir,mdl,'tmwinternal',fname);
    fullPath=fullfile(startDir,relPath);
end


function ret=locIsRapidAccel(mdl)
    cs=getActiveConfigSet(mdl);
    stf=get_param(cs,'SystemTargetFile');
    ret=strcmpi(stf,'raccel.tlc');
end
