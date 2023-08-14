classdef NullStore<codergui.internal.util.Store




    methods
        function value=read(~,~)%#ok<STOUT>
            error('NullStore does not store anything');
        end

        function exists=has(~,~)
            exists=false;
        end

        function write(~,~,~)
        end

        function remove(~,~)
        end

        function flush(~)
        end
    end
end
