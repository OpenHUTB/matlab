classdef ProgressConsole<slreportgen.webview.ProgressMonitor















    properties(Access=private)
        PreviousMessage string="";
    end

    methods
        function this=ProgressConsole(varargin)
            this=this@slreportgen.webview.ProgressMonitor(varargin{:});
        end
    end

    methods(Access=protected)
        function update(this)
            percent=this.getPercent();

            if isnan(percent)
                message=sprintf("%s",this.Message);
            else
                message=sprintf("[%.2f%%] %s",this.getPercent()*100,regexprep(this.Message,'\s',' '));
            end

            if(message~=this.PreviousMessage)
                disp(message);
                this.PreviousMessage=message;
            end
        end
    end
end