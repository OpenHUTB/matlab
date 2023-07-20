function text=getText(varargin)





    if nargin==0
        editor=matlab.desktop.editor.getActive;
        text=editor.SelectedText;
    else
        srcKey=varargin{1};
        if rmisl.isSidString(srcKey)
            fullText=rmiml.mlfbGetCode(srcKey);
        else
            try
                fullText=filePathToText(srcKey);
            catch ex %#ok<NASGU>
                text=getString(message('Slvnv:rmiml:FileNotFound',srcKey));
                return;
            end
        end
        if nargin>1
            range=varargin{2};
            if ischar(range)

                range=slreq.idToRange(srcKey,range);
                if isempty(range)
                    text='';
                    return;
                elseif range(end)==0
                    text='';
                    return;
                else

                end
            end
            text=fullText(range(1):range(2)-1);
        else
            text=fullText;
        end
    end
end

function fullText=filePathToText(fPath)
    fDir=fileparts(fPath);
    if isempty(fDir)
        fullPath=which(fPath);
        if isempty(fullPath)
            error(message('Slvnv:rmiml:FileNotFound',fPath));
        end
    elseif exist(fPath,'file')==2
        fullPath=fPath;
    else
        error(message('Slvnv:rmiml:FileNotFound',fPath));
    end


    docInEditor=matlab.desktop.editor.findOpenDocument(fullPath);
    if isempty(docInEditor)

        fullText=matlab.internal.getCode(fullPath);
    else
        fullText=char(docInEditor.Text);
    end

end


