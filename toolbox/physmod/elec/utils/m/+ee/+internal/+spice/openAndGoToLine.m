function varargout=openAndGoToLine(fileName,subcircuitName)





    A=split(fileread(fileName),sprintf('\n'));
    B=regexp(A,['^.SUBCKT\s+',subcircuitName,'\s+']);
    whichline=find(~cellfun(@isempty,B));

    fileInfo=matlab.desktop.editor.openAndGoToLine(which(fileName),whichline);
    switch nargout
    case 0
        varargout={};
    case 1
        varargout={fileInfo};
    end

