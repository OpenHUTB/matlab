function BuildSequentialSolution(obj,bc)%#ok<INUSD>





    try
        clear([obj.data.mname,'_st']);



        if isempty(obj.BuildConfig)
            need_mex=false;
            codegen_line='codegen(obj.FunctionName,''-args'',obj.InputArgs,''-o'',fullfile(obj.data.workdirectory,[obj.data.tempname ''_st'']),''-d'',fullfile(obj.data.workdirectory,''codegen'',[obj.data.tempname ''sequential'']));';
            if~obj.Debugging
                [~,log]=evalc(codegen_line);
            else
                eval(codegen_line);%#ok<*EVLCS> 
            end

        elseif isa(obj.BuildConfig,'coder.MexCodeConfig')
            need_mex=false;
            codegen_line='codegen(obj.FunctionName,''-args'',obj.InputArgs,''-o'',fullfile(obj.data.workdirectory,[obj.data.tempname ''_st'']),''-config'',obj.BuildConfig,''-d'',fullfile(obj.data.workdirectory,''codegen'',[obj.data.tempname ''sequential'']));';
            if~obj.Debugging
                [~,log]=evalc(codegen_line);
            else
                eval(codegen_line);
            end

        else
            need_mex=true;
        end

        if(~need_mex)
            if~obj.Debugging
                coder.internal.errorIf(~isfield(log,'summary'),'dsp:dspunfold:ErrorBuildSequential');
                coder.internal.errorIf(~log.summary.passed,'dsp:dspunfold:ErrorBuildSequential');
            end
        else

            GenerateRenamedTop(obj,[obj.data.tempname,'_seq']);


            codegen_line='codegen([obj.data.tempname ''_seq''],''-args'',obj.InputArgs,''-o'',[''lib'' obj.data.tempname ''sequential''],''-config'',bc,''-d'',fullfile(obj.data.workdirectory,''codegen'',[obj.data.tempname ''sequential'']),''-I'',obj.data.workdirectory,''-I'',obj.data.currentdirectory);';

            if~obj.Debugging
                [~,log]=evalc(codegen_line);
                coder.internal.errorIf(~isfield(log,'summary'),'dsp:dspunfold:ErrorBuildSequential');
                coder.internal.errorIf(~log.summary.passed,'dsp:dspunfold:ErrorBuildSequential');
            else
                eval(codegen_line);
            end


            GenerateSequentialMexFile(obj);


            mex_line=['mex '...
            ,fullfile(obj.data.workdirectory,[obj.data.tempname,'_seq_mex.c']),' '...
            ,fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original'],'interface',['_coder_',obj.data.fname,'_mex.c']),' '...
            ,fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original'],'interface',['_coder_',obj.data.fname,'_api.c']),' '...
            ,'-l',obj.data.tempname,'sequential -lemlrt '...
            ,'-L"',fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'sequential']),'" '...
            ,'-I"',fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'sequential']),'" '...
            ,'-I"',fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original']),'" '...
            ,obj.data.includes...
            ,'-output ',fullfile(obj.data.workdirectory,[obj.data.tempname,'_st']),' '...
            ];

            if~obj.Debugging
                evalc(mex_line);
            else
                mex_line=[mex_line,'-v -g '];
                eval(mex_line);
            end
        end
    catch err %#ok<NASGU>
        coder.internal.error('dsp:dspunfold:ErrorBuildSequential');
    end

    try

        GenerateSequentialMexHelp(obj);
    catch err %#ok<NASGU>
        coder.internal.error('dsp:dspunfold:ErrorBuildSequentialHelp');
    end

