function d=addData(this,varargin)





    try
        d=RptgenML.createStylesheetElement(this,varargin{:});
    catch ME
        d=[];
        warning(ME.message);
    end

