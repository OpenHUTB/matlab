classdef S2PFile<rf.internal.apps.budget.Element




    properties
FileName
    end

    properties(Hidden)
Sparameters
        Amplifier=[]
        OIP3=Inf
    end

    methods(Hidden)
        function out=autoforward(obj)
            try
                out=nport(obj.FileName);
            catch
                out=nport(obj.Sparameters);
                out.PrivateFileName=obj.FileName;
            end
            out.Name=matlab.lang.makeValidName(obj.Name);
        end
    end
end
