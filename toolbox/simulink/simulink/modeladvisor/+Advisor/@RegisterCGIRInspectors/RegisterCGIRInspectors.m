classdef(Sealed=true)RegisterCGIRInspectors<Advisor.BaseRegisterCGIRInspectors















    methods(Static=true)








        function singleObj=getInstance()
            persistent localStaticObj;
            if isempty(localStaticObj)||~isvalid(localStaticObj)
                localStaticObj=Advisor.RegisterCGIRInspectors;
            end
            singleObj=localStaticObj;
        end
    end

end
