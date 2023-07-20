function read(this,aFilename)






    if nargin>1
        aFilename=convertStringsToChars(aFilename);
    end

    if nargin<2
        filename=this.filename;
    else
        filename=aFilename;
    end

    if isempty(filename)
        DAStudio.error('RTW:autosar:badReadArgument');
    end


    if exist(filename,'file')==0
        DAStudio.error('RTW:autosar:badReadFilename',filename);
    end

    if exist(filename,'file')~=2
        DAStudio.error('RTW:autosar:badReadAutosarFile',filename);
    end


    directory=fileparts(filename);
    if isempty(directory)
        this.filename=which(filename);
    else
        this.filename=filename;
    end


