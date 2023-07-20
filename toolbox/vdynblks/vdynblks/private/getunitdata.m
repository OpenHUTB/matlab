function ConvertStruct=getunitdata(mtype,varargin)






    if isempty(varargin)
        ConvertStruct=aeroconvertdata(mtype);
    elseif length(varargin)==1
        ConvertStruct=aeroconvertdata(mtype,varargin{1});
    else
        ConvertStruct=aeroconvertdata(mtype,varargin{1},varargin{2});
    end
