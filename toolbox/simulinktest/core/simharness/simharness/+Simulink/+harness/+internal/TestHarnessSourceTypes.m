classdef TestHarnessSourceTypes



    properties
        name='';
        val=0;
    end

    methods
        function t=TestHarnessSourceTypes(n,v)
            t.name=n;
            t.val=v;
        end
    end

    enumeration
        NONE('None',0)
        INPORT('Inport',1)
        SIGNAL_BUILDER('Signal Builder',2)
        FROM_WORKSPACE('From Workspace',3)
        FROM_FILE('From File',4)
        REACTIVE_TEST('Test Sequence',5)
        CUSTOM('Custom',6)
        UNKNOWN_SRC('Unknown',7)
        CONSTANT('Constant',8)
        GROUND('Ground',9)
        SIGNAL_EDITOR('Signal Editor',10)
        STATEFLOW('Chart',11)
    end
end

