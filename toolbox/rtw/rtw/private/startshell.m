function startshell(varargin)






    if nargin<1
        startPath=pwd;
    else
        startPath=varargin{1};
    end

    curDir=pwd;

    try
        cd(startPath);
        if ispc
            cmd='start';
        else
            cmd='xterm&';
        end
        rtw.system(cmd);
        cd(curDir);
    catch exc %#ok<NASGU>
        cd(curDir);
    end;
