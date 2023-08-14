classdef(Abstract)AlgorithmParameterSet

    properties

    end

    methods
        function obj=setAlgorithmParameters(obj,varargin)

            myParamVals=varargin{:};
            len=numel(myParamVals);
            if mod(len,2)~=0
                DAStudio.error('CoderFoundation:AlgorithmParameters:oddArguments');
            end


            for idx=1:2:len


                obj=setPropertyValue(obj,myParamVals{idx},myParamVals{idx+1});
            end
        end

        function obj=setPropertyValue(obj,pName,pValue)

            if(isprop(obj,pName))
                pValidName=pName;
            else
                pValidName=coder.algorithm.parameterset.validateName(obj,pName);
            end


            obj.(pValidName)=pValue;
        end

    end
end
