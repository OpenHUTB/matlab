function[binfoMATFile,codeName]=getBinfoMATFileAndCodeName(codeDir)




    rtwProjFile=fullfile(codeDir,'rtw_proj.tmw');
    if~isfile(rtwProjFile)
        error(message('RTW:buildProcess:buildDirInvalid',codeDir));
    end
    fid=fopen(rtwProjFile,'rt');
    if fid==-1
        error(message('RTW:utility:fileIOError',rtwProjFile,'open'));
    end

    rtwProjLine=fgetl(fid);
    if ischar(rtwProjLine)

        codeNameCell=regexp(rtwProjLine,'^Simulink Coder project for\s*(\w*)\s*using','tokens','once');
        assert(~isempty(codeNameCell),'Failed to parse codeName');
        codeName=codeNameCell{1};
        assert(~isempty(codeName),'Failed to parse codeName');
        assert(contains(codeDir,codeName),...
        'codeName is assumed to be part of codeDir.');
    else
        error(message('RTW:buildProcess:buildDirInvalid',codeDir));
    end


    for i=1:3
        rtwProjLine=fgetl(fid);
    end
    fclose(fid);
    if ischar(rtwProjLine)
        binfoMATFile=deblank(strrep(rtwProjLine,'The rtwinfomat located at: ',''));
    else
        error(message('RTW:buildProcess:buildDirInvalid',codeDir));
    end
    binfoMATFile=fullfile(codeDir,binfoMATFile);
    if~isfile(binfoMATFile)
        error(message('RTW:buildProcess:buildDirInvalid',codeDir));
    end
