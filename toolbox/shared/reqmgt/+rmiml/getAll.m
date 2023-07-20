function[result,rawData]=getAll(varargin)














    rawData=mleditor.getAll(varargin{:},false);

    if isempty(rawData)
        result=java.util.ArrayList(0);
    else
        result=rmiut.cellToJava(rawData,(nargin<2));
    end

end

