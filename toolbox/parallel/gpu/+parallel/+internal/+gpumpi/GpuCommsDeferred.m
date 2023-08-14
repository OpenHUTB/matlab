classdef(Hidden=true)GpuCommsDeferred





    properties(SetAccess=immutable)
Sender
Size
Tag
    end

    methods
        function obj=GpuCommsDeferred(X,tag)
            obj.Sender=spmdIndex;
            obj.Size=size(X);
            if nargin==2
                obj.Tag=tag;
            else
                obj.Tag=0;
            end
        end
    end

    methods(Static)

        function X=loadobj(S)



            [useFallback,X]=parallel.internal.gpumpi.gpuSpmdReceive(S.Sender,S.Size,S.Tag);
            if useFallback





                X=spmdReceive(S.Sender,S.Tag);
            end
        end

    end
end
