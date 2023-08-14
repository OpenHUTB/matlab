function this=StylesheetHeaderCell(parentObj,varargin)






    this=feval(mfilename('class'));
    if length(varargin)==0||isempty(varargin{1})
        javaHandle=parentObj.JavaHandle.getOwnerDocument.createElement('xsl:when');
        javaHandle.setAttribute('test','');
        varargin{1}=javaHandle;
    end


    this.init(parentObj,varargin{:});

