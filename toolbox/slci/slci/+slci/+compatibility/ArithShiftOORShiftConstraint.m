

classdef ArithShiftOORShiftConstraint<slci.compatibility.Constraint

    methods(Access=private,Static=true)
        function status=isOORShiftValue(datatype,shiftvalue)
            allowableShift=round(log2(double(intmax(datatype))));
            status=abs(shiftvalue)>allowableShift;
        end
    end

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'ArithShiftOORShift',...
            aObj.ParentBlock().getName());
        end

    end

    methods
        function obj=ArithShiftOORShiftConstraint()
            obj.setEnum('ArithShiftOORShift');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            mode=aObj.ParentBlock().getParam('BitShiftNumberSource');
            bitshift=slResolve(...
            aObj.ParentBlock().getParam('BitShiftNumber'),...
            aObj.ParentBlock().getSID);

            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');

            if(strcmpi(mode,'Dialog'))

                inDataType=compiledPortDataTypes.Inport;
                if(strcmpi(inDataType,'uint8')||strcmpi(inDataType,'int8')...
                    ||strcmpi(inDataType,'uint16')||strcmpi(inDataType,'int16')...
                    ||strcmpi(inDataType,'uint16')||strcmpi(inDataType,'int16'))
                    if(numel(bitshift)==1)

                        if(slci.compatibility.ArithShiftOORShiftConstraint.isOORShiftValue(char(inDataType),bitshift))
                            out=aObj.getIncompatibility();
                            return;
                        end
                    else

                        if(sum(slci.compatibility.ArithShiftOORShiftConstraint.isOORShiftValue(char(inDataType),bitshift)))
                            out=aObj.getIncompatibility();
                            return;
                        end
                    end
                end
            end
        end

        function errCode=getErrorCode(aObj)%#ok
            errCode='ArithShiftOORShiftConstraintRecAction';
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            [SubTitle,Information,StatusText,~]=getSpecificMAStrings@slci.compatibility.Constraint(aObj,status);
            RecAction=DAStudio.message(['Slci:compatibility:',aObj.getErrorCode()]);
        end
    end
end
