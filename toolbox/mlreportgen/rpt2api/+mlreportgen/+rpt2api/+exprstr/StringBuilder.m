classdef StringBuilder<handle












    properties


        Str char=''
    end

    methods
        function obj=StringBuilder()

        end

        function build(obj,char)


            obj.Str=[obj.Str,char];
        end

    end

end

