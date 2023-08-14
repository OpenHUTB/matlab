classdef(Hidden)SystemProp<matlab.system.SystemAttributes




















%#function sigdatatypes.checkNumericOrLogicalScalar
%#function matlab.system.StringSet
%#function matlab.system.internal.StringSetGF









    properties(Nontunable,Access=private)




        MajorVersionNumber=matlab.system.SystemProp.createVersionNumber('major');
        MinorVersionNumber=matlab.system.SystemProp.createVersionNumber('minor');
    end

    properties(Nontunable,Hidden,SetAccess={?dataflow.internal.mixin.SystemNodeActual})
GraphNode
    end

    methods(Static,Hidden,Access=protected)
        header=getHeaderImpl

        groups=getPropertyGroupsImpl

        simUsing=getSimulateUsingImpl(platformName)

        isVisible=showSimulateUsingImpl

        isVisible=showFiSettingsImpl
    end

    methods(Static,Hidden,Sealed,Access=protected)
        fiSettings=getFiSettingsImpl
    end

    methods(Static,Hidden,Sealed)
        header=getDisplayHeader(systemName)

        groups=getDisplayPropertyGroups(systemName,argument)

        simUsing=getSimulateUsing(systemName,platformName)

        fiSettings=getFiSettings(systemName)

        isVisible=showSimulateUsing(systemName)

        isVisible=showFiSettings(systemName)
    end

    methods(Static,Hidden)
        num=createVersionNumber(bMajor)

        props=getDisplayPropertiesImpl

        props=getDisplayFixedPointPropertiesImpl
    end

    methods(Hidden,Sealed)
        names=getInputNames(obj)

        names=getOutputNames(obj)

        name=getInstanceName(obj)

        setInstanceName(obj,name)

        g=getParentGraph(obj)

        props=scanProperties(obj,filterFcn)
        methodNames=scanMethods(obj,filterFcn)
    end

    methods(Access=protected)
        names=getInputNamesImpl(obj)

        names=getOutputNamesImpl(obj)
    end




    methods(Access=protected,Hidden)
        sysObjNodeCloneHelper(this,other)

        setProperties(obj,narg,varargin)

        validateCustomDataType(~,prop,type,res)

        validateInstanceName(obj,name)
    end

    methods(Access=protected)
        function obj=SystemProp



            if~isa(obj,'matlab.system.SystemInterface')
                matlab.system.internal.error('MATLAB:system:systemPropNotSystemObject');
            end
        end
    end

    methods(Hidden)
        ver=getVersionString(obj)

        [majorv,minorv]=getVersionNumber(obj)
    end




    methods(Access=protected)
        groups=getPropertyGroups(obj)

        groups=getPropertyGroupsLongImpl(obj)
    end

    methods(Sealed,Access=private)
        [groups,hasHiddenGroups]=getCPPSystemObjectPropertyGroups(obj,isLongDisplay)

        [groups,hasHiddenGroups]=convertSystemObjectGroupsToCustomDisplayGroups(obj,systemObjectGroups,isLongDisplay)
    end

    methods(Sealed,Access=protected)
        [groups,hasHiddenGroups]=getDefaultCustomDisplayPropertyGroups(obj,isLongDisplay)

        matlabGroups=removeInactivePropertiesFromPropertyGroups(obj,matlabGroups)

        matlabGroups=convertToTrueFalseStructPropertyGroups(obj,matlabGroups)
    end

    methods(Static,Hidden)
        longDisplayFromClick(obj,variableName,className)
    end





    methods(Hidden,Sealed)
        expression=toConstructorExpression(obj,varargin)

        props=getPublicProperties(obj,inclusionFlags,defaultValues)

        flag=isPublicClone(obj,other)

        [globalList,glStepOutput,glUpdate]=findRuntimeGlobals(obj)
    end




    methods(Access=protected,Hidden,Sealed)
        inactiveProps=parseInputs(obj,args,valueonlyprops)

        checkModesAndWordLengths(obj,prefix)

        dtInfo=getSourceDataTypeInfo(obj,maxVal)

        dtInfo=getFixptDataTypeInfo(obj,prefixes,nomiscparams)

        dtInfo=processParamSection(obj,dtInfo,prefix)
    end

    methods(Static,Hidden)
        flag=isPublicSetProp(mp)

        flag=isPublicGetProp(mp)
    end

    methods(Sealed,Hidden)
        names=getStepOrOutputMethodInputNames(obj)

        names=getStepOrOutputMethodOutputNames(obj)
    end

    methods(Access=private)
        names=getMethodArgumentNames(obj,methodName,methodInfoArgListName,...
        expectedArgCount,varargName,defaultDefiningClass)
    end

    methods(Access=protected,Hidden)
        y=isFullSaveLoadEnabled(obj,childClassData)
    end
end
