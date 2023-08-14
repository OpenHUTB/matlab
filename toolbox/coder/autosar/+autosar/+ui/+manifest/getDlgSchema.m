




function dlgstruct=getDlgSchema(obj)
    if isa(obj,'autosar.ui.metamodel.M3ITerminalNode')

        m3iPort=obj.getM3iObject();
        mdlName=obj.getModelName();

        if~isempty(m3iPort)
            dlgstruct=getDlgSchemaForPort(m3iPort,mdlName);
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DialogTag='autosar_manifest_properties_dialog';
        else
            dlgstruct.DialogTitle='';
            dlgstruct.Items={};
            dlgstruct.EmbeddedButtonSet={};
        end
    end
end

function dlgstruct=getDlgSchemaForPort(m3iPort,mdlName)

    dlgstruct=[];

    arExplorer=autosar.ui.utils.findExplorer(m3iPort.modelM3I);
    assert(~isempty(arExplorer));
    instanceIdentifier=autosar.internal.adaptive.manifest.ManifestUtilities.getInstanceIdentifier(mdlName,m3iPort);

    pkgEditRow=2;
    apiObj=autosar.api.getAUTOSARProperties(mdlName);

    if~slfeature('AdaptiveAutogenInstanceSpecifier')
        instanceSpecifierEdit.Name=DAStudio.message('autosarstandard:ui:uiLabelInstanceSpecifier');
        instanceSpecifierEdit.HideName=false;
        instanceSpecifierEdit.Type='edit';
        instanceSpecifierEdit.Mode=true;
        instanceSpecifierEdit.Tag='instanceSpecifierEdit';
        value=apiObj.get(autosar.api.Utils.getQualifiedName(m3iPort),'InstanceSpecifier');
        instanceSpecifierEdit.Value=value;
        instanceSpecifierEdit.RowSpan=[pkgEditRow,pkgEditRow];
        instanceSpecifierEdit.ColSpan=[1,25];
        instanceSpecifierEdit.MatlabMethod='autosar.ui.manifest.applyManifestProperties';
        instanceSpecifierEdit.MatlabArgs={mdlName,m3iPort,'%dialog',instanceSpecifierEdit.Tag};

        if(strcmp(apiObj.get('XmlOptions','IdentifyServiceInstance'),'InstanceIdentifier'))
            instanceSpecifierEdit.Enabled=false;
        end
    end

    pkgEditRow=pkgEditRow+1;

    instanceIdentifierEdit.Name=DAStudio.message('autosarstandard:ui:uiLabelInstanceIdentifier');
    instanceIdentifierEdit.HideName=false;
    instanceIdentifierEdit.Type='edit';
    instanceIdentifierEdit.Mode=true;
    instanceIdentifierEdit.Tag='instanceIdentifierEdit';
    instanceIdentifierEdit.Value=instanceIdentifier;

    if(strcmp(apiObj.get('XmlOptions','IdentifyServiceInstance'),'InstanceSpecifier'))
        instanceIdentifierEdit.Enabled=false;
    end

    instanceIdentifierEdit.RowSpan=[pkgEditRow,pkgEditRow];
    instanceIdentifierEdit.ColSpan=[1,25];
    instanceIdentifierEdit.MatlabMethod='autosar.ui.manifest.applyManifestProperties';
    instanceIdentifierEdit.MatlabArgs={mdlName,m3iPort,'%dialog',instanceIdentifierEdit.Tag};

    manifestGroup.Name=DAStudio.message('autosarstandard:ui:uiManifestAttributes');
    manifestGroup.Type='group';
    manifestGroup.LayoutGrid=[pkgEditRow,25];
    manifestGroup.RowSpan=[1,pkgEditRow];
    manifestGroup.ColSpan=[1,25];
    manifestGroup.RowStretch=zeros(1,pkgEditRow);
    manifestGroup.RowStretch(end)=1;
    if slfeature('AdaptiveAutogenInstanceSpecifier')
        manifestGroup.Items={instanceIdentifierEdit};
    else
        manifestGroup.Items={instanceSpecifierEdit,instanceIdentifierEdit};
    end

    pkgEditRow=pkgEditRow+1;

    if isa(m3iPort,'Simulink.metamodel.arplatform.port.ServiceRequiredPort')
        serviceDiscoveryValue=apiObj.get(autosar.api.Utils.getQualifiedName(m3iPort),'ServiceDiscoveryMode');
    else

        serviceDiscoveryValue='';
    end
    serviceDiscoveryCombo.Name=DAStudio.message('autosarstandard:ui:uiLabelServiceDiscoveryMode');
    serviceDiscoveryCombo.HideName=false;
    serviceDiscoveryCombo.Type='combobox';
    serviceDiscoveryCombo.Entries={autosar.mm.util.ServiceDiscoveryEnum.OneTime.char();...
    autosar.mm.util.ServiceDiscoveryEnum.DynamicDiscovery.char()};
    serviceDiscoveryCombo.Mode=true;
    serviceDiscoveryCombo.Tag='serviceDiscoverCombo';
    serviceDiscoveryCombo.Value=serviceDiscoveryValue;
    serviceDiscoveryCombo.RowSpan=[1,1];
    serviceDiscoveryCombo.ColSpan=[1,25];
    serviceDiscoveryCombo.MatlabMethod='autosar.mm.util.ServiceDiscoveryUtils.setServiceDiscoveryModeForUI';
    serviceDiscoveryCombo.MatlabArgs={mdlName,m3iPort,'%dialog',serviceDiscoveryCombo.Tag};

    serviceDiscoveryGroup.Name=DAStudio.message('autosarstandard:ui:uiLabelServiceDiscoveryTitle');
    serviceDiscoveryGroup.Type='group';
    serviceDiscoveryGroup.LayoutGrid=[1,25];
    serviceDiscoveryGroup.RowSpan=[4,4];
    serviceDiscoveryGroup.ColSpan=[1,25];
    serviceDiscoveryGroup.Items={serviceDiscoveryCombo};
    serviceDiscoveryGroup.Visible=...
    isa(m3iPort,'Simulink.metamodel.arplatform.port.ServiceRequiredPort');

    pkgEditRow=pkgEditRow+1;
    bottomSpacer.Type='panel';
    bottomSpacer.RowSpan=[pkgEditRow,pkgEditRow];
    data={...
    manifestGroup,...
    serviceDiscoveryGroup,...
    bottomSpacer};

    dlgstruct.DialogTitle='';
    dlgstruct.Items=data;
    dlgstruct.LayoutGrid=[pkgEditRow,1];
    dlgstruct.RowStretch=zeros(1,pkgEditRow);
    dlgstruct.RowStretch(end)=1;
end


