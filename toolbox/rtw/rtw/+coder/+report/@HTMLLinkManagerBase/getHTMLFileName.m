function out=getHTMLFileName(obj,fullFileName)
    out='';
    if~isempty(fullFileName)&&iscell(fullFileName)
        fullFileName=fullFileName{1};
    end
    [p,f,ext]=fileparts(fullFileName);
    if~isempty(ext)
        out=fullfile(p,'html',[f,'_',ext(2:end),'.html']);

        if~exist(out,'file')
            out=fullfile(obj.BuildDir,'html',[f,'_',ext(2:end),'.html']);
        end
    end
end
