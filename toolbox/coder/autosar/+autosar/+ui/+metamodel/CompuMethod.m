





classdef CompuMethod<handle
    properties(SetObservable=true)
        M3iObj;
        ModelName;
        CompuMethodName;
        CloseListener;
    end

    methods
        function obj=CompuMethod(mObj,modelName,compuMethodName)
            obj.M3iObj=mObj;
            obj.ModelName=modelName;
            obj.CompuMethodName=compuMethodName;


            modelH=get_param(obj.ModelName,'Handle');
            obj.CloseListener=Simulink.listener(modelH,'CloseEvent',...
            @CloseCB);
        end

        function varType=getPropDataType(~,~)
            varType='ustring';
        end


        function[isValid,msg]=hApplyCB(obj,dlg)

            maxShortNameLength=get_param(obj.ModelName,'AutosarMaxShortNameLength');
            cmNameValue=dlg.getWidgetValue('CompuMethodNameEdit');
            isValid=1;

            msg=autosar.ui.utils.isValidARIdentifier({cmNameValue},'shortName',maxShortNameLength);
            if~isempty(msg)
                isValid=0;
                return;
            end
            modelM3I=obj.M3iObj.ParentM3I.M3iObject;
            assert(modelM3I.RootPackage.size==1);
            arRoot=modelM3I.RootPackage.front();
            categoryValue=dlg.getWidgetValue('CategoryCombo');
            unitValue=dlg.getComboBoxText('UnitCombo');
            displayFormatValue=dlg.getWidgetValue('DisplayFormatEdit');
            packageValue=dlg.getWidgetValue('PackageEdit');
            slTypeValue=dlg.getComboBoxText('SlTypeCombo');
            slTypeValue=autosar.utils.StripPrefix(slTypeValue);
            if isempty(slTypeValue)||strcmp(slTypeValue,DAStudio.message('RTW:autosar:selectERstr'))
                isValid=0;
                msg=DAStudio.message('autosarstandard:ui:selectSlDataTypeForCompuMethod');
                return;
            end
            if isempty(packageValue)
                packageValue=arRoot.DataTypePackage;
            else
                msg=autosar.ui.utils.isValidARIdentifier({packageValue},'absPath',maxShortNameLength);
                if~isempty(msg)
                    isValid=0;
                    return;
                end
            end

            if~isempty(displayFormatValue)
                [isValid,msg]=autosar.validation.AutosarUtils.checkDisplayFormat(displayFormatValue,'CompuMethod');
                if~isValid
                    return;
                end
            end

            t=M3I.Transaction(modelM3I);
            m3iCompuMethod=Simulink.metamodel.types.CompuMethod(modelM3I);
            m3iCompuMethod.Name=cmNameValue;

            switch categoryValue
            case 0
                m3iCompuMethod.Category=Simulink.metamodel.types.CompuMethodCategory.Identical;
            case 1
                m3iCompuMethod.Category=Simulink.metamodel.types.CompuMethodCategory.Linear;
            case 2
                m3iCompuMethod.Category=Simulink.metamodel.types.CompuMethodCategory.TextTable;
            otherwise
                assert(false,'CompuMethod Category not handled!');
            end
            if~isempty(displayFormatValue)
                m3iCompuMethod.DisplayFormat=displayFormatValue;
            end
            if~isempty(unitValue)
                collectedObjects=autosar.ui.utils.collectObject(obj.M3iObj.ParentM3I.M3iObject,...
                autosar.ui.metamodel.PackageString.UnitClass);
                result=arrayfun(@(x)strcmp(x.Name,unitValue),...
                collectedObjects,'uniformoutput',true);
                if any(result)
                    m3iCompuMethod.Unit=collectedObjects(result);
                else
                    unitBuilder=autosar.mm.sl2mm.UnitBuilder(modelM3I,maxShortNameLength);
                    unitBuilder.addDefaultUnit(m3iCompuMethod,unitValue);
                end
            end
            m3iCompuMethodPkg=autosar.mm.Model.getOrAddARPackage(modelM3I,...
            packageValue);
            m3iCompuMethodPkg.packagedElement.append(m3iCompuMethod);
            try
                errorCodes=autosar.mm.util.mapSLDataTypes(obj.ModelName,m3iCompuMethod,{slTypeValue},'',true);
                if numel(errorCodes)>0
                    msg=DAStudio.message(errorCodes{1:numel(errorCodes)});
                    isValid=false;
                    t.cancel();
                else
                    t.commit();
                end
            catch ME
                msg=ME.message;
                isValid=false;
                t.cancel();
            end
        end


        function dlg=getDialogSchema(obj)
            import autosar.mm.util.XmlOptionsAdapter;

            rowOffset=1;
            columnOffset=2;
            columnCount=15;
            CompuMethodNameLabel.Type='text';
            CompuMethodNameLabel.Name=[autosar.ui.metamodel.PackageString.Name,':'];
            CompuMethodNameLabel.Tag='CompuMethodNameLabel';
            CompuMethodNameLabel.RowSpan=[rowOffset,rowOffset];
            CompuMethodNameLabel.ColSpan=[2,columnOffset];

            CompuMethodNameEdit.Type='edit';
            CompuMethodNameEdit.Tag='CompuMethodNameEdit';
            CompuMethodNameEdit.Value=obj.CompuMethodName;
            CompuMethodNameEdit.RowSpan=[rowOffset,rowOffset];
            CompuMethodNameEdit.ColSpan=[columnOffset+1,columnCount];

            rowOffset=rowOffset+1;
            CategoryLabel.Type='text';
            CategoryLabel.Name=[autosar.ui.metamodel.PackageString.Category,':'];
            CategoryLabel.Tag='CategoryLabel';
            CategoryLabel.RowSpan=[rowOffset,rowOffset];
            CategoryLabel.ColSpan=[2,columnOffset];

            cmMetaClass=Simulink.metamodel.types.CompuMethod.MetaClass;
            type=cmMetaClass.getProperty('Category').type;
            cmCategories=cell(type.ownedLiteral.size()-1,0);
            index=1;
            for ii=1:type.ownedLiteral.size()
                if ii==3||ii==5
                    continue;
                end
                cmCategories{index}=type.ownedLiteral.at(ii).name;
                index=index+1;
            end

            CategoryCombo.Type='combobox';
            CategoryCombo.Tag='CategoryCombo';
            CategoryCombo.Value=cmCategories{2};
            CategoryCombo.Entries=cmCategories;
            CategoryCombo.RowSpan=[rowOffset,rowOffset];
            CategoryCombo.ColSpan=[columnOffset+1,columnCount];

            rowOffset=rowOffset+1;
            UnitLabel.Type='text';
            UnitLabel.Name=[autosar.ui.metamodel.PackageString.Unit,':'];
            UnitLabel.Tag='UnitLabel';
            UnitLabel.RowSpan=[rowOffset,rowOffset];
            UnitLabel.ColSpan=[2,columnOffset];

            collectedObjects=autosar.ui.utils.collectObject(obj.M3iObj.ParentM3I.M3iObject,...
            autosar.ui.metamodel.PackageString.UnitClass);
            result=arrayfun(@(x)strcmp(x.Name,autosar.ui.metamodel.PackageString.NoUnit),...
            collectedObjects,'uniformoutput',true);
            if any(result)
                unitNames=cell(length(collectedObjects),0);
            else
                unitNames=cell(length(collectedObjects)+1,0);
                unitNames{1}=autosar.ui.metamodel.PackageString.NoUnit;
            end
            for index=1:length(collectedObjects)
                unitNames{index+1}=collectedObjects(index).Name;
            end
            UnitCombo.Type='combobox';
            UnitCombo.Tag='UnitCombo';
            UnitCombo.Entries=unitNames;
            UnitCombo.Value=autosar.ui.metamodel.PackageString.NoUnit;
            UnitCombo.RowSpan=[rowOffset,rowOffset];
            UnitCombo.ColSpan=[columnOffset+1,columnCount];

            rowOffset=rowOffset+1;
            DisplayFormatLabel.Type='text';
            DisplayFormatLabel.Name=[autosar.ui.metamodel.PackageString.DisplayFormat,':'];
            DisplayFormatLabel.Tag='DisplayFormatLabel';
            DisplayFormatLabel.RowSpan=[rowOffset,rowOffset];
            DisplayFormatLabel.ColSpan=[2,columnOffset];

            DisplayFormatEdit.Type='edit';
            DisplayFormatEdit.Tag='DisplayFormatEdit';
            DisplayFormatEdit.RowSpan=[rowOffset,rowOffset];
            DisplayFormatEdit.ColSpan=[columnOffset+1,columnCount];

            rowOffset=rowOffset+1;
            PackageLabel.Type='text';
            PackageLabel.Name=[autosar.ui.metamodel.PackageString.packageLabel];
            PackageLabel.Tag='PackageLabel';
            PackageLabel.RowSpan=[rowOffset,rowOffset];
            PackageLabel.ColSpan=[2,columnOffset];

            arRoot=obj.M3iObj.ParentM3I.M3iObject.RootPackage.front();
            packageValue=XmlOptionsAdapter.get(arRoot,'CompuMethodPackage');
            if isempty(packageValue)
                packageValue=arRoot.DataTypePackage;
            end
            PackageEdit.Type='edit';
            PackageEdit.Tag='PackageEdit';
            PackageEdit.Value=packageValue;
            PackageEdit.RowSpan=[rowOffset,rowOffset];
            PackageEdit.ColSpan=[columnOffset+1,columnCount];

            rowOffset=rowOffset+1;
            SlTypeLabel.Type='text';
            SlTypeLabel.Name=[autosar.ui.metamodel.PackageString.SLTypes,':'];
            SlTypeLabel.Tag='SlTypeLabel';
            SlTypeLabel.RowSpan=[rowOffset,rowOffset];
            SlTypeLabel.ColSpan=[2,columnOffset];

            vars=evalinGlobalScope(obj.ModelName,'whos');
            slTypes={DAStudio.message('RTW:autosar:selectERstr')};
            for ii=1:numel(vars)
                if autosar.ui.metamodel.SimulinkDataType.isAllowedSlTypeName(...
                    obj.ModelName,vars(ii).name)
                    slTypes=[slTypes,vars(ii).name];%#ok<AGROW>
                end
            end
            slTypes=[slTypes,'Enum:'];
            SlTypeCombo.Type='combobox';
            SlTypeCombo.Tag='SlTypeCombo';
            SlTypeCombo.Editable=true;
            SlTypeCombo.Value=slTypes{1};
            SlTypeCombo.Entries=slTypes;
            SlTypeCombo.RowSpan=[rowOffset,rowOffset];
            SlTypeCombo.ColSpan=[columnOffset+1,columnCount];

            rowOffset=rowOffset+1;
            spacer.Type='text';
            spacer.Name='';
            spacer.Tag='spacer';
            spacer.RowSpan=[rowOffset,rowOffset];
            spacer.ColSpan=[1,columnCount];





            dlg.DialogTitle=DAStudio.message('autosarstandard:ui:uiWizardAddTitle','CompuMethod');
            dlg.LayoutGrid=[rowOffset,columnCount];

            dlg.Items={CompuMethodNameLabel,CompuMethodNameEdit,...
            CategoryLabel,CategoryCombo,...
            UnitLabel,UnitCombo,...
            DisplayFormatLabel,DisplayFormatEdit,...
            PackageLabel,PackageEdit,...
            SlTypeLabel,SlTypeCombo,...
            spacer};
            dlg.Sticky=true;
            dlg.StandaloneButtonSet={'Help','Cancel','OK'};
            dlg.PreApplyCallback='hApplyCB';
            dlg.PreApplyArgs={obj,'%dialog'};
            dlg.Source=obj;
            dlg.DialogTag='AddCompuMethod';
            dlg.HelpMethod='helpview';
            dlg.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_add_compumethod'};
        end
    end
end


function CloseCB(eventSrc,~)
    root=DAStudio.ToolRoot;
    arDialog=root.getOpenDialogs.find('dialogTag','AddCompuMethod');
    for i=1:length(arDialog)
        dlgSrc=arDialog.getDialogSource();
        modelH=get_param(dlgSrc.ModelName,'Handle');
        if modelH==eventSrc.Handle
            dlgSrc.delete;
            break;
        end
    end
end



