classdef ProfileWrapper<systemcomposer.internal.propertyInspector.wrappers.ElementWrapper



    properties
        profileName;
        profile;
        schemaType;
    end

    methods
        function obj=ProfileWrapper(varargin)

            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ElementWrapper(varargin{:});
            obj.schemaType='Profile';
        end

        function setPropElement(obj)
            obj.profileName=obj.archName;
            obj.profile=systemcomposer.internal.profile.Profile.findLoadedProfile(obj.profileName);
            obj.element=mf.zero.getModel(obj.profile).findElement(obj.uuid);
        end

        function name=getName(obj)

            name=obj.element.getName;
        end

        function tooltip=getNameTooltip(~,~)
            tooltip=DAStudio.message('SystemArchitecture:ProfileDesigner:PrototypeNameTooltip');
        end

        function tooltip=getDescTooltip(~,~)
            tooltip=DAStudio.message('SystemArchitecture:ProfileDesigner:ProfileDescriptionTooltip');
        end

        function error=setName(obj,changeSet,~)

            error='';
            newValue=changeSet.newValue;
            try
                txn=obj.beginTransaction();
                obj.element.setName(newValue);
                txn.commit();
            catch
                error='Failed to set Name';
            end
        end

        function friendlyName=getFriendlyName(obj)

            friendlyName=obj.element.friendlyName;
        end

        function description=getDescription(obj)
            description=obj.element.description;
        end

        function txn=beginTransaction(obj)
            mdl=mf.zero.getModel(obj.element);
            txn=mdl.beginTransaction();
        end

        function commitTransaction(obj,fcn)
            txn=obj.beginTransaction();
            fcn();
            txn.commit();
        end
    end
end

