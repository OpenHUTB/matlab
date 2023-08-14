classdef SingalTypes
    
    properties
        name = '';
        val = 0;
    end
    
    methods
      function t = SingalTypes(n, v)
         t.name = n;
         t.val = v;
      end     
    end

    enumeration
        VARIABLE  (DAStudio.message('sltest:fuzzer:SigVariable'), Simulink.fuzzer.internal.SingalIndex.VARIABLE_SIGNAL.val)
        SQUARE    (DAStudio.message('sltest:fuzzer:SigSquare'), Simulink.fuzzer.internal.SingalIndex.SQUARE_SIGNAL.val)
   end
end

