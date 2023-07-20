classdef XmlOptionsGetter<handle





    properties(Access=private)
        SchemaVersion;
        AppDataTypePackage;
        PlatformDataTypePackage;
        UsePlatformTypeReferences;
        NativeDeclaration;
        MDGPackage;
        DataConstraintPackage;
        InternalDataConstraintPackage;
        InternalDataConstraintExport;
        SwBaseTypePackage;
        ConstantSpecificationPackage;
        SystemConstantPackage;
        SwAddressMethodPackage;
        CompuMethodPackage;
        UnitPackage;
        SwRecordLayoutPackage;
        ComponentPackage;
        ImpDataTypePkgs;
        IfPkgList;
        TimingPackage;
        SystemPackage;
    end

    methods
        function this=XmlOptionsGetter(m3iModel)


            impDataTypePkgs={};
            appDataTypePkgs={};
            interConstrPkgs={};
            physConstrPkgs={};

            primTypeObjs=autosar.mm.Model.findChildByTypeName(...
            m3iModel,'Simulink.metamodel.types.PrimitiveType',true,true);
            structTypeObjs=autosar.mm.Model.findChildByTypeName(...
            m3iModel,'Simulink.metamodel.types.Structure',true,true);
            matrixTypeObjs=autosar.mm.Model.findChildByTypeName(...
            m3iModel,'Simulink.metamodel.types.Matrix',true,true);
            lutObjs=autosar.mm.Model.findChildByTypeName(...
            m3iModel,'Simulink.metamodel.types.LookupTableType',true,true);
            sharedAxisObjs=autosar.mm.Model.findChildByTypeName(...
            m3iModel,'Simulink.metamodel.types.SharedAxisType',true,true);

            for ii=1:length(primTypeObjs)
                if isa(primTypeObjs{ii}.containerM3I,'Simulink.metamodel.types.LookupTableType')...
                    ||isa(primTypeObjs{ii}.containerM3I,'Simulink.metamodel.types.Axis')

                    continue;
                end
                objPkgPath=getContainerPkgPath(primTypeObjs{ii});
                if primTypeObjs{ii}.IsApplication==false
                    impDataTypePkgs=[impDataTypePkgs,objPkgPath];%#ok<AGROW>

                    if~isempty(primTypeObjs{ii}.DataConstr)
                        interConstrPkgs=[interConstrPkgs,getContainerPkgPath(primTypeObjs{ii}.DataConstr)];%#ok<AGROW>
                    end
                else
                    appDataTypePkgs=[appDataTypePkgs,objPkgPath];%#ok<AGROW>
                    if~isempty(primTypeObjs{ii}.DataConstr)
                        physConstrPkgs=[physConstrPkgs,getContainerPkgPath(primTypeObjs{ii}.DataConstr)];%#ok<AGROW>
                    end
                end
            end

            for ii=1:length(structTypeObjs)
                objPkgPath=getContainerPkgPath(structTypeObjs{ii});
                if structTypeObjs{ii}.IsApplication==false
                    impDataTypePkgs=[impDataTypePkgs,objPkgPath];%#ok<AGROW>
                else
                    appDataTypePkgs=[appDataTypePkgs,objPkgPath];%#ok<AGROW>
                end
            end

            for ii=1:length(matrixTypeObjs)
                objPkgPath=getContainerPkgPath(matrixTypeObjs{ii});
                if matrixTypeObjs{ii}.IsApplication==false
                    impDataTypePkgs=[impDataTypePkgs,objPkgPath];%#ok<AGROW>
                else
                    appDataTypePkgs=[appDataTypePkgs,objPkgPath];%#ok<AGROW>
                end
            end
            this.ImpDataTypePkgs=impDataTypePkgs;

            for ii=1:length(lutObjs)
                appDataTypePkgs=[appDataTypePkgs,getContainerPkgPath(lutObjs{ii})];%#ok<AGROW>
            end

            for ii=1:length(sharedAxisObjs)
                appDataTypePkgs=[appDataTypePkgs,getContainerPkgPath(sharedAxisObjs{ii})];%#ok<AGROW>
            end



            this.SchemaVersion=arxml.getDefaultSchemaVersion();

            if isempty(appDataTypePkgs)
                this.AppDataTypePackage='';
            else
                this.AppDataTypePackage=autosar.ui.utils.mostFrequentString(appDataTypePkgs);
            end

            this.MDGPackage=getXMLOptionPackageByClass(m3iModel,...
            'Simulink.metamodel.arplatform.common.ModeDeclarationGroup');

            if isempty(physConstrPkgs)
                this.DataConstraintPackage='';
            else
                this.DataConstraintPackage=autosar.ui.utils.mostFrequentString(physConstrPkgs);
            end
            if isempty(interConstrPkgs)
                this.InternalDataConstraintPackage='';
                this.InternalDataConstraintExport=false;
            else
                this.InternalDataConstraintPackage=autosar.ui.utils.mostFrequentString(interConstrPkgs);
                this.InternalDataConstraintExport=true;
            end

            [this.UsePlatformTypeReferences,this.NativeDeclaration,this.PlatformDataTypePackage]=...
            autosar.mm.util.XMLOptionsPlatformTypesUtils.inferImportedDefaults(m3iModel);

            this.SwBaseTypePackage=getXMLOptionPackageByClass(m3iModel,...
            'Simulink.metamodel.types.SwBaseType');
            this.ConstantSpecificationPackage=getXMLOptionPackageByClass(m3iModel,...
            'Simulink.metamodel.types.ConstantSpecification');
            this.SystemConstantPackage=getXMLOptionPackageByClass(m3iModel,...
            'Simulink.metamodel.arplatform.variant.SystemConst');
            this.SwAddressMethodPackage=getXMLOptionPackageByClass(m3iModel,...
            'Simulink.metamodel.arplatform.common.SwAddrMethod');
            this.CompuMethodPackage=getXMLOptionPackageByClass(m3iModel,...
            'Simulink.metamodel.types.CompuMethod');
            this.UnitPackage=getXMLOptionPackageByClass(m3iModel,...
            'Simulink.metamodel.types.Unit');
            this.SwRecordLayoutPackage=getXMLOptionPackageByClass(m3iModel,...
            'Simulink.metamodel.types.SwRecordLayout');
            this.ComponentPackage=getXMLOptionPackageByClass(m3iModel,...
            'Simulink.metamodel.arplatform.component.Component');
            this.TimingPackage=getXMLOptionPackageByClass(m3iModel,...
            'Simulink.metamodel.arplatform.timingExtension.TimingExtension');
            this.SystemPackage=getXMLOptionPackageByClass(m3iModel,...
            'Simulink.metamodel.arplatform.system.System');

            this.IfPkgList=getPkgListByClass(m3iModel,...
            'Simulink.metamodel.arplatform.interface.PortInterface');

        end

        function xmlOpts=getXmlOpts(this,m3iComp,maxShortNameLength)



            compXmlOpts=this.getComponentDependentOpts(m3iComp,maxShortNameLength);


            xmlOpts=struct(...
            'ImplementationTypeReference',compXmlOpts.ImplementationTypeReference,...
            'InternalBehaviorQualifiedName',compXmlOpts.InternalBehaviorQualifiedName,...
            'ImplementationQualifiedName',compXmlOpts.ImplementationQualifiedName,...
            'InterfacePackage',compXmlOpts.InterfacePackage,...
            'DataTypePackage',compXmlOpts.DataTypePackage,...
            'DataTypeMappingPackage',compXmlOpts.DataTypeMappingPackage,...
            'SchemaVersion',this.SchemaVersion,...
            'AppDataTypePackage',this.AppDataTypePackage,...
            'PlatformDataTypePackage',this.PlatformDataTypePackage,...
            'UsePlatformTypeReferences',this.UsePlatformTypeReferences,...
            'NativeDeclaration',this.NativeDeclaration,...
            'MDGPackage',this.MDGPackage,...
            'DataConstraintPackage',this.DataConstraintPackage,...
            'InternalDataConstraintPackage',this.InternalDataConstraintPackage,...
            'InternalDataConstraintExport',this.InternalDataConstraintExport,...
            'SwBaseTypePackage',this.SwBaseTypePackage,...
            'ConstantSpecificationPackage',this.ConstantSpecificationPackage,...
            'SystemConstantPackage',this.SystemConstantPackage,...
            'SwAddressMethodPackage',this.SwAddressMethodPackage,...
            'CompuMethodPackage',this.CompuMethodPackage,...
            'UnitPackage',this.UnitPackage,...
            'SwRecordLayoutPackage',this.SwRecordLayoutPackage,...
            'ComponentPackage',this.ComponentPackage,...
            'TimingPackage',this.TimingPackage,...
            'SystemPackage',this.SystemPackage,...
            'ExportLookupTableApplicationValueSpecification',...
            compXmlOpts.ExportLookupTableApplicationValueSpecification...
            );
        end
    end

    methods(Access=private)


        function compXmlOpts=getComponentDependentOpts(this,m3iComp,maxShortNameLength)
            compXmlOpts=struct(...
            'ImplementationTypeReference','',...
            'InternalBehaviorQualifiedName','',...
            'ImplementationQualifiedName','',...
            'InterfacePackage','',...
            'DataTypePackage','',...
            'DataTypeMappingPackage',''...
            );


            defaultPkg=i_get_default_root_package(m3iComp,maxShortNameLength);


            compName=m3iComp.Name;
            if isempty(m3iComp.containerM3I)
                compPackage=defaultPkg;
            else
                compPackage=getContainerPkgPath(m3iComp);
            end

            dtMapPkgList={};
            isComposition=autosar.composition.Utils.isM3IComposition(m3iComp);
            if~isComposition&&...
                ~isempty(m3iComp.Behavior)&&m3iComp.Behavior.isvalid()
                if m3iComp.Behavior.DataTypeMapping.size>0
                    for dtsetIdx=1:m3iComp.Behavior.DataTypeMapping.size
                        dtSet=m3iComp.Behavior.DataTypeMapping.at(dtsetIdx);
                        dtMapPkgPath=getContainerPkgPath(dtSet);
                        dtMapPkgList=[dtMapPkgList,{dtMapPkgPath}];%#ok<AGROW>
                    end
                end
            end

            if isempty(dtMapPkgList)
                compXmlOpts.DataTypeMappingPackage='';
            else
                compXmlOpts.DataTypeMappingPackage=autosar.ui.utils.mostFrequentString(dtMapPkgList);
            end


            if isComposition

                ibQName='';
            else
                ibQName=autosar.mm.Model.getExtraInternalBehaviorInfo(m3iComp.Behavior).qName;
                if isempty(ibQName)
                    ibQName=autosar.mm.util.XmlOptionsAdapter.get(m3iComp,'InternalBehaviorQualifiedName');
                    if~isempty(ibQName)
                        ibQName=[fileparts(ibQName),'/',m3iComp.Behavior.Name];
                    else
                        ibQName=[compPackage,'/ib/',m3iComp.Behavior.Name];
                    end
                end
            end

            compXmlOpts.ImplementationTypeReference='Allowed';
            if~isComposition
                if isImplementationDataTypeReferenceAllowed(m3iComp)
                    compXmlOpts.ImplementationTypeReference='Allowed';
                else
                    compXmlOpts.ImplementationTypeReference='NotAllowed';
                end
            end

            if~isComposition
                compXmlOpts.InternalBehaviorQualifiedName=ibQName;
                compXmlOpts.ImplementationQualifiedName=[compPackage,'/',...
                arxml.arxml_private('p_create_aridentifier',[compName,'_imp'],maxShortNameLength)];
            end

            if isempty(this.IfPkgList)
                ifPkgName=[defaultPkg,'/',...
                arxml.arxml_private('p_create_aridentifier',[compName,'_if'],maxShortNameLength)];
            else
                ifPkgName=autosar.ui.utils.mostFrequentString(this.IfPkgList);
            end
            compXmlOpts.InterfacePackage=ifPkgName;

            if isempty(this.ImpDataTypePkgs)
                compXmlOpts.DataTypePackage=...
                [compPackage,'/',arxml.arxml_private('p_create_aridentifier',[compName,'_dt'],maxShortNameLength)];
            else
                compXmlOpts.DataTypePackage=autosar.ui.utils.mostFrequentString(this.ImpDataTypePkgs);
            end

            compXmlOpts.ExportLookupTableApplicationValueSpecification=true;
            if~isComposition&&...
                ~autosar.mm.util.XMLOptionsLookupTableUtils.canExportLUTApplicationValueSpecification(m3iComp)
                compXmlOpts.ExportLookupTableApplicationValueSpecification=false;
            end

        end
    end
end

function objPkgList=getPkgListByClass(modelM3I,className)
    objs=autosar.mm.Model.findChildByTypeName(...
    modelM3I,className,true,true);
    objPkgList=cell(1,length(objs));
    for ii=1:length(objs)
        objPkgPath=getContainerPkgPath(objs{ii});
        objPkgList{ii}=objPkgPath;
    end
end
function pkg=getXMLOptionPackageByClass(modelM3I,className)
    objPkgList=getPkgListByClass(modelM3I,className);
    if isempty(objPkgList)
        pkg='';
    else
        pkg=autosar.ui.utils.mostFrequentString(objPkgList);
    end
end

function val=isImplementationDataTypeReferenceAllowed(m3iComp)
    val=false;

    if isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')

        IterateAdaptivePortTypes(m3iComp.RequiredPorts);
        if val==true
            return;
        end
        IterateAdaptivePortTypes(m3iComp.ProvidedPorts);
        if val==true
            return;
        end
    else
        IterateDataElementTypes(m3iComp.ReceiverPorts);
        if val==true
            return;
        end
        IterateDataElementTypes(m3iComp.SenderPorts);
        if val==true
            return;
        end
        IterateDataElementTypes(m3iComp.SenderReceiverPorts);
        if val==true
            return;
        end
        IterateDataElementTypes(m3iComp.NvReceiverPorts);
        if val==true
            return;
        end
        IterateDataElementTypes(m3iComp.NvSenderPorts);
        if val==true
            return;
        end
        IterateDataElementTypes(m3iComp.NvSenderReceiverPorts);
        if val==true
            return;
        end
        IterateArgumentTypes(m3iComp.ServerPorts)
        if val==true
            return;
        end
        IterateArgumentTypes(m3iComp.ClientPorts)
        if val==true
            return;
        end
        behavior=m3iComp.Behavior;
        for ii=1:behavior.Parameters.size()
            refType=behavior.Parameters.at(ii).Type;
            if~isempty(refType)
                if~refType.IsApplication
                    val=true;
                    return;
                end
            end
        end
        for ii=1:behavior.ArTypedPIM.size()
            refType=behavior.ArTypedPIM.at(ii).Type;
            if~isempty(refType)
                if~refType.IsApplication
                    val=true;
                    return;
                end
            end
        end
        for ii=1:behavior.StaticMemory.size()
            refType=behavior.StaticMemory.at(ii).Type;
            if~isempty(refType)
                if~refType.IsApplication
                    val=true;
                    return;
                end
            end
        end
        for ii=1:behavior.IRV.size()
            refType=behavior.IRV.at(ii).Type;
            if~isempty(refType)
                if~refType.IsApplication
                    val=true;
                    return;
                end
            end
        end
    end
    function IterateDataElementTypes(ports)
        for i=1:ports.size()
            port=ports.at(i);
            for j=1:port.Interface.DataElements.size()
                refType=port.Interface.DataElements.at(j).Type;
                if~isempty(refType)
                    if~refType.IsApplication
                        val=true;
                        return;
                    end
                end
            end
        end
    end
    function IterateArgumentTypes(ports)
        for i=1:ports.size()
            clientPort=ports.at(i);
            for j=1:clientPort.Interface.Operations.size()
                operation=clientPort.Interface.Operations.at(j);
                for k=1:operation.Arguments.size()
                    refType=operation.Arguments.at(k).Type;
                    if~isempty(refType)
                        if~refType.IsApplication
                            val=true;
                            return;
                        end
                    end
                end
            end
        end
    end
    function IterateAdaptivePortTypes(ports)

        for i=1:ports.size()
            port=ports.at(i);
            for j=1:port.Interface.Methods.size()
                method=port.Interface.Methods.at(j);
                for k=1:method.Arguments.size()
                    refType=method.Arguments.at(k).Type;
                    if~isempty(refType)
                        if~refType.IsApplication
                            val=true;
                            return;
                        end
                    end
                end
            end
            for j=1:port.Interface.Events.size()
                refType=port.Interface.Events.at(j).Type;
                if~isempty(refType)
                    if~refType.IsApplication
                        val=true;
                        return;
                    end
                end
            end
            for j=1:port.Interface.Fields.size()
                refType=port.Interface.Fields.at(j).Type;
                if~isempty(refType)
                    if~refType.IsApplication
                        val=true;
                        return;
                    end
                end
            end
        end
    end
end

function defaultRootPackage=i_get_default_root_package(m3iComp,maxShortNameLength)

    pkgNames=arxml.splitAbsolutePath(getContainerPkgPath(m3iComp));

    defaultRootPackage='';
    for ii=1:length(pkgNames)-1
        defaultRootPackage=[defaultRootPackage,'/',pkgNames{ii}];%#ok
    end

    if isempty(defaultRootPackage)
        defaultRootPackage=['/',...
        arxml.arxml_private('p_create_aridentifier',[m3iComp.Name,'_pkg'],maxShortNameLength)];
    end
end

function pkgPath=getContainerPkgPath(pkgElement)
    if pkgElement.isvalid()
        pkgPath=autosar.api.Utils.getQualifiedName(pkgElement.containerM3I);
    else
        pkgPath='';
    end
end




