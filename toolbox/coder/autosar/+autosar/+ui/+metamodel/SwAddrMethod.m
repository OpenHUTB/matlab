





classdef SwAddrMethod<handle
    properties(SetObservable=true)
        M3iObj;
        ModelName;
        SwAddrMethodName;
        CloseListener;
        ProtectedNames;
    end

    methods
        function obj=SwAddrMethod(mObj,modelName,swAddrMethodName,protectedNames)
            obj.M3iObj=mObj;
            obj.ModelName=modelName;
            obj.SwAddrMethodName=swAddrMethodName;
            obj.ProtectedNames=protectedNames;


            modelH=get_param(obj.ModelName,'Handle');
            obj.CloseListener=Simulink.listener(modelH,'CloseEvent',...
            @CloseCB);
        end


        function[isValid,msg]=hApplyCB(obj,dlg)

            maxShortNameLength=get_param(obj.ModelName,'AutosarMaxShortNameLength');
            swAddrMethodNameValue=dlg.getWidgetValue('SwAddrMethodNameEdit');
            msg='';
            isValid=1;

            if ismember(swAddrMethodNameValue,obj.ProtectedNames)
                isValid=0;
                msg=DAStudio.message('RTW:autosar:errorDuplicateSwAddrMethod',swAddrMethodNameValue);
                return;
            end

            idcheckmessage=autosar.ui.utils.isValidARIdentifier({swAddrMethodNameValue},...
            'shortName',maxShortNameLength);
            if~isempty(idcheckmessage)
                isValid=0;
                msg=idcheckmessage;
                return;
            end
            modelM3I=obj.M3iObj.ParentM3I.M3iObject;
            assert(modelM3I.RootPackage.size==1);
            arRoot=modelM3I.RootPackage.front();
            sectionTypeValue=dlg.getWidgetValue('SectionTypeCombo');
            packageValue=dlg.getWidgetValue('PackageEdit');
            if isempty(packageValue)
                packageValue=[arRoot.DataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.SwAddressMethods];
            end
            idcheckmessage=autosar.ui.utils.isValidARIdentifier({packageValue},'absPath',maxShortNameLength);
            if~isempty(idcheckmessage)
                isValid=0;
                msg=idcheckmessage;
                return;
            end


            t=M3I.Transaction(modelM3I);
            m3iSwAddrMethod=Simulink.metamodel.arplatform.common.SwAddrMethod(modelM3I);
            m3iSwAddrMethod.Name=swAddrMethodNameValue;

            switch sectionTypeValue
            case 0
                m3iSwAddrMethod.SectionType=Simulink.metamodel.arplatform.behavior.SectionTypeKind.CalibrationVariables;
            case 1
                m3iSwAddrMethod.SectionType=Simulink.metamodel.arplatform.behavior.SectionTypeKind.Calprm;
            case 2
                m3iSwAddrMethod.SectionType=Simulink.metamodel.arplatform.behavior.SectionTypeKind.Code;
            case 3
                m3iSwAddrMethod.SectionType=Simulink.metamodel.arplatform.behavior.SectionTypeKind.ConfigData;
            case 4
                m3iSwAddrMethod.SectionType=Simulink.metamodel.arplatform.behavior.SectionTypeKind.Const;
            case 5
                m3iSwAddrMethod.SectionType=Simulink.metamodel.arplatform.behavior.SectionTypeKind.ExcludeFromFlash;
            case 6
                m3iSwAddrMethod.SectionType=Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var;
            otherwise
                assert(false,'Unexpected SectionType!');
            end

            m3iSwAddrMethod.MemoryAllocationKeywordPolicy=autosar.ui.metamodel.PackageString.DefaultMemoryAllocationKeywordPolicy;

            m3iSwAddrMethodPkg=autosar.mm.Model.getOrAddARPackage(modelM3I,...
            packageValue);
            m3iSwAddrMethodPkg.packagedElement.append(m3iSwAddrMethod);
            t.commit();
        end


        function dlg=getDialogSchema(obj)

            rowOffset=1;
            columnOffset=2;
            columnCount=15;
            SwAddrMethodNameLabel.Type='text';
            SwAddrMethodNameLabel.Name=[autosar.ui.metamodel.PackageString.Name,':'];
            SwAddrMethodNameLabel.Tag='SwAddrMethodNameLabel';
            SwAddrMethodNameLabel.RowSpan=[rowOffset,rowOffset];
            SwAddrMethodNameLabel.ColSpan=[2,columnOffset];

            SwAddrMethodNameEdit.Type='edit';
            SwAddrMethodNameEdit.Tag='SwAddrMethodNameEdit';
            SwAddrMethodNameEdit.Value=obj.SwAddrMethodName;
            SwAddrMethodNameEdit.RowSpan=[rowOffset,rowOffset];
            SwAddrMethodNameEdit.ColSpan=[columnOffset+1,columnCount];

            rowOffset=rowOffset+1;
            SectionTypeLabel.Type='text';
            SectionTypeLabel.Name=[autosar.ui.metamodel.PackageString.SectionType,':'];
            SectionTypeLabel.Tag='SectionTypeLabel';
            SectionTypeLabel.RowSpan=[rowOffset,rowOffset];
            SectionTypeLabel.ColSpan=[2,columnOffset];

            swAddrMethodMetaClass=Simulink.metamodel.arplatform.common.SwAddrMethod.MetaClass;
            type=swAddrMethodMetaClass.getProperty('SectionType').type;
            sectionTypeValues=cell(type.ownedLiteral.size()-1,0);
            index=1;
            for ii=1:type.ownedLiteral.size()
                sectionTypeValues{index}=type.ownedLiteral.at(ii).name;
                index=index+1;
            end

            SectionTypeCombo.Type='combobox';
            SectionTypeCombo.Tag='SectionTypeCombo';
            SectionTypeCombo.Value=autosar.ui.metamodel.PackageString.DefaultSectionType;
            SectionTypeCombo.Entries=sectionTypeValues;
            SectionTypeCombo.RowSpan=[rowOffset,rowOffset];
            SectionTypeCombo.ColSpan=[columnOffset+1,columnCount];

            rowOffset=rowOffset+1;
            PackageLabel.Type='text';
            PackageLabel.Name=[autosar.ui.metamodel.PackageString.packageLabel];
            PackageLabel.Tag='PackageLabel';
            PackageLabel.RowSpan=[rowOffset,rowOffset];
            PackageLabel.ColSpan=[2,columnOffset];

            arRoot=obj.M3iObj.ParentM3I.M3iObject.RootPackage.front();
            packageValue=...
            autosar.ui.metamodel.SwAddrMethod.getDefaultSwAddrMethodPackage(...
            arRoot);
            PackageEdit.Type='edit';
            PackageEdit.Tag='PackageEdit';
            PackageEdit.Value=packageValue;
            PackageEdit.RowSpan=[rowOffset,rowOffset];
            PackageEdit.ColSpan=[columnOffset+1,columnCount];

            rowOffset=rowOffset+1;
            spacer.Type='text';
            spacer.Name='';
            spacer.Tag='spacer';
            spacer.RowSpan=[rowOffset,rowOffset];
            spacer.ColSpan=[1,columnCount];





            dlg.DialogTitle=DAStudio.message('autosarstandard:ui:uiWizardAddTitle','SwAddrMethod');
            dlg.LayoutGrid=[rowOffset,columnCount];

            dlg.Items={SwAddrMethodNameLabel,SwAddrMethodNameEdit,...
            SectionTypeLabel,SectionTypeCombo,...
            PackageLabel,PackageEdit,...
            spacer};
            dlg.Sticky=true;
            dlg.StandaloneButtonSet={'Help','Cancel','OK'};
            dlg.PreApplyCallback='hApplyCB';
            dlg.PreApplyArgs={obj,'%dialog'};
            dlg.Source=obj;
            dlg.DialogTag='AddSwAddrMethod';
            dlg.HelpMethod='helpview';
            dlg.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_add_swaddrmethod'};
        end
    end

    methods(Static,Access=public)
        function packageValue=getDefaultSwAddrMethodPackage(arRoot)
            packageValue=autosar.mm.util.XmlOptionsAdapter.get(arRoot,'SwAddressMethodPackage');
            if isempty(packageValue)
                packageValue=[arRoot.DataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.SwAddressMethods];
            end
        end
    end
end


function CloseCB(eventSrc,~)
    root=DAStudio.ToolRoot;
    arDialog=root.getOpenDialogs.find('dialogTag','AddSwAddrMethod');
    for i=1:length(arDialog)
        dlgSrc=arDialog.getDialogSource();
        modelH=get_param(dlgSrc.ModelName,'Handle');
        if modelH==eventSrc.Handle
            dlgSrc.delete;
            break;
        end
    end
end


