classdef DesignParameterChecker<handle

    methods
        function obj=DesignParameterChecker(hwBoard)
            newfpgaparams=soc.internal.getCustomBoardParams(hwBoard);
            obj.fdesObj=newfpgaparams.fdesObj;
        end

        function errMsg=checkValue(obj,pName,errName,pVal,varargin)
            if nargin==5
                cObj=obj.getValueConstraints(pName,varargin{1});
            else
                cObj=obj.getValueConstraints(pName);
            end
            errMsg=obj.checkValueImpl(errName,pVal,cObj);
        end

        function errMsg=checkValueDependentConstraints(obj,pName,errName,pVal,depPName)%#ok<INUSL>
            cObj=obj.getValueConstraints(depPName);
            errMsg=obj.checkValueImpl(errName,pVal,cObj);
        end

        function errMsg=checkValueSpecifiedConstraints(obj,pName,errName,pVal,cObj)%#ok<INUSL>
            errMsg=obj.checkValueImpl(errName,pVal,cObj);
        end

        function cObj=getValueConstraints(obj,pName,varargin)
            if nargin==3
                cObj=obj.fdesObj.getValueConstraints(pName,varargin{1});
            else
                cObj=obj.fdesObj.getValueConstraints(pName);
            end
        end

    end

    methods(Access=private)

        function errMsg=checkValueImpl(obj,errName,pVal,cObj)%#ok<INUSL>
            errMsg='';
            if isempty(cObj.PossibleValues)
                if ischar(pVal)
                    pVal=str2num(pVal);%#ok<ST2NM>
                end
                if isempty(pVal)||~isscalar(pVal)||~isreal(pVal)||...
                    pVal<cObj.MinValue||pVal>cObj.MaxValue||~isequal(pVal,pVal)
                    errMsg=message('soc:msgs:ValueRangeCheck',errName,num2str(pVal),num2str(cObj.MinValue),num2str(cObj.MaxValue));
                end
            else
                if isnumeric(pVal),pVal=cObj.PossibleValues{pVal};end
                if~any(strcmp(pVal,cObj.PossibleValues))
                    errMsg=message('soc:msgs:ValueListCheck',errName,pVal,strjoin(cObj.PossibleValues,', '));
                end
            end
        end
    end
    properties(Access=private)
fdesObj
    end

end
