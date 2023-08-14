function value=getDocProperty(doc,propTag)
    tmpDir=tempname();
    mkdir(tmpDir);
    tmpFile=[tmpDir,filesep,'tmp.zip'];
    copyfile(doc,tmpFile);
    unzip(tmpFile,tmpDir);
    value=getValueFromXml([tmpDir,filesep,'docProps',filesep,'core.xml'],propTag);
    rmdir(tmpDir,'s');
end

function value=getValueFromXml(fname,propTag)
    fid=fopen(fname,'r');
    xml=fread(fid,'*char')';
    match=regexp(xml,['>([^<]+)</',propTag,'>'],'tokens');
    if isempty(match)
        warning('failed to get %s value from %s',propTag,fname);
        value='';
    else
        value=match{1}{1};
    end
    fclose(fid);
end
