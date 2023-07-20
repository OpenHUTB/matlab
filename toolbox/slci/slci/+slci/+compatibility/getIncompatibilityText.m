function out=getIncompatibilityText(aCode,varargin)



    cmd='out = DAStudio.message(''Slci:compatibility:';
    cmd=[cmd,aCode,''''];
    for i=1:nargin-1
        cmd=[cmd,', varargin{',num2str(i),'}'];
    end
    cmd=[cmd,');'];
    eval(cmd);
