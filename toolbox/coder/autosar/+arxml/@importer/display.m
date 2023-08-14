function display(this)%#ok<DISPLAY>












    fprintf(1,'\n%s =\n\n',inputname(1));
    fprintf(1,'The file "%s" contains:\n',this.file.filename);

    compositionNames=this.getCompositionComponentNames();
    if numel(compositionNames)>0
        headerText='Composition-Software-Component-Type';
        displayContent(compositionNames,headerText);
    end


    m3iAtomicCompSeq=autosar.mm.Model.findObjectByMetaClass(this.arModel,...
    Simulink.metamodel.arplatform.component.AtomicComponent.MetaClass,true,true);
    m3iAdaptiveCompSeq=autosar.mm.Model.findObjectByMetaClass(this.arModel,...
    Simulink.metamodel.arplatform.component.AdaptiveApplication.MetaClass,true,false);
    if~m3iAtomicCompSeq.isEmpty()||~m3iAdaptiveCompSeq.isEmpty()

        displayAtomicComponentsMatchingKind(m3iAtomicCompSeq,'Application',...
        'Application-Software-Component-Type');
        displayAtomicComponentsMatchingKind(m3iAdaptiveCompSeq,'AdaptiveApplication',...
        'Adaptive-Application-Software-Component-Type');
        displayAtomicComponentsMatchingKind(m3iAtomicCompSeq,'ComplexDeviceDriver',...
        'Complex-Device-Driver-Software-Component-Type');
        displayAtomicComponentsMatchingKind(m3iAtomicCompSeq,'EcuAbstraction',...
        'ECU-Abstraction-Software-Component-Type');
        displayAtomicComponentsMatchingKind(m3iAtomicCompSeq,'SensorActuator',...
        'Sensor-Actuator-Software-Component-Type');
        displayAtomicComponentsMatchingKind(m3iAtomicCompSeq,'ServiceProxy',...
        'Service-Proxy-Software-Component-Type');
    else
        fprintf(1,'  0 Atomic-Software-Component-Type\n');
    end

    compNames=this.getCalibrationComponentNames();
    if numel(compNames)>0
        headerText='Parameter-Software-Component-Type';
        displayContent(compNames,headerText);
    end

    predefinedVariants=this.find('/','PredefinedVariant','PathType','FullyQualified')';
    if numel(predefinedVariants)>0
        headerText='Predefined-Variant';
        displayContent(predefinedVariants,headerText);
    end
end

function displayAtomicComponentsMatchingKind(m3iAtomicCompSeq,compKind,headerText)
    if strcmp(compKind,'AdaptiveApplication')

        m3iComps=m3i.filter(@(m3iObj)isa(m3iObj,...
        'Simulink.metamodel.arplatform.component.AdaptiveApplication'),m3iAtomicCompSeq);
    else

        m3iComps=m3i.filter(@(m3iObj)strcmp(m3iObj.Kind.toString,...
        Simulink.metamodel.arplatform.component.AtomicComponentKind.(compKind).toString),...
        m3iAtomicCompSeq);
    end

    if numel(m3iComps)>0
        compNames=m3i.mapcell(@(m3iObj)autosar.api.Utils.getQualifiedName(m3iObj),m3iComps);
        displayContent(compNames,headerText);
    end
end

function displayContent(compNames,headerText)
    assert(iscell(compNames),'compNames should be a cell array');

    leadingSpace='  ';
    nComps=numel(compNames);
    fprintf(1,'%s%d %s:\n',leadingSpace,nComps,headerText);

    doubleLeadingSpace=[leadingSpace,leadingSpace];
    for compIdx=1:length(compNames)
        fprintf(1,'%s''%s''\n',doubleLeadingSpace,compNames{compIdx});
    end
end



