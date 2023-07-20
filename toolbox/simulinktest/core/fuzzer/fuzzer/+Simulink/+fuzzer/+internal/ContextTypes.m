classdef ContextTypes
    
    properties
        name = '';
        val = 0;
    end
    
    methods
      function t = ContextTypes(n, v)
         t.name = n;
         t.val = v;
      end     
    end

    enumeration
        BLOCK       (DAStudio.message('sltest:fuzzer:BlockContext'), Simulink.fuzzer.internal.ContextIndex.val)
        ASSESSMENT  (DAStudio.message('sltest:fuzzer:AssessmentContext'), Simulink.fuzzer.internal.ContextIndex.val)
        
   end
end

