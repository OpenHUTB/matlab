function launchVariantManager(action,rootModelName,blockPathObject,expandSelectedRow)






    if nargin<3
        blockPathObject=[];
    end

    if nargin<4
        expandSelectedRow=false;
    end



    if isempty(blockPathObject)

        if slfeature('VMGRV2UI')<1
            variantmanager(action,rootModelName);
            return;
        end


        isInstalled=handleVMgrSPKGInstall();
        if~isInstalled
            return;
        end

        waitBar=createWaitBar(rootModelName);%#ok<NASGU>
        slvariants.internal.manager.core.getUI(get_param(rootModelName,'Handle'));
        return;
    end



    blockPathRootModel=Simulink.variant.utils.convertBlockPathObjectToRootModelPath(blockPathObject);

    if slfeature('VMGRV2UI')<1
        variantmanager(action,rootModelName,blockPathRootModel,expandSelectedRow);
        return;
    end


    isInstalled=handleVMgrSPKGInstall();
    if~isInstalled
        return;
    end



    waitBar=createWaitBar(rootModelName);%#ok<NASGU>
    slvariants.internal.manager.core.getUI(get_param(rootModelName,'Handle'));


    slvariants.internal.manager.core.navigateToPath(get_param(rootModelName,'Handle'),blockPathRootModel,expandSelectedRow);

    function isInstalled=handleVMgrSPKGInstall()



        [isInstalled,~,isMATLABOnline]=slvariants.internal.utils.getVMgrInstallInfo('Variant Manager');
        if isMATLABOnline
            showMATLABOnlineMessage();
            return;
        end
        if~isInstalled
            slvariants.internal.utils.showVMgrSPKGInstallDialog();
            return;
        end
    end

    function showMATLABOnlineMessage()
        obj=DAStudio.DialogProvider;
        dlgText=MException(message('Simulink:VariantManager:MATLABOnlineNotSupported','Variant Manager'));
        dlgTitle=MException(message('Simulink:VariantManager:MATLABOnlineNotSupportedTitle'));
        obj.msgbox(dlgText.message,dlgTitle.message,true);
    end

end

function waitBar=createWaitBar(modelName)
    waitBar=DAStudio.WaitBar;
    waitBar.setWindowTitle(message('Simulink:VariantManagerUI:FrameTitlevm').getString()+" : "+modelName);
    waitBar.setLabelText(message('Simulink:VariantManagerUI:LoadingVariantManagerLabel').getString);
    waitBar.setCircularProgressBar(true);
    waitBar.setCancelButtonText('');
    waitBar.show();
end


