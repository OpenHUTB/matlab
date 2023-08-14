classdef(CaseInsensitiveProperties=true)slsfEdittimeCheck<ModelAdvisor.Check
    methods

        function CheckObj=slsfEdittimeCheck(input)
            CheckObj=CheckObj@ModelAdvisor.Check(input);
            CheckObj.CallbackStyle='DetailStyle';
        end
    end
end
