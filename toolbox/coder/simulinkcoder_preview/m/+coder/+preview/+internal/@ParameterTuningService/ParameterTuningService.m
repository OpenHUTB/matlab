classdef ParameterTuningService<coder.preview.internal.StorageClass




    methods
        function obj=ParameterTuningService(sourceDD,type,name)

            obj@coder.preview.internal.StorageClass(sourceDD,type,name);


            obj.SupportMultipleInstance=false;
        end
    end
end
