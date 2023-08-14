classdef(Hidden)Dispatcher<handle






























    properties(Access=private)
        ClassNameToFunction;
    end

    methods
        function this=Dispatcher()
            this.ClassNameToFunction=dictionary(...
            string.empty(),...
            function_handle.empty());
        end

        function ret=dispatch(this,slpobj,varargin)









            if this.ClassNameToFunction.isKey(slpobj.ClassName)
                fcn=this.ClassNameToFunction(slpobj.ClassName);
                objH=slpobj.getHandle();
                ret=fcn(this,objH,varargin{:});
            else
                ret=[];
                for i=1:numel(slpobj.SuperClassNames)
                    superClassName=slpobj.SuperClassNames{i};
                    if this.ClassNameToFunction.isKey(superClassName)
                        fcn=this.ClassNameToFunction(superClassName);
                        objH=slpobj.getHandle();
                        ret=fcn(this,objH,varargin{:});
                        break;
                    end
                end
            end
        end

        function bind(this,className,fcn)







            if this.ClassNameToFunction.isKey(className)
                if~isempty(this.ClassNameToFunction(className))
                    error(message('slreportgen_webview:webview:AlreadyBinded',className));
                end
            end
            this.ClassNameToFunction(className)=fcn;
        end

        function unbind(this,className)



            this.ClassNameToFunction(className)=[];
        end
    end
end
