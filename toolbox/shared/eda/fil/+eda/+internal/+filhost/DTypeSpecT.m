



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
...

classdef DTypeSpecT<eda.internal.mcosutils.InheritEvalT

    properties(SetAccess=protected)
        inhRule=eda.internal.filhost.DTypeInheritRuleT('Inherit: auto');
    end
    properties(SetAccess=private,SetObservable=true)
        mode=eda.internal.filhost.DTypeModeT('Use builtin');
        builtin=eda.internal.filhost.DTypeBuiltinT('double');
        fxScalingMode=eda.internal.filhost.DTypeFixptScalingModeT('Fixed-point: binary point scaling');
        fxScalingSpec=eda.internal.filhost.DTypeFixptScalingSpecT;
        signedness=eda.internal.filhost.DTypeSignednessT('Unsigned');
    end

    methods(Access=public)

        function this=DTypeSpecT(varargin)

            if(isempty(varargin)),return;end

            ctorArgs=this.localEval(this,varargin{:});


            if(length(ctorArgs)==1&&strcmp(class(ctorArgs{1}),'Simulink.NumericType'))
                ctorArgs{1}=fixdt(ctorArgs{1});
            end

            if(length(ctorArgs)==1&&ischar(ctorArgs{1}))

                if(~isempty(regexp(ctorArgs{1},'^sfix|^ufix|^fixdt','once'))||...
                    any(strcmp(ctorArgs{1},this.builtin.strValues)))
                    this=this.stringCtor(ctorArgs{1});
                    this.setNoInh();
                else
                    this=this.InhEvalCtor(this,ctorArgs{1});
                end

            elseif(length(ctorArgs)==1&&strcmp(class(ctorArgs{1}),class(this)))
                this=eda.internal.mcosutils.ObjUtilsT.CopyCtor(this,ctorArgs{1});


            else
                error(message('EDALink:FILParamErrWarn:BadDtypeSpecCtorArgs'));
            end

        end

        function bitwidth=getBitwidth(this)
            if(~strcmp(this.inhRule.asString(),'No inheritance'))
                bitwidth=-1;
            else
                switch(this.mode.asString())
                case 'Use builtin'
                    switch(this.builtin.asString())
                    case 'double',bitwidth=64;
                    case 'single',bitwidth=32;
                    case 'boolean',bitwidth=1;
                    otherwise
                        nt=numerictype(this.builtin.asString());
                        bitwidth=nt.WordLength;
                    end
                case 'Use fixed point'
                    bitwidth=this.fxScalingSpec.wordLength;
                end
            end
        end

        function outS=getStruct(this,simstatus)
            this=this.evalInBase(simstatus);

            outS.mode=this.mode.asInt();
            outS.inhRule=this.inhRule.asInt();
            outS.builtin=this.builtin.asInt();
            outS.fxScalingMode=this.fxScalingMode.asInt();
            outS.fxScalingSpec=struct(this.fxScalingSpec);
            outS.signedness=this.signedness.asInt();
        end
    end

    methods
        function set.mode(this,val)
            this.mode=eda.internal.filhost.DTypeModeT(val);
        end
        function set.builtin(this,val)
            this.builtin=eda.internal.filhost.DTypeBuiltinT(val);
        end
        function set.fxScalingMode(this,val)
            this.fxScalingMode=eda.internal.filhost.DTypeFixptScalingModeT(val);
        end
        function set.fxScalingSpec(this,val)
            classVal=eda.internal.filhost.DTypeFixptScalingSpecT(val);
            this.fxScalingSpec=classVal;
        end
        function set.signedness(this,val)
            this.signedness=eda.internal.filhost.DTypeSignednessT(val);
        end
    end

    methods(Access=protected)
        function list=getObjStringCtorList_(this)
            bw=this.getBitwidth();
            list={''};







            if(bw==1)
                list=[list,{'boolean'}];
            end
            list=[list,{...
            numerictype(0,bw,0).tostringInternalSlName,...
            numerictype(1,bw,0).tostringInternalSlName,...
            numerictype(0,bw,0).tostringInternalFixdt,...
            numerictype(1,bw,0).tostringInternalFixdt}];
        end



        function dtStr=asString_(this)
            dtStr='';
            switch(this.mode.asString())
            case 'Use builtin'
                dtStr=this.builtin.asString();

            case 'Use fixed point'
                signed=this.signedness.asInt();
                switch(this.fxScalingMode.asString())
                case 'Fixed-point: unspecified scaling'
                    fxp=fixdt(signed,this.fxScalingSpec.wordLength);
                case 'Fixed-point: binary point scaling'
                    fxp=fixdt(signed,this.fxScalingSpec.wordLength,...
                    this.fxScalingSpec.fractionLength);
                case 'Fixed-point: slope and bias scaling'
                    fxp=fixdt(signed,this.fxScalingSpec.wordLength,...
                    this.fxScalingSpec.totalSlope,this.fxScalingSpec.bias);
                end
                dtStr=fixdt(fxp);
            end
        end
    end

    methods(Access=private)
        function this=stringCtor(this,strArg)
            if(any(strcmp(strArg,this.builtin.strValues)))
                this.mode='Use builtin';
                this.builtin=strArg;
                switch(this.builtin.asString())
                case{'int8','int16','int32','single','double','int64'}
                    this.signedness=eda.internal.filhost.DTypeSignednessT('Signed');
                case{'boolean','uint8','uint16','uint32','uint64'}
                    this.signedness=eda.internal.filhost.DTypeSignednessT('Unsigned');
                end
            else



                if(regexp(strArg,'^ufix|^sfix'))
                    strArg=['fixdt(''',strArg,''')'];
                end


                if(regexp(strArg,'^fixdt'))
                    try
                        fxp=eval(strArg);
                    catch ME
                        error(message('EDALink:DTypeSpecT:BadFixdtExpression',ME.message()));
                    end
                    this.mode='Use fixed point';
                    this.signedness=fxp.Signedness;
                    this.fxScalingMode=fxp.DataTypeMode;

                    switch(fxp.DataTypeMode)
                    case 'Fixed-point: binary point scaling'
                        this.fxScalingSpec=...
                        {'wordLength',fxp.WordLength,'fractionLength',fxp.FractionLength};
                    case 'Fixed-point: slope and bias scaling'
                        this.fxScalingSpec=...
                        {'wordLength',fxp.WordLength,'totalSlope',fxp.Slope,'bias',fxp.Bias};
                    case 'Fixed-point: unspecified scaling'
                        this.fxScalingSpec=...
                        {'wordLength',fxp.WordLength};
                    end
                end
            end
        end
    end

end


