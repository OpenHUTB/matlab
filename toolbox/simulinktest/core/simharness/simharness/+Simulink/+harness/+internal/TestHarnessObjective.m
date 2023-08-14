classdef TestHarnessObjective

    properties
        name='';
        val=0;
    end

    methods
        function t=TestHarnessObjective(n,v)
            t.name=n;
            t.val=v;
        end
    end

    enumeration
        PROTOTYPE('Prototyping',0)
        DEVELOP('Refinement/Debugging',1)
        TEST('Verification',2)
        CUSTOM('Custom',3)
    end
end

