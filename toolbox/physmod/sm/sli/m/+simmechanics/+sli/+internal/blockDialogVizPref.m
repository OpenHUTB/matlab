function result=blockDialogVizPref(varargin)




    persistent SHOWVIZ

    if nargin>0
        if((islogical(varargin{1})&&varargin{1})||strcmpi(varargin{1},'on'))
            SHOWVIZ=true;
        else
            SHOWVIZ=false;
        end
    else
        if isempty(SHOWVIZ)
            SHOWVIZ=true;
        end
    end

    result=SHOWVIZ;
