classdef Set<autosar.mm.util.Map





    methods(Access=public)








        function self=Set(varargin)
            self=self@autosar.mm.util.Map(varargin{:});
        end




        function self=set(self,key)
            self.set@autosar.mm.util.Map(key,true);
        end

    end

end


