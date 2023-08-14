function sscnewfileimpl(name,template)






    try
        narginchk(1,2);

        if nargin==1
            template='default';
            if strcmpi(name,'-list')
                simscape.internal.template.displayTemplateList;
                return;
            end
        end

        name=pm_charvector(name);
        template=pm_charvector(template);


        if~isvarname(name)
            pm_error('physmod:simscape:templates:newfile:InvalidMatlabId',name);
        elseif any(strcmp(name,simscape.internal.reservedKeywords))
            pm_error('physmod:simscape:templates:newfile:ReservedKeyword',name);
        end


        keywords=simscape.internal.template.getTemplateKeywords;
        if keywords.isKey(template)
            template=keywords(template);
        end


        fullFileName=which(template);
        if isempty(fullFileName)||strcmpi(fullFileName,'Not on MATLAB path')
            pm_error('physmod:simscape:templates:newfile:NotOnPath',template);
        end


        [~,~,ext]=fileparts(fullFileName);
        if strcmpi(ext,'.sscp')
            pm_error('physmod:simscape:templates:newfile:ProtectedFile',fullFileName);
        elseif~strcmpi(ext,'.ssc')
            pm_error('physmod:simscape:templates:newfile:InvalidFileType',fullFileName);
        end


        res=simscape.internal.template.findName(fullFileName);
        contents=lReplaceName(fileread(fullFileName),...
        res.line,res.column,res.name,name);


        newFile=[name,'.ssc'];
        lPrintFile(newFile,contents);
        lOpenFileForEditing(newFile);

    catch e
        throwAsCaller(e);
    end

end

function out=lReplaceName(str,line,col,oldName,newName)

    lines=splitlines(str);
    pm_assert(line<=length(lines));

    lineStr=lines{line};
    lines{line}=[lineStr(1:col-1),newName,lineStr(col+length(oldName):end)];
    out=strjoin(lines,newline);
end

function lPrintFile(filename,contents)

    filename=strcat(pwd,filesep,filename);
    if exist(filename,'file')
        pm_error('physmod:simscape:templates:newfile:FileAlreadyExists',filename);
    end
    fid=simscape.compiler.support.open_file_for_write(filename);
    fprintf(fid,'%s',contents);
    fclose(fid);
end

function lOpenFileForEditing(newFile)

    if matlab.desktop.editor.isEditorAvailable
        edit(newFile);
    end
end