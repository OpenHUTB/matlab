classdef(CaseInsensitiveProperties=true)slEdittimeCheck<ModelAdvisor.Check
    methods

        function CheckObj=slEdittimeCheck(input)
            CheckObj=CheckObj@ModelAdvisor.Check(input);
            CheckObj.CallbackStyle='DetailStyle';
        end
    end
end
