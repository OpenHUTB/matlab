classdef(Hidden=true)EnableAccessToBWSCallback





    properties
    end

    methods(Static)

        function doSetEnableBWS(ddgDialogObj,dialogH,enableBWS)
            ddName=dialogH.getWidgetValue('DataDictionary');
            ddName=strtrim(ddName);
            if~enableBWS
                [~,~,ext]=fileparts(ddName);
                if isempty(ext)
                    ddName=[ddName,'.sldd'];
                end
                try
                    ddTmp=Simulink.dd.open(ddName);
                    dialogH.setVisible('inheritedBWSAccess',ddTmp.HasAccessToBaseWorkspace);
                    ddTmp.close
                catch e %#ok<NASGU>

                    dialogH.setVisible('inheritedBWSAccess',false);
                end
            else
                dialogH.setVisible('inheritedBWSAccess',false);
            end
            defaultModelPropCB_ddg(dialogH,ddgDialogObj.source,'EnableAccessToBaseWorkspace',enableBWS);
        end

    end
end

