



function aPath=fixPathSep(aPath)


    persistent wrongFilesepChar filesepChar
    if isempty(wrongFilesepChar)
        filesepChar=filesep;
        if isunix
            wrongFilesepChar='\';
        else
            wrongFilesepChar='/';
        end
    end

    aPath(aPath==wrongFilesepChar)=filesepChar;
