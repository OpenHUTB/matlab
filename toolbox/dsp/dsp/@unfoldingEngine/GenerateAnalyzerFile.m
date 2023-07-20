function GenerateAnalyzerFile(obj,for_autodetect,config)



    try
        if~for_autodetect
            UnfoldingVerbose(obj,true,'Generate analyzer help');
            GenerateAnalyzerHelp(obj);
        end

        clear([obj.data.mname,'_analyzer']);

        if for_autodetect
            gen=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.tempname,'_analyzer']);
        else
            gen=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.mname,'_analyzer']);
        end
        gen.Path=obj.data.workdirectory;
        gen.RCSRevisionAndDate=false;
        gen.EndOfFileMarker=false;
        gen.AlignEndOfLineComments=false;
        gen.Copyright=['Copyright ',convertStringsToChars(string(year(datetime('now')))),' The MathWorks, Inc.'];
        if for_autodetect
            gen.OutputArgs={'pass'};
        else
            gen.OutputArgs={'report'};
        end
        if numel(obj.data.TopFunctionInputs)==0
            if for_autodetect
                gen.InputArgs={'input1'};
            else
                gen.InputArgs={'input1_arg'};
            end
        else
            for i=1:numel(obj.data.TopFunctionInputs)
                if for_autodetect
                    gen.InputArgs=[gen.InputArgs,{sprintf('input%d',i)}];
                else
                    gen.InputArgs=[gen.InputArgs,{sprintf('input%d_arg',i)}];
                end
            end
        end

        gen.addCode('try');
        gen.addCode('report.Latency = %d;',obj.data.Latency);
        gen.addCode('report.Speedup = [];');
        gen.addCode('report.Pass = [];');

        if~for_autodetect
            gen.addCode('if nargin==1')

            gen.addCode('if strcmpi(input1_arg,''latency'')')
            gen.addCode('return;');
            gen.addCode('end;');

            gen.addCode('if strcmp(input1_arg,''UnfoldedStateLength'')')
            gen.addCode('report = [];');
            if config.SKIP_AHEAD==0
                if config.REAL_SKIP_AHEAD==Inf
                    gen.addCode('report.StateLength = Inf;');
                else
                    gen.addCode('report.StateLength = 0;');
                end
            else
                if any(obj.data.FrameInputs)
                    if config.SKIP_AHEAD_SUBFRAME==0
                        sl=config.SKIP_AHEAD*obj.data.FRAMES_LENGTH;
                    else
                        sl=(config.SKIP_AHEAD-1)*obj.data.FRAMES_LENGTH+config.SKIP_AHEAD_SUBFRAME;
                    end
                    gen.addCode('report.StateLength = %d;',sl);
                else
                    gen.addCode('report.StateLength = %d;',config.SKIP_AHEAD);
                end
            end
            if any(obj.data.FrameInputs)
                gen.addCode('report.StateUnit = ''samples'';');
            else
                gen.addCode('report.StateUnit = ''frames'';');
            end

            gen.addCode('return;');
            gen.addCode('end;');
            gen.addCode('end')
        end

        gen.addCode('original_rng_state = rng;');
        gen.addCode('c = onCleanup(@()CleanWorkspace(original_rng_state));');
        gen.addCode('fprintf(''%%s\\n'',getString(message(''dsp:dspunfold:AnalyzingMultithreadedMexLog'',[''%s.'' mexext])));',obj.data.real_mname);

        if~for_autodetect
            if obj.AnalyzerInputDifferent
                strictCheck=false;
                if config.SKIP_AHEAD<=1&&config.Threads>1
                    strictCheck=true;
                end
                if~strictCheck
                    gen.addCode('differentInputs = [];');
                end
                inputsChecked=0;
            end
            for i=1:numel(obj.data.TopFunctionInputs)
                gen.addCode(' ');
                gen.addCode('coder.internal.errorIf(size(input%d_arg,1)<%d,''dsp:dspunfold:InputTooSmall'',num2str(%d),num2str(%d));',i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1),i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
                gen.addCode('if rem(size(input%d_arg,1),%d)~=0',i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
                gen.addCode('coder.internal.warning(''dsp:dspunfold:InputTruncate'',num2str(%d),num2str(%d),num2str(size(input%d_arg,1)-(rem(size(input%d_arg,1),%d))));',i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1),i,i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
                gen.addCode('end');
                if~obj.AnalyzerInputDifferent
                    if~isa(obj.InputArgs{i},'coder.Constant')
                        gen.addCode('if size(input%d_arg,1)<%d',i,2*obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
                        gen.addCode('coder.internal.warning(''dsp:dspunfold:InputSame'',num2str(%d));',i);
                        gen.addCode('end');
                    end
                end
                gen.addCode('input%d_idx_mt = 1;',i);
                gen.addCode('input%d_idx_st = 1;',i);
                if obj.AnalyzerInputDifferent
                    if~isa(obj.InputArgs{i},'coder.Constant')
                        if strictCheck
                            gen.addCode('differentInputs = [];');
                        end
                        gen.addCode('[input,input%d_idx_st] = GetSlice(input%d_arg,input%d_idx_st,%d);',i,i,i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
                        gen.addCode('CheckResults(input,input,1/2);',i)
                        gen.addCode('while input%d_idx_st~=1',i);
                        gen.addCode('[input_tmp,input%d_idx_st] = GetSlice(input%d_arg,input%d_idx_st,%d);',i,i,i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
                        gen.addCode('if ~CheckResults(input,input_tmp,1/2)')
                        gen.addCode('differentInputs = true;');
                        gen.addCode('end');
                        gen.addCode('end');
                        gen.addCode('input%d_idx_st = 1;',i);
                        inputsChecked=inputsChecked+1;
                        if strictCheck
                            gen.addCode('if isempty(differentInputs)');
                            gen.addCode('coder.internal.warning(''dsp:dspunfold:InputSame'',num2str(%d));',i);
                            gen.addCode('end');
                        end
                    else
                        gen.addCode('[input,~] = GetSlice(input%d_arg,input%d_idx_st,%d);',i,i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
                        gen.addCode('CheckResults(input,input,1/2);')
                    end
                end
            end
            if obj.AnalyzerInputDifferent
                if~strictCheck&&inputsChecked>0
                    gen.addCode('if isempty(differentInputs)');
                    gen.addCode('coder.internal.warning(''dsp:dspunfold:InputAllSame'');');
                    gen.addCode('end');
                end
            end
        end


        gen.addCode(' ');
        gen.addCode('% check results');
        gen.addCode('error_found=false;');
        if for_autodetect
            gen.addCode('clear %s_mt;',obj.data.tempname);
            gen.addCode('clear %s_st;',obj.data.tempname);
            if(obj.GenerateEmpty)
                gen.addCode('clear %s_empty;',obj.data.tempname);
            end
        else
            gen.addCode('clear %s;',obj.data.real_mname);
            gen.addCode('clear %s_st;',obj.data.mname);
            if(obj.GenerateEmpty)
                gen.addCode('clear %s_empty;',obj.data.mname);
            end
        end
        gen.addCode('rng(0,''twister'');');
        gen.addCode('% consume latency in sequential to trigger errors before even going to parallel');
        gen.addCode('for k = 1:%d',obj.data.Latency);
        if for_autodetect
            workcall=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.tempname,'_st']);
        else
            workcall=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.mname,'_st']);
        end
        for i=1:numel(obj.data.TopFunctionOutputs)
            workcall.OutputArgs=[workcall.OutputArgs,{sprintf('output%d_st ',i)}];
        end
        for i=1:numel(obj.data.TopFunctionInputs)
            if~for_autodetect
                gen.addCode('[input%d,input%d_idx_st] = GetSlice(input%d_arg,input%d_idx_st,%d);',i,i,i,i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
            end
            workcall.InputArgs=[workcall.InputArgs,{sprintf('input%d',i)}];
        end
        gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
        gen.addCode('end');
        if for_autodetect
            gen.addCode('clear %s_st;',obj.data.tempname);
        else
            gen.addCode('clear %s_st;',obj.data.mname);
        end
        if~for_autodetect
            for i=1:numel(obj.data.TopFunctionInputs)
                gen.addCode('input%d_idx_st = 1;',i);
            end
        end
        gen.addCode('rng(0,''twister'');');
        gen.addCode('% consume latency');
        gen.addCode('for k = 1:%d',obj.data.Latency);
        if for_autodetect
            workcall=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.tempname,'_mt']);
        else
            workcall=sigutils.internal.emission.MatlabFunctionGenerator(obj.data.real_mname);
        end
        for i=1:numel(obj.data.TopFunctionOutputs)
            workcall.OutputArgs=[workcall.OutputArgs,{sprintf('output%d_mt',i)}];
        end
        for i=1:numel(obj.data.TopFunctionInputs)
            if~for_autodetect
                gen.addCode('[input%d,input%d_idx_mt] = GetSlice(input%d_arg,input%d_idx_mt,%d);',i,i,i,i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
            end
            workcall.InputArgs=[workcall.InputArgs,{sprintf('input%d',i)}];
        end
        gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
        gen.addCode('end');
        gen.addCode('% start compare results');
        gen.addCode('% check results for 3*latency frames (feel free to modify this value for longer results checking)');
        gen.addCode('for k = 1:%d',obj.data.Latency*3);
        workcall2=workcall;
        if for_autodetect
            workcall=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.tempname,'_st']);
        else
            workcall=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.mname,'_st']);
        end
        for i=1:numel(obj.data.TopFunctionOutputs)
            workcall.OutputArgs=[workcall.OutputArgs,{sprintf('output%d_st ',i)}];
        end
        for i=1:numel(obj.data.TopFunctionInputs)
            if~for_autodetect
                gen.addCode('[input%d,input%d_idx_st] = GetSlice(input%d_arg,input%d_idx_st,%d);',i,i,i,i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
            end
            workcall.InputArgs=[workcall.InputArgs,{sprintf('input%d',i)}];
        end
        gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
        for i=1:numel(obj.data.TopFunctionInputs)
            if~for_autodetect
                gen.addCode('[input%d,input%d_idx_mt] = GetSlice(input%d_arg,input%d_idx_mt,%d);',i,i,i,i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
            end
        end
        gen.addCode('%s;',strtrim(workcall2.getFcnInterface.char))
        for i=1:numel(obj.data.TopFunctionOutputs)
            gen.addCode('if ~CheckResults(output%d_mt,output%d_st,1/2)',i,i)
            gen.addCode('error_found=true;');
            gen.addCode('break;');
            gen.addCode('end');
        end
        gen.addCode('end');

        if~for_autodetect

            gen.addCode(' ');
            gen.addCode('% profile parallel mex');
            gen.addCode('clear %s;',obj.data.real_mname);
            gen.addCode('clear %s_st;',obj.data.mname);
            if(obj.GenerateEmpty)
                gen.addCode('clear %s_empty;',obj.data.mname);
            end
            for i=1:numel(obj.data.TopFunctionInputs)
                gen.addCode('[input%d,~] = GetSlice(input%d_arg,1,%d);',i,i,obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1));
            end

            gen.addCode('rng(0,''twister'');');


            gen.addCode('for k = 1:%d',obj.data.Latency*2);
            workcall=sigutils.internal.emission.MatlabFunctionGenerator(obj.data.real_mname);
            for i=1:numel(obj.data.TopFunctionInputs)
                workcall.InputArgs=[workcall.InputArgs,{sprintf('input%d',i)}];
            end
            gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
            gen.addCode('end');
            gen.addCode('loops_mt=0;');
            gen.addCode('tic;');
            gen.addCode('% try to limit profiling to about 3 seconds (feel free to modify this time for longer profiling)');
            gen.addCode('while (toc<3)')
            gen.addCode('for k=1:%d',obj.data.Latency)
            gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
            gen.addCode('end');
            gen.addCode('loops_mt=loops_mt+1;');
            gen.addCode('end');
            gen.addCode('time_mt = toc;');


            gen.addCode(' ');
            gen.addCode('% profile sequential mex');
            gen.addCode('clear %s;',obj.data.real_mname);
            gen.addCode('clear %s_st;',obj.data.mname);
            if(obj.GenerateEmpty)
                gen.addCode('clear %s_empty;',obj.data.mname);
            end
            gen.addCode('rng(0,''twister'');');
            gen.addCode('loops_st =0;');

            workcall=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.mname,'_st']);
            for i=1:numel(obj.data.TopFunctionInputs)
                workcall.InputArgs=[workcall.InputArgs,{sprintf('input%d',i)}];
            end
            gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))

            gen.addCode('tic;');
            gen.addCode('while (loops_st <loops_mt)')
            gen.addCode('for k=1:%d',obj.data.Latency)
            gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
            gen.addCode('end');
            gen.addCode('loops_st =loops_st +1;');
            gen.addCode('end');
            gen.addCode('time_st = toc;');
            gen.addCode('speedup = time_st/time_mt;');


            if(obj.GenerateEmpty)
                gen.addCode(' ');
                gen.addCode('% profile empty mex');
                gen.addCode('clear %s;',obj.data.real_mname);
                gen.addCode('clear %s_st;',obj.data.mname);
                if(obj.GenerateEmpty)
                    gen.addCode('clear %s_empty;',obj.data.mname);
                end
                gen.addCode('rng(0,''twister'');');
                gen.addCode('loops_st =0;');
                gen.addCode('tic;');
                gen.addCode('while (loops_st <loops_mt)')
                gen.addCode('for k=1:%d',obj.data.Latency)
                workcall=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.mname,'_empty']);
                for i=1:numel(obj.data.TopFunctionInputs)
                    workcall.InputArgs=[workcall.InputArgs,{sprintf('input%d',i)}];
                end
                gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
                gen.addCode('end');
                gen.addCode('loops_st =loops_st +1;');
                gen.addCode('end');
                gen.addCode('time_empty = toc;');
                gen.addCode('speedup_no_overheads = (time_st-time_empty)/(time_mt-time_empty);');
            end
        end


        gen.addCode(' ');
        gen.addCode('% display statistics');
        if for_autodetect
            gen.addCode('if ~error_found');
            gen.addCode('pass=true;');
            gen.addCode('else');
            gen.addCode('pass=false;');
            gen.addCode('end');
            gen.addCode('clear %s_mt;',obj.data.tempname);
            gen.addCode('clear %s_st;',obj.data.tempname);
            if(obj.GenerateEmpty)
                gen.addCode('clear %s_empty;',obj.data.tempname);
            end
        else
            gen.addCode('fprintf(''%%s\\n'',getString(message(''dsp:dspunfold:AnalyzingLatencyLog'',''%d'')));',obj.data.Latency);
            gen.addCode('report.Speedup = speedup;');
            gen.addCode('fprintf(''%s\n'',getString(message(''dsp:dspunfold:AnalyzingSpeedupLog'',sprintf(''%.1fx'',speedup))));');
            if(obj.GenerateEmpty)
                gen.addCode('fprintf(''Speedup without matlab&mex overheads = %.1fx\n'',speedup_no_overheads);');
            end
            gen.addCode('report.Pass = true;');
            gen.addCode('if error_found');
            gen.addCode('report.Pass = false;');
            gen.addCode('coder.internal.warning(''dsp:dspunfold:WrongNumerics'',[''%s.'' mexext],[''%s_st.'' mexext],[''%s.'' mexext])',obj.data.real_mname,obj.data.mname,obj.data.real_mname);
            gen.addCode('end');
            gen.addCode('clear %s;',obj.data.real_mname);
            gen.addCode('clear %s_st;',obj.data.mname);
            if(obj.GenerateEmpty)
                gen.addCode('clear %s_empty;',obj.data.mname);
            end
        end

        gen.addCode('catch err');
        if for_autodetect
            gen.addCode('clear %s_mt;',obj.data.tempname);
            gen.addCode('clear %s_st;',obj.data.tempname);
            if(obj.GenerateEmpty)
                gen.addCode('clear %s_empty;',obj.data.tempname);
            end
        else
            gen.addCode('clear %s;',obj.data.real_mname);
            gen.addCode('clear %s_st;',obj.data.mname);
            if(obj.GenerateEmpty)
                gen.addCode('clear %s_empty;',obj.data.mname);
            end
        end
        gen.addCode('error(err.identifier,err.message);');
        gen.addCode('end');
        gen.addCode(' ');





        if~for_autodetect
            gen_sub=sigutils.internal.emission.MatlabFunctionGenerator('GetSlice');
            gen_sub.InputArgs={'input_arg','idx','framesize'};
            gen_sub.OutputArgs={'slice','newidx'};
            gen_sub.addCode('dimensions = size(input_arg);');
            gen_sub.addCode('dimensions(1) = framesize;');
            gen_sub.addCode('slice = reshape(input_arg(idx:idx+framesize-1,:),dimensions);');
            gen_sub.addCode('newidx = idx+framesize;');
            gen_sub.addCode('if newidx+framesize-1 > size(input_arg,1)-(rem(size(input_arg,1),framesize))')
            gen_sub.addCode('newidx=1;');
            gen_sub.addCode('end');
            gen.addLocalFunction(gen_sub);
        end


        gen_sub=sigutils.internal.emission.MatlabFunctionGenerator('CleanWorkspace');
        gen_sub.InputArgs={'original_rng_state'};
        gen_sub.addCode('clear %s;',obj.data.real_mname);
        gen_sub.addCode('clear %s_st;',obj.data.mname);
        if(obj.GenerateEmpty)
            gen_sub.addCode('clear %s_empty;',obj.data.mname);
        end
        gen_sub.addCode('rng(original_rng_state);');
        gen.addLocalFunction(gen_sub);


        gen_sub=sigutils.internal.emission.MatlabFunctionGenerator('CheckResults');
        gen_sub.InputArgs={'val1','val2','tolerance'};
        gen_sub.OutputArgs={'equal'};
        gen_sub.addCode('equal=recursiveCheck(val1,val2,tolerance);');
        gen_sub.addCode('equal=equal & recursiveCheck(val2,val1,tolerance);');
        gen.addLocalFunction(gen_sub);


        gen_sub=sigutils.internal.emission.MatlabFunctionGenerator('recursiveCheck');
        gen_sub.InputArgs={'in1','in2','tolerance'};
        gen_sub.OutputArgs={'equal'};
        gen_sub.addCode('equal=true;');
        gen_sub.addCode('if isnumeric(in1) || islogical(in1) || ischar(in1)');
        gen_sub.addCode('if ~isequal(size(in1),size(in2))');
        gen_sub.addCode('equal=false;');
        gen_sub.addCode('elseif isreal(in1)');
        gen_sub.addCode('if ~isreal(in2)');
        gen_sub.addCode('equal=false;');
        gen_sub.addCode('else');
        gen_sub.addCode('if isfloat(in1)');
        gen_sub.addCode('equal=(norm(in1-in2,inf)<=(eps(class(in1))^tolerance));');
        gen_sub.addCode('else');
        gen_sub.addCode('equal = isequal(in1,in2);');
        gen_sub.addCode('end');
        gen_sub.addCode('end');
        gen_sub.addCode('else');
        gen_sub.addCode('if isreal(in2)');
        gen_sub.addCode('equal=false;');
        gen_sub.addCode('else');
        gen_sub.addCode('if isfloat(in1)');
        gen_sub.addCode('equal=(norm(real(in1)-real(in2),inf)<=(eps(class(in1))^tolerance));');
        gen_sub.addCode('equal=equal & (norm(imag(in1)-imag(in2),inf)<=(eps(class(in1))^tolerance));');
        gen_sub.addCode('else');
        gen_sub.addCode('equal = isequal(in1,in2);');
        gen_sub.addCode('end');
        gen_sub.addCode('end');
        gen_sub.addCode('end');
        gen_sub.addCode('elseif iscell(in1)');
        gen_sub.addCode('if ~iscell(in2)');
        gen_sub.addCode('equal = false;');
        gen_sub.addCode('elseif ~isequal(numel(in1),numel(in2))');
        gen_sub.addCode('equal = false;');
        gen_sub.addCode('else');
        gen_sub.addCode('for i=1:numel(in1)');
        gen_sub.addCode('equal=equal & recursiveCheck(in1{i},in2{i},tolerance);');
        gen_sub.addCode('end');
        gen_sub.addCode('end');
        gen_sub.addCode('else');
        gen_sub.addCode('in1_fields=fieldnames(in1);');
        gen_sub.addCode('in2_fields=fieldnames(in2);');
        gen_sub.addCode('if ~isequal(in1_fields,in2_fields)');
        gen_sub.addCode('equal=false;');
        gen_sub.addCode('else');
        gen_sub.addCode('for i=1:numel(in1_fields)');
        gen_sub.addCode('equal=equal & recursiveCheck(in1.(in1_fields{i}),in2.(in2_fields{i}),tolerance);');
        gen_sub.addCode('end');
        gen_sub.addCode('end');
        gen_sub.addCode('end');

        gen.addLocalFunction(gen_sub);

        gen.writeFile;
        if~for_autodetect
            if~obj.Debugging
                pcode(fullfile(obj.data.workdirectory,[obj.data.mname,'_analyzer.m']),'-INPLACE');
                movefile(fullfile(obj.data.workdirectory,[obj.data.mname,'_analyzer.p']),fullfile(obj.data.workdirectory,[obj.data.tempname,'_analyzer.p']),'f');
            else
                movefile(fullfile(obj.data.workdirectory,[obj.data.mname,'_analyzer.m']),fullfile(obj.data.workdirectory,[obj.data.tempname,'_analyzer.m']),'f');
            end
        end

    catch err %#ok<NASGU>
        coder.internal.error('dsp:dspunfold:ErrorBuildAnalyzer');
    end

end

