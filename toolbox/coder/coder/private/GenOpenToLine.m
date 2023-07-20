function GenOpenToLine(scriptName,filePath,lineNo,colNo,varargin)



    if nargin==4
        msgType='Error';
    else
        msgType=varargin{1};
    end
    switch msgType
    case 'Warning'
        msgId='warningIn';
    case 'Info'
        msgId='infoIn';
    otherwise
        msgId='errorIn';
    end
    if HasDesktop
        href=sprintf('matlab: emlcprivate(''emcopentoline'',''%s'',%d,%d);',...
        filePath,lineNo,colNo);
        msgText=message(['Coder:reportGen:',msgId],...
        href,scriptName,lineNo,colNo).getString;
    else
        msgText=message(['Coder:reportGen:',msgId,'ND'],...
        scriptName,lineNo,colNo).getString;
    end
    disp(msgText);
