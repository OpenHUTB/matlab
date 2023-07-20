function[title,titleDirty]=getTitle(this)
    appName=this.AppName;
    if strcmp(appName,'sdi')
        id='sdi';
    elseif strcmp(appName,'siganalyzer')
        id='sigAnalyzer';
    end

    if~isempty(this.FileName)
        title=getString(message(['SDI:',id,':TitleFileNotDirty'],this.FileName));
        titleDirty=getString(message(['SDI:',id,':TitleFileDirty'],this.FileName));
    else
        title=getString(message(['SDI:',id,':ToolName']));
        titleDirty=getString(message(['SDI:',id,':TitleUnnamedFileDirty']));
    end
end
