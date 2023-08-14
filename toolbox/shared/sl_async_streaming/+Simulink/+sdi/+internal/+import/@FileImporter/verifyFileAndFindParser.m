function[fullFilename,parser]=verifyFileAndFindParser(this,filename,varargin)
    [~,shortFilename,extension]=fileparts(filename);
    if isempty(extension)

        fullFilename=[shortFilename,'.mat'];
        if~exist(fullFilename,'file')
            excluding={'.mat'};
            fullFilename=lookForExistingFile(this,shortFilename,excluding);
        end
    else
        fullFilename=filename;
    end

    fileExists=exist(fullFilename,'file');
    if~fileExists
        error(message('SDI:sdi:ImportFileNotFound'));
    end

    [~,~,extension]=fileparts(fullFilename);
    parser=getParser(this,extension,fullFilename,varargin{:});
end