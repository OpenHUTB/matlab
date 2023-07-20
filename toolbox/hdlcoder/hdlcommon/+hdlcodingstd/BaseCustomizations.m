



classdef BaseCustomizations<handle
    methods
        function this=BaseCustomizations(varargin)



            mlock;
        end



        function str=toString(this)
            str=class(this);
        end

        function str=char(this)
            str=this.toString();
        end


        function code=serialize(this)
            code=char(this);
        end

        function disp(this)
            disp(this.toString())
        end
    end
end
