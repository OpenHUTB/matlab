classdef LogVisualizationDlg<Simulink.HMI.BrowserDlg





    methods


        function obj=LogVisualizationDlg(url_path,title,geometry,dlgUUID,sigInfo)
            url_path=connector.applyNonce(url_path);
            callbacks=[];
            USE_CEF=false;
            DEBUG_ON=false;

            obj=obj@Simulink.HMI.BrowserDlg(...
            url_path,...
            title,...
            geometry,...
            callbacks,...
            USE_CEF,...
            DEBUG_ON,...
            [],...
            false,...
            {sigInfo});

            if nargin>3
                obj.DlgUUID=dlgUUID;
            end
            if nargin>4
                obj.SigInfo.mdl=sigInfo.mdl;
                obj.SigInfo.portH=sigInfo.portH;
            end

            obj.initializeDialogForLogAndVisualization();
            obj.initializeDialogForDataAccess();
        end


        function delete(this)
            if~isempty(this.ModelCloseListener)
                delete(this.ModelCloseListener);
            end
        end


        loggingSettingChangeCB(this,dlg)
        dataAccessSettingCB(this,dlg)
        [success,errormsg]=preApplyCB(this,dlg)
        applyCB(this,dlg)
        closeCB(this,dlg)
        helpCB(this,dlg)
    end


    methods(Static)
        val=getDefaultHeight(mdl)
        val=getDefaultWidth(mdl)
    end


    methods(Access=private)
        tab=getLoggingAndVisualizationTab(this,visualizationProps);
        tab=getDataAccessTab(this);
        tab=getTolerancesTab(this);

        initializeDialogForLogAndVisualization(this);
        initializeDialogForDataAccess(this);

        applyVisualizationProperties(this,dlg);
        applyDataAccessProperties(this,dlg);
        applyTolerances(this,dlg);

        ret=getPortSettings(this);
        [blockPath,portIndex]=elaborateContext(this);
        dlg=findDialog(this);
        [sig,index]=findInstrumentedSignal(this);
        instrumentSignalIfNeeded(this);
        setInstrumentedSignal(this,sig,index);
    end


    properties(Hidden)
DlgUUID
SigInfo
LineSettings
ModelCloseListener
    end


    properties(Constant,Hidden)
        TAB_CONTAINER_TAG='SigSettingsDlg_TabContainer_Tag';
        FRAME_MODE_TAG='sigFrameMode';
        VISUAL_TYPE_TAG='sigVisualType';
        COMPLEX_FORMAT_TAG='sigComplexFormat'
        SUBPLOT_TAG='txtSubPlot'
    end
end


