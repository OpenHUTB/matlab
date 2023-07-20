



function hiliteCode(mdlName,title,input)



    fileNames=keys(input);

    data={};

    for idx=1:numel(fileNames)
        fileName=fileNames{idx};
        lineNos=input(fileName);
        if isempty(lineNos)
            data{end+1}...
            =struct('file',fileName,'line',1);%#ok
        else
            for iLine=1:numel(lineNos)
                data{end+1}...
                =struct('file',fileName,...
                'line',lineNos(iLine));%#ok
            end
        end
    end

    if~isempty(data)
        values.title=title;
        values.data=data';
        simulinkcoder.internal.util.highlightInCode(mdlName,values);
    end
end
