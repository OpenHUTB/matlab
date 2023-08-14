



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

classdef InhUint32T<eda.internal.mcosutils.InheritEvalT
    properties(SetAccess=protected)
        inhRule=eda.internal.filhost.InheritRuleT('Inherit: auto');
    end
    properties(SetAccess=private,SetObservable=true)
        value=uint32(1);
        minval=intmin('uint32');
        maxval=intmax('uint32');
    end
    properties(Constant=true,Hidden=true)
        observableProps_=[];
    end
    methods(Access=public)
        function this=InhUint32T(varargin)

            if(isempty(varargin)),return;end

            ctorArgs=this.localEval(this,varargin{:});

            if(length(ctorArgs)==3)
                this.minval=ctorArgs{2};
                this.maxval=ctorArgs{3};
                ctorArgs=ctorArgs(1);
            end

            if(length(ctorArgs)==1&&isnumeric(ctorArgs{1}))
                arg=ctorArgs{1};
                if(length(arg)>=1)
                    this.value=arg;
                else

                end
                this.setNoInh();

            elseif(length(ctorArgs)==1&&ischar(ctorArgs{1}))
                this=this.InhEvalCtor(this,ctorArgs{:});

            elseif(length(ctorArgs)==1&&strcmp(class(ctorArgs{1}),class(this)))
                this=eda.internal.mcosutils.ObjUtilsT.CopyCtor(this,ctorArgs{1});


            else
                error(message('EDALink:FILParamErrWarn:BadInhUint32CtorArgs'));
            end

        end

        function outS=getStruct(this,simstatus)
            this=this.evalInBase(simstatus);

            outS=struct(this);
            outS.inhRule=this.inhRule.asInt();
        end


    end

    methods
        function set.value(this,val)
            this.value=...
            eda.internal.mcosutils.ObjUtilsT.CheckNumeric(...
            val,'uint32',[this.minval,this.maxval],'value');
        end
    end

    methods(Access=protected)
        function strRep=asString_(this)
            strRep=mat2str(this.value);
        end
    end

end
