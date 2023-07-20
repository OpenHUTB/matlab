classdef JavaListenerAdapter<Simulink.ModelManagement.Project.BatchJob.BatchJobListener




    properties
JavaListener
    end

    methods(Access=public)

        function listener=JavaListenerAdapter(javaListener)
            listener.JavaListener=javaListener;
        end

        function initializing(listener)
            listener.JavaListener.initializing();
        end

        function running(listener,file)
            javaFile=java.io.File(file);
            listener.JavaListener.running(javaFile);
        end

        function completed(listener,file,status,output,result)
            javaFile=java.io.File(file);
            if(status)
                javaStatus=com.mathworks.toolbox.slproject.extensions.batchjob.batchjob.BatchJobStatus.COMPLETED;
            else
                javaStatus=com.mathworks.toolbox.slproject.extensions.batchjob.batchjob.BatchJobStatus.FAILED;
            end
            javaOutput=evalc('disp(output)');
            javaResult=evalc('disp(result)');
            listener.JavaListener.completed(javaFile,javaStatus,javaOutput,javaResult);
        end

        function finalizing(listener)
            listener.JavaListener.finalizing();
        end

    end

end

