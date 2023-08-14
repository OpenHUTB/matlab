

classdef DataExchangeInterfaceParameterConstraint<slci.compatibility.PositiveModelParameterConstraint



    methods

        function obj=DataExchangeInterfaceParameterConstraint(aFatal,aParameterName,varargin)
            obj=obj@slci.compatibility.PositiveModelParameterConstraint(aFatal,aParameterName,varargin{:});
            obj.setEnum('DataExchangeInterfaceParameter');
            obj.setCompileNeeded(0);
            obj.setFatal(0);
        end


        function out=check(aObj)
            out=[];
            if(~aObj.ParentModel().isConfigsetParam(aObj.getParameterName())||...
                strcmpi(aObj.ParentModel().getParam(aObj.getParameterName()),'off'))
                return;
            end
            out=aObj.getIncompatibility();
        end
    end

end
