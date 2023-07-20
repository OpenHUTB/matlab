classdef TestHarnessSinkTypes



    properties
        name='';
        val=0;
    end

    methods
        function t=TestHarnessSinkTypes(n,v)
            t.name=n;
            t.val=v;
        end
    end

    enumeration
        NONE('None',0)
        OUTPORT('Outport',1)
        SCOPE('Scope',2)
        TO_WORKSPACE('To Workspace',3)
        TO_FILE('To File',4)
        REACTIVE_TEST('Test Assessment',5)
        CUSTOM('Custom',6)
        UNKNOWN_SINK('Unknown',7)
        TERMINATOR('Terminator',8)
        STATEFLOW('Stateflow Chart Assessment',9)
    end
end
