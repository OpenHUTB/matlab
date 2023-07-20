classdef SDIAppFramework<Simulink.sdi.internal.AppFramework




    methods
        function this=SDIAppFramework(eng)
            this.Engine_=eng;
        end
    end

    properties(Access='private')
Engine_
    end
end
