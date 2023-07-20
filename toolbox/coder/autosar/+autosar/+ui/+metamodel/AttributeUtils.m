classdef(Hidden)AttributeUtils





    methods(Access=public,Static)
        function propValue=getPropValue(m3iObject,propName)
            propValue='';
            if m3iObject.isvalid()
                if m3iObject.has(propName)
                    propValue=autosar.ui.metamodel.AttributeUtils.transformPropValue(m3iObject,propName);
                elseif strcmp(propName,autosar.ui.metamodel.PackageString.Unit)
                    propValue=autosar.ui.metamodel.PackageString.NoUnit;
                elseif strcmp(propName,autosar.ui.metamodel.PackageString.SwAddrMethod)
                    propValue=DAStudio.message('RTW:autosar:uiUnselectOptions');
                end
            end
        end

        function propValue=getPropAllowedValues(m3iObject,propName)
            propValue={};
            if m3iObject.has(propName)
                prop=m3iObject.getMetaClass().getProperty(propName);
                if strcmp(prop.type.qualifiedName,'Simulink.metamodel.arplatform.component.AtomicComponentKind')
                    propValue=autosar.composition.Utils.getSupportedComponentKinds();
                elseif isa(prop.type,...
                    autosar.ui.metamodel.PackageString.M3IImmutableEnumeration)
                    enums=prop.type.ownedLiteral;
                    propValue=cell(enums.size,0);
                    for i=1:enums.size
                        propValue(i)={enums.at(i).name};
                    end
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.M3IBoolean)
                    propValue={autosar.ui.metamodel.PackageString.True,...
                    autosar.ui.metamodel.PackageString.False};
                elseif any(strcmp(prop.type.qualifiedName,autosar.ui.metamodel.PackageString.InterfacesCell(1:end)))||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.UnitClass)
                    collectedObjects=autosar.ui.utils.collectObject(m3iObject.modelM3I,...
                    prop.type.qualifiedName);
                    propValue=cell(length(collectedObjects),0);
                    for index=1:length(collectedObjects)
                        propValue(index)={collectedObjects(index).Name};
                    end
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.ModeDeclarationClass)
                    propValue=cell(m3iObject.Mode.size(),0);
                    for index=1:m3iObject.Mode.size()
                        propValue(index)={m3iObject.Mode.at(index).Name};
                    end
                elseif strcmp(propName,autosar.ui.metamodel.PackageString.SwAddrMethod)
                    propValue{1}=autosar.ui.metamodel.PackageString.NoneSelection;
                    swAddrMethodCategory=...
                    autosar.mm.util.SwAddrMethodHelper.getSwAddrMethodCategoryFromM3IObject(m3iObject);
                    propValue=[propValue,...
                    autosar.mm.util.SwAddrMethodHelper.findSwAddrMethodsForCategory(...
                    m3iObject.modelM3I,swAddrMethodCategory)];
                end
            elseif strcmp(propName,autosar.ui.metamodel.PackageString.Unit)
                prop=m3iObject.getMetaClass().getProperty(propName);
                collectedObjects=autosar.ui.utils.collectObject(m3iObject.modelM3I,...
                prop.type.qualifiedName);
                result=arrayfun(@(x)strcmp(x.Name,autosar.ui.metamodel.PackageString.NoUnit),...
                collectedObjects,'uniformoutput',true);
                if any(result)
                    propValue=cell(numel(collectedObjects),0);
                    for index=1:numel(collectedObjects)
                        propValue{index}=collectedObjects(index).Name;
                    end
                else
                    propValue=cell(numel(collectedObjects)+1,0);
                    propValue{1}=autosar.ui.metamodel.PackageString.NoUnit;
                    for index=1:numel(collectedObjects)
                        propValue{index+1}=collectedObjects(index).Name;
                    end
                end
            elseif strcmp(propName,autosar.ui.metamodel.PackageString.SwAddrMethod)
                propValue{1}=autosar.ui.metamodel.PackageString.NoneSelection;
                swAddrMethodCategory=...
                autosar.mm.util.SwAddrMethodHelper.getSwAddrMethodCategoryFromM3IObject(m3iObject);
                propValue=[propValue,...
                autosar.mm.util.SwAddrMethodHelper.findSwAddrMethodsForCategory(...
                m3iObject.modelM3I,swAddrMethodCategory)];
            end
        end

        function propValue=getPropDataType(m3iObject,propName)
            propValue='edit';
            if m3iObject.has(propName)
                prop=m3iObject.getMetaClass().getProperty(propName);
                if isa(prop.type,...
                    autosar.ui.metamodel.PackageString.M3IImmutableEnumeration)
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.M3IBoolean)
                    propValue='enum';
                elseif any(strcmp(prop.type.qualifiedName,autosar.ui.metamodel.PackageString.InterfacesCell(1:end)))
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.ModeDeclarationClass)
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.UnitClass)
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.SwAddrMethodClass)
                    propValue='enum';
                end
            elseif any(strcmp(propName,{autosar.ui.metamodel.PackageString.Unit,...
                autosar.ui.metamodel.PackageString.SwAddrMethod}))
                propValue='enum';
            end
        end

        function isValid=isValidNameValue(m3iObject,propName,propValue)
            if isempty(propValue)
                isValid=any(strcmp(propName,...
                {autosar.ui.metamodel.PackageString.DisplayFormat,...
                autosar.ui.metamodel.PackageString.majorVersionNode,...
                autosar.ui.metamodel.PackageString.minorVersionNode}));
                return;
            end



            if strcmp(propValue,autosar.ui.metamodel.PackageString.NoUnit)&&...
                strcmp(propName,autosar.ui.metamodel.PackageString.Unit)
                isValid=true;
            elseif strcmp(propValue,autosar.ui.metamodel.PackageString.NoneSelection)&&...
                strcmp(propName,autosar.ui.metamodel.PackageString.SwAddrMethod)
                isValid=true;
            elseif strcmp(propName,...
                autosar.ui.metamodel.PackageString.DisplayFormat)
                [isValid,idcheckmessage]=...
                autosar.validation.AutosarUtils.checkDisplayFormat(propValue,...
                autosar.api.Utils.getQualifiedName(m3iObject));
            elseif strcmp(propName,autosar.ui.metamodel.PackageString.Category)&&...
                isa(m3iObject,autosar.ui.metamodel.PackageString.CompuMethodClass)

                if strcmp(propValue,'RatFunc')
                    isValid=false;
                    idcheckmessage=DAStudio.message('autosarstandard:common:CompuMethodCategoryRatFuncNotAllowed',...
                    m3iObject.Name);
                elseif strcmp(propValue,'LinearAndTextTable')
                    isValid=false;
                    idcheckmessage=DAStudio.message('autosarstandard:common:CompuMethodCategoryLinearAndTextTableNotAllowed',...
                    m3iObject.Name);
                else
                    switch m3iObject.Category
                    case Simulink.metamodel.types.CompuMethodCategory.TextTable
                        [~,~,result]=autosar.mm.util.getLiteralsFromTextTableCompuMethods(m3iObject);
                        if result
                            isValid=false;
                            idcheckmessage=DAStudio.message('autosarstandard:common:compuMethodCategoryChangeNotAllowed',...
                            'CompuMethod',m3iObject.Name,autosar.ui.metamodel.PackageString.Category,propValue);
                        else
                            isValid=true;
                        end
                    case Simulink.metamodel.types.CompuMethodCategory.Linear
                        [~,~,result]=autosar.mm.util.getScalingFromLinearCompuMethod(m3iObject);
                        if result
                            isValid=false;
                            idcheckmessage=DAStudio.message('autosarstandard:common:compuMethodCategoryChangeNotAllowed',...
                            'CompuMethod',m3iObject.Name,autosar.ui.metamodel.PackageString.Category,propValue);
                        else
                            isValid=true;
                        end
                    otherwise
                        isValid=true;
                    end
                end
            elseif strcmp(propName,...
                autosar.ui.metamodel.PackageString.RunnableSymbol)
                [isValid,idcheckmessage]=...
                autosar.validation.AutosarUtils.checkSymbol(propValue);
            elseif strcmp(propName,...
                autosar.ui.metamodel.PackageString.CseCode)
                isValid=true;
            elseif strcmp(propName,...
                autosar.ui.metamodel.PackageString.CseCodeFactor)
                numVal=str2double(propValue);
                if isnan(numVal)||(numVal~=floor(numVal))
                    idcheckmessage=DAStudio.message(...
                    'autosarstandard:validation:invalidCseCodeFactor',...
                    m3iObject.Name);
                    isValid=false;
                else
                    isValid=true;
                end
            elseif strcmp(propName,'Symbol')&&...
                isa(m3iObject,autosar.ui.configuration.PackageString.SymbolProps)

                [isValid,idcheckmessage]=autosar.validation.AutosarUtils.checkSymbol(propValue);
            elseif strcmp(propName,autosar.ui.metamodel.PackageString.NamedProperty)
                m3iModel=m3iObject.modelM3I;
                maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(m3iModel);
                idcheckmessage=autosar.ui.utils.isValidARIdentifier(propValue,...
                'shortname',maxShortNameLength);
                isValid=isempty(idcheckmessage);
            elseif any(strcmp(propName,...
                {autosar.ui.metamodel.PackageString.majorVersionNode,...
                autosar.ui.metamodel.PackageString.minorVersionNode}))
                [isValid,idcheckmessage]=autosar.validation.AutosarUtils.checkVersion(propValue,propName);
            else

                isValid=true;
            end

            if~isValid
                errordlg(idcheckmessage,...
                autosar.ui.metamodel.PackageString.ErrorTitle,...
                'replace');
                return;
            end

            if(strcmp(propName,...
                autosar.ui.metamodel.PackageString.RunnableSymbol))&&...
                isa(m3iObject,...
                autosar.ui.configuration.PackageString.Runnables)

                isValid=checkErrorForRunnableSymbol(m3iObject,propValue);
            elseif strcmp(propName,autosar.ui.metamodel.PackageString.NamedProperty)
                if isa(m3iObject,'Simulink.metamodel.arplatform.port.Port')
                    listObjs=[];
                    errID='RTW:autosar:errorDuplicatePort';
                    m3iComp=m3iObject.containerM3I;
                    if isa(m3iComp,autosar.ui.metamodel.PackageString.ComponentsCell{4})
                        isValid=autosar.ui.utils.checkDuplicateInSequence(m3iComp.RequiredPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.ProvidedPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.PersistencyProvidedRequiredPorts,propValue);
                    else
                        isValid=autosar.ui.utils.checkDuplicateInSequence(m3iComp.ReceiverPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.SenderPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.SenderReceiverPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.ModeReceiverPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.NvReceiverPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.NvSenderPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.NvSenderReceiverPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.ServerPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.ClientPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.ParameterReceiverPorts,propValue)...
                        &&autosar.ui.utils.checkDuplicateInSequence(m3iComp.TriggerReceiverPorts,propValue);
                    end
                elseif isa(m3iObject,...
                    autosar.ui.configuration.PackageString.Runnables)
                    m3iBehavior=m3iObject.containerM3I;
                    isValid=autosar.ui.utils.checkDuplicateInSequence(m3iBehavior.Runnables,propValue)&&...
                    autosar.ui.utils.checkDuplicateInSequence(m3iBehavior.Events,propValue)&&...
                    autosar.ui.utils.checkDuplicateInSequence(m3iBehavior.IRV,propValue);
                    listObjs=[];
                    errID='RTW:autosar:internalBehavShortNameClash';
                elseif isa(m3iObject,...
                    'Simulink.metamodel.arplatform.behavior.Event')
                    m3iBehavior=m3iObject.containerM3I;
                    isValid=autosar.ui.utils.checkDuplicateInSequence(m3iBehavior.Runnables,propValue)&&...
                    autosar.ui.utils.checkDuplicateInSequence(m3iBehavior.Events,propValue)&&...
                    autosar.ui.utils.checkDuplicateInSequence(m3iBehavior.IRV,propValue);
                    listObjs=[];
                    errID='RTW:autosar:internalBehavShortNameClash';
                elseif isa(m3iObject,...
                    'Simulink.metamodel.arplatform.interface.PortInterface')
                    listObjs=m3iObject.containerM3I.packagedElement;
                    errID='RTW:autosar:errorDuplicateInterface';
                elseif isa(m3iObject,...
                    autosar.ui.metamodel.PackageString.CompuMethodClass)
                    listObjs=m3iObject.containerM3I.packagedElement;
                    errID='RTW:autosar:shortNameClash';
                elseif isa(m3iObject,...
                    autosar.ui.configuration.PackageString.DataElement)||...
                    isa(m3iObject,...
                    autosar.ui.configuration.PackageString.PersistencyData)
                    m3iBehavior=m3iObject.containerM3I;
                    if strcmp(class(m3iObject),'Simulink.metamodel.arplatform.behavior.IrvData')%#ok<STISA>
                        isValid=autosar.ui.utils.checkDuplicateInSequence(m3iBehavior.Runnables,propValue)&&...
                        autosar.ui.utils.checkDuplicateInSequence(m3iBehavior.Events,propValue)&&...
                        autosar.ui.utils.checkDuplicateInSequence(m3iBehavior.IRV,propValue);
                        listObjs=[];
                        errID='RTW:autosar:internalBehavShortNameClash';
                    elseif isa(m3iObject.containerM3I,autosar.ui.metamodel.PackageString.InterfacesCell{7})
                        listObjs=m3iObject.containerM3I.Events;
                        errID='RTW:autosar:errorDuplicateEvent';
                    else
                        listObjs=m3iObject.containerM3I.DataElements;
                        errID='RTW:autosar:errorDuplicateDataElement';
                    end
                elseif isa(m3iObject,...
                    autosar.ui.configuration.PackageString.Operation)


                    m3iInterface=m3iObject.containerM3I;
                    if isa(m3iInterface,autosar.ui.metamodel.PackageString.InterfacesCell{2})
                        listObjs=m3iInterface.Operations;
                        errID='RTW:autosar:errorDuplicateOperation';
                    elseif isa(m3iInterface,autosar.ui.metamodel.PackageString.InterfacesCell{7})
                        listObjs=m3iInterface.Methods;
                        errID='RTW:autosar:errorDuplicateMethod';
                    end
                elseif isa(m3iObject,...
                    autosar.ui.configuration.PackageString.ArgumentData)
                    listObjs=m3iObject.containerM3I.Arguments;
                    errID='RTW:autosar:errorDuplicateArgument';
                elseif isa(m3iObject,...
                    autosar.ui.configuration.PackageString.FieldData)
                    listObjs=m3iObject.containerM3I.Fields;
                    errID='RTW:autosar:errorDuplicateField';
                elseif isa(m3iObject,...
                    autosar.ui.configuration.PackageString.SymbolProps)
                    listObjs=m3iObject.containerM3I.Namespaces;
                    errID='RTW:autosar:errorDuplicateNamespace';
                elseif isa(m3iObject,...
                    'Simulink.metamodel.arplatform.common.SwAddrMethod')
                    listObjs=m3iObject.containerM3I.packagedElement;
                    errID='RTW:autosar:errorDuplicateSwAddrMethod';
                else
                    listObjs=[];
                    errID='';
                end
                if~isempty(listObjs)
                    isValid=autosar.ui.utils.checkDuplicateInSequence(listObjs,propValue);
                end
                if~isValid
                    errMsg=DAStudio.message(errID,propValue);
                    errordlg(errMsg,...
                    autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                end
            end
        end

        function setPropValue(m3iObject,propName,propValue)
            prop=m3iObject.getMetaClass().getProperty(propName);
            if~isempty(prop)
                t=M3I.Transaction(m3iObject.modelM3I);

                if isa(prop.type,autosar.ui.metamodel.PackageString.M3IImmutableDataType)
                    factory=Simulink.metamodel.foundation.Factory.createNewFactory(m3iObject.rootModel);
                    if prop.type.package==M3I.MetaPackage
                        factory=M3I.Factory.createNewFactory(m3iObject.rootModel);
                    end


                    if isempty(propValue)&&any(strcmp(propName,...
                        {autosar.ui.metamodel.PackageString.majorVersionNode,...
                        autosar.ui.metamodel.PackageString.minorVersionNode}))
                        m3iObject.(propName)=propValue;
                    else
                        propValue=factory.createFromString(prop.type.qualifiedName,propValue);
                        factory.delete;
                        m3iObject.setOrAdd(propName,propValue);
                    end
                elseif any(strcmp(prop.type.qualifiedName,autosar.ui.metamodel.PackageString.InterfacesCell(1:end)))||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.ModeDeclarationClass)||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.UnitClass)||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.SwAddrMethodClass)
                    if strcmp(propValue,autosar.ui.metamodel.PackageString.NoUnit)
                        if strcmp(prop.type.qualifiedName,...
                            autosar.ui.metamodel.PackageString.UnitClass)
                            m3iObject.setOrAdd(propName,Simulink.metamodel.types.Unit.empty);
                        end
                    elseif strcmp(propValue,autosar.ui.metamodel.PackageString.NoneSelection)
                        if strcmp(prop.type.qualifiedName,...
                            autosar.ui.metamodel.PackageString.SwAddrMethodClass)
                            m3iObject.setOrAdd(propName,Simulink.metamodel.arplatform.common.SwAddrMethod.empty);
                        end
                    else
                        collectedObjects=autosar.ui.utils.collectObject(m3iObject.modelM3I,...
                        prop.type.qualifiedName);
                        for index=1:length(collectedObjects)
                            if strcmp(propValue,collectedObjects(index).Name)
                                m3iObject.setOrAdd(propName,collectedObjects(index));
                                break;
                            end
                        end
                    end
                elseif strcmp(prop.type.qualifiedName,autosar.ui.metamodel.PackageString.LongNameClass)
                    m3iModel=m3iObject.modelM3I;
                    assert(isa(m3iObject,'Simulink.metamodel.arplatform.interface.FlowData'),...
                    'Expected to set LongName on DataElement.');
                    autosar.mm.sl2mm.ModelBuilder.createOrUpdateM3ILongName(m3iModel,m3iObject,propValue);
                else
                    pValue=m3iObject.getOne(propName);
                    if isempty(pValue)
                        autosar.ui.utils.populateInterface(m3iObject,propValue);
                    else
                        pValue.Name=propValue;
                    end
                end
                t.commit;


                explorer=autosar.ui.utils.findExplorer(m3iObject.modelM3I);
                if~isempty(explorer)
                    if isa(m3iObject,autosar.ui.configuration.PackageString.ArgumentData)||...
                        isa(m3iObject,autosar.ui.configuration.PackageString.SymbolProps)
                        imme=DAStudio.imExplorer(explorer);
                        imme.enableListSorting(false,'Name',false);
                    end
                end
            end
        end

        function validAttributes=getProperties(m3iObj)
            isComposite=false;
            validAttributesSeq=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(m3iObj,isComposite);

            validAttributes=cell(1,validAttributesSeq.size());
            validAttributes{1}=autosar.ui.metamodel.PackageString.Name;
            index=2;
            for ii=1:validAttributesSeq.size()
                if~strcmp(validAttributesSeq.at(ii).name,...
                    autosar.ui.metamodel.PackageString.Name)
                    validAttributes{index}=validAttributesSeq.at(ii).name;
                    index=index+1;
                end
            end


            if isa(m3iObj,autosar.ui.metamodel.PackageString.ComponentClass)
                validAttributes=setdiff(validAttributes,...
                autosar.ui.metamodel.PackageString.BehaviorProperty,'stable');
            elseif isa(m3iObj,autosar.ui.configuration.PackageString.DataElement)||...
                isa(m3iObj,autosar.ui.configuration.PackageString.ArgumentData)||...
                isa(m3iObj,autosar.ui.configuration.PackageString.ParameterData)||...
                isa(m3iObj,'Simulink.metamodel.arplatform.interface.VariableData')||...
                isa(m3iObj,'Simulink.metamodel.arplatform.interface.FieldData')
                validAttributes=setdiff(validAttributes,...
                {autosar.ui.metamodel.PackageString.TypeProperty,...
                autosar.ui.metamodel.PackageString.SwAlignment},'stable');

                if isa(m3iObj,autosar.ui.configuration.PackageString.IRV)



                    validAttributes=setdiff(validAttributes,...
                    'InvalidationPolicy','stable');
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.ParameterData)
                    validAttributes=setdiff(validAttributes,...
                    'Kind','stable');
                end

                if slfeature('AUTOSARLongNameAuthoring')
                    if isa(m3iObj,autosar.ui.configuration.PackageString.DataElement)&&...
                        isa(m3iObj.containerM3I,autosar.ui.metamodel.PackageString.InterfacesCell{1})


                        validAttributes{end+1}=autosar.ui.metamodel.PackageString.LongName;
                    end
                end


                if isa(m3iObj.containerM3I,autosar.ui.metamodel.PackageString.InterfacesCell{6})
                    validAttributes=setdiff(validAttributes,...
                    'InvalidationPolicy','stable');
                end

                if isa(m3iObj.containerM3I,'Simulink.metamodel.arplatform.interface.ServiceInterface')||...
                    isa(m3iObj.containerM3I.containerM3I,'Simulink.metamodel.arplatform.interface.ServiceInterface')
                    validAttributes=setdiff(validAttributes,...
                    'SwAddrMethod','stable');
                end


            elseif isa(m3iObj,'Simulink.metamodel.arplatform.interface.PersistencyData')
                validAttributes=setdiff(validAttributes,{'SwCalibrationAccess',...
                'Type','SwAlignment','DisplayFormat','SwAddrMethod'},'stable');
            elseif isa(m3iObj,autosar.ui.metamodel.PackageString.InterfacesCell{3})
                validAttributes=setxor(validAttributes,...
                autosar.ui.metamodel.PackageString.ModeSwitchInterfaceAdditionalProps,'stable');
            elseif isa(m3iObj,'Simulink.metamodel.arplatform.interface.PersistencyKeyValueInterface')
                validAttributes=setdiff(validAttributes,'UpdateStrategy','stable');
            elseif isa(m3iObj,autosar.ui.metamodel.PackageString.ValueTypeClass)
                validAttributes=setxor(validAttributes,...
                autosar.ui.metamodel.PackageString.ImplementationDataTypeAdditionalProps,'stable');
            elseif isa(m3iObj,autosar.ui.metamodel.PackageString.OperationClass)
                validAttributes=setdiff(validAttributes,...
                'PossibleError','stable');
            end
            if any(ismember(validAttributes,'SwAddrMethod'))
                validAttributes=setdiff(validAttributes,'SwAddrMethod','stable');
                validAttributes{end+1}='SwAddrMethod';
            end


            if isa(m3iObj,autosar.ui.metamodel.PackageString.ComponentClass)||...
                isa(m3iObj,autosar.ui.metamodel.PackageString.InterfaceClass)||...
                isa(m3iObj,autosar.ui.metamodel.PackageString.SwAddrMethodClass)||...
                isa(m3iObj,autosar.ui.metamodel.PackageString.CompuMethodClass)
                validAttributes{end+1}=DAStudio.message('autosarstandard:ui:uiExportedXmlFile');
            end
        end
    end

    methods(Access=private,Static)
        function propValue=transformPropValue(m3iObject,propName)
            propValue='';
            p=m3iObject.getOne(propName);

            if isa(p,autosar.ui.metamodel.PackageString.M3IValueName)...
                ||isa(p,autosar.ui.metamodel.PackageString.M3IImmutableValueName)
                propValue=p.toString;
            elseif p.has(autosar.ui.metamodel.PackageString.NamedProperty)
                propValue=p.getOne(autosar.ui.metamodel.PackageString.NamedProperty).toString;
            end
        end
    end
end


function isValid=checkErrorForRunnableSymbol(m3iObject,propValue)
    isValid=~autosar.api.Utils.checkRunnableSymbolClash(...
    m3iObject,propValue);
    if~isValid
        errMsg=DAStudio.message(...
        'RTW:autosar:runnableSymbolClash',propValue);
        errordlg(errMsg,...
        autosar.ui.metamodel.PackageString.ErrorTitle,...
        'replace');
    end
end



