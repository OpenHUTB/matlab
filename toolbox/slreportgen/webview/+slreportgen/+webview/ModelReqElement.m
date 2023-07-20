classdef ModelReqElement<slreportgen.webview.ModelElement







    methods
        function this=ModelReqElement(document,id,width,height,sourceUrl)
            this@slreportgen.webview.ModelElement(document,id,width,height,sourceUrl);
            this.Widget='slreqwebview/ReqApp';
        end
    end
end

