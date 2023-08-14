


classdef HardwareModelParameterConstraint<slci.compatibility.PositiveModelParameterConstraint

    methods

        function out=hasAutoFix(obj)
            switch obj.getParameterName()



            case{'ProdBitPerChar',...
                'ProdBitPerShort',...
                'ProdBitPerInt',...
                'ProdBitPerLong',...
                'ProdBitPerFloat',...
                'ProdBitPerDouble',...
                'ProdBitPerPointer',...
                'ProdBitPerSizeT',...
                'ProdBitPerPtrDiffT',...
                'ProdWordSize',...
                'ProdIntDivRoundTo',...
                'ProdShiftRightIntArith',...
                }
                out=false;
            otherwise
                out=true;
            end
        end

        function obj=HardwareModelParameterConstraint(aFatal,aParameterName,varargin)
            obj=obj@slci.compatibility.PositiveModelParameterConstraint(aFatal,aParameterName,varargin{:});
            obj.setEnum('HardwareImplementationPane');
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            [SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings@slci.compatibility.PositiveModelParameterConstraint(aObj,status,varargin{:});
            if~status
                RecAction=[RecAction,' ',DAStudio.message('Slci:compatibility:SLCIHardwareSettingNote')];
            end
        end

    end
end
