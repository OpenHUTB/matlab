classdef InheritEvalT<handle
    properties(Abstract=true,SetAccess=protected)
        inhRule;
    end
    properties(Constant=true,Hidden=true)
        noInhRule_='No inheritance';
        expVarOrFunc_='<expression, variable, or function>';
    end
    properties(Access=private)
        ctorStr_='';
        evalInBase_=false;
    end

    methods(Static=true,Access=public)
        function ctorArgs=localEval(obj,varargin)
            ctorArgs=varargin;
            if(length(ctorArgs)==1...
                &&ischar(ctorArgs{1})...
                &&~any(strcmp(ctorArgs{1},obj.inhRule.strValues)))
                obj.setCtorStr(ctorArgs{1});
                try

                    ctorArgs=eval(ctorArgs{1});
                    if(~iscell(ctorArgs))
                        ctorArgs={ctorArgs};
                    end
                catch ME %#ok<NASGU>

                end
            end
        end

        function this=InhEvalCtor(this,strArg)
            try
                this.inhRule=feval(class(this.inhRule),strArg);
                this.ctorStr_=strArg;
                this.evalInBase_=false;
            catch ME



                stacknames={ME.stack.name};
                if(any(strcmp('InheritEvalT.evalInBase',stacknames)))
                    error(message('EDALink:FILParamErrWarn:FailedDeferredEval'));
                else
                    this.setNoInh;
                    this.ctorStr_=strArg;
                    this.evalInBase_=true;
                end
            end
        end
    end
    methods(Access=public)
        function this=InheritEvalT(varargin)

        end

        function strRep=asString(this)
            if~isempty(this.ctorStr_)
                strRep=this.ctorStr_;
            elseif(~strcmp(this.inhRule.asString(),this.noInhRule_))
                strRep=this.inhRule.asString();
            else
                strRep=this.asString_();
            end
        end

        function strCtorList=stringCtorList(this)
            vsl=[this.inhRule.strValues,this.getObjStringCtorList_(),this.expVarOrFunc_];
            strCtorList=vsl(~strcmp(this.noInhRule_,vsl));
        end

        function yesno=isEvalInBaseCtor(this)
            yesno=this.evalInBase_;
        end

        function this=evalInBase(this,simstatus)
            if(~strcmp(simstatus,'stopped')&&this.evalInBase_)
                evaledCtorStr=evalin('base',this.ctorStr_);


                if(strcmp(class(evaledCtorStr),'function_handle'))
                    varargout=evaledCtorStr();
                    evaledCtorStr=varargout;
                end

                this=feval(class(this),evaledCtorStr);
            else

            end
        end

        function this=setNoInh(this)
            this.inhRule=feval(class(this.inhRule),this.noInhRule_);
        end

        function this=setCtorStr(this,val)
            this.ctorStr_=val;
        end
    end

    methods(Access=protected)
        function list=getObjStringCtorList_(this)%#ok<MANU>
            list=[];
        end
        function str=asString_(this)%#ok<MANU>
            str='';
        end
    end
end

