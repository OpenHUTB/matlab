function GenerateParallelMexHeader(obj)



    pStr=StringWriter();

    pStr.addcr('#ifndef _SUPPORT_APIS_');
    pStr.addcr('#define _SUPPORT_APIS_');

    pStr.addcr('');
    pStr.addcr('#include <string.h>')
    if ispc
        pStr.addcr('#include <windows.h>')
        pStr.addcr();
        pStr.addcr('static HANDLE worker_thread_handler;')
        pStr.addcr('static HANDLE worker_semaphore_1;')
        pStr.addcr('static HANDLE worker_semaphore_2;')
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('static HANDLE input_thread_handler;')
            pStr.addcr('static HANDLE input_semaphore_1;')
            pStr.addcr('static HANDLE input_semaphore_2;')
        end
    else
        pStr.addcr('#include <pthread.h>')
        pStr.addcr('#include <semaphore.h>')
        pStr.addcr('#include <fcntl.h>')
        pStr.addcr();
        pStr.addcr('static char ws1_name[16],ws2_name[16],is1_name[16],is2_name[16];');
        pStr.addcr('static pthread_t worker_thread_handler;')
        pStr.addcr('static sem_t *worker_semaphore_1;')
        pStr.addcr('static sem_t *worker_semaphore_2;')
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('static pthread_t input_thread_handler;')
            pStr.addcr('static sem_t *input_semaphore_1;')
            pStr.addcr('static sem_t *input_semaphore_2;')
        end
    end

    pStr.addcr('');
    pStr.addcr('static volatile bool shutdown_requested = false;');

    pStr.addcr('');
    pStr.addcr('#include <ipp.h>');
    pStr.addcr('#include <limits.h>');
    pStr.addcr('static void fast_copy(void *src, void *dst, size_t length)')
    pStr.addcr('{');
    pStr.addcr('if ((length<16)||((length>>2)>=INT_MAX)) {');
    pStr.addcr('memcpy(dst,src,length);');
    pStr.addcr('} else {');
    pStr.addcr('size_t len=((length>>2)<<2);');
    pStr.addcr('ippsCopy_32f((const Ipp32f *)src,(Ipp32f *)dst,(int)(len>>2));');
    pStr.addcr('if (length>len)');
    pStr.addcr('memcpy(((char*)dst)+len,((char*)src)+len,length-len);');
    pStr.addcr('}');
    pStr.addcr('}');
    pStr.addcr();
    pStr.addcr('static void __TOP_WORKER__()');
    pStr.addcr('{');
    if ispc
        pStr.addcr('ReleaseSemaphore(worker_semaphore_1,1,NULL);');
        pStr.addcr('WaitForSingleObject(worker_semaphore_2,INFINITE);');
    else
        pStr.addcr('sem_post(worker_semaphore_1);');
        pStr.addcr('sem_wait(worker_semaphore_2);');
    end
    pStr.addcr('}');

    pStr.addcr('static void  __WORKER_TOP__()');
    pStr.addcr('{');
    if ispc
        pStr.addcr('WaitForSingleObject(worker_semaphore_1,INFINITE);');
        pStr.addcr('ReleaseSemaphore(worker_semaphore_2,1,NULL);');
    else
        pStr.addcr('sem_wait(worker_semaphore_1);');
        pStr.addcr('sem_post(worker_semaphore_2);');
    end
    pStr.addcr('}');

    if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
        pStr.addcr('');
        pStr.addcr('static void __TOP_INPUT__()');
        pStr.addcr('{');
        if ispc
            pStr.addcr('ReleaseSemaphore(input_semaphore_1,1,NULL);');
            pStr.addcr('WaitForSingleObject(input_semaphore_2,INFINITE);');
        else
            pStr.addcr('sem_post(input_semaphore_1);');
            pStr.addcr('sem_wait(input_semaphore_2);');
        end
        pStr.addcr('}');


        pStr.addcr('');
        pStr.addcr('static void __INPUT_TOP__()');
        pStr.addcr('{');
        if ispc
            pStr.addcr('WaitForSingleObject(input_semaphore_1,INFINITE);');
            pStr.addcr('ReleaseSemaphore(input_semaphore_2,1,NULL);');
        else
            pStr.addcr('sem_wait(input_semaphore_1);');
            pStr.addcr('sem_post(input_semaphore_2);');
        end
        pStr.addcr('}');
    end

    pStr.addcr('');
    pStr.addcr('static void __CLOSE_THREADS__()');
    pStr.addcr('{');
    if ispc
        pStr.addcr('if (worker_thread_handler) WaitForSingleObject(worker_thread_handler,INFINITE);');
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('if (input_thread_handler) WaitForSingleObject(input_thread_handler,INFINITE);');
        end
        pStr.addcr('if (worker_thread_handler) CloseHandle(worker_thread_handler);');
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('if (input_thread_handler) CloseHandle(input_thread_handler);');
        end
        pStr.addcr('if (worker_semaphore_1) CloseHandle(worker_semaphore_1);');
        pStr.addcr('if (worker_semaphore_2) CloseHandle(worker_semaphore_2);');
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('if (input_semaphore_1) CloseHandle(input_semaphore_1);');
            pStr.addcr('if (input_semaphore_2) CloseHandle(input_semaphore_2);');
        end
    else
        pStr.addcr('if (worker_thread_handler) pthread_join(worker_thread_handler, NULL);');
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('if (input_thread_handler) pthread_join(input_thread_handler, NULL);');
        end
        pStr.addcr('if (worker_semaphore_1) sem_close(worker_semaphore_1);')
        pStr.addcr('sem_unlink(ws1_name);');
        pStr.addcr('if (worker_semaphore_2) sem_close(worker_semaphore_2);')
        pStr.addcr('sem_unlink(ws2_name);');
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('if (input_semaphore_1) sem_close(input_semaphore_1);')
            pStr.addcr('sem_unlink(is1_name);');
            pStr.addcr('if (input_semaphore_2) sem_close(input_semaphore_2);')
            pStr.addcr('sem_unlink(is2_name);');
        end
    end
    pStr.addcr('}');

    pStr.addcr('');
    if ispc
        pStr.addcr('#define __WORKER_THREAD_DECL__ DWORD WINAPI worker_thread(LPVOID lpParam)');
        pStr.addcr('DWORD WINAPI worker_thread(LPVOID lpParam);');
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('#define __INPUT_THREAD_DECL__ DWORD WINAPI input_thread(LPVOID lpParam)');
            pStr.addcr('DWORD WINAPI input_thread(LPVOID lpParam);');
        end
    else
        pStr.addcr('#define __WORKER_THREAD_DECL__ void *worker_thread(void *ptr)');
        pStr.addcr('void *worker_thread(void *ptr);');
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('#define __INPUT_THREAD_DECL__ void *input_thread(void *ptr)');
            pStr.addcr('void *input_thread(void *ptr);');
        end
    end

    pStr.addcr('');
    pStr.addcr('static void __SHUTDOWN__()');
    pStr.addcr('{');
    pStr.addcr('shutdown_requested = true;');
    pStr.addcr('__TOP_WORKER__();');
    if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
        pStr.addcr('__TOP_INPUT__();');
    end
    pStr.addcr('}');
    pStr.addcr('');
    pStr.addcr('static void __CHECK_SHUTDOWN__()');
    pStr.addcr('{');
    if ispc
        pStr.addcr('if (shutdown_requested)')
        pStr.addcr('ExitThread(0);')
    else
        pStr.addcr('if (shutdown_requested)')
        pStr.addcr('pthread_exit(NULL);')
    end
    pStr.addcr('}');

    pStr.addcr('');
    pStr.add('#define __THREAD_MARK_EXIT__ ');
    if~ispc
        pStr.addcr('pthread_exit(NULL);');
    else
        pStr.addcr('return 1;');
    end

    pStr.addcr('');
    pStr.addcr('static void __CREATE_THREADS__()');
    pStr.addcr('{');
    if ispc
        pStr.addcr('DWORD ThreadID;');
        pStr.addcr('worker_semaphore_1 = CreateSemaphore(NULL,0,1,0);');
        pStr.addcr('if (!worker_semaphore_1) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));
        pStr.addcr('worker_semaphore_2 = CreateSemaphore(NULL,0,1,0);');
        pStr.addcr('if (!worker_semaphore_2) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('input_semaphore_1 = CreateSemaphore(NULL,0,1,0);');
            pStr.addcr('if (!input_semaphore_1) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));
            pStr.addcr('input_semaphore_2 = CreateSemaphore(NULL,0,1,0);');
            pStr.addcr('if (!input_semaphore_2) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));
        end
        pStr.addcr('worker_thread_handler = CreateThread(NULL,0,worker_thread,NULL,0,&ThreadID);');
        pStr.addcr('if (!worker_thread_handler) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('input_thread_handler = CreateThread(NULL,0,input_thread,NULL,0,&ThreadID);');
            pStr.addcr('if (!input_thread_handler) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));
        end
    else
        pStr.addcr('int i,try;');
        pStr.addcr('bool semCreated;');
        pStr.addcr('const char semDictonary[] = "0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";');

        pStr.addcr('semCreated=false;');
        pStr.addcr('for (try=0;(try<10) && (!semCreated);try++) {');
        pStr.addcr('ws1_name[0]=''w'';ws1_name[1]=''1''; for (i=2;i<15;i++) ws1_name[i] = semDictonary[rand() % sizeof(semDictonary)]; ws1_name[i] = 0;');
        pStr.addcr('worker_semaphore_1 = sem_open(ws1_name, O_CREAT | O_EXCL, 0644, 0);');
        pStr.addcr('if (worker_semaphore_1!=SEM_FAILED) semCreated=true;');
        pStr.addcr('}');
        pStr.addcr('if (!semCreated) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));

        pStr.addcr('semCreated=false;');
        pStr.addcr('for (try=0;(try<10) && (!semCreated);try++) {');
        pStr.addcr('ws2_name[0]=''w'';ws2_name[1]=''2''; for (i=2;i<15;i++) ws2_name[i] = semDictonary[rand() % sizeof(semDictonary)]; ws2_name[i] = 0;');
        pStr.addcr('worker_semaphore_2 = sem_open(ws2_name, O_CREAT | O_EXCL, 0644, 0);');
        pStr.addcr('if (worker_semaphore_2!=SEM_FAILED) semCreated=true;');
        pStr.addcr('}');
        pStr.addcr('if (!semCreated) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)

            pStr.addcr('semCreated=false;');
            pStr.addcr('for (try=0;(try<10) && (!semCreated);try++) {');
            pStr.addcr('is1_name[0]=''i'';is1_name[1]=''1''; for (i=2;i<15;i++) is1_name[i] = semDictonary[rand() % sizeof(semDictonary)]; is1_name[i] = 0;');
            pStr.addcr('input_semaphore_1 = sem_open(is1_name, O_CREAT | O_EXCL, 0644, 0);');
            pStr.addcr('if (input_semaphore_1!=SEM_FAILED) semCreated=true;');
            pStr.addcr('}');
            pStr.addcr('if (!semCreated) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));

            pStr.addcr('semCreated=false;');
            pStr.addcr('for (try=0;(try<10) && (!semCreated);try++) {');
            pStr.addcr('is2_name[0]=''i'';is2_name[1]=''2''; for (i=2;i<15;i++) is2_name[i] = semDictonary[rand() % sizeof(semDictonary)]; is2_name[i] = 0;');
            pStr.addcr('input_semaphore_2 = sem_open(is2_name, O_CREAT | O_EXCL, 0644, 0);');
            pStr.addcr('if (input_semaphore_2!=SEM_FAILED) semCreated=true;');
            pStr.addcr('}');
            pStr.addcr('if (!semCreated) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));
        end
        pStr.addcr('pthread_create (&worker_thread_handler, NULL, worker_thread, (void*) &i);');
        pStr.addcr('if (!worker_thread_handler) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));
        if numel(obj.data.TopFunctionInputs)>numCoderConstant(obj)
            pStr.addcr('pthread_create (&input_thread_handler, NULL, input_thread, (void*) &i);');
            pStr.addcr('if (!input_thread_handler) {free_memory();mexErrMsgIdAndTxt("dsp:dspunfold:ErrorCannotStartMEX","%s");}',getString(message('dsp:dspunfold:ErrorCannotStartMEX',[obj.data.real_mname,obj.data.mext],obj.data.real_mname)));
        end
    end
    pStr.addcr('}');

    pStr.addcr('');
    pStr.addcr('#endif');



    if chars(pStr)>0
        indentCode(pStr,'c');
        write(pStr,fullfile(obj.data.workdirectory,[obj.data.tempname,'_support_apis.h']));
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
