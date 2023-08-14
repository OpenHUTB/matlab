classdef CurveFitVariableFromWorkspace<handle





    methods(Static)
        function[hasVar,curveFitObj]=getCurveFitVarFromBase(cfitVar)
            hasVar=false;
            curveFitObj=[];
            if ischar(cfitVar)
                vars=evalin('base','whos');
                requiredVar=ismember({vars.class},'cfit')&ismember({vars.name},cfitVar);
                if any(requiredVar)
                    hasVar=true;
                    curveFitObj=evalin('base',vars(requiredVar).name);
                end
            end
        end
    end
end


