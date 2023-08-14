classdef BatchJobListener<handle




    methods(Abstract,Access=public)

        initializing(listener);

        running(listener,file);

        completed(listener,file,status,output,result);

        finalizing(listener);

    end

end

