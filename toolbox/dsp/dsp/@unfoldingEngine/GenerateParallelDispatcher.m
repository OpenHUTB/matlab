function GenerateParallelDispatcher(obj,config,for_autodetect)




    gen=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.tempname,'_par']);
    gen.Path=obj.data.workdirectory;
    gen.RCSRevisionAndDate=false;
    gen.EndOfFileMarker=false;
    copyrightStr=['Copyright ',convertStringsToChars(string(year(datetime('now')))),' The MathWorks, Inc.'];
    gen.Copyright=copyrightStr;

    gen=GenerateParallelWorkers(obj,gen,config,for_autodetect);

    gen.RCSRevisionAndDate=false;
    gen.EndOfFileMarker=false;
    gen.Copyright=copyrightStr;
    for i=1:numel(obj.data.TopFunctionOutputs)
        gen.OutputArgs=[gen.OutputArgs,{obj.data.TopFunctionOutputs{i}.VarName}];
    end
    for i=1:numel(obj.data.TopFunctionInputs)
        gen.InputArgs=[gen.InputArgs,{obj.data.TopFunctionInputs{i}.VarName}];
    end


    if obj.Threads>1
        gen.addPersistentVariables('firstRun');
        gen.addPersistentInitCode('firstRun=true;');
    end


    if config.Threads>1
        if~ismac
            gen.addCode('coder.ceval(''omp_set_dynamic(true);//'');')
            gen.addCode('coder.ceval(''#pragma omp parallel num_threads(%d)//'');',config.Threads)
            gen.addCode('coder.ceval(''{//'');')
            gen.addCode('coder.ceval(''#pragma omp sections nowait//'');')
            gen.addCode('coder.ceval(''{//'');')
        else
            gen.addCode('coder.ceval(''{//'');')
            gen.addCode('coder.ceval(''dispatch_queue_t %s_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); //'');',obj.data.tempname)
            gen.addCode('coder.ceval(''dispatch_group_t %s_group = dispatch_group_create(); //'');',obj.data.tempname)
        end
    end
    for u=1:config.Threads
        if config.Threads>1
            gen.addCode('%%%% Thread %d',u);
            if~ismac
                gen.addCode('coder.ceval(''#pragma omp section//'');');
                gen.addCode('coder.ceval(''{//'');');
            else
                gen.addCode('coder.ceval(''dispatch_group_async(%s_group, %s_queue, ^{ //'');',obj.data.tempname,obj.data.tempname);
            end
            gen.addCode('coder.ceval(''#define SD (&SD[%d])  //'');',u-1);
        end
        workcall=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.tempname,'_thread_',num2str(u)]);
        for i=1:numel(obj.data.TopFunctionOutputs)
            workcall.OutputArgs=[workcall.OutputArgs,{sprintf('%s.u%d',obj.data.TopFunctionOutputs{i}.VarName,u)}];
        end
        for i=1:numel(obj.data.TopFunctionInputs)
            if isa(obj.InputArgs{i},'coder.Constant')
                workcall.InputArgs=[workcall.InputArgs,{sprintf('%s',obj.data.TopFunctionInputs{i}.VarName)}];
            else
                workcall.InputArgs=[workcall.InputArgs,{sprintf('%s.buffer',obj.data.TopFunctionInputs{i}.VarName)}];
            end
        end
        if obj.Threads>1
            workcall.InputArgs=[workcall.InputArgs,{'firstRun'}];
        end
        gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
        if config.Threads>1
            gen.addCode('coder.ceval(''#undef SD //'');');
            if~ismac
                gen.addCode('coder.ceval(''} //'');');
            else
                gen.addCode('coder.ceval(''}); //'');');
            end
        end
    end
    if config.Threads>1
        if~ismac
            gen.addCode('coder.ceval(''}//'');')
            gen.addCode('coder.ceval(''}//'');')
        else
            gen.addCode('coder.ceval(''dispatch_group_wait(%s_group, DISPATCH_TIME_FOREVER); //'');',obj.data.tempname)
            gen.addCode('coder.ceval(''dispatch_release(%s_group); //'');',obj.data.tempname)
            gen.addCode('coder.ceval(''}//'');')
        end
    end
    if obj.Threads>1
        gen.addCode('firstRun = false;');
    end


    if config.Threads>1
        if~ismac
            gen.addCode('coder.cinclude(''<omp.h>'');');
            if ispc
                gen.addCode('coder.updateBuildInfo(''addCompileFlags'',''/openmp'');');
            else
                gen.addCode('coder.updateBuildInfo(''addCompileFlags'',''-fopenmp'');');
            end
        else
            gen.addCode('coder.cinclude(''<dispatch/dispatch.h>'');');
        end
    end
    for i=1:numel(obj.data.TopFunctionOutputs)
        gen.addCode('coder.cstructname(%s,''%s_struct'')',obj.data.TopFunctionOutputs{i}.VarName,obj.data.TopFunctionOutputs{i}.VarName);
    end

    gen.writeFile;

end

