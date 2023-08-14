classdef saveMaskHelperForSysObject

    methods(Static)
        function updateAdvacedAttribsOfMaskParams(aMaskObj,doDialogCallBackParams,...
            mxArrayParams,...
            mxNumStructParams)
            numParameters=numel(aMaskObj.Parameters);
            for i=1:numParameters
                aMaskParam=aMaskObj.Parameters(i);
                paramName=aMaskParam.Name;
                bDoDialogCallBackAttribSet=any(strcmp(doDialogCallBackParams,paramName));
                bMxArryAttribSet=any(strcmp(mxArrayParams,paramName));
                bMxNumStructAttribSet=any(strcmp(mxNumStructParams,paramName));
                if(~bDoDialogCallBackAttribSet&&~bMxArryAttribSet&&~bMxNumStructAttribSet)
                    continue;
                end
                aMaskParam.setAttributes('do-dialog-callback',bDoDialogCallBackAttribSet,...
                'mxarray',bMxArryAttribSet,...
                'mxnumstruct',bMxNumStructAttribSet);

            end
        end

        function[result,hOpenedDoc,bDialogCustomizationPresent]=getUserResponseToRemoveDialogCustomizations(blockHandle)
            sysObjFileName=get_param(blockHandle,'System');
            fullPathsysObjFileName=which(sysObjFileName);
            if isempty(fullPathsysObjFileName)||strcmp(fullPathsysObjFileName,'Not on MATLAB path')
                MException(message('Simulink:Masking:SysObjectFileDoesNotExistInMatlabPath',[sysObjFileName,'.m'])).throw;
            end
            result=true;
            bDialogCustomizationPresent=false;
            dialogCustomizationMethodName='getPropertyGroupsImpl';
            document=matlab.desktop.editor.findOpenDocument(fullPathsysObjFileName);
            hOpenedDoc=[];
            if isempty(document)
                hOpenedDoc=matlab.desktop.editor.openDocument(fullPathsysObjFileName);
            end
            if matlab.system.editor.internal.DocumentAction().findMethod(fullPathsysObjFileName,dialogCustomizationMethodName)
                bDialogCustomizationPresent=true;
                msg=DAStudio.message('Simulink:Masking:removeSysObjectDialogCustomization',...
                [sysObjFileName,'_mask','.xml'],dialogCustomizationMethodName,[sysObjFileName,'.m']);
                saveLabel=DAStudio.message('Simulink:Masking:DlgCustomizationSave');
                cancelLabel=DAStudio.message('Simulink:Masking:DlgCustomizationCancel');
                dialogTitle=DAStudio.message('Simulink:Masking:DlgCustomizationTitle');


                userResponse=questdlg(msg,dialogTitle,saveLabel,cancelLabel,saveLabel);
                if strcmp(userResponse,cancelLabel)||isempty(userResponse)
                    result=false;
                end
            end
        end

        function removeDialogCustomizationsFromSysObjectFile(blockHandle)
            sysObjFileName=get_param(blockHandle,'System');
            fullPathsysObjFileName=which(sysObjFileName);
            dialogCustomizationMethodName='getPropertyGroupsImpl';
            matlab.system.editor.internal.DocumentAction.removeSystemObjectMethod(fullPathsysObjFileName,dialogCustomizationMethodName);
            doc=matlab.desktop.editor.findOpenDocument(fullPathsysObjFileName);
            if doc.Editable
                doc.save;
            end
        end
    end
end
