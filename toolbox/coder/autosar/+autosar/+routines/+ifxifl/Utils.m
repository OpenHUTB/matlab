classdef Utils




    methods(Static)
        function value=getParamNumericalValueFromBlock(blkH,paramName)



            workspaceParam=get_param(blkH,paramName);
            [exists,workspaceParamObj]=...
            autosar.utils.Workspace.objectExistsInModelScope(bdroot(blkH),workspaceParam);
            if exists
                if isa(workspaceParamObj,'Simulink.Parameter')
                    value=workspaceParamObj.Value;
                elseif isnumeric(workspaceParamObj)

                    value=workspaceParamObj;
                else
                    autosar.routines.ifxifl.Utils.throwInvalidParamSettingError(blkH,paramName);
                end
            else
                value=str2double(workspaceParam);
            end

            if isnan(value)
                autosar.routines.ifxifl.Utils.throwInvalidParamSettingError(blkH,paramName);
            end
        end
    end
    methods(Static,Access=private)
        function throwInvalidParamSettingError(blkH,paramName)
            mslException=MSLException(blkH,message('Simulink:Parameters:InvParamSetting',getfullname(blkH),paramName));
            autosar.routines.RoutineBlock.logErrorCallback(blkH,mslException);
        end
    end
end
