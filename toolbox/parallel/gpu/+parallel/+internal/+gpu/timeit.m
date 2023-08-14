function[t,measurement_overhead,measurement_details]=timeit(f,num_outputs)









    flushFunction=str2func('_gpu_flushLazyQueue');
    waitFunction=str2func('_gpu_waitForDevice');



    deviceToUse=determineDevice(f,num_outputs);

    flushFunction();
    waitFunction(deviceToUse);

    t_rough=roughEstimate(f,num_outputs,waitFunction,deviceToUse);




    if t_rough==0
        t_rough=max(parallel.internal.timeit.functionHandleCallOverhead(f),1e-9);
    end

    flushFunction();
    waitFunction(deviceToUse);





    desired_inner_loop_time=0.001;
    num_inner_iterations=max(ceil(desired_inner_loop_time/t_rough),1);


    num_outer_iterations=11;



    estimated_running_time=num_outer_iterations*num_inner_iterations*t_rough;
    long_time=15;
    min_outer_iterations=3;
    if estimated_running_time>long_time
        num_outer_iterations=ceil(long_time/(num_inner_iterations*t_rough));
        num_outer_iterations=max(num_outer_iterations,min_outer_iterations);
    end

    runtimes=twoLoopTimer(num_outer_iterations,num_inner_iterations,...
    num_outputs,f,flushFunction,waitFunction,deviceToUse);



    t=median(runtimes)/num_inner_iterations;

    waitTime=gpuWaitCallTime(waitFunction,deviceToUse);
    flushTime=gpuFlushCallTime(flushFunction);

    [functionCallOverhead,measurement_details]=matlab.internal.timeit.functionHandleCallOverhead(f);
    measurement_details.WaitTime=waitTime;
    measurement_details.FlushTime=flushTime;

    measurement_overhead=((matlab.internal.timeit.tictocCallTime()+flushTime)/num_inner_iterations)+...
    functionCallOverhead+waitTime;

    t=max(t-measurement_overhead,0);

    if t<(5*measurement_overhead)
        warning(message('parallel:gpu:gputimeit:HighOverhead'));
    end

    function t=roughEstimate(f,num_f_outputs,waitFunction,device_index)





        tic();
        elapsed=toc();%#ok<NASGU>
        tic();
        elapsed=toc();%#ok<NASGU>



        runtimes=[];
        time_threshold=3;
        iter_count=0;
        output_array=cell(1,num_f_outputs);
        while sum(runtimes)<0.001
            iter_count=iter_count+1;










            switch num_f_outputs
            case 0
                tic();
                f();
                waitFunction(device_index);
                runtimes(end+1)=toc();%#ok<AGROW>

            case 1
                tic();
                out1=f();%#ok<NASGU>
                waitFunction(device_index);
                runtimes(end+1)=toc();%#ok<AGROW>
                clear out1;

            case 2
                tic();
                [out1,out2]=f();%#ok<ASGLU>
                waitFunction(device_index);
                runtimes(end+1)=toc();%#ok<AGROW>
                clear out1 out2;

            case 3
                tic();
                [out1,out2,out3]=f();%#ok<ASGLU>
                waitFunction(device_index);
                runtimes(end+1)=toc();%#ok<AGROW>
                clear out1 out2 out3;

            case 4
                tic();
                [out1,out2,out3,out4]=f();%#ok<ASGLU>
                waitFunction(device_index);
                runtimes(end+1)=toc();%#ok<AGROW>
                clear out1 out2 out4;

            otherwise
                tic();
                [output_array{1:num_f_outputs}]=f();%#ok<NASGU>
                waitFunction(device_index);
                runtimes(end+1)=toc();%#ok<AGROW>
                output_array=cell(1,num_f_outputs);
            end

            if iter_count==1
                if runtimes>time_threshold




                    break;
                else

                    runtimes=[];
                end
            end
        end

        t=median(runtimes);

        function runtimes=twoLoopTimer(num_outer_iterations,num_inner_iterations,...
            num_outputs,f,flushFunction,waitFunction,deviceToUse)

            runtimes=zeros(num_outer_iterations,1);
            output_array=cell(1,num_outputs);





            for k=1:num_outer_iterations


















                switch num_outputs
                case 0
                    tic();
                    for p=1:num_inner_iterations
                        f();
                        flushFunction();
                    end
                    waitFunction(deviceToUse);
                    runtimes(k)=toc();

                case 1
                    tic();
                    for p=1:num_inner_iterations
                        out1=f();%#ok<NASGU>
                        flushFunction();
                    end
                    waitFunction(deviceToUse);
                    runtimes(k)=toc();
                    clear out1;

                case 2
                    tic();
                    for p=1:num_inner_iterations
                        [out1,out2]=f();%#ok<ASGLU>
                        flushFunction();
                    end
                    waitFunction(deviceToUse);
                    runtimes(k)=toc();
                    clear out1 out2;

                case 3
                    tic();
                    for p=1:num_inner_iterations
                        [out1,out2,out3]=f();%#ok<ASGLU>
                        flushFunction();
                    end
                    waitFunction(deviceToUse);
                    runtimes(k)=toc();
                    clear out1 out2 out3;

                case 4
                    tic();
                    for p=1:num_inner_iterations
                        [out1,out2,out3,out4]=f();%#ok<ASGLU>
                        flushFunction();
                    end
                    waitFunction(deviceToUse);
                    runtimes(k)=toc();
                    clear out1 out2 out3 out4;

                otherwise
                    tic();
                    for p=1:num_inner_iterations
                        [output_array{1:num_outputs}]=f();
                        flushFunction();
                    end
                    waitFunction(deviceToUse);
                    runtimes(k)=toc();
                    output_array=cell(1,num_outputs);
                end

            end

            function device_index=determineDevice(f,num_f_outputs)



                if num_f_outputs==0
                    f();
                else
                    output_array=cell(1,num_f_outputs);
                    [output_array{:}]=f();%#ok<NASGU>
                end

                if~parallel.internal.gpu.isAnyDeviceSelected()
                    warning(message('parallel:gpu:gputimeit:NoDeviceSelected'));
                end

                device=parallel.gpu.GPUDevice.current();
                device_index=device.Index;


                function t=gpuFlushCallTime(flushFunction)

                    persistent tflush;
                    if~isempty(tflush)
                        t=tflush;
                        return;
                    end
                    num_repeats=101;


                    runtimes=zeros(1,num_repeats);


                    flushFunction();
                    flushFunction();
                    flushFunction();

                    for k=1:num_repeats
                        runtimes(k)=gpuFlushTimeExperiment(flushFunction);
                    end

                    t=min(runtimes);
                    tflush=t;

                    function t=gpuFlushTimeExperiment(flushFunction)


                        tic();


                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();


                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();


                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();


                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();


                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();


                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();


                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();


                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();


                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();


                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();
                        flushFunction();flushFunction();

                        t=toc()/100;

                        function t=gpuWaitCallTime(waitFunction,index)






                            persistent twait;
                            persistent waitIndex;
                            if~isempty(twait)&&waitIndex==index
                                t=twait;
                                return;
                            end

                            num_repeats=101;


                            runtimes=zeros(1,num_repeats);


                            waitFunction(index);
                            waitFunction(index);
                            waitFunction(index);

                            for k=1:num_repeats
                                runtimes(k)=gpuWaitTimeExperiment(waitFunction,index);
                            end

                            t=min(runtimes);
                            twait=t;
                            waitIndex=index;

                            function t=gpuWaitTimeExperiment(waitFunction,index)


                                tic();


                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);


                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);


                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);


                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);


                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);


                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);


                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);


                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);


                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);


                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);
                                waitFunction(index);waitFunction(index);

                                t=toc()/100;

