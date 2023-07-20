function templatepath=getDefaultTemplatePath(filetype,getNonEng)





    mfilepath=fileparts(mfilename('fullpath'));
    templatefilepath=fileparts(mfilepath);

    switch lower(filetype)
    case 'docx'
        templatepath=fullfile(templatefilepath,'templates','slreqrpttemplate.dotx');
    case 'htmx'
        templatepath=fullfile(templatefilepath,'templates','slreqrpttemplate.htmtx');
    case 'html'
        templatepath=fullfile(templatefilepath,'templates','slreqrpttemplate.htmt');
    case 'pdf'
        if nargin<2
            getNonEng=~locIsInEng;
        end
        if getNonEng
            templatepath=fullfile(templatefilepath,'templates','slreqrpttemplate_noneng.pdftx');
        else
            templatepath=fullfile(templatefilepath,'templates','slreqrpttemplate.pdftx');
        end
    otherwise

        error('unknown file type');
    end
end

function out=locIsInEng
    persistent result;
    if isempty(result)
        locale=feature('locale');
        lang=locale.messages;
        if strncmpi(lang,'ja',2)||strncmpi(lang,'zh_CN',5)||strncmpi(lang,'ko_KR',5)||strncmpi(lang,'es_ES',5)
            result=false;
        else
            result=true;
        end
    end
    out=result;
end