


classdef SharedUtilitiesSymbolsConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='To verify shared utils, symbols must be set to default value';
        end


        function obj=SharedUtilitiesSymbolsConstraint()
            obj.setEnum('SharedUtilitiesSymbols');
            obj.setCompileNeeded(1);
            obj.setFatal(false);

        end


        function out=check(aObj)
            out=[];

            if~aObj.ParentModel.getInspectSharedUtils

                return;
            end

            mdlHdl=get_param(aObj.ParentModel().getHandle(),'Handle');

            customSymbolStrTmpVar=get_param(mdlHdl,'CustomSymbolStrTmpVar');
            defaultStrTmpVar='$N$M';

            customSymbolStrUtil=get_param(mdlHdl,'CustomSymbolStrUtil');
            defautlStrUtil='$N$C';

            isSupported=strcmpi(customSymbolStrTmpVar,defaultStrTmpVar)...
            &&strcmpi(customSymbolStrUtil,defautlStrUtil);

            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end
    end
end