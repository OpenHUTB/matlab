function[pass,config]=BuildParallelSolution(obj,bc,overlap,allow_to_fail,for_autodetect)





    pass=false;

    try
        clear(obj.data.real_mname);
        bc.EnableOpenMP=false;

        if obj.Threads==1
            bc.MultiInstanceCode=false;
            config.Threads=1;
            config.Repetition=obj.Repetition;
            config.SKIP_AHEAD=0;
            config.SKIP_AHEAD_SUBFRAME=0;
            config.REAL_SKIP_AHEAD=0;
        elseif(overlap.SKIP_AHEAD==(obj.Threads-1)*obj.Repetition&&overlap.SKIP_AHEAD_SUBFRAME==0)
            bc.MultiInstanceCode=false;
            config.Threads=1;
            config.Repetition=obj.Threads*obj.Repetition;
            config.SKIP_AHEAD=0;
            config.SKIP_AHEAD_SUBFRAME=0;
            config.REAL_SKIP_AHEAD=Inf;
            if~for_autodetect
                if any(obj.data.FrameInputs)
                    coder.internal.warning('dsp:dspunfold:SingleThreadedFallbackSamples',num2str(obj.data.FRAMES_LENGTH),num2str(obj.Threads-1),num2str(obj.Repetition),num2str(obj.data.FRAMES_LENGTH*(obj.Threads-1)*obj.Repetition));
                else
                    coder.internal.warning('dsp:dspunfold:SingleThreadedFallbackFrames',num2str(obj.Threads-1),num2str(obj.Repetition),num2str((obj.Threads-1)*obj.Repetition));
                end
            end
        else
            bc.MultiInstanceCode=true;
            config.Threads=obj.Threads;
            config.Repetition=obj.Repetition;
            config.SKIP_AHEAD=overlap.SKIP_AHEAD;
            config.SKIP_AHEAD_SUBFRAME=overlap.SKIP_AHEAD_SUBFRAME;
            config.REAL_SKIP_AHEAD=overlap.SKIP_AHEAD;
        end

        GenerateParallelDispatcher(obj,config,for_autodetect);


        args={};
        for i=1:numel(obj.InputArgs)
            if isa(obj.InputArgs{i},'coder.Constant')
                args{i}=eval('obj.InputArgs{i}');%#ok<AGROW>
            else
                args{i}=eval('coder.cstructname(coder.typeof(struct(''buffer'',struct(''frame'',repmat(obj.InputArgs(i),config.SKIP_AHEAD+config.Repetition*config.Threads,1)))),[obj.data.TopFunctionInputs{i}.VarName ''_struct''])');%#ok<AGROW>
            end
        end


        codegen_line='codegen([obj.data.tempname ''_par''],''-args'',args,''-o'',[''lib'' obj.data.tempname ''parallel''],''-config'',bc,''-d'',fullfile(obj.data.workdirectory,''codegen'',[obj.data.tempname ''parallel'']),''-I'',obj.data.workdirectory,''-I'',obj.data.currentdirectory);';

        if~obj.Debugging
            [~,log]=evalc(codegen_line);
            coder.internal.errorIf(~isfield(log,'summary'),'dsp:dspunfold:ErrorBuildParallel');
            coder.internal.errorIf(~log.summary.passed,'dsp:dspunfold:ErrorBuildParallel');
        else
            eval(codegen_line);%#ok<*EVLCS> 
        end



        GenerateParallelMexHeader(obj);


        GenerateParallelMexFile(obj,config);


        mex_line=['mex '...
        ,'''',fullfile(obj.data.workdirectory,[obj.data.tempname,'_par_mex.c']),'''',' '...
        ,'''',fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original'],'interface',['_coder_',obj.data.fname,'_mex.c']),'''',' '...
        ,'''',fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original'],'interface',['_coder_',obj.data.fname,'_api.c']),'''',' '...
        ,'-l',obj.data.tempname,'parallel -l',obj.data.tempname,'original -lemlrt -lmwipp '...
        ,'-L"',fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'parallel']),'" '...
        ,'-I"',fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'parallel']),'" '...
        ,'-L"',fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original']),'" '...
        ,'-I"',fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original']),'" '...
        ,'-I"',fullfile(matlabroot,'toolbox','shared','ipp','include',computer('arch')),'" '...
        ,obj.data.includes...
        ,'-output ','''',fullfile(obj.data.workdirectory,[obj.data.tempname,'_mt']),'''',' '...
        ];
        if ispc
            mex_line_v2=[mex_line,' -lmwdsp_halidesim -ldspcgsim '];
        else
            mex_line_v2=[mex_line,' -lmwdsp_halidesim -lmwdspcgsim '];
        end
        try
            if~obj.Debugging
                evalc(mex_line_v2);
            else
                mex_line_v2=[mex_line_v2,'-v -g '];
                eval(mex_line_v2);
            end
        catch
            if~obj.Debugging
                evalc(mex_line);
            else
                mex_line=[mex_line,'-v -g '];
                eval(mex_line);
            end
        end

    catch
        coder.internal.errorIf(~allow_to_fail||config.SKIP_AHEAD_SUBFRAME==0,'dsp:dspunfold:ErrorBuildParallel');
        return;
    end

    try

        GenerateParallelMexHelp(obj,config);
    catch
        coder.internal.errorIf(~allow_to_fail||config.SKIP_AHEAD_SUBFRAME==0,'dsp:dspunfold:ErrorBuildParallelHelp');
        return;
    end


    pass=true;


