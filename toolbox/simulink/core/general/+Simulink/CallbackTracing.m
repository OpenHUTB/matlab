
















classdef CallbackTracing<handle

    methods(Static)
        function openReport(varargin)
            narginchk(0,1);

            if(nargin==0)
                blockFullName=gcs;
                splitContents=strsplit(blockFullName,'/');
                modelName=splitContents{1};
            else
                modelName=varargin{1};
            end


            model_handle=get_param(modelName,'Handle');

            CallbackTracing('Create',model_handle);

        end

        function resetReport(varargin)
            narginchk(0,1);


            if(nargin==0)
                blockFullName=gcs;
                splitContents=strsplit(blockFullName,'/');
                modelName=splitContents{1};
            else
                modelName=varargin{1};
            end

            slInternal('resetCallbackTracingReport',modelName);

            CallbackTracing('Reset',modelName);

        end
    end

end

