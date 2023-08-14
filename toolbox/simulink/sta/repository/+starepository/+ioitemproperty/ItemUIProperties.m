classdef ItemUIProperties<handle







    properties
State
isDisplayParentName
    end
    properties(Dependent)
Icon
    end

    properties(Constant,Abstract,Hidden)
NormalIcon
ErrorIcon
WarningIcon
    end
    methods(Access='protected')
        function obj=ItemUIProperties
            obj.isDisplayParentName=true;
        end
    end

    methods
        function anIcon=get.Icon(obj)

            anIcon=obj.NormalIcon;
        end
        function set.State(obj,itemstate)

            switch itemstate
            case starepository.ioitemproperty.ItemState.Normal
                obj.State=itemstate;

            case starepository.ioitemproperty.ItemState.Error
                obj.State=itemstate;

            case starepository.ioitemproperty.ItemState.Warning
                obj.State=itemstate;

            otherwise
                error(message('sl_sta_repository:item:InvalidItemState'));
            end
        end
    end

end


