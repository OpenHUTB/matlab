function[status,result]=system(cmd,varargin)



    if nargin>0
        cmd=convertStringsToChars(cmd);
    end

    lBuildLogger=[];
    [status,result]=coder.make.internal.system(cmd,lBuildLogger,varargin);
