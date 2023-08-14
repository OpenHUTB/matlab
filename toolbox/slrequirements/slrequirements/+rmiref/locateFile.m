function located=locateFile(doc)




    if exist(doc,'file')
        absPathTest=fullfile(pwd,doc);
        if exist(absPathTest,'file')
            located=absPathTest;
        else
            located=doc;
        end
    else

        located=which(doc);
        if isempty(located)
            error(message('Slvnv:rmiref:DocCheckWord:locateDocument',doc));
        end
    end
end
