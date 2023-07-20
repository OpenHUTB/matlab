



function stdVersion=getLanguageStdVersion(languageMode,languageExtra)

    stdVersion=convertToPolyspaceStdVersion(languageMode);
    if isempty(stdVersion)

        stdVer=regexp(languageExtra,'^(\-\-c(\+\+)?\d+)$','match');
        stdVer(cellfun(@isempty,stdVer))=[];
        if~isempty(stdVer)

            stdVersion=convertToPolyspaceStdVersion(strrep(stdVer{end}{3:end},'++','xx'));
        end
    end


    function stdVer=convertToPolyspaceStdVersion(str)

        stdVer='';
        switch str
        case{'c90','c99','c11'}
            stdVer=str;
        case{'c17','c18'}

            stdVer='c11';
        case{'cxx03','cxx11','cxx14','cxx17'}
            stdVer=strrep(str,'xx','pp');
        case 'cxx20'

            stdVer='cpp17';
        otherwise
        end


