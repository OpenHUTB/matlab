



classdef ControlPortDataTypeConstraint<slci.compatibility.IndexPortDataTypeConstraint

    methods


        function out=getDescription(aObj)%#ok
            out='Index port data type of Switch block must be of data type bool';
        end


        function obj=ControlPortDataTypeConstraint(aPortKind,aPortNumber)
            obj=obj@slci.compatibility.IndexPortDataTypeConstraint(aPortKind,aPortNumber);
            obj.setEnum('ControlPortDataTypeConstraint');
            obj.setCompileNeeded(1);
            obj.setFatal(false);

            obj.setSupportedDataType({'bool'});
        end


        function out=check(aObj)
            out=check@slci.compatibility.IndexPortDataTypeConstraint(aObj);
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            [SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings@slci.compatibility.IndexPortDataTypeConstraint(aObj,status,varargin{:});
        end
    end



end

