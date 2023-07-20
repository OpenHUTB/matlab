function res=getResource(key,varargin)




    key=strcat("MATLAB:dependency:report:",key);
    res=string(message(key,varargin{:}));
end
