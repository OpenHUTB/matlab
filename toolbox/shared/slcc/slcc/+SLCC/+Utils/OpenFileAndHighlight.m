
function OpenFileAndHighlight(path,line,col,length,hMdl)


    if nargin<5
        hMdl=[];
    end

    if~isempty(path)
        [~,fileName,ext]=fileparts(path);
        if strcmp(ext,'.in')&&~isempty(regexp(fileName,'^cxxfe_','once'))

            assert(~isempty(hMdl),'Model handle should not be empty!');
            configset.highlightParameter(hMdl,'SimCustomSourceCode');
        else
            opentoline(path,line,col);
            doc=matlab.desktop.editor.findOpenDocument(path);

            doc.Selection=[line,col,line,col+length];
        end
    elseif~isempty(hMdl)



        configset.highlightParameter(hMdl,'SimCustomHeaderCode');
    else
        return;
    end
end