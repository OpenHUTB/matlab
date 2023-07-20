

classdef SharedUtilitiesPortableWordSizesConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Support PortableWordSizes off for shared utils inspection';
        end


        function obj=SharedUtilitiesPortableWordSizesConstraint()
            obj.setEnum('SharedUtilitiesPortableWordSizes');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];

            if~aObj.ParentModel.getInspectSharedUtils

                return;
            end

            mdlHdl=get_param(aObj.ParentModel().getHandle(),'Handle');

            tls=get_param(mdlHdl,'PortableWordSizes');
            supportedValue={'off'};

            isSupported=strcmpi(tls,supportedValue);

            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end
    end
end