classdef Env<handle
    properties(SetAccess=private)
        CEnv=[];
        GlobalOptions=cgfe.c.GlobalOptions;
        SessionOptions=cgfe.c.SessionOptions;
        ownCgCtx=true;
    end

    methods
        function this=Env(varargin)

            cgCtx=[];
            for ii=1:numel(varargin)
                arg=varargin{ii};
                if isa(arg,'internal.cxxfe.FrontEndOptions')
                    this.GlobalOptions=arg;
                elseif isa(arg,'cgfe.c.SessionOptions')
                    this.SessionOptions=arg;
                else
                    if isstruct(arg)&&isfield(arg,'ptr')&&numel(arg.ptr)==2
                        cgCtx=arg;
                        this.ownCgCtx=false;
                    end
                end
            end

            this.CEnv=cfe_mex('cfe_new_env',this.GlobalOptions,this.SessionOptions,cgCtx);

        end

        function delete(this)

            if this.ownCgCtx
                cfe_mex('cfe_delete_env',this.CEnv);
            end
        end

        function scopeName=parse(this,aString,arg)
            if nargin>1
                aString=convertStringsToChars(aString);
            end
            if(nargin<2)||(~ischar(aString))||(isempty(aString))
                DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
            end
            if nargin==3&&isstruct(arg)&&isfield(arg,'ptr')&&numel(arg.ptr)==2
                scopeName=cfe_mex('cfe_parse_buffer',this.CEnv,aString,arg);
            else
                scopeName=cfe_mex('cfe_parse_buffer',this.CEnv,aString);
            end
        end

        function scopeName=parseFile(this,aString,arg)
            if nargin>1
                aString=convertStringsToChars(aString);
            end
            if(nargin<2)||(~ischar(aString))||(isempty(aString))
                DAStudio.error('Simulink:tools:CGFESecondArgNotAString')
            end
            if nargin==3&&isstruct(arg)&&isfield(arg,'ptr')&&numel(arg.ptr)==2
                scopeName=cfe_mex('cfe_parse_file',this.CEnv,aString,arg);
            else
                scopeName=cfe_mex('cfe_parse_file',this.CEnv,aString);
            end
        end

        function scopePtr=getOrCreateScope(this,aScopeName,aParentScopeName)
            if nargin>1
                aScopeName=convertStringsToChars(aScopeName);
            end
            if(nargin<2)||(~ischar(aScopeName))||(isempty(aScopeName))
                DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
            end
            if nargin==3
                aParentScopeName=convertStringsToChars(aParentScopeName);
                if~ischar(aParentScopeName)||isempty(aParentScopeName)
                    DAStudio.error('Simulink:tools:CGFEThirdArgNotAString');
                end
                scopePtr=cfe_mex('cfe_get_or_create_scope',this.CEnv,aScopeName,aParentScopeName);
            else
                scopePtr=cfe_mex('cfe_get_or_create_scope',this.CEnv,aScopeName);
            end
        end


        function printScope(this,aScopeName,aFileName)
            if nargin>1
                aScopeName=convertStringsToChars(aScopeName);
            end
            if nargin==3
                if(~ischar(aScopeName))||(isempty(aScopeName))
                    DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
                end
                aFileName=convertStringsToChars(aFileName);
                if(~ischar(aFileName))||(isempty(aFileName))
                    DAStudio.error('Simulink:tools:CGFEThirdArgNotAString');
                end
                cfe_mex('cfe_print_html_scope',this.CEnv,aScopeName,aFileName);
            elseif nargin==2
                if(~ischar(aScopeName))||(isempty(aScopeName))
                    DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
                end
                cfe_mex('cfe_print_html_scope',this.CEnv,aScopeName);
            else
                cfe_mex('cfe_print_html_scope',this.CEnv);
            end
        end

        function cEmitScope(this,aScopeName,aFileName)
            if nargin>1
                aScopeName=convertStringsToChars(aScopeName);
            end
            if(nargin<2)||(~ischar(aScopeName))||(isempty(aScopeName))
                DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
            end
            if nargin>=3
                aFileName=convertStringsToChars(aFileName);
                [fpath,fname]=fileparts(aFileName);
                cfe_mex('cfe_c_emit_scope',this.CEnv,aScopeName,fpath,fname);
            else
                cfe_mex('cfe_c_emit_scope',this.CEnv,aScopeName);
            end
        end

        function varargout=cEmitFunction(this,aScopeName,aFcnName,aFileName)
            if nargin>1
                aScopeName=convertStringsToChars(aScopeName);
            end
            if nargin>2
                aFcnName=convertStringsToChars(aFcnName);
            end
            if nargin>3
                aFileName=convertStringsToChars(aFileName);
            end
            if(nargin<3)||(isempty(aScopeName))||(~ischar(aScopeName))||(isempty(aFcnName))||(~ischar(aFcnName))
                DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
            end
            txt=cfe_mex('cfe_c_emit_function',this.CEnv,aScopeName,aFcnName);
            if nargin>=4&&~isempty(txt)
                [fpath,fname]=fileparts(aFileName);
                filename=fullfile(fpath,[fname,'.c']);
                fid=fopen(filename,'wt');
                fprintf(fid,'%s\n',txt);
                fclose(fid);
                if isempty(which('c_beautifier'))==0
                    c_beautifier(filename);
                end
            end
            if nargout>0
                varargout{1}=txt;
            end
        end

        function dotEmitCfg(this,aScopeName,aFcnName,aFileName)
            if nargin>1
                aScopeName=convertStringsToChars(aScopeName);
            end
            if nargin>2
                aFcnName=convertStringsToChars(aFcnName);
            end
            if nargin>3
                aFileName=convertStringsToChars(aFileName);
            end
            if(nargin<3)||(isempty(aScopeName))||(~ischar(aScopeName))||(isempty(aFcnName))||(~ischar(aFcnName))
                DAStudio.error('Simulink:tools:CGFESecondAndThirdArgNotAString');
            end
            if nargin>=4
                [fpath,fname]=fileparts(aFileName);
                cfe_mex('cfe_dot_emit_cfg',this.CEnv,aScopeName,aFcnName,fpath,fname);
            else
                cfe_mex('cfe_dot_emit_cfg',this.CEnv,aScopeName,aFcnName);
            end
        end

        function str=cgelEmitScope(this,aScopeName,aFileName)
            if nargin>1
                aScopeName=convertStringsToChars(aScopeName);
            end
            if nargin>2
                aFileName=convertStringsToChars(aFileName);%#ok
            end
            if(nargin<2)||(~ischar(aScopeName))||(isempty(aScopeName))
                DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
            end

            str=cfe_mex('cfe_cgel_emit_scope',this.CEnv,aScopeName);

            if nargin>=3

            end
        end

        function[outVar,outType,outFcn]=getScopeSymbols(this,aScopeName,aParentScopeName)
            if nargin>1
                aScopeName=convertStringsToChars(aScopeName);
            end
            if(nargin<2)||(~ischar(aScopeName))||(isempty(aScopeName))
                DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
            end
            if nargin==3
                if~ischar(aParentScopeName)||isempty(aParentScopeName)
                    DAStudio.error('Simulink:tools:CGFEThirdArgNotAString');
                end
                [outVar,outType,outFcn]=cfe_mex('cfe_get_scope_symbols',this.CEnv,aScopeName,aParentScopeName);
            else
                [outVar,outType,outFcn]=cfe_mex('cfe_get_scope_symbols',this.CEnv,aScopeName);
            end
        end

        function isOk=deleteSession(this,aScopeName)
            if nargin>1
                aScopeName=convertStringsToChars(aScopeName);
            end
            if(nargin<2)||(~ischar(aScopeName))||(isempty(aScopeName))
                DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
            end
            isOk=cfe_mex('cfe_delete_scope',this.CEnv,aScopeName);
        end

        function fcnNames=getFcnNames(this,aScopeName)
            if nargin>1
                aScopeName=convertStringsToChars(aScopeName);
            end
            if(nargin<2)||(~ischar(aScopeName))||(isempty(aScopeName))
                DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
            end
            fcnNames=cfe_mex('cfe_get_scope_fcns',this.CEnv,aScopeName);
        end

        function fcnNames=getMessages(this,aScopeName)
            if nargin>1
                aScopeName=convertStringsToChars(aScopeName);
            end
            if(nargin<2)||(~ischar(aScopeName))||(isempty(aScopeName))
                DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
            end
            fcnNames=cfe_mex('cfe_get_scope_msgs',this.CEnv,aScopeName);
        end

        function scopeNames=getScopeNames(this,aParentScopeName)
            if nargin==2
                aParentScopeName=convertStringsToChars(aParentScopeName);
                if~ischar(aParentScopeName)||isempty(aParentScopeName)
                    DAStudio.error('Simulink:tools:CGFESecondArgNotAString');
                end
                scopeNames=cfe_mex('cfe_get_scope_names',this.CEnv,aParentScopeName);
            else
                scopeNames=cfe_mex('cfe_get_scope_names',this.CEnv);
            end
        end

        function targetHwInfo=getTargetHarswareInfo(this)

            targetHwInfo=this.GlobalOptions.Target;
        end

        function gOptions=getGlobalOptions(this)

            gOptions=this.GlobalOptions;
        end

        function sOptions=getSessionOptions(this)

            sOptions=this.SessionOptions;
        end

        function this=setSessionOptions(this,aSessionOptions)
            if~isa(aSessionOptions,'cgfe.c.SessionOptions')
                me=MException('Simulink:tools:CGFESecondArgNotAClassOf',...
                DAStudio.message('Simulink:tools:CGFESecondArgNotAClassOf','cgfe.c.SessionOptions'));
                me.throw();
            end

            cfe_mex('cfe_set_session_options',aSessionOptions);

            this.SessionOptions=aSessionOptions;
        end

        function xConvertUnstructuredRegions(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'ConvertUnstructuredRegions');
        end

        function xConvertCyclicUnstructuredRegions(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'ConvertCyclicUnstructuredRegions');
        end

        function xDeadCodeElimination(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'DeadCodeElimination');
        end

        function xLoopFusion(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'LoopFusion');
        end

        function xLoopUnrolling(this,aScopeName,aLoopThreshold,doUnrollIf)
            if nargin<4
                doUnrollIf=true;
            end
            if nargin<3
                aLoopThreshold=500;
            end

            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'LoopUnrolling',aLoopThreshold,doUnrollIf);
        end

        function xConstantFolding(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'ConstantFolding');
        end

        function xConstantUnfolding(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'ConstantUnfolding');
        end

        function xShrinkTypes(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'ShrinkTypes');
        end

        function xExpressionFolding(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'ExpressionFolding');
        end

        function xReuseLocals(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'ReuseLocals');
        end

        function xLocalDeadCode(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'LocalDeadCode');
        end

        function xFunctionInlining(this,aScopeName,aFcnName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'FunctionInlining',aFcnName);
        end

        function xMoveScopeContents(this,aFromScopeName,aToScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aFromScopeName,'MoveScopeContents',aToScopeName);
        end

        function xPeepHole(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'PeepHole');
        end

        function xRemoveAllUnsupportedOp(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'RemoveAllUnsupportedOp');
        end

        function xRemoveUnsupportedOp(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'RemoveUnsupportedOp');
        end

        function xRemoveGotoLabel(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'RemoveGotoLabel');
        end

        function xRemoveNestedAssignment(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'RemoveNestedAssignment');
        end

        function xRemoveConditional(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'RemoveConditional');
        end

        function xUniquifyName(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'UniquifyName');
        end

        function xCCastElimination(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'CCastElimination');
        end

        function xDeleteEmptyFcns(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'DeleteEmptyFcns');
        end

        function xSanityCheck(this,aScopeName,doStrictCheck)
            if nargin<3
                doStrictCheck=true;
            end
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'SanityCheck',doStrictCheck);
        end

        function xReplaceNilToNull(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'ReplaceNilToNull');
        end

        function xBackFolding(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'BackFolding');
        end

        function xStrengthReduction(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'StrengthReduction');
        end

        function xCorePruneUnusedVars(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'CorePruneUnusedVars');
        end

        function xCorePruneUnusedNamedConsts(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'CorePruneUnusedNamedConsts');
        end

        function xConvertIfWithIdenticalBranches(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'ConvertIfWithIdenticalBranches');
        end

        function xNegateIfWithEmptyTrue(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'NegateIfWithEmptyTrue');
        end

        function xConvertIfToSwitch(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'ConvertIfToSwitch');
        end

        function xCCastInsertion(this,aScopeName)
            cfe_mex('cfe_xform_scope',this.CEnv,aScopeName,'CCastInsertion');
        end

    end

    methods(Static)
        function setLoggerLevel(aLevel)
            cfe_mex('cfe_set_log_level',lower(aLevel));
        end
    end
end


