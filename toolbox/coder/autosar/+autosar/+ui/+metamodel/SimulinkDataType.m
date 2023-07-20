




classdef SimulinkDataType<handle
    properties(SetObservable=true)
        ParentDlg;
        M3iObj;
        ModelName;
        CloseListener;
    end

    methods
        function obj=SimulinkDataType(parentDlg,mObj,modelName)
            obj.ParentDlg=parentDlg;
            obj.M3iObj=mObj;
            obj.ModelName=modelName;

            modelH=get_param(obj.ModelName,'Handle');
            obj.CloseListener=Simulink.listener(modelH,'CloseEvent',...
            @CloseCB);
        end

        function varType=getPropDataType(~,~)
            varType='ustring';
        end


        function[isValid,msg]=hApplyCB(obj,dlg)
            isValid=true;
            msg='';
            slTypeValue=dlg.getWidgetValue('SimulinkDataTypeCombo');
            slTypeValue=autosar.utils.StripPrefix(slTypeValue);
            if isempty(slTypeValue)||strcmp(slTypeValue,DAStudio.message('RTW:autosar:selectERstr'))
                isValid=false;
                msg=DAStudio.message('autosarstandard:ui:selectSlDataTypeForCompuMethod');
                return;
            end
            try
                errorCodes=autosar.mm.util.mapSLDataTypes(obj.ModelName,obj.M3iObj,{slTypeValue},'',true);
                if numel(errorCodes)>0
                    msg=DAStudio.message(errorCodes{1:numel(errorCodes)});
                    isValid=false;
                else
                    obj.ParentDlg.refresh();
                end
            catch ME
                msg=ME.message;
                isValid=false;
            end
        end

        function dlg=getDialogSchema(obj)
            import autosar.mm.util.ExternalToolInfoAdapter;

            rowOffset=1;
            columnCount=15;
            rowOffset=rowOffset+1;

            vars=evalinGlobalScope(obj.ModelName,'whos');
            slTypes={DAStudio.message('RTW:autosar:selectERstr')};
            setSlDataTypes=ExternalToolInfoAdapter.get(obj.M3iObj,...
            autosar.ui.metamodel.PackageString.SlDataTypes);

            for ii=1:numel(vars)
                if~any(strcmp(setSlDataTypes,vars(ii).name))...
                    &&obj.isAllowedSlTypeName(obj.ModelName,vars(ii).name)
                    slTypes=[slTypes,vars(ii).name];%#ok<AGROW>
                end
            end
            slTypes=[slTypes,'Enum:'];

            SimulinkDataTypeCombo.Type='combobox';
            SimulinkDataTypeCombo.Name=[autosar.ui.metamodel.PackageString.SLTypes,':'];
            SimulinkDataTypeCombo.Tag='SimulinkDataTypeCombo';
            SimulinkDataTypeCombo.Editable=true;
            SimulinkDataTypeCombo.Value=slTypes{1};
            SimulinkDataTypeCombo.Entries=slTypes;
            SimulinkDataTypeCombo.RowSpan=[rowOffset,rowOffset];
            SimulinkDataTypeCombo.ColSpan=[2,columnCount];

            rowOffset=rowOffset+1;

            spacer.Type='text';
            spacer.Name='';
            spacer.Tag='spacer';
            spacer.RowSpan=[rowOffset,rowOffset];
            spacer.ColSpan=[1,columnCount];




            if isa(obj.M3iObj,autosar.ui.metamodel.PackageString.CompuMethodClass)
                objectCategory=autosar.ui.metamodel.PackageString.CompuMethod;
            elseif isa(obj.M3iObj,autosar.ui.metamodel.PackageString.ValueTypeClass)
                objectCategory=autosar.ui.metamodel.PackageString.ImplementationDataType;
            end

            dlg.DialogTitle=DAStudio.message('autosarstandard:ui:setSlDataTypeForCompuMethod',objectCategory);
            dlg.LayoutGrid=[rowOffset,columnCount];

            dlg.Items={SimulinkDataTypeCombo,spacer};

            dlg.Sticky=true;
            dlg.StandaloneButtonSet={'Help','Cancel','OK'};
            dlg.PreApplyCallback='hApplyCB';
            dlg.PreApplyArgs={obj,'%dialog'};
            dlg.Source=obj;
            dlg.DialogTag='MapDataType';
            dlg.HelpMethod='helpview';
            dlg.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_add_compumethod'};
        end
    end
    methods(Static=true,Access='public')
        function isAllowed=isAllowedSlTypeName(modelName,slTypeName)
            slTypeName=autosar.utils.StripPrefix(slTypeName);
            isAllowed=false;
            mprops=meta.class.fromName(slTypeName);
            if~isempty(mprops)&&coder.internal.isSupportedEnumClass(mprops)
                isAllowed=true;
            else
                dtInfo=SimulinkFixedPoint.DTContainerInfo(slTypeName,get_param(modelName,'Object'));
                if dtInfo.isAlias
                    isAllowed=true;
                elseif dtInfo.isEnum
                    typeName=autosar.utils.StripPrefix(dtInfo.evaluatedDTString);
                    isAllowed=autosar.ui.metamodel.SimulinkDataType.isAllowedSlTypeName(modelName,typeName);
                elseif~isempty(dtInfo.evaluatedNumericType)
                    isAllowed=dtInfo.evaluatedNumericType.IsAlias;
                end
            end
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


