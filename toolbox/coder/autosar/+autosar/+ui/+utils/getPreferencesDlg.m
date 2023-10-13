
function dlgstruct = getPreferencesDlg( m3iRoot, nameValueArgs )

arguments
    m3iRoot( 1, 1 )Simulink.metamodel.arplatform.common.AUTOSAR
    nameValueArgs.IsDlgForInterfaceEditor logical = false;
end

import autosar.mm.util.XmlOptionsAdapter;



xmlOptionRows = autosar.ui.utils.XmlOptionsRow.empty(  );


[ isSharedDictionary, dictFullName ] = autosar.dictionary.Utils.isSharedM3IModel( m3iRoot.rootModel );
if isSharedDictionary
    m3iModelContext = autosar.api.internal.M3IModelContext.createContext( dictFullName );
else
    m3iModelContext = autosar.api.internal.M3IModelContext.createContext(  ...
        autosar.mm.observer.ObserversDispatcher.findModelFromMetaModel( m3iRoot.rootModel ) );
end

spacer1.Name = 'Spacer';
spacer1.Type = 'text';
spacer1.ColSpan = [ 1, 15 ];
spacer1.Visible = 0;


xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( spacer1, true );
columnOffset = 2;

xmlOptionsSourceText.Name = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsSourceComboName' );
xmlOptionsSourceText.Type = 'text';
xmlOptionsSourceText.ColSpan = [ 2, columnOffset ];
xmlOptionsSourceText.Tag = 'XmlOptionsSourceLabel';

xmlOptionsSourceCombo.Name = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsSourceComboName' );
xmlOptionsSourceCombo.HideName = true;
xmlOptionsSourceCombo.Type = 'combobox';
xmlOptionsSourceCombo.Tag = 'XmlOptionsSource';
xmlOptionsSourceCombo.Entries = {  ...
    DAStudio.message( 'autosarstandard:ui:uiXmlOptionsSourceComboInlinedValue' ),  ...
    DAStudio.message( 'autosarstandard:ui:uiXmlOptionsSourceComboInheritValue' ) };
xmlOptionsSourceCombo.Enabled = true;
xmlOptionsSourceVal = XmlOptionsAdapter.get( m3iRoot, 'XmlOptionsSource' );
if strcmp( xmlOptionsSourceVal, char( autosar.mm.util.XmlOptionsSourceEnum.Inlined ) )
    xmlOptionsSourceCombo.Value = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsSourceComboInlinedValue' );
else
    assert( strcmp( xmlOptionsSourceVal, char( autosar.mm.util.XmlOptionsSourceEnum.Inherit ) ),  ...
        'Unexpected value for XmlOptionsSource: %s', xmlOptionsSourceVal );
    xmlOptionsSourceCombo.Value = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsSourceComboInheritValue' );
end
xmlOptionsSourceCombo.Editable = 0;
xmlOptionsSourceCombo.ColSpan = [ columnOffset + 1, 15 ];
xmlOptionsSourceCombo.MatlabMethod = 'autosar.ui.utils.xmlOptionsSourceChangedCallback';
xmlOptionsSourceCombo.MatlabArgs = { '%dialog', xmlOptionsSourceCombo.Tag };



isArchitectureModel = m3iModelContext.isContextArchitectureModel(  );
if ( ~isArchitectureModel && ~m3iModelContext.isContextMappedToAdaptiveApplication(  ) )

    xmlOptionsSourceVisible = nameValueArgs.IsDlgForInterfaceEditor || ~isSharedDictionary;
    xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow(  ...
        { xmlOptionsSourceText, xmlOptionsSourceCombo }, xmlOptionsSourceVisible );



    xmlOptionsVisible = strcmp( xmlOptionsSourceVal,  ...
        char( autosar.mm.util.XmlOptionsSourceEnum.Inlined ) );
else
    xmlOptionsVisible = true;
end

if isSharedDictionary && nameValueArgs.IsDlgForInterfaceEditor



    schemaVersionText.Name = [ DAStudio.message( 'RTW:autosar:generateXMLForSchema' ), ':' ];
    schemaVersionText.Type = 'text';
    schemaVersionText.ColSpan = [ 2, columnOffset ];
    schemaVersionText.Visible = xmlOptionsVisible;
    schemaVersionText.Tag = 'schemaVersionText';

    schemaVersionCombo.Name = DAStudio.message( 'autosarstandard:interface_dictionary:SchemaVersionHeader' );
    schemaVersionCombo.HideName = true;
    schemaVersionCombo.Type = 'combobox';
    schemaVersionCombo.Tag = 'SchemaVersion';
    schemaVersionCombo.Value = XmlOptionsAdapter.get( m3iRoot, 'SchemaVersion' );

    schemaVersionCombo.Editable = 0;
    schemaVersionCombo.ToolTip = DAStudio.message( 'autosarstandard:interface_dictionary:SchemaVersionTooltip' );
    schemaVersionCombo.Entries = XmlOptionsAdapter.getEnumPropertyValues( 'SchemaVersion' );
    schemaVersionCombo.ColSpan = [ columnOffset + 1, 15 ];
    schemaVersionCombo.Visible = xmlOptionsVisible;

    xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { schemaVersionText, schemaVersionCombo },  ...
        XmlOptionsAdapter.isVisibleProperty( 'SchemaVersion', m3iModelContext ) );
end

packagingText.Name = DAStudio.message( 'RTW:autosar:uiPackagingComboName' );
packagingText.Type = 'text';
packagingText.Tag = 'packagingText';
packagingText.ColSpan = [ 2, columnOffset ];
packagingText.Visible = xmlOptionsVisible;

packagingCombo.Name = DAStudio.message( 'RTW:autosar:uiPackagingComboName' );
packagingCombo.HideName = true;
packagingCombo.Type = 'combobox';

packagingCombo.Tag = 'ExportedXMLFilePackaging';
packagingCombo.Entries = {  ...
    DAStudio.message( 'RTW:autosar:uiPackagingComboModularValue' ),  ...
    DAStudio.message( 'RTW:autosar:uiPackagingComboSingleFileValue' ) };
packagingCombo.Enabled = true;
if m3iRoot.ArxmlFilePackaging == Simulink.metamodel.arplatform.common.ArxmlFilePackagingKind.SingleFile
    packagingCombo.Value = DAStudio.message( 'RTW:autosar:uiPackagingComboSingleFileValue' );
else
    packagingCombo.Value = DAStudio.message( 'RTW:autosar:uiPackagingComboModularValue' );
end
packagingCombo.Editable = 0;
packagingCombo.ColSpan = [ columnOffset + 1, 15 ];
packagingCombo.Visible = xmlOptionsVisible;

if ~isArchitectureModel
    xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { packagingText, packagingCombo }, true );
end

pkgPathLabel.Name = DAStudio.message( 'RTW:autosar:uiPackagePathsLabel' );
pkgPathLabel.Type = 'text';
pkgPathLabel.Bold = 1;
pkgPathLabel.ColSpan = [ 1, 15 ];
pkgPathLabel.FontPointSize = 6;
pkgPathLabel.Visible = xmlOptionsVisible;
pkgPathLabel.Tag = 'pkgPathLabel';

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( pkgPathLabel, true );

componentPackageText.Name = DAStudio.message( 'RTW:autosar:uiCompPackageLabel' );
componentPackageText.Type = 'text';
componentPackageText.Tag = 'ComponentPackageLabel';
componentPackageText.ColSpan = [ 2, columnOffset ];

componentPackageEdit.Name = DAStudio.message( 'RTW:autosar:uiCompPackageLabel' );
componentPackageEdit.HideName = true;
componentPackageEdit.Type = 'edit';
componentPackageEdit.Tag = 'ComponentPackage';
componentPackageEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'ComponentPackage' );
componentPackageEdit.ColSpan = [ columnOffset + 1, 15 ];

componentPackageBrowse.Type = 'pushbutton';
componentPackageBrowse.Tag = 'componentPackageBrowse';
componentPackageBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
componentPackageBrowse.ColSpan = [ 16, 17 ];
componentPackageBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
componentPackageBrowse.MatlabArgs = { m3iRoot, '%dialog', componentPackageEdit.Tag };
componentPackageBrowse.Visible = 0;

if isArchitectureModel
    xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow(  ...
        { componentPackageText, componentPackageEdit, componentPackageBrowse },  ...
        true );
end

datatypePackageText.Name = DAStudio.message( 'RTW:autosar:uiDatatypePackageLabel' );
datatypePackageText.Tag = 'datatypePackageText';
datatypePackageText.Type = 'text';
datatypePackageText.ColSpan = [ 2, columnOffset ];
datatypePackageText.Visible = xmlOptionsVisible;

datatypePackageEdit.Name = DAStudio.message( 'RTW:autosar:uiDatatypePackageLabel' );
datatypePackageEdit.HideName = true;
datatypePackageEdit.Type = 'edit';
datatypePackageEdit.Tag = 'DatatypePackage';
datatypePackageEdit.Value = m3iRoot.DataTypePackage;
datatypePackageEdit.ColSpan = [ columnOffset + 1, 15 ];
datatypePackageEdit.Visible = xmlOptionsVisible;

datatypePackageBrowse.Type = 'pushbutton';
datatypePackageBrowse.Tag = 'datatypePackageBrowse';
datatypePackageBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
datatypePackageBrowse.ColSpan = [ 16, 17 ];
datatypePackageBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
datatypePackageBrowse.MatlabArgs = { m3iRoot, '%dialog', datatypePackageEdit.Tag };
datatypePackageBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { datatypePackageText, datatypePackageEdit, datatypePackageBrowse },  ...
    true );

interfacePackageText.Name = DAStudio.message( 'RTW:autosar:uiInterfacePackageLabel' );
interfacePackageText.Type = 'text';
interfacePackageText.ColSpan = [ 2, columnOffset ];
interfacePackageText.Visible = xmlOptionsVisible;
interfacePackageText.Tag = 'interfacePackageText';

interfacePackageEdit.Name = DAStudio.message( 'RTW:autosar:uiInterfacePackageLabel' );
interfacePackageEdit.HideName = true;
interfacePackageEdit.Type = 'edit';
interfacePackageEdit.Tag = 'InterfacePackage';
interfacePackageEdit.Value = m3iRoot.InterfacePackage;
interfacePackageEdit.ColSpan = [ columnOffset + 1, 15 ];
interfacePackageEdit.Visible = xmlOptionsVisible;

interfacePackageBrowse.Type = 'pushbutton';
interfacePackageBrowse.Tag = 'interfacePackageBrowse';
interfacePackageBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
interfacePackageBrowse.ColSpan = [ 16, 17 ];
interfacePackageBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
interfacePackageBrowse.MatlabArgs = { m3iRoot, '%dialog', interfacePackageEdit.Tag };
interfacePackageBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { interfacePackageText, interfacePackageEdit, interfacePackageBrowse },  ...
    true );

if slfeature( 'AUTOSARPlatformTypesRefAndNativeDecl' )
    platformTypesOptionsLabel.Name = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsPlatformTypesLabel' );
    platformTypesOptionsLabel.Type = 'text';
    platformTypesOptionsLabel.Bold = 1;
    platformTypesOptionsLabel.ColSpan = [ 1, 15 ];
    platformTypesOptionsLabel.FontPointSize = 6;
    platformTypesOptionsLabel.Visible = xmlOptionsVisible;
    platformTypesOptionsLabel.Tag = 'platformTypesOptionsLabel';

    xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( platformTypesOptionsLabel,  ...
        true );

    platformTypePkgText.Name = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsPlatformDataTypePackage' );
    platformTypePkgText.Type = 'text';
    platformTypePkgText.ColSpan = [ 2, columnOffset ];
    platformTypePkgText.Visible = xmlOptionsVisible;
    platformTypePkgText.Tag = 'platformTypePkgText';

    platformTypePkgEdit.Name = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsPlatformDataTypePackage' );
    platformTypePkgEdit.HideName = true;
    platformTypePkgEdit.Type = 'edit';
    platformTypePkgEdit.Tag = 'PlatformDTPackage';
    platformTypePkgEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'PlatformDataTypePackage' );
    platformTypePkgEdit.ColSpan = [ columnOffset + 1, 15 ];
    platformTypePkgEdit.Visible = xmlOptionsVisible;

    xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { platformTypePkgText, platformTypePkgEdit },  ...
        XmlOptionsAdapter.isVisibleProperty( 'PlatformDataTypePackage', m3iModelContext ) );

    platformTypesRefText.Name = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsPlatformReference' );
    platformTypesRefText.Type = 'text';
    platformTypesRefText.ColSpan = [ 2, columnOffset ];
    platformTypesRefText.Visible = xmlOptionsVisible;
    platformTypesRefText.Tag = 'platformTypesRefText';

    platformTypesRefCombo.Name = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsPlatformReference' );
    platformTypesRefCombo.HideName = true;
    platformTypesRefCombo.Type = 'combobox';
    platformTypesRefCombo.Tag = 'UsePlatformTypeReferences';

    platformTypesRefCombo.Value = XmlOptionsAdapter.get( m3iRoot, 'UsePlatformTypeReferences' );
    platformTypesRefCombo.Editable = 0;
    platformTypesRefCombo.ToolTip = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsPlatformReferenceTooltip' );
    platformTypesRefCombo.Entries = XmlOptionsAdapter.getEnumPropertyValues( 'UsePlatformTypeReferences' );
    platformTypesRefCombo.ColSpan = [ columnOffset + 1, 15 ];
    platformTypesRefCombo.Visible = xmlOptionsVisible;

    xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { platformTypesRefText, platformTypesRefCombo },  ...
        XmlOptionsAdapter.isVisibleProperty( 'UsePlatformTypeReferences', m3iModelContext ) );

    nativeDeclarationText.Name = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsNativeDeclaration' );
    nativeDeclarationText.Type = 'text';
    nativeDeclarationText.ColSpan = [ 2, columnOffset ];
    nativeDeclarationText.Visible = xmlOptionsVisible;
    nativeDeclarationText.Tag = 'nativeDeclarationText';

    nativeDeclarationCombo.Name = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsNativeDeclaration' );
    nativeDeclarationCombo.HideName = true;
    nativeDeclarationCombo.Type = 'combobox';
    nativeDeclarationCombo.Tag = 'NativeDeclaration';

    nativeDeclarationCombo.Value = XmlOptionsAdapter.get( m3iRoot, 'NativeDeclaration' );
    nativeDeclarationCombo.Editable = 0;
    nativeDeclarationCombo.ToolTip = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsNativeDeclarationTooltip' );
    nativeDeclarationCombo.Entries = XmlOptionsAdapter.getEnumPropertyValues( 'NativeDeclaration' );
    nativeDeclarationCombo.ColSpan = [ columnOffset + 1, 15 ];
    nativeDeclarationCombo.Visible = xmlOptionsVisible;

    xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { nativeDeclarationText, nativeDeclarationCombo },  ...
        XmlOptionsAdapter.isVisibleProperty( 'NativeDeclaration', m3iModelContext ) );
end

addPkgPathLabel.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackagesLabel' );
addPkgPathLabel.Type = 'text';
addPkgPathLabel.Bold = 1;
addPkgPathLabel.ColSpan = [ 1, 15 ];
addPkgPathLabel.FontPointSize = 6;
addPkgPathLabel.Visible = xmlOptionsVisible;
addPkgPathLabel.Tag = 'addPkgPathLabel';

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( addPkgPathLabel,  ...
    true );

applTypePkgText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'ApplicationDataType Package' );
applTypePkgText.Type = 'text';
applTypePkgText.ColSpan = [ 2, columnOffset ];
applTypePkgText.Visible = xmlOptionsVisible;
applTypePkgText.Tag = 'applTypePkgText';

applTypePkgEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'ApplicationDataType' );
applTypePkgEdit.HideName = true;
applTypePkgEdit.Type = 'edit';
applTypePkgEdit.Tag = 'ApplDTPackage';
applTypePkgEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'ApplicationDataTypePackage' );
applTypePkgEdit.ColSpan = [ columnOffset + 1, 15 ];
applTypePkgEdit.Visible = xmlOptionsVisible;

applTypeBrowse.Type = 'pushbutton';
applTypeBrowse.Tag = 'applTypeBrowse';
applTypeBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
applTypeBrowse.ColSpan = [ 16, 17 ];
applTypeBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
applTypeBrowse.MatlabArgs = { m3iRoot, '%dialog', applTypePkgEdit.Tag };
applTypeBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { applTypePkgText, applTypePkgEdit, applTypeBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'ApplicationDataTypePackage', m3iModelContext ) );

baseTypeText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'SwBaseType Package' );
baseTypeText.Type = 'text';
baseTypeText.ColSpan = [ 2, columnOffset ];
baseTypeText.Visible = xmlOptionsVisible;
baseTypeText.Tag = 'baseTypeText';

baseTypeEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'SwBaseType' );
baseTypeEdit.HideName = true;
baseTypeEdit.Type = 'edit';
baseTypeEdit.Tag = 'BaseTypePackage';
baseTypeEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'SwBaseTypePackage' );
baseTypeEdit.ColSpan = [ columnOffset + 1, 15 ];
baseTypeEdit.Visible = xmlOptionsVisible;

baseTypeBrowse.Type = 'pushbutton';
baseTypeBrowse.Tag = 'baseTypeBrowse';
baseTypeBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
baseTypeBrowse.ColSpan = [ 16, 17 ];
baseTypeBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
baseTypeBrowse.MatlabArgs = { m3iRoot, '%dialog', baseTypeEdit.Tag };
baseTypeBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { baseTypeText, baseTypeEdit, baseTypeBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'SwBaseTypePackage', m3iModelContext ) );

dataTypeMapText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'DataTypeMappingSet Package' );
dataTypeMapText.Type = 'text';
dataTypeMapText.ColSpan = [ 2, columnOffset ];
dataTypeMapText.Visible = xmlOptionsVisible;
dataTypeMapText.Tag = 'dataTypeMapText';

dataTypeMapEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'DataTypeMappingSet' );
dataTypeMapEdit.HideName = true;
dataTypeMapEdit.Type = 'edit';
dataTypeMapEdit.Tag = 'DataTypeMapPackage';
dataTypeMapEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'DataTypeMappingPackage' );
dataTypeMapEdit.ColSpan = [ columnOffset + 1, 15 ];
dataTypeMapEdit.Visible = xmlOptionsVisible;

dataTypeMapBrowse.Type = 'pushbutton';
dataTypeMapBrowse.Tag = 'dataTypeMapBrowse';
dataTypeMapBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
dataTypeMapBrowse.ColSpan = [ 16, 17 ];
dataTypeMapBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
dataTypeMapBrowse.MatlabArgs = { m3iRoot, '%dialog', dataTypeMapEdit.Tag };
dataTypeMapBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { dataTypeMapText, dataTypeMapEdit, dataTypeMapBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'DataTypeMappingPackage', m3iModelContext ) );

constantText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'ConstantSpecification Package' );
constantText.Type = 'text';
constantText.ColSpan = [ 2, columnOffset ];
constantText.Visible = xmlOptionsVisible;
constantText.Tag = 'constantText';

constantEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'ConstantSpecification' );
constantEdit.HideName = true;
constantEdit.Type = 'edit';
constantEdit.Tag = 'ConstantPackage';
constantEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'ConstantSpecificationPackage' );
constantEdit.ColSpan = [ columnOffset + 1, 15 ];
constantEdit.Visible = xmlOptionsVisible;

constantBrowse.Type = 'pushbutton';
constantBrowse.Tag = 'constantBrowse';
constantBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
constantBrowse.ColSpan = [ 16, 17 ];
constantBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
constantBrowse.MatlabArgs = { m3iRoot, '%dialog', constantEdit.Tag };
constantBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { constantText, constantEdit, constantBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'ConstantSpecificationPackage', m3iModelContext ) );

dataConstrText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'Physical DataConstraints Package' );
dataConstrText.Type = 'text';
dataConstrText.ColSpan = [ 2, columnOffset ];
dataConstrText.Visible = xmlOptionsVisible;
dataConstrText.Tag = 'dataConstrText';

dataConstrEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'DataConstraints' );
dataConstrEdit.HideName = true;
dataConstrEdit.Type = 'edit';
dataConstrEdit.Tag = 'DataConstrPackage';
dataConstrEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'DataConstraintPackage' );
dataConstrEdit.ColSpan = [ columnOffset + 1, 15 ];
dataConstrEdit.Visible = xmlOptionsVisible;

dataConstrBrowse.Type = 'pushbutton';
dataConstrBrowse.Tag = 'dataConstrBrowse';
dataConstrBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
dataConstrBrowse.ColSpan = [ 16, 17 ];
dataConstrBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
dataConstrBrowse.MatlabArgs = { m3iRoot, '%dialog', dataConstrEdit.Tag };
dataConstrBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { dataConstrText, dataConstrEdit, dataConstrBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'DataConstraintPackage', m3iModelContext ) );

sysConstantText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'SystemConstant Package' );
sysConstantText.Type = 'text';
sysConstantText.ColSpan = [ 2, columnOffset ];
sysConstantText.Visible = xmlOptionsVisible;
sysConstantText.Tag = 'sysConstantText';

sysConstantEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'SystemConstant' );
sysConstantEdit.HideName = true;
sysConstantEdit.Type = 'edit';
sysConstantEdit.Tag = 'SysConstantPackage';
sysConstantEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'SystemConstantPackage' );
sysConstantEdit.ColSpan = [ columnOffset + 1, 15 ];
sysConstantEdit.Visible = xmlOptionsVisible;

sysConstantBrowse.Type = 'pushbutton';
sysConstantBrowse.Tag = 'sysConstantBrowse';
sysConstantBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
sysConstantBrowse.ColSpan = [ 16, 17 ];
sysConstantBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
sysConstantBrowse.MatlabArgs = { m3iRoot, '%dialog', sysConstantEdit.Tag };
sysConstantBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { sysConstantText, sysConstantEdit, sysConstantBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'SystemConstantPackage', m3iModelContext ) );

if slfeature( 'AUTOSARPostBuildVariant' )
    pbVarCritText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
        'PostBuildVariantCriterion Package' );
    pbVarCritText.Type = 'text';
    pbVarCritText.ColSpan = [ 2, columnOffset ];
    pbVarCritText.Visible = xmlOptionsVisible;
    pbVarCritText.Tag = 'pbVarCritText';
    pbVarCritText.Visible = xmlOptionsVisible;

    pbVarCritEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
        'PostBuildVariantCriterion' );
    pbVarCritEdit.HideName = true;
    pbVarCritEdit.Type = 'edit';
    pbVarCritEdit.Tag = 'PostBuildCriterionPackage';
    pbVarCritEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'PostBuildCriterionPackage' );
    pbVarCritEdit.ColSpan = [ columnOffset + 1, 15 ];
    pbVarCritEdit.Visible = xmlOptionsVisible;

    pbVarCritBrowse.Type = 'pushbutton';
    pbVarCritBrowse.Tag = 'pbVarCritBrowse';
    pbVarCritBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
    pbVarCritBrowse.ColSpan = [ 16, 17 ];
    pbVarCritBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
    pbVarCritBrowse.MatlabArgs = { m3iRoot, '%dialog', pbVarCritEdit.Tag };
    pbVarCritBrowse.Visible = 0;

    xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { pbVarCritText, pbVarCritEdit, pbVarCritBrowse },  ...
        XmlOptionsAdapter.isVisibleProperty( 'PostBuildCriterionPackage', m3iModelContext ) );
end

swAddressText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'SwAddressMethod Package' );
swAddressText.Type = 'text';
swAddressText.ColSpan = [ 2, columnOffset ];
swAddressText.Visible = xmlOptionsVisible;
swAddressText.Tag = 'swAddressText';

swAddressEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'SwAddressMethod' );
swAddressEdit.HideName = true;
swAddressEdit.Type = 'edit';
swAddressEdit.Tag = 'SwAddrPackage';
swAddressEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'SwAddressMethodPackage' );
swAddressEdit.ColSpan = [ columnOffset + 1, 15 ];
swAddressEdit.Visible = xmlOptionsVisible;

swAddressBrowse.Type = 'pushbutton';
swAddressBrowse.Tag = 'swAddressBrowse';
swAddressBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
swAddressBrowse.ColSpan = [ 16, 17 ];
swAddressBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
swAddressBrowse.MatlabArgs = { m3iRoot, '%dialog', swAddressEdit.Tag };
swAddressBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { swAddressText, swAddressEdit, swAddressBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'SwAddressMethodPackage', m3iModelContext ) );

mdgText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'ModeDeclarationGroup Package' );
mdgText.Type = 'text';
mdgText.ColSpan = [ 2, columnOffset ];
mdgText.Visible = xmlOptionsVisible;
mdgText.Tag = 'mdgText';

mdgEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'ModeDeclarationGroup' );
mdgEdit.HideName = true;
mdgEdit.Type = 'edit';
mdgEdit.Tag = 'MDGPackage';
mdgEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'ModeDeclarationGroupPackage' );
mdgEdit.ColSpan = [ columnOffset + 1, 15 ];
mdgEdit.Visible = xmlOptionsVisible;

mdgBrowse.Type = 'pushbutton';
mdgBrowse.Tag = 'mdgBrowse';
mdgBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
mdgBrowse.ColSpan = [ 16, 17 ];
mdgBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
mdgBrowse.MatlabArgs = { m3iRoot, '%dialog', mdgEdit.Tag };
mdgBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { mdgText, mdgEdit, mdgBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'ModeDeclarationGroupPackage', m3iModelContext ) );

compuText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'CompuMethod Package' );
compuText.Type = 'text';
compuText.ColSpan = [ 2, columnOffset ];
compuText.Visible = xmlOptionsVisible;
compuText.Tag = 'compuText';

compuEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'CompuMethod' );
compuEdit.HideName = true;
compuEdit.Type = 'edit';
compuEdit.Tag = 'CompuPackage';
compuEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'CompuMethodPackage' );
compuEdit.ColSpan = [ columnOffset + 1, 15 ];
compuEdit.Visible = xmlOptionsVisible;

compuBrowse.Type = 'pushbutton';
compuBrowse.Tag = 'compuBrowse';
compuBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
compuBrowse.ColSpan = [ 16, 17 ];
compuBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
compuBrowse.MatlabArgs = { m3iRoot, '%dialog', compuEdit.Tag };
compuBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { compuText, compuEdit, compuBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'CompuMethodPackage', m3iModelContext ) );

unitsText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'Unit Package' );
unitsText.Type = 'text';
unitsText.ColSpan = [ 2, columnOffset ];
unitsText.Visible = xmlOptionsVisible;
unitsText.Tag = 'unitsText';

unitsEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'Unit' );
unitsEdit.HideName = true;
unitsEdit.Type = 'edit';
unitsEdit.Tag = 'UnitPackage';
unitsEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'UnitPackage' );
unitsEdit.ColSpan = [ columnOffset + 1, 15 ];
unitsEdit.Visible = xmlOptionsVisible;

unitBrowse.Type = 'pushbutton';
unitBrowse.Tag = 'unitBrowse';
unitBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
unitBrowse.ColSpan = [ 16, 17 ];
unitBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
unitBrowse.MatlabArgs = { m3iRoot, '%dialog', unitsEdit.Tag };
unitBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { unitsText, unitsEdit, unitBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'UnitPackage', m3iModelContext ) );

recordLayoutText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'SwRecordLayout Package' );
recordLayoutText.Type = 'text';
recordLayoutText.ColSpan = [ 2, columnOffset ];
recordLayoutText.Visible = xmlOptionsVisible;
recordLayoutText.Tag = 'recordLayoutText';

recordLayoutEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'SwRecordLayout' );
recordLayoutEdit.HideName = true;
recordLayoutEdit.Type = 'edit';
recordLayoutEdit.Tag = 'SwRecordLayoutPackage';
recordLayoutEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'SwRecordLayoutPackage' );
recordLayoutEdit.ColSpan = [ columnOffset + 1, 15 ];
recordLayoutEdit.Visible = xmlOptionsVisible;

recordLayoutBrowse.Type = 'pushbutton';
recordLayoutBrowse.Tag = 'compuBrowse';
recordLayoutBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
recordLayoutBrowse.ColSpan = [ 16, 17 ];
recordLayoutBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
recordLayoutBrowse.MatlabArgs = { m3iRoot, '%dialog', recordLayoutEdit.Tag };
recordLayoutBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { recordLayoutText, recordLayoutEdit, recordLayoutBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'SwRecordLayoutPackage', m3iModelContext ) );

internalDataConstrText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'Internal DataConstraints Package' );
internalDataConstrText.Type = 'text';
internalDataConstrText.ColSpan = [ 2, columnOffset ];
internalDataConstrText.Visible = xmlOptionsVisible;
internalDataConstrText.Tag = 'internalDataConstrText';

internalDataConstrEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
    'Internal DataConstraints' );
internalDataConstrEdit.HideName = true;
internalDataConstrEdit.Type = 'edit';
internalDataConstrEdit.Tag = 'InternalDataConstrPackage';
internalDataConstrEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'InternalDataConstraintPackage' );
internalDataConstrEdit.ColSpan = [ columnOffset + 1, 15 ];
internalDataConstrEdit.Visible = xmlOptionsVisible;

internalDataConstrBrowse.Type = 'pushbutton';
internalDataConstrBrowse.Tag = 'dataConstrBrowse';
internalDataConstrBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
internalDataConstrBrowse.ColSpan = [ 16, 17 ];
internalDataConstrBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
internalDataConstrBrowse.MatlabArgs = { m3iRoot, '%dialog', internalDataConstrEdit.Tag };
internalDataConstrBrowse.Visible = 0;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { internalDataConstrText, internalDataConstrEdit, internalDataConstrBrowse },  ...
    XmlOptionsAdapter.isVisibleProperty( 'InternalDataConstraintPackage', m3iModelContext ) );

if slfeature( 'AUTOSAREcuExtract' )
    systemPkgText.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
        'System Package' );
    systemPkgText.Type = 'text';
    systemPkgText.ColSpan = [ 2, columnOffset ];
    systemPkgText.Visible = xmlOptionsVisible;
    systemPkgText.Tag = 'systemPkgText';

    systemPkgEdit.Name = DAStudio.message( 'RTW:autosar:uiAdditionalPackageStr',  ...
        'System Package' );
    systemPkgEdit.HideName = true;
    systemPkgEdit.Type = 'edit';
    systemPkgEdit.Tag = 'SystemPackage';
    systemPkgEdit.Value = XmlOptionsAdapter.get( m3iRoot, 'SystemPackage' );
    systemPkgEdit.ColSpan = [ columnOffset + 1, 15 ];
    systemPkgEdit.Visible = xmlOptionsVisible;

    systemPkgBrowse.Type = 'pushbutton';
    systemPkgBrowse.Tag = 'systemPkgBrowse';
    systemPkgBrowse.Name = autosar.ui.metamodel.PackageString.browseLabel;
    systemPkgBrowse.ColSpan = [ 16, 17 ];
    systemPkgBrowse.MatlabMethod = 'autosar.ui.utils.editPackage';
    systemPkgBrowse.MatlabArgs = { m3iRoot, '%dialog', systemPkgEdit.Tag };
    systemPkgBrowse.Visible = 0;

    xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow(  ...
        { systemPkgText, systemPkgEdit, systemPkgBrowse },  ...
        XmlOptionsAdapter.isVisibleProperty( 'SystemPackage', m3iModelContext ) );
end

additionalOptionsLabel.Name = DAStudio.message( 'RTW:autosar:uiAdditionalOptionsLabel' );
additionalOptionsLabel.Type = 'text';
additionalOptionsLabel.Bold = 1;
additionalOptionsLabel.ColSpan = [ 1, 15 ];
additionalOptionsLabel.FontPointSize = 6;
additionalOptionsLabel.Visible = xmlOptionsVisible;
additionalOptionsLabel.Tag = 'additionalOptionsLabel';

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( additionalOptionsLabel,  ...
    true );

implTypeRefText.Name = DAStudio.message( 'RTW:autosar:uiImplTypeRefComboName' );
implTypeRefText.Type = 'text';
implTypeRefText.ColSpan = [ 2, columnOffset ];
implTypeRefText.Visible = xmlOptionsVisible;
implTypeRefText.Tag = 'implTypeRefText';

implTypeRefCombo.Name = DAStudio.message( 'RTW:autosar:uiImplTypeRefComboName' );
implTypeRefCombo.HideName = true;
implTypeRefCombo.Type = 'combobox';
implTypeRefCombo.Tag = 'ImplementationTypeReference';

implTypeRefCombo.Value = XmlOptionsAdapter.get( m3iRoot, 'ImplementationTypeReference' );
implTypeRefCombo.Editable = 0;
implTypeRefCombo.ToolTip = DAStudio.message( 'RTW:autosar:uiImplTypeRefComboNameToolTip' );
implTypeRefCombo.Entries = XmlOptionsAdapter.getEnumPropertyValues( 'ImplementationTypeReference' );
implTypeRefCombo.ColSpan = [ columnOffset + 1, 15 ];
implTypeRefCombo.Visible = xmlOptionsVisible;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { implTypeRefText, implTypeRefCombo },  ...
    XmlOptionsAdapter.isVisibleProperty( 'ImplementationTypeReference', m3iModelContext ) );

swCalibrationAccessText.Name = DAStudio.message( 'RTW:autosar:uiSwCalibrationAccessComboName' );
swCalibrationAccessText.Type = 'text';
swCalibrationAccessText.ColSpan = [ 2, columnOffset ];
swCalibrationAccessText.Visible = xmlOptionsVisible;
swCalibrationAccessText.Tag = 'SwCalibrationAccessText';

swCalibrationAccessCombo.Name = DAStudio.message( 'RTW:autosar:uiSwCalibrationAccessComboName' );
swCalibrationAccessCombo.HideName = true;
swCalibrationAccessCombo.Type = 'combobox';
swCalibrationAccessCombo.Tag = 'SwCalibrationAccessDefault';

swCalibrationAccessCombo.Value = XmlOptionsAdapter.get( m3iRoot, 'SwCalibrationAccessDefault' );
swCalibrationAccessCombo.Editable = 0;
swCalibrationAccessCombo.Entries = XmlOptionsAdapter.getEnumPropertyValues( 'SwCalibrationAccessDefault' );
swCalibrationAccessCombo.ColSpan = [ columnOffset + 1, 15 ];
swCalibrationAccessCombo.Visible = xmlOptionsVisible;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { swCalibrationAccessText, swCalibrationAccessCombo },  ...
    XmlOptionsAdapter.isVisibleProperty( 'SwCalibrationAccessDefault', m3iModelContext ) );

compuDirectionText.Name = DAStudio.message( 'RTW:autosar:uiCompuDirectionComboName' );
compuDirectionText.Type = 'text';
compuDirectionText.ColSpan = [ 2, columnOffset ];
compuDirectionText.Visible = xmlOptionsVisible;
compuDirectionText.Tag = 'compuDirectionText';

compuDirectionCombo.Name = DAStudio.message( 'RTW:autosar:uiCompuDirectionComboName' );
compuDirectionCombo.HideName = true;
compuDirectionCombo.Type = 'combobox';
compuDirectionCombo.Tag = 'CompuMethodDirection';

compuDirectionCombo.Value = XmlOptionsAdapter.get( m3iRoot, 'CompuMethodDirection' );
compuDirectionCombo.Editable = 0;
compuDirectionCombo.Entries = XmlOptionsAdapter.getEnumPropertyValues( 'CompuMethodDirection' );
compuDirectionCombo.ColSpan = [ columnOffset + 1, 15 ];
compuDirectionCombo.Visible = xmlOptionsVisible;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { compuDirectionText, compuDirectionCombo },  ...
    XmlOptionsAdapter.isVisibleProperty( 'CompuMethodDirection', m3iModelContext ) );

internConstrsRefText.Name = DAStudio.message( 'autosarstandard:ui:uiInternalDataConstrComboName' );
internConstrsRefText.Type = 'text';
internConstrsRefText.ColSpan = [ 2, columnOffset ];
internConstrsRefText.Visible = xmlOptionsVisible;
internConstrsRefText.Tag = 'internConstrsRefText';

internConstrsRefCheckBox.HideName = false;
internConstrsRefCheckBox.Type = 'checkbox';
internConstrsRefCheckBox.Tag = 'InternalDataConstraintExport';
internConstrsRefCheckBox.Visible = xmlOptionsVisible;

internConstrsRefCheckBox.Value = XmlOptionsAdapter.get( m3iRoot, 'InternalDataConstraintExport' );
internConstrsRefCheckBox.Editable = 0;
internConstrsRefCheckBox.ToolTip = DAStudio.message( 'autosarstandard:ui:uiInternalDataConstrComboNameToolTip' );
internConstrsRefCheckBox.ColSpan = [ columnOffset + 1, 15 ];
internConstrsRefCheckBox.Visible = xmlOptionsVisible;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { internConstrsRefText, internConstrsRefCheckBox },  ...
    XmlOptionsAdapter.isVisibleProperty( 'InternalDataConstraintExport', m3iModelContext ) );
if slfeature( 'AUTOSARLUTRecordValueSpec' )
    lutApplValueSpecText.Name = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsLUTApplValueSpecCheckBoxName' );
    lutApplValueSpecText.Type = 'text';
    lutApplValueSpecText.ColSpan = [ 2, columnOffset ];
    lutApplValueSpecText.Visible = xmlOptionsVisible;
    lutApplValueSpecText.Tag = 'lutApplValueSpecText';

    lutApplValueSpecCheckBox.HideName = false;
    lutApplValueSpecCheckBox.Type = 'checkbox';
    lutApplValueSpecCheckBox.Tag = 'ExportLookupTableApplicationValueSpecification';
    lutApplValueSpecCheckBox.Visible = xmlOptionsVisible;

    lutApplValueSpecCheckBox.Value = XmlOptionsAdapter.get( m3iRoot, 'ExportLookupTableApplicationValueSpecification' );
    lutApplValueSpecCheckBox.Editable = 0;
    lutApplValueSpecCheckBox.ToolTip = DAStudio.message( 'autosarstandard:ui:uiXmlOptionsLUTApplValueSpecTooltip' );
    lutApplValueSpecCheckBox.ColSpan = [ columnOffset + 1, 15 ];
    lutApplValueSpecCheckBox.Visible = xmlOptionsVisible;

    xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { lutApplValueSpecText, lutApplValueSpecCheckBox },  ...
        XmlOptionsAdapter.isVisibleProperty( 'ExportLookupTableApplicationValueSpecification', m3iModelContext ) );
end

identifyServiceInstanceText.Name = DAStudio.message( 'autosarstandard:ui:uiServiceInstanceIdentifyComboName' );
identifyServiceInstanceText.Type = 'text';
identifyServiceInstanceText.ColSpan = [ 2, columnOffset ];
identifyServiceInstanceText.Visible = xmlOptionsVisible;
identifyServiceInstanceText.Tag = 'identifyServiceInstanceText';

identifyServiceInstanceCombo.Name = DAStudio.message( 'autosarstandard:ui:uiServiceInstanceIdentifyComboName' );
identifyServiceInstanceCombo.HideName = true;
identifyServiceInstanceCombo.Type = 'combobox';
identifyServiceInstanceCombo.Tag = 'IdentifyServiceInstance';

identifyServiceInstanceCombo.Value = XmlOptionsAdapter.get( m3iRoot, 'IdentifyServiceInstance' );
identifyServiceInstanceCombo.Editable = 0;
identifyServiceInstanceCombo.ToolTip = DAStudio.message( 'autosarstandard:ui:uiServiceInstanceIdentifyComboToolTip' );
identifyServiceInstanceCombo.Entries = XmlOptionsAdapter.getEnumPropertyValues( 'IdentifyServiceInstance' );
identifyServiceInstanceCombo.ColSpan = [ columnOffset + 1, 15 ];
identifyServiceInstanceCombo.Visible = xmlOptionsVisible;

xmlOptionRows( end  + 1 ) = autosar.ui.utils.XmlOptionsRow( { identifyServiceInstanceText, identifyServiceInstanceCombo },  ...
    XmlOptionsAdapter.isVisibleProperty( 'IdentifyServiceInstance', m3iModelContext ) );

dlgstruct = assembleDlgStructFromRows( xmlOptionRows, m3iRoot, m3iModelContext );
end

function dlgstruct = assembleDlgStructFromRows( xmlOptionsRows, m3iRoot, m3iModelContext )


if m3iModelContext.isContextMappedToAdaptiveApplication(  )
    helpViewID = 'autosar_config_props_xml_adaptive';
else
    helpViewID = 'autosar_config_props_xml';
end


dlgstruct.DialogTitle = DAStudio.message( 'RTW:autosar:uiXMLOptionsTitle' );
dlgstruct.DialogTag = 'autosar_xmloptions_dialog';
dlgstruct.HelpMethod = 'helpview';
dlgstruct.HelpArgs = { fullfile( docroot, 'autosar', 'helptargets.map' ), helpViewID };
dlgstruct.IsScrollable = 0;
dlgstruct.EmbeddedButtonSet = { 'Help', 'Apply' };
dlgstruct.PreApplyCallback = 'autosar.ui.xmlOptions.XmlOptionsModifier.applyChanges';
dlgstruct.PreApplyArgs = { '%dialog', m3iRoot };
dlgstruct.PreApplyArgsDT = { 'handle', 'handle' };
dlgstruct.Items = {  };



xmlOptionsRows = xmlOptionsRows( [ xmlOptionsRows.IsVisible ] );

numRows = length( xmlOptionsRows );
for rowIdx = 1:numRows
    items = xmlOptionsRows( rowIdx ).Items;


    for itemIdx = 1:length( items )
        items{ itemIdx }.RowSpan = [ rowIdx, rowIdx ];
    end
    dlgstruct.Items = [ dlgstruct.Items, items ];
end


numColumns = 15;
dlgstruct.LayoutGrid = [ numRows + 1, numColumns ];
dlgstruct.RowStretch = zeros( 1, numRows + 1 );
dlgstruct.RowStretch( end  ) = 1;
dlgstruct.ColStretch = zeros( 1, numColumns );
dlgstruct.ColStretch( end  ) = 1;
end


