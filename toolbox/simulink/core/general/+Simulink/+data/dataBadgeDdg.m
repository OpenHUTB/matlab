



classdef dataBadgeDdg<handle
    properties
mModelName
    end

    methods

        function obj=dataBadgeDdg(modelName)
            obj.mModelName=modelName;
        end

        function schema=getDialogSchema(obj)
            rowNum=1;

            mwsImage.Type='image';
            mwsImage.Tag='mwsImage';
            mwsImage.RowSpan=[rowNum,rowNum];
            mwsImage.ColSpan=[1,1];
            mwsImage.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','SimulinkWorkspace.png');
            mwsImage.MatlabMethod='Simulink.data.dataBadgeDdg.performAction';
            mwsImage.MatlabArgs={obj.mModelName,'modelworkspace'};
            mwsImage.Enabled=true;

            mwsLink.Name=DAStudio.message('Simulink:dialog:WorkspaceLocation_Model');
            mwsLink.ToolTip=DAStudio.message('Simulink:dialog:DataBadge_MWSTooltip');
            mwsLink.Type='hyperlink';
            mwsLink.MatlabMethod='Simulink.data.dataBadgeDdg.performAction';
            mwsLink.MatlabArgs={obj.mModelName,'%tag'};
            mwsLink.Tag='modelworkspace';
            mwsLink.RowSpan=[rowNum,rowNum];
            mwsLink.ColSpan=[2,4];
            mwsLink.Enabled=true;

            rowNum=rowNum+1;
            valSrc.Name=DAStudio.message('sl_valuesrc:messages:ValueSetMgrTitle');
            valSrc.ToolTip=DAStudio.message('sl_valuesrc:messages:LaunchAppTooltip');
            valSrc.Type='hyperlink';
            valSrc.MatlabMethod='Simulink.data.dataBadgeDdg.performAction';
            valSrc.MatlabArgs={obj.mModelName,'%tag'};
            valSrc.Tag='valuesrc';
            valSrc.RowSpan=[rowNum,rowNum];
            valSrc.ColSpan=[3,4];
            valSrc.Alignment=4;
            valSrc.Enabled=true;
            valsrcImage.Type='image';
            valsrcImage.Tag='valsrcImage';
            valsrcImage.RowSpan=[rowNum,rowNum];
            valsrcImage.ColSpan=[2,2];
            valsrcImage.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','NoOverriddenValues.png');
            valsrcImage.MatlabMethod=valSrc.MatlabMethod;
            valsrcImage.MatlabArgs=valSrc.MatlabArgs;

            if slfeature('MWSValueSource')<2
                valSrc.Enabled=false;
                valSrc.Visible=false;
                valsrcImage.Enabled=false;
                valsrcImage.Visible=false;
            elseif isequal(get_param(obj.mModelName,'HasValueManager'),'on')
                vsm=get_param(obj.mModelName,'ValueManager');
                if vsm.hasNonDefaultValueOverrideData
                    valsrcImage.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','OverriddenValues.png');
                end
            end

            try
                if isempty(get_param(obj.mModelName,'ModelWorkspace'))
                    mwsLink.Visible=false;
                    mwsImage.Visible=false;
                    valSrc.Visible=false;
                end
            catch
                mwsLink.Enabled=false;
                mwsImage.Enabled=false;
                valSrc.Enabled=false;
            end

            rowNum=rowNum+1;

            ddImage.Type='image';
            ddImage.Tag='ddImage';
            ddImage.RowSpan=[rowNum,rowNum];
            ddImage.ColSpan=[1,1];
            ddImage.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','DictionaryGlobal.png');

            ddImage.MatlabMethod='Simulink.data.dataBadgeDdg.performAction';
            ddImage.MatlabArgs={obj.mModelName,'datadictionary'};

            if isempty(get_param(obj.mModelName,'DataDictionary'))
                ddImage.Enabled=false;
                ddLink.Enabled=false;
            else
                ddLink.ToolTip=DAStudio.message('Simulink:dialog:DataBadge_DDTooltip',get_param(obj.mModelName,'DataDictionary'));
            end
            ddLink.Name=DAStudio.message('Simulink:dialog:WorkspaceLocation_Dictionary');
            ddLink.Type='hyperlink';
            ddLink.MatlabMethod='Simulink.data.dataBadgeDdg.performAction';
            ddLink.MatlabArgs={obj.mModelName,'%tag'};
            ddLink.Tag='datadictionary';
            ddLink.RowSpan=[rowNum,rowNum];
            ddLink.ColSpan=[2,4];

            showExtData=false;
            if slfeature('ShowExternalDataNode')>0
                showExtData=true;
            end
            extImage.Type='image';
            extImage.Tag='extImage';
            extImage.RowSpan=[rowNum,rowNum];
            extImage.ColSpan=[1,1];
            extImage.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','ModelExternalData.png');
            extImage.MatlabMethod='Simulink.data.dataBadgeDdg.performAction';
            extImage.MatlabArgs={obj.mModelName,'externaldata'};

            hasBrokeredData=false;
            if slfeature('SlModelBroker')>0
                bd=get_param(obj.mModelName,'slobject');
                br=bd.getBroker;
                try
                    hasBrokeredData=br.hasAnyDataSources();
                catch e
                    warning(e.message);
                end
            end
            hasBrokeredSLDD=false;
            if slfeature('SLLibrarySLDD')>0
                bd=get_param(obj.mModelName,'slobject');
                libSLDDs=bd.getBroker().getExternalReferenceURLs('#BROKEREDSLDD');

                try
                    hasBrokeredSLDD=~isempty(libSLDDs);
                catch e
                    warning(e.message);
                end
            end

            if(isempty(get_param(obj.mModelName,'ExternalSources'))||...
                isequal(get_param(obj.mModelName,'ExternalSources'),{''}))&&...
                isempty(get_param(obj.mModelName,'DataDictionary'))&&...
                isequal(hasBrokeredSLDD,false)&&...
                isequal(hasBrokeredData,false)
                extImage.Enabled=false;
                extLink.Enabled=false;
            end

            extLink.Name=DAStudio.message('Simulink:dialog:ModelExternalData');
            extLink.ToolTip=DAStudio.message('Simulink:dialog:DataBadge_ExtDataTooltip');
            extLink.Type='hyperlink';
            extLink.MatlabMethod='Simulink.data.dataBadgeDdg.performAction';
            extLink.MatlabArgs={obj.mModelName,'%tag'};
            extLink.Tag='externaldata';
            extLink.RowSpan=[rowNum,rowNum];
            extLink.ColSpan=[2,4];

            mdlProps.Type='image';
            mdlProps.Tag='configure';
            mdlProps.MatlabMethod='Simulink.data.dataBadgeDdg.performAction';
            mdlProps.MatlabArgs={obj.mModelName,'%tag'};
            mdlProps.RowSpan=[rowNum,rowNum];
            mdlProps.ColSpan=[5,5];
            mdlProps.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Toolbars','16px','ModelConfigurationParameters_16.png');
            if showExtData
                mdlProps.ToolTip=DAStudio.message('Simulink:dialog:ConfigureExtDataTooltip');
            else
                mdlProps.ToolTip=DAStudio.message('Simulink:dialog:ConfigureDataDictTooltip');
            end

            linksPanel.Type='panel';
            linksPanel.Name='';
            linksPanel.Items={mwsImage,mwsLink,valSrc,valsrcImage};
            if showExtData
                linksPanel.Items{end+1}=extImage;
                linksPanel.Items{end+1}=extLink;
            else
                linksPanel.Items{end+1}=ddImage;
                linksPanel.Items{end+1}=ddLink;
            end
            linksPanel.Items{end+1}=mdlProps;
            linksPanel.LayoutGrid=[rowNum,5];
            linksPanel.ColStretch=[0,0,0,1,0];


            schema.Items={linksPanel};
            schema.Transient=true;
            schema.DialogStyle='frameless';
            schema.DialogTitle='';
            schema.StandaloneButtonSet={''};
            schema.ExplicitShow=true;
            schema.IsScrollable=false;

            schema.DialogTag='dataBadgeDdg';

        end
    end

    methods(Static)

        function launchDialog(hModel)
            dataBadgeDlg=Simulink.data.dataBadgeDdg(hModel);
            hDlg=DAStudio.Dialog(dataBadgeDlg);

            width=hDlg.position(3);
            height=hDlg.position(4);
            pos=find_current_canvas_lowerleft_global();
            pos=pos+[24,-(height+24)];
            hDlg.position=[pos,width,height];

            hDlg.show();
        end

        function performAction(modelName,action)
            switch action
            case 'modelworkspace'
                slprivate('exploreListNode',modelName,'model','');

            case 'datadictionary'
                if~isempty(get_param(modelName,'DataDictionary'))
                    opensldd(get_param(modelName,'DataDictionary'));
                end

            case 'externaldata'
                if bdIsSubsystem(modelName)
                    open_system(modelName);
                end
                slprivate('exploreListNode',modelName,'modelnode',DAStudio.message('Simulink:Data:ExternalDataNode'),true);

            case 'configure'
                slprivate('openLinkToDict',modelName);

            case 'valuesrc'
                sl_valuesrc.ValueSrcManager.launch(modelName);

            otherwise
                disp('Unknown action');
            end
        end

    end

end


function pos=find_current_canvas_lowerleft_global()
    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    canvas=allStudios(1).App.getActiveEditor.getCanvas;
    rect=canvas.GlobalPosition;
    pos=[rect(1),rect(2)+rect(4)];
end
