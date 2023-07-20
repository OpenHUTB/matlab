classdef ContextIndex
    
    properties
        val = 0;
        valStr = '';
    end
    
    methods
      function t = ContextIndex(v)
         t.val = v;
         t.valStr = num2str(v);
      end     
    end
    
    enumeration
        BLOCK_CONTEXT (0)
        ASSESSMENT_CONTEXT (1)
    end
end