function GenerateParallelMexFile(obj,config)



    pStr=StringWriter();

    data=obj.data;


    pStrFile=StringWriter();
    filename=fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'parallel'],[obj.data.tempname,'_par.h']);
    readfile(pStrFile,filename);

    hfile=cellstr(pStrFile);
    startln=find(contains(hfile,[' ',obj.data.tempname,'_par(']));
    endline=find(contains(hfile(startln:end),';'));


    coder.internal.errorIf(isempty(startln)||isempty(endline),'dsp:dspunfold:InternalError');

    startln=startln(1);
    endline=endline(1);
    declaration=[hfile{startln:startln+endline-1}];
    declaration=strrep(declaration,'extern ','');
    declaration=strrep(declaration,';','');
    hasSD=false;
    indx=strfind(declaration,[obj.data.tempname,'_par(']);
    indx_start=indx+length([obj.data.tempname,'_par(']);
    if contains(declaration(indx_start:end),'*SD')
        hasSD=true;
    end


    if hasSD
        persistentVarType=[obj.data.tempname,'_parPersistentData'];
        pStrFile=StringWriter();
        filename=fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'parallel'],[obj.data.tempname,'_par_types.h']);
        readfile(pStrFile,filename);
        hfile=cellstr(pStrFile);
        startln=find(contains(hfile,persistentVarType),1);
        hasPD=~isempty(startln);
    end


    pStrFile=StringWriter();
    filename=fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original'],[obj.data.fname,'.h']);
    readfile(pStrFile,filename);
    hfile=cellstr(pStrFile);
    startln=find(contains(hfile,[' ',obj.data.fname,'(']));
    endline=find(contains(hfile(startln:end),';'));


    coder.internal.errorIf(isempty(startln)||isempty(endline),'dsp:dspunfold:InternalError');

    startln=startln(1);
    endline=endline(1);
    declaration=[hfile{startln:startln+endline-1}];
    declaration=strrep(declaration,'extern ','');
    declaration=strrep(declaration,';','');

    for i=1:numel(data.TopFunctionInputs)
        data.TopFunctionInputs{i}.VarType.Interface.Class='';
        data.TopFunctionInputs{i}.VarType.Interface.Pointer=false;
        data.TopFunctionInputs{i}.VarType.Interface.Name='';
    end
    for i=1:numel(data.TopFunctionOutputs)
        data.TopFunctionOutputs{i}.VarType.Interface.Class='';
        data.TopFunctionOutputs{i}.VarType.Interface.Pointer=false;
        data.TopFunctionOutputs{i}.VarType.Interface.Name='';
    end



    indx=strfind(declaration,[obj.data.fname,'(']);
    coder.internal.errorIf(isempty(indx),'dsp:dspunfold:InternalError');
    output_index=1;
    if(~contains(declaration(1:indx-1),'void'))
        data.TopFunctionOutputs{1}.VarType.Interface.Class=strtrim(strrep(strrep(strrep(declaration(1:indx-1),'*',''),'static',''),'inline',''));
        if(contains(declaration(1:indx-1),'*'))

            data.TopFunctionOutputs{1}.VarType.Interface.Pointer=true;
        end
        output_index=2;
    end


    indx_start=indx+length([obj.data.fname,'(']);
    topHasSD=false;
    stackIdx=strfind(declaration(indx_start:end),'*SD');
    if~isempty(stackIdx)
        topHasSD=true;
        indx_start=indx_start+stackIdx+2;
        indx=strfind(declaration(indx_start:end),',');
        if isempty(indx)
            indx=strfind(declaration(indx_start:end),')');
            coder.internal.errorIf(isempty(indx),'dsp:dspunfold:InternalError');
        end
        indx_start=indx_start+min(indx);
    end

    for i=1:numel(data.TopFunctionInputs)
        if isa(obj.InputArgs{i},'coder.Constant')
            continue;
        end
        indx_comma=strfind(declaration(indx_start:end),',');
        indx_par=strfind(declaration(indx_start:end),')');
        coder.internal.errorIf(isempty(indx_comma)&&isempty(indx_par),'dsp:dspunfold:InternalError');
        if isempty(indx_comma)
            indx_end=min(indx_par);
        else
            indx_end=min(min(indx_comma),min(indx_par));
        end

        current_arg=strtrim(declaration(indx_start:indx_start+indx_end-2));


        indx_bracket=strfind(current_arg,'[');
        indx_star=strfind(current_arg,'*');
        if~isempty(indx_bracket)||~isempty(indx_star)%#ok
            data.TopFunctionInputs{i}.VarType.Interface.Pointer=true;
            if~isempty(indx_bracket)
                indx_bracket=min(indx_bracket);
                current_arg=strtrim(current_arg(1:indx_bracket-1));
            end
            current_arg=strtrim(strrep(current_arg,'*',''));
        end


        spaceidx=strfind(current_arg,' ');
        idx=spaceidx(end);
        data.TopFunctionInputs{i}.VarType.Interface.Class=strtrim(current_arg(1:idx));


        data.TopFunctionInputs{i}.VarType.Interface.Name=strtrim(current_arg(idx:end));

        indx_start=indx_start+indx_end;
    end


    for i=output_index:numel(data.TopFunctionOutputs)
        indx_comma=strfind(declaration(indx_start:end),',');
        indx_par=strfind(declaration(indx_start:end),')');
        coder.internal.errorIf(isempty(indx_comma)&&isempty(indx_par),'dsp:dspunfold:InternalError');
        if isempty(indx_comma)
            indx_end=min(indx_par);
        else
            indx_end=min(min(indx_comma),min(indx_par));
        end

        current_arg=strtrim(declaration(indx_start:indx_start+indx_end-2));


        indx_bracket=strfind(current_arg,'[');
        indx_star=strfind(current_arg,'*');
        if~isempty(indx_bracket)||~isempty(indx_star)%#ok
            data.TopFunctionOutputs{i}.VarType.Interface.Pointer=true;
            if~isempty(indx_bracket)
                indx_bracket=min(indx_bracket);
                current_arg=strtrim(current_arg(1:indx_bracket-1));
            end
            current_arg=strtrim(strrep(current_arg,'*',''));
        end


        spaceidx=strfind(current_arg,' ');
        idx=spaceidx(end);
        data.TopFunctionOutputs{i}.VarType.Interface.Class=strtrim(current_arg(1:idx));


        data.TopFunctionOutputs{i}.VarType.Interface.Name=strtrim(current_arg(idx:end));

        indx_start=indx_start+indx_end;
    end



    pStr.addcr('#include "mex.h"');
    pStr.addcr('#include <stdio.h>')
    pStr.addcr('#include "%s_par.h"',obj.data.tempname)
    pStr.addcr('#include "%s_par_initialize.h"',obj.data.tempname)
    pStr.addcr('#include "%s_support_apis.h"',obj.data.tempname)
    if topHasSD
        pStr.addcr('#include "%s.h"',obj.data.fname)
    end


    pStr.addcr();
    pStr.addcr('/*Global variables*/');
    if(config.Threads>1)&&hasSD
        pStr.addcr('static %s_parStackData *SDLocal = NULL;',obj.data.tempname);
    end
    pStr.addcr('static volatile bool write_buffer = false;');
    pStr.addcr('static volatile bool process_buffer = false;')
    pStr.addcr('static volatile int IO_frame_index = 0;')
    for i=1:numel(data.TopFunctionInputs)
        if isa(obj.InputArgs{i},'coder.Constant')
            continue;
        end
        pStr.addcr('static volatile int channels_%s = 0;',data.TopFunctionInputs{i}.VarName);
        pStr.addcr('static %s_struct *%s_buff = NULL;',data.TopFunctionInputs{i}.VarName,data.TopFunctionInputs{i}.VarName);
        pStr.addcr('static %s *%s_ptr = NULL;',data.TopFunctionInputs{i}.VarType.Interface.Class,data.TopFunctionInputs{i}.VarName);
    end
    for i=1:numel(data.TopFunctionOutputs)
        pStr.addcr('static volatile int channels_%s = 0;',data.TopFunctionOutputs{i}.VarName);
        if obj.NonBlockingOutput
            pStr.addcr('static %s_struct *%s_buff = NULL;',data.TopFunctionOutputs{i}.VarName,data.TopFunctionOutputs{i}.VarName);
        else
            pStr.addcr('static %s_struct *%s_buff = NULL;',data.TopFunctionOutputs{i}.VarName,data.TopFunctionOutputs{i}.VarName);
            pStr.addcr('static char *%s_temp = NULL;',data.TopFunctionOutputs{i}.VarName);
        end
    end


    pStr.addcr();
    pStr.addcr('#define SAFE_FREE(a) if (a) {free(a);a=NULL;}');
    pStr.addcr('int free_memory(void)',obj.data.fname);
    pStr.addcr('{');
    for i=1:numel(data.TopFunctionInputs)
        if isa(obj.InputArgs{i},'coder.Constant')
            continue;
        end
        pStr.addcr('SAFE_FREE(%s_buff);',data.TopFunctionInputs{i}.VarName);
    end
    for i=1:numel(data.TopFunctionOutputs)
        pStr.addcr('SAFE_FREE(%s_buff);',data.TopFunctionOutputs{i}.VarName);
        if~obj.NonBlockingOutput
            pStr.addcr('SAFE_FREE(%s_temp);',data.TopFunctionOutputs{i}.VarName);
        end
    end
    if(config.Threads>1)&&hasSD
        if hasPD
            pStr.addcr('if (SDLocal)');
            pStr.addcr('SAFE_FREE(SDLocal[0].pd);');
        end
        pStr.addcr('SAFE_FREE(SDLocal);');
    end
    pStr.addcr('}');
    pStr.addcr();
    pStr.addcr('/*Close Mex*/');
    pStr.addcr('void %s_xil_terminate(void)',obj.data.fname);
    pStr.addcr('{');
    pStr.addcr('__SHUTDOWN__();');
    pStr.addcr('__CLOSE_THREADS__();');
    pStr.addcr();
    pStr.addcr('free_memory();');
    pStr.addcr();
    pStr.addcr('}');

    pStr.addcr('void %s_xil_shutdown(void)',obj.data.fname);
    pStr.addcr('{');
    pStr.addcr('}');


    pStr.addcr('/*Worker thread*/');
    pStr.addcr('__WORKER_THREAD_DECL__');
    pStr.addcr('{');
    pStr.addcr('while (1) {');
    pStr.addcr('__WORKER_TOP__();');
    pStr.addcr('__CHECK_SHUTDOWN__();');
    pStr.addcr('__WORKER_TOP__();');
    pStr.addcr();
    pStr.add([obj.data.tempname,'_par(']);
    if(config.Threads>1)&&hasSD
        pStr.add('SDLocal');
        if(numel(data.TopFunctionOutputs)>0)||(numel(data.TopFunctionInputs)>numCoderConstant(obj))
            pStr.add(',');
        end
    end
    for i=1:numel(data.TopFunctionInputs)
        if isa(obj.InputArgs{i},'coder.Constant')
            continue;
        end
        if i>1
            pStr.add(',');
        end
        pStr.add('&%s_buff[!write_buffer]',data.TopFunctionInputs{i}.VarName);
    end
    for i=1:numel(data.TopFunctionOutputs)
        if(i==1)&&(numel(data.TopFunctionInputs)>numCoderConstant(obj))
            pStr.add(',')
        end
        if obj.NonBlockingOutput
            pStr.add('&%s_buff[!write_buffer]',data.TopFunctionOutputs{i}.VarName);
        else
            pStr.add('&%s_buff[0]',data.TopFunctionOutputs{i}.VarName);
        end
        if i<numel(data.TopFunctionOutputs)
            pStr.add(',');
        end
    end
    pStr.addcr(');');

    pStr.addcr();
    pStr.addcr('__WORKER_TOP__();');
    pStr.addcr('__CHECK_SHUTDOWN__();');
    pStr.addcr('__WORKER_TOP__();');
    pStr.addcr('}');
    pStr.addcr('__THREAD_MARK_EXIT__;');
    pStr.addcr('}');

    if numCoderConstant(obj)~=numel(data.TopFunctionInputs)

        pStr.addcr();
        pStr.addcr('/*Input thread*/');
        pStr.addcr('__INPUT_THREAD_DECL__');
        pStr.addcr('{');

        pStr.addcr('while (1) {');
        pStr.addcr('__INPUT_TOP__();');
        pStr.addcr('__CHECK_SHUTDOWN__();');
        pStr.addcr('__INPUT_TOP__();');
        pStr.addcr();

        for i=1:numel(data.TopFunctionInputs)
            if isa(obj.InputArgs{i},'coder.Constant')
                continue;
            end
            pStr.addcr();
            [N,F,C,StateLength]=getInputInfo(data.TopFunctionInputs{i},config);
            pStr.addcr('/*Copy input %s into the internal buffer*/',N);
            pStr.addcr('fast_copy((void*)%s_ptr,(void*)%s%s_buff[write_buffer].buffer[IO_frame_index+%d].frame, sizeof(%s_buff[0].buffer[0].frame));',N,isPointer(F,C),N,StateLength,N);
        end

        pStr.addcr();
        pStr.addcr('if (process_buffer) {')
        for i=1:numel(data.TopFunctionInputs)
            if isa(obj.InputArgs{i},'coder.Constant')
                continue;
            end
            pStr.addcr();
            [N,F,C,StateLength]=getInputInfo(data.TopFunctionInputs{i},config);

            pStr.addcr('/*Prepare the "history" for input %s by updating the beginning of the next input ping pong buffer*/',N);
            if config.SKIP_AHEAD>1

                pStr.addcr('/*Not all the states needed are inside the current frame, so we copy from the tail of the other ping pong buffer, and concatenate to it the current frame*/');
                for y=2:StateLength
                    pStr.addcr('fast_copy((void*)%s%s_buff[write_buffer].buffer[%d].frame,(void*)%s%s_buff[!write_buffer].buffer[%d].frame,sizeof(%s_buff[0].buffer[0].frame));',isPointer(F,C),N,config.Threads*config.Repetition+y-2,isPointer(F,C),N,y-2,N);
                end
                pStr.addcr('fast_copy((void*)%s_ptr,(void*)%s%s_buff[!write_buffer].buffer[%d].frame,sizeof(%s_buff[0].buffer[0].frame));',N,isPointer(F,C),N,StateLength-1,N);
            else

                pStr.addcr('/*All the states needed are inside the current frame, so we copy only a part (or all) of it into the next ping pong buffer*/');
                pStr.addcr('fast_copy((void*)%s_ptr,(void*)%s%s_buff[!write_buffer].buffer[0].frame,sizeof(%s_buff[0].buffer[0].frame));',N,isPointer(F,C),N,N);
            end
        end
        pStr.addcr('}');
        pStr.addcr();
        pStr.addcr('__INPUT_TOP__();');
        pStr.addcr('__CHECK_SHUTDOWN__();');
        pStr.addcr('__INPUT_TOP__();');
        pStr.addcr('}');
        pStr.addcr('__THREAD_MARK_EXIT__;')
        pStr.addcr('}');
    end


    pStr.addcr();
    pStr.addcr('%s',declaration);
    pStr.addcr('{');


    pStr.addcr('static bool mex_initialized=false;');
    pStr.addcr('static bool worker_started=false;');
    if(output_index==2)
        if data.TopFunctionOutputs{1}.VarType.Interface.Pointer
            pStr.addcr('%s *%s;',data.TopFunctionOutputs{1}.VarType.Interface.Class,data.TopFunctionOutputs{1}.VarName);
        else
            pStr.addcr('%s %s;',data.TopFunctionOutputs{1}.VarType.Interface.Class,data.TopFunctionOutputs{1}.VarName);
        end
        pStr.addcr('%s *%s_ptr = &%s;',data.TopFunctionOutputs{1}.VarType.Interface.Class,data.TopFunctionOutputs{1}.VarName,data.TopFunctionOutputs{1}.VarName);
    end

    if numel(data.TopFunctionOutputs)
        pStr.addcr('int U = IO_frame_index/%d;',config.Repetition);
        pStr.addcr('int R = IO_frame_index-(U*%d);',config.Repetition);
    end

    for i=output_index:numel(data.TopFunctionOutputs)
        if data.TopFunctionOutputs{i}.VarType.Interface.Pointer
            pStr.addcr('%s *%s_ptr = %s;',data.TopFunctionOutputs{i}.VarType.Interface.Class,data.TopFunctionOutputs{i}.VarName,data.TopFunctionOutputs{i}.VarType.Interface.Name);
        else
            pStr.addcr('%s *%s_ptr = &%s;',data.TopFunctionOutputs{i}.VarType.Interface.Class,data.TopFunctionOutputs{i}.VarName,data.TopFunctionOutputs{i}.VarType.Interface.Name);
        end
    end
    for i=1:numel(data.TopFunctionInputs)
        if isa(obj.InputArgs{i},'coder.Constant')
            continue;
        end
        if data.TopFunctionInputs{i}.VarType.Interface.Pointer
            pStr.addcr('%s_ptr = %s;',data.TopFunctionInputs{i}.VarName,data.TopFunctionInputs{i}.VarType.Interface.Name);
        else
            pStr.addcr('%s_ptr = &%s;',data.TopFunctionInputs{i}.VarName,data.TopFunctionInputs{i}.VarType.Interface.Name);
        end
    end


    pStr.addcr();
    pStr.addcr('/*Construct everything needed by unfolding*/');
    pStr.addcr('if (!mex_initialized) {');
    pStr.addcr('shutdown_requested=false;');
    for i=1:numel(data.TopFunctionInputs)
        if isa(obj.InputArgs{i},'coder.Constant')
            continue;
        end
        pStr.addcr();
        pStr.addcr('%s_buff = (void*)calloc(2*sizeof(%s_struct),1);',data.TopFunctionInputs{i}.VarName,data.TopFunctionInputs{i}.VarName);
        pStr.addcr('if (!%s_buff) {free_memory(); mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotAllocateMemory","%s");}',data.TopFunctionInputs{i}.VarName,getString(message('dsp:dspunfold:ErrorCannotAllocateMemory',[obj.data.real_mname,obj.data.mext])));
    end

    for i=1:numel(data.TopFunctionOutputs)
        pStr.addcr();
        if~obj.NonBlockingOutput
            pStr.addcr('%s_buff = (void*)calloc(sizeof(%s_struct),1);',data.TopFunctionOutputs{i}.VarName,data.TopFunctionOutputs{i}.VarName);
            pStr.addcr('if (!%s_buff) {free_memory(); mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotAllocateMemory","%s");}',data.TopFunctionOutputs{i}.VarName,getString(message('dsp:dspunfold:ErrorCannotAllocateMemory',[obj.data.real_mname,obj.data.mext])));
            pStr.addcr('%s_temp = (void*)calloc(sizeof(%s_buff[0].u1.r%s.frame),1);',data.TopFunctionOutputs{i}.VarName,data.TopFunctionOutputs{i}.VarName,repIndex(config.Repetition));
            pStr.addcr('if (!%s_temp) {free_memory(); mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotAllocateMemory","%s");}',data.TopFunctionOutputs{i}.VarName,getString(message('dsp:dspunfold:ErrorCannotAllocateMemory',[obj.data.real_mname,obj.data.mext])));
        else
            pStr.addcr('%s_buff = (void*)calloc(2*sizeof(%s_struct),1);',data.TopFunctionOutputs{i}.VarName,data.TopFunctionOutputs{i}.VarName);
            pStr.addcr('if (!%s_buff) {free_memory(); mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotAllocateMemory","%s");}',data.TopFunctionOutputs{i}.VarName,getString(message('dsp:dspunfold:ErrorCannotAllocateMemory',[obj.data.real_mname,obj.data.mext])));
        end
    end

    if(config.Threads>1)&&hasSD

        pStr.addcr();
        pStr.addcr('{');
        if hasPD
            pStr.addcr('int cnt;');
        end
        pStr.addcr('SDLocal = (void*)malloc(sizeof(%s_parStackData)*%d);',obj.data.tempname,config.Threads);
        pStr.addcr('if (!SDLocal) {free_memory(); mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotAllocateMemory","%s");}',getString(message('dsp:dspunfold:ErrorCannotAllocateMemory',[obj.data.real_mname,obj.data.mext])));
        if hasPD
            pStr.addcr('SDLocal[0].pd = (void*)calloc(sizeof(%s),1);',persistentVarType);
            pStr.addcr('if (!SDLocal[0].pd) {free_memory(); mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotAllocateMemory","%s");}',getString(message('dsp:dspunfold:ErrorCannotAllocateMemory',[obj.data.real_mname,obj.data.mext])));
        end
        if hasPD
            pStr.addcr([obj.data.tempname,'_par_initialize(&SDLocal[0]);']);
            pStr.addcr('for (cnt=1;cnt<%d;cnt++) SDLocal[cnt].pd = SDLocal[0].pd;',config.Threads)
        else
            pStr.addcr([obj.data.tempname,'_par_initialize();']);
        end
        pStr.addcr('}');
    else
        pStr.addcr([obj.data.tempname,'_par_initialize();']);
    end
    pStr.addcr();
    pStr.addcr('__CREATE_THREADS__();');
    pStr.addcr();
    pStr.addcr('mex_initialized=true;');
    pStr.addcr('}');

    pStr.addcr();
    pStr.addcr('if (!process_buffer) {');
    if numCoderConstant(obj)~=numel(data.TopFunctionInputs)
        pStr.addcr('/*Start input*/');
        pStr.addcr('__TOP_INPUT__();');
        pStr.addcr('__TOP_INPUT__();');
    end


    if(~obj.NonBlockingOutput)
        pStr.addcr('/*Wait worker finished*/');
        pStr.addcr('if (IO_frame_index==0)&&(worker_started) {');
        pStr.addcr('__TOP_WORKER__();');
        pStr.addcr('__TOP_WORKER__();');
        pStr.addcr('}');
    end


    for i=1:numel(data.TopFunctionOutputs)
        pStr.addcr();
        [N,F,C]=getOutputInfo(obj,data.TopFunctionOutputs{i});
        pStr.addcr('/*copy to the output*/');
        if(obj.NonBlockingOutput)
            pStr.addcr('switch (U) {');
            for cs=1:config.Threads
                pStr.addcr('case %d : ',cs-1);
                if F*C==1
                    if config.Repetition>1
                        pStr.addcr('fast_copy((void*)&%s_buff[write_buffer].u%d.r[R].frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                    else
                        pStr.addcr('fast_copy((void*)&%s_buff[write_buffer].u%d.r.frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                    end
                else
                    if config.Repetition>1
                        pStr.addcr('fast_copy((void*)%s_buff[write_buffer].u%d.r[R].frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                    else
                        pStr.addcr('fast_copy((void*)%s_buff[write_buffer].u%d.r.frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                    end
                end
                pStr.addcr('break;');
            end
            pStr.addcr('}');
        else
            pStr.addcr('switch (U) {');
            for cs=1:config.Threads
                pStr.addcr('case %d : ',cs-1);
                if F*C==1
                    if config.Repetition>1
                        pStr.addcr('fast_copy((void*)&%s_buff[0].u%d.r[R].frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                        pStr.addcr('if (IO_frame_index==0)')
                        pStr.addcr('fast_copy((void*)&%s_buff[0].u%d.r[%d].frame,(void*)%s_temp,sizeof(%s_buff[0].u1.r%s.frame));',N,config.Threads,config.Repetition-1,N,N,repIndex(config.Repetition));
                    else
                        pStr.addcr('fast_copy((void*)&%s_buff[0].u%d.r.frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                        pStr.addcr('if (IO_frame_index==0)')
                        pStr.addcr('fast_copy((void*)&%s_buff[0].u%d.r.frame,(void*)%s_temp,sizeof(%s_buff[0].u1.r%s.frame));',N,config.Threads,N,N,repIndex(config.Repetition));
                    end
                else
                    if config.Repetition>1
                        pStr.addcr('fast_copy((void*)%s_buff[0].u%d.r[R].frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                        pStr.addcr('if (IO_frame_index==0)')
                        pStr.addcr('fast_copy((void*)%s_buff[0].u%d.r[%d].frame,(void*)%s_temp,sizeof(%s_buff[0].u1.r%s.frame));',N,config.Threads,config.Repetition-1,N,N,repIndex(config.Repetition));
                    else
                        pStr.addcr('fast_copy((void*)%s_buff[0].u%d.r.frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                        pStr.addcr('if (IO_frame_index==0)')
                        pStr.addcr('fast_copy((void*)%s_buff[0].u%d.r.frame,(void*)%s_temp,sizeof(%s_buff[0].u1.r%s.frame));',N,config.Threads,N,N,repIndex(config.Repetition));
                    end
                end
                pStr.addcr('break;');
            end
            pStr.addcr('}');
        end
    end
    pStr.addcr('} else {');

    if obj.NonBlockingOutput

        pStr.addcr('/*if we have output double buffer, before launching a new math, we have to make sure the previous one finished*/');
        pStr.addcr('/*Wait worker finished*/');
        pStr.addcr('if (worker_started) {');
        pStr.addcr('__TOP_WORKER__();');
        pStr.addcr('__TOP_WORKER__();');
        pStr.addcr('}');
    end


    if numCoderConstant(obj)~=numel(data.TopFunctionInputs)
        pStr.addcr('/*Start input*/');
        pStr.addcr('__TOP_INPUT__();');
        pStr.addcr('__TOP_INPUT__();');
    end


    for i=1:numel(data.TopFunctionOutputs)
        pStr.addcr();
        [N,F,C]=getOutputInfo(obj,data.TopFunctionOutputs{i});
        pStr.addcr('/*copy to the output*/');
        if(obj.NonBlockingOutput)
            pStr.addcr('switch (U) {');
            for cs=1:config.Threads
                pStr.addcr('case %d : ',cs-1);
                if F*C==1
                    if config.Repetition>1
                        pStr.addcr('fast_copy((void*)&%s_buff[write_buffer].u%d.r[R].frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                    else
                        pStr.addcr('fast_copy((void*)&%s_buff[write_buffer].u%d.r.frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                    end
                else
                    if config.Repetition>1
                        pStr.addcr('fast_copy((void*)%s_buff[write_buffer].u%d.r[R].frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                    else
                        pStr.addcr('fast_copy((void*)%s_buff[write_buffer].u%d.r.frame,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,cs,N,N,repIndex(config.Repetition));
                    end
                end
                pStr.addcr('break;');
            end
            pStr.addcr('}');
        else
            pStr.addcr('fast_copy((void*)%s_temp,(void*)%s_ptr,sizeof(%s_buff[0].u1.r%s.frame));',N,N,N,repIndex(config.Repetition));
        end
    end
    pStr.addcr('}');

    if numCoderConstant(obj)~=numel(data.TopFunctionInputs)

        pStr.addcr();
        pStr.addcr('/*Wait for input to finish*/');
        pStr.addcr('__TOP_INPUT__();');
        pStr.addcr('__TOP_INPUT__();');
    end


    pStr.addcr();
    pStr.addcr('/*Advance frame index*/');
    pStr.addcr('IO_frame_index=IO_frame_index+1;');


    pStr.addcr();
    pStr.addcr('/*If next frame is the last one, we can start preparing to launch the work*/');
    pStr.addcr('if (IO_frame_index==%d)',config.Threads*config.Repetition-1);
    pStr.addcr('process_buffer=true;');


    pStr.addcr();
    pStr.addcr('/*So all data are ready for the work to start*/');
    pStr.addcr('if (IO_frame_index==%d) {',config.Threads*config.Repetition);
    pStr.addcr('IO_frame_index=0;');
    pStr.addcr('write_buffer=!write_buffer;');
    pStr.addcr('worker_started=true;');
    pStr.addcr('/*Start worker*/');
    pStr.addcr('__TOP_WORKER__();');
    pStr.addcr('__TOP_WORKER__();');
    pStr.addcr('process_buffer=false;');
    pStr.addcr('}');

    if(output_index==2)
        pStr.addcr();
        pStr.addcr('return %s;',data.TopFunctionOutputs{1}.VarName);
    end

    pStr.addcr('}');


    if(chars(pStr)>0)
        indentCode(pStr,'c');
        write(pStr,fullfile(obj.data.workdirectory,[obj.data.tempname,'_par_mex.c']));
    end

end



function dataChannels=getChannels(data)
    dataChannels=1;
    for i=2:numel(data.VarType.LogInfo.Size)
        dataChannels=dataChannels*data.VarType.LogInfo.Size(i);
    end
end

function[N,F,C,StateLength]=getInputInfo(data,config)
    F=data.VarType.LogInfo.Size(1);
    N=data.VarName;
    C=getChannels(data);
    StateLength=config.SKIP_AHEAD;
end

function pointerString=isPointer(F,C)
    if F*C==1
        pointerString='&';
    else
        pointerString='';
    end
end

function pointerString=repIndex(R)
    if R>1
        pointerString='[0]';
    else
        pointerString='';
    end
end

function[N,F,C]=getOutputInfo(~,data)
    F=data.VarType.LogInfo.Size(1);
    N=data.VarName;
    C=getChannels(data);
end

function num=numCoderConstant(obj)
    num=0;
    for i=1:numel(obj.InputArgs)
        if isa(obj.InputArgs{i},'coder.Constant')
            num=num+1;
        end
    end
end
