function[gen_output]=GenerateParallelWorkers(obj,gen_input,config,for_autodetect)



    gen_output=gen_input;

    for u=1:config.Threads
        gen=sigutils.internal.emission.MatlabFunctionGenerator([obj.data.tempname,'_thread_',num2str(u)]);
        gen.addCode('coder.inline(''never'');');
        tname=[obj.data.tempname,'_',num2str(u)];
        hasFirstRun=false;

        if(~for_autodetect)&&(obj.RunFirstFrame)&&(obj.Threads>1)&&(numel(obj.data.TopFunctionInputs)~=numCoderConstant(obj))
            startIdx=config.Repetition*(u-1)+1;
            if(config.SKIP_AHEAD_SUBFRAME==0&&startIdx>config.SKIP_AHEAD+1)||(config.SKIP_AHEAD_SUBFRAME~=0&&startIdx>config.SKIP_AHEAD)
                hasFirstRun=true;
                gen.addCode('if firstRun')
                workcall=sigutils.internal.emission.MatlabFunctionGenerator(tname);
                for i=1:numel(obj.data.TopFunctionInputs)
                    if isa(obj.InputArgs{i},'coder.Constant')
                        workcall.InputArgs=[workcall.InputArgs,{sprintf('in%d',i)}];
                    else
                        workcall.InputArgs=[workcall.InputArgs,{sprintf('in%d(%d).frame',i,config.SKIP_AHEAD+1)}];
                    end
                end
                gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
                gen.addCode('end');
            end
        end

        if config.SKIP_AHEAD_SUBFRAME~=0

            gen.addCode('% Consume states (sub frame)')
            startIdx=config.Repetition*(u-1)+1;
            if startIdx<=config.SKIP_AHEAD||(hasFirstRun&&startIdx==config.SKIP_AHEAD+1)
                gen.addCode('if ~firstRun',config.SKIP_AHEAD)
            end
            workcall=sigutils.internal.emission.MatlabFunctionGenerator(tname);
            for i=1:numel(obj.data.TopFunctionInputs)
                if isa(obj.InputArgs{i},'coder.Constant')
                    workcall.InputArgs=[workcall.InputArgs,{sprintf('in%d',i)}];
                elseif(~obj.data.TopFunctionInputs{i}.VarFrame)
                    workcall.InputArgs=[workcall.InputArgs,{sprintf('in%d(%d).frame',i,startIdx)}];
                else
                    F=obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size(1);
                    arg=sprintf('in%d(%d).frame(%d:%d',i,startIdx,F-config.SKIP_AHEAD_SUBFRAME+1,F);

                    for dim=2:numel(obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size)
                        arg=sprintf('%s,:',arg);
                    end
                    arg=sprintf('%s)',arg);
                    workcall.InputArgs=[workcall.InputArgs,{arg}];
                end
            end
            gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
            if startIdx<=config.SKIP_AHEAD||(hasFirstRun&&startIdx==config.SKIP_AHEAD+1)
                gen.addCode('end');
            end
        end

        if(config.SKIP_AHEAD~=0&&config.SKIP_AHEAD_SUBFRAME==0)||(config.SKIP_AHEAD>1&&config.SKIP_AHEAD_SUBFRAME~=0)

            startIdx=config.Repetition*(u-1)+1;
            if config.SKIP_AHEAD_SUBFRAME~=0
                startIdx=startIdx+1;
            end
            endIdx=config.Repetition*(u-1)+config.SKIP_AHEAD;
            gen.addCode('% Consume states (full frames)')
            gen.addCode('for i=%d:%d',startIdx,endIdx)
            if startIdx<=config.SKIP_AHEAD
                gen.addCode('if ~firstRun || i>%d',config.SKIP_AHEAD)
            end
            workcall=sigutils.internal.emission.MatlabFunctionGenerator(tname);
            for i=1:numel(obj.data.TopFunctionInputs)
                if isa(obj.InputArgs{i},'coder.Constant')
                    workcall.InputArgs=[workcall.InputArgs,{sprintf('in%d',i)}];
                else
                    workcall.InputArgs=[workcall.InputArgs,{sprintf('in%d(i).frame',i)}];
                end
            end
            gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
            if startIdx<=config.SKIP_AHEAD
                gen.addCode('end');
            end
            gen.addCode('end')
        end



        r=1;
        gen.addCode('%% Repetition %d',r)
        workcall=sigutils.internal.emission.MatlabFunctionGenerator(tname);
        for i=1:numel(obj.data.TopFunctionOutputs)
            workcall.OutputArgs=[workcall.OutputArgs,{sprintf('ref%d',i)}];
        end
        for i=1:numel(obj.data.TopFunctionInputs)
            if isa(obj.InputArgs{i},'coder.Constant')
                workcall.InputArgs=[workcall.InputArgs,{sprintf('in%d',i)}];
            else
                workcall.InputArgs=[workcall.InputArgs,{sprintf('in%d(%d).frame',i,1+config.SKIP_AHEAD+config.Repetition*(u-1)+(r-1))}];
            end
        end
        gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
        for i=1:numel(obj.data.TopFunctionOutputs)
            gen.addCode('out%d.r = coder.nullcopy(repmat(struct(''frame'',ref%d),%d,1));',i,i,config.Repetition);
            gen.addCode('out%d.r(%d).frame = ref%d;',i,1,i);
        end


        if(config.Repetition>1)
            gen.addCode('%% Repetition(s) %d to %d',2,config.Repetition)
            gen.addCode('for repetition=2:%d',config.Repetition)
            workcall=sigutils.internal.emission.MatlabFunctionGenerator(tname);
            for i=1:numel(obj.data.TopFunctionOutputs)
                workcall.OutputArgs=[workcall.OutputArgs,{sprintf('out%d.r(repetition).frame',i)}];
            end
            for i=1:numel(obj.data.TopFunctionInputs)
                if isa(obj.InputArgs{i},'coder.Constant')
                    workcall.InputArgs=[workcall.InputArgs,{sprintf('in%d',i)}];
                else
                    workcall.InputArgs=[workcall.InputArgs,{sprintf('in%d(%d+repetition).frame',i,config.SKIP_AHEAD+config.Repetition*(u-1))}];
                end
            end
            gen.addCode('%s;',strtrim(workcall.getFcnInterface.char))
            gen.addCode('end');
        end


        for i=1:numel(obj.data.TopFunctionOutputs)
            gen.OutputArgs=[gen.OutputArgs,{['out',num2str(i)]}];
        end
        for i=1:numel(obj.data.TopFunctionInputs)
            gen.InputArgs=[gen.InputArgs,{['in',num2str(i)]}];
        end
        gen.InputArgs=[gen.InputArgs,{'firstRun'}];

        gen_output.addLocalFunction(gen);


        GenerateRenamedTop(obj,tname);
    end

end


function num=numCoderConstant(obj)
    num=0;
    for i=1:numel(obj.InputArgs)
        if isa(obj.InputArgs{i},'coder.Constant')
            num=num+1;
        end
    end
end
