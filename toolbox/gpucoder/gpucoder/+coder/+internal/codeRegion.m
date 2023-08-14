classdef codeRegion<handle %#codegen 





    properties

        Id;


        Type int16;


        Name;

    end

    methods(Static)
        function n=matlabCodegenNontunableProperties(~)
            n={'Name','Type'};
        end
    end


    methods
        function obj=codeRegion(type,name)
            coder.inline('always');
            coder.allowpcode('plain');
            if coder.gpu.internal.isGpuEnabled
                switch type
                case 'metric'
                    obj.Type=0;
                case 'profile'
                    obj.Type=1;
                end
                obj.Name=name;
                obj.Id=coder.nullcopy(0);
                coder.ceval('#__region_start',obj,obj.Type,coder.internal.stringConst(obj.Name),coder.ref(obj.Id));
            end
        end

        function regionEnd(obj)
            coder.inline('always');
            if coder.gpu.internal.isGpuEnabled
                coder.ceval('#__region_end',obj,obj.Type,coder.ref(obj.Id));
            end
        end
    end
end
