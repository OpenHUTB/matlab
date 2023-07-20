classdef SingalIndex
    
    properties
        val = 0;
        valStr = '';
    end
    
    methods
      function t = SingalIndex(v)
         t.val = v;
         t.valStr = num2str(v);
      end     
    end
    
    enumeration
        VARIABLE_SIGNAL (0)
        SQUARE_SIGNAL (1)
    end
end
