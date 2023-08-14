



...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

classdef STimeSpecT<eda.internal.mcosutils.InheritEvalT
    properties(SetAccess=protected)
        inhRule=eda.internal.filhost.STimeInheritRuleT('Inherit: Inherit via internal rule');
    end
    properties(SetAccess=private)
        period=double(1.0);
        offset=double(0.0);
    end

    methods(Access=public)

        function this=STimeSpecT(varargin)

            if(isempty(varargin)),return;end

            ctorArgs=this.localEval(this,varargin{:});

            if(length(ctorArgs)==1&&isnumeric(ctorArgs{1}))
                arg=ctorArgs{1};
                if(length(arg)==1)
                    this.period=arg;
                elseif(length(arg)==2)
                    this.period=arg(1);
                    this.offset=arg(2);
                else

                end
                this.setNoInh();

            elseif(length(ctorArgs)==2&&all(cellfun(@isnumeric,ctorArgs)))
                this.period=ctorArgs{1};
                this.offset=ctorArgs{2};
                this.setNoInh();

            elseif(length(ctorArgs)==1&&ischar(ctorArgs{1}))
                this=this.InhEvalCtor(this,ctorArgs{:});

            elseif(length(ctorArgs)==1&&strcmp(class(ctorArgs{1}),class(this)))
                this=eda.internal.mcosutils.ObjUtilsT.CopyCtor(this,ctorArgs{1});


            else
                error(message('EDALink:FILParamErrWarn:BadSTimeSpecCtorArgs'));
            end

        end

        function outS=getStruct(this,simstatus)
            this=this.evalInBase(simstatus);

            outS=struct(this);
            outS.inhRule=this.inhRule.asInt();
        end
    end

    methods

        function set.period(this,val)
            this.period=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'double',[0,inf],'period');
        end

        function set.offset(this,val)
            this.offset=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'double',[0,realmax],'offset');
        end
    end

    methods(Access=protected)

        function strList=getObjStringCtorList_(this)%#ok<MANU>
            strList={'1','[1 0]'};
        end

        function stStr=asString_(this)
            if(this.offset~=0)
                stStr=mat2str([this.period,this.offset]);
            else
                stStr=mat2str(this.period);
            end
        end
    end

end
