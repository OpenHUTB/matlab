function hdlCodeCleanUp(this,type)


    if strcmpi(type,'HDLLib')
        this.HDL.entity_library=recursiveLibClean(this.HDL.entity_library);
    elseif strcmpi(type,'HDLFile')

        this.HDLFiles=removeDuplicateFile(this.HDLFiles);
    end
end


function strOut=recursiveLibClean(strIn)
    index=strfind(strIn,';\n');
    if isempty(index)
        strOut=strIn;
    else
        b=regexprep(strIn(index(1)+3:end),[strIn(1:index(1)),'\\n'],'');
        strOut=[strIn(1:index(1)+2),recursiveLibClean(b)];
    end
end

function FileListOut=removeDuplicateFile(FileListIn)
    FileListOut={};
    keepCopies=[];
    j=1;
    for i=1:length(FileListIn)
        allCopies=find(strcmp(FileListIn,FileListIn(i)));
        if length(allCopies)==1
            firstFile=allCopies;
        else
            firstFile=allCopies(1);
        end
        tmp=(keepCopies==firstFile);
        if isempty(find(tmp,1))
            keepCopies(j)=firstFile;%#ok<AGROW>
            j=j+1;
        end
    end
    for i=keepCopies
        FileListOut{end+1}=FileListIn{i};%#ok<*AGROW>
    end

end





























