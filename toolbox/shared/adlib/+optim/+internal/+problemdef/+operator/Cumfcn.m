classdef(Abstract)Cumfcn<optim.internal.problemdef.Operator




    properties(GetAccess=public,SetAccess=protected)

InputSize


Dim



Direction
    end

    methods(Access=protected)

        function op=Cumfcn(inSz,varargin)

            op.InputSize=inSz;
            [~,op.Dim,op.Direction]=checkIsValid(op,varargin{:});
            if isempty(op.Dim)

                if prod(inSz)>1
                    op.Dim=find(inSz~=1,1,'first');
                else
                    op.Dim=1;
                end
            end

        end

        function[ok,dim,direction]=checkIsValid(~,varargin)


            dim=[];
            direction="forward";


            if nargin<2
                ok=true;
                return
            end



            if~matlab.internal.datatypes.isScalarText(varargin{1})

                dim=varargin{1};
                if(~isnumeric(dim)&&~islogical(dim))||~isscalar(dim)||~isreal(dim)||dim<1||floor(dim)~=dim||~isfinite(dim)
                    throwAsCaller(MException(message('MATLAB:getdimarg:dimensionMustBePositiveInteger')));
                end
                varargin=varargin(2:end);
            else
                dim=[];
            end


            isForward=false;
            isReverse=false;
            validStrings=["forward","reverse","includenan","omitnan"];
            for i=1:numel(varargin)
                thisStr=validatestring(varargin{i},validStrings);
                if strcmp(thisStr,"forward")
                    if isForward||isReverse
                        throwAsCaller(MException('shared_adlib:cumfcn:duplicateDirection',...
                        message('MATLAB:cumfun:duplicateDirection')));
                    else
                        isForward=true;
                        direction="forward";
                    end
                elseif strcmp(thisStr,"reverse")
                    if isForward||isReverse
                        throwAsCaller(MException('shared_adlib:cumfcn:duplicateDirection',...
                        message('MATLAB:cumfun:duplicateDirection')));
                    else
                        isReverse=true;
                        direction="reverse";
                    end
                elseif any(strcmp(thisStr,["includenan","omitnan"]))
                    throwAsCaller(MException('shared_adlib:operators:CumfcnNaNFlagNotSupported',...
                    message('shared_adlib:operators:CumfcnNaNFlagNotSupported')));
                end
            end

            ok=true;

        end

    end

    methods(Access=public)


        function numParens=getOutputParens(~)
            numParens=1;
        end


        function[funStr,numParens]=buildNonlinearStr(op,~,...
            leftVarName,~,leftParens,~)
            funStr=op.OperatorStr+createOperatorInputs(op,leftVarName);
            numParens=leftParens+1;
        end


        function outSz=getOutputSize(op,~,~,~)

            outSz=op.InputSize;
        end

    end

    methods

        function fcnInputs=createOperatorInputs(op,leftVarName)

            fcnInputs="("+leftVarName+", "+op.Dim+", '"+op.Direction+"')";
        end
    end

end
