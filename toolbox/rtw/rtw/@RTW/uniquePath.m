function[retVal,idx]=uniquePath(string_cell,varargin)








    if ispc
        [retVal,idx]=RTW.unique(string_cell,'ignorecase',varargin{1:end});
    else
        [retVal,idx]=RTW.unique(string_cell,varargin{1:end});
    end
