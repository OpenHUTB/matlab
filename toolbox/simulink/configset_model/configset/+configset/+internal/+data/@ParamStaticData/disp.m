function disp(obj)

    if isempty(obj.Location)
        fprintf('Configuration Set Parameter: %s\n',obj.FullName);
    else
        f=strjoin(obj.Location.file,filesep);
        file=fullfile(matlabroot,f);
        fprintf('Configuration Set Parameter: <a href="matlab:matlab.desktop.editor.openAndGoToLine(''%s'',%d);">%s</a>\n',...
        file,obj.Location.line,obj.FullName);
    end
    disp@handle(obj);
