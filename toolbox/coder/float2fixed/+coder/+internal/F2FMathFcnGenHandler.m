



classdef F2FMathFcnGenHandler<handle
    properties(Access=private)


autoReplaceObjs
    end

    methods(Access=public)
        function this=F2FMathFcnGenHandler()
            this.autoReplaceObjs=coder.internal.lib.Map();
        end


        function addLookupFunction(this,name,lookupCfg)
            assert(isa(lookupCfg,'coder.internal.mathfcngenerator.HDLLookupTable'));

            assert(~this.autoReplaceObjs.isKey(name));

            this.autoReplaceObjs(name)=lookupCfg;
        end



        function[code,me]=getCode(this)

            reFormatCode=@(code)regexprep(code,'(\n\s+\n)+',char(10));
            code='';
            me=[];
            keys=this.autoReplaceObjs.keys;
            for ii=1:length(keys)
                key=keys{ii};
                autoRepCfg=this.autoReplaceObjs(key);
                autoRepCfg.GenFixptCode=true;
                try
                    code=[code,reFormatCode(autoRepCfg.generateMATLAB(key))];%#ok<AGROW>
                catch ex
                    me=MException('Coder:FXPCONV:MathFcnGenFailed',key,ex.message);
                    me.addCause(ex);
                end
            end
        end
    end

    methods(Static)

        function internalObj=buildLookupConfig(autoRepCfg)
            assert(isa(autoRepCfg,'coder.internal.mathfcngenerator.Config'));

            internalObj=coder.internal.mathfcngenerator.MathFunctionGenerator('UserInterp','Linear (degree-1 Polynomial)','CandidateFunctionName',autoRepCfg.getName()).getGeneratorObject(autoRepCfg);
            internalObj.forwardProperties(autoRepCfg);
            internalObj.GenFixptCode=true;
        end
    end
end