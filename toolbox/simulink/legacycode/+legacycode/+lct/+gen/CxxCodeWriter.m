



classdef(Hidden=true)CxxCodeWriter<rtw.connectivity.CCodeWriter


    methods(Hidden)




        function this=CxxCodeWriter(outWriter)
            this@rtw.connectivity.CCodeWriter(outWriter);
        end
    end


    methods



        function wBlockStart(this,varargin)
            if nargin<2
                wBlockStart@rtw.connectivity.CCodeWriter(this,'');
            else
                wBlockStart@rtw.connectivity.CCodeWriter(this,varargin{:});
            end
        end




        function wBlockEnd(this,varargin)
            if nargin<2
                wBlockEnd@rtw.connectivity.CCodeWriter(this,'');
            else
                wBlockEnd@rtw.connectivity.CCodeWriter(this,varargin{:});
            end
        end




        function wCmt(this,cmt,varargin)
            if nargin>2
                cmt=sprintf(cmt,varargin{:});
            elseif nargin<2
                cmt='';
            end
            this.wComment(cmt);
        end




        function wMultiCmtStart(this,cmt,varargin)
            if nargin>2
                cmt=sprintf(cmt,varargin{:});
            elseif nargin<2
                cmt='';
            end
            this.wMultilineCommentStart(cmt);
        end




        function wMultiCmtMiddle(this,cmt,varargin)
            if nargin>2
                cmt=sprintf(cmt,varargin{:});
            elseif nargin<2
                cmt='';
            end
            this.wMultilineCommentMiddle(cmt);
        end




        function wMultiCmtEnd(this,cmt,varargin)
            if nargin>2
                cmt=sprintf(cmt,varargin{:});
            elseif nargin<2
                cmt='';
            end
            this.wMultilineCommentEnd(cmt);
        end
    end

end


