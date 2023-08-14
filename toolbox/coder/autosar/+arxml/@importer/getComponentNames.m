function compList=getComponentNames(this,compKind)































    if nargin<2
        compKind='Atomic';
    end

    validatestring(compKind,[{'Atomic','Composition','Parameter','AdaptiveApplication'}...
    ,autosar.composition.Utils.getSupportedComponentKinds()],2);

    compList=[];
    if strcmp(compKind,'Atomic')
        compList=p_getcomponentnames(this,'Atomic');
        compList=[compList;p_getcomponentnames(this,'AdaptiveApplication')];
    else
        try

            cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

            compList=p_getcomponentnames(this,compKind);
        catch Me

            autosar.mm.util.MessageReporter.throwException(Me);
        end
    end



