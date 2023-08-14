classdef(Sealed)SpecialVarsInfoManager<handle





    properties(Access=private)

        mModelName;

        mVarIDMap;

        mDataAccessor;

        mIsVariableMap;

        mIsVariableWithClassMap;

        mSimulinkVariantObjectsConditionMap;

        mSimulinkParameterIsExpValueMap;

        mSLVarCtrlIsExpValueMap;

        mSimulinkParameterExpressionMap;

        mSLVarCtrlExpressionMap;

        mAllVarsNamesValuesMap;

        mAllVarsNamesSourceMap;

        mSimulinkVariantIDs=[];

        mVariantParameterIDs=[];

        mAliasTypeIDs=[];

        mNumericTypeIDs=[];



        mUseRestrictedDataForIsSlexprValueMap=false;
    end

    methods(Access=private)

        function varID=getVarID(this,varName)
            varName=char(varName);
            if~this.mVarIDMap.isKey(varName)


                varID=this.mDataAccessor.identifyByName(varName);
                if numel(varID)>1
                    varID=varID(1);
                end
                this.mVarIDMap(varName)=varID;
            end
            varID=this.mVarIDMap(varName);
        end


        function value=getVariableValueImpl(this,varName)


            value=Simulink.variant.utils.slddaccess.evalExpressionInGlobalScope(this.mModelName,varName);
        end



        function source=getSourceInBaseWksAndLibraryLinkedDDs(this,varName,ddSpec)
            isVarInBaseWorkspace=evalin('base',['exist(''',varName,''', ''var'')']);
            sourceBwks=slvariants.internal.config.utils.getGlobalWorkspaceName('');
            if isVarInBaseWorkspace
                source=sourceBwks;
            else
                varID=this.getVarID(varName);
                if isempty(varID)

                    source=slvariants.internal.config.utils.getGlobalWorkspaceName(ddSpec);
                else
                    source=varID.getDataSourceFriendlyName();
                end
            end
        end


        function objectNameValuePair=getNameValuePairs(this,objectIDs)
            objectNameValuePair=repmat(struct('Name',{{}},'Object',{{}}),numel(objectIDs),1);
            for i=1:numel(objectIDs)
                objectNameValuePair(i,1).Name=objectIDs(i).Name;
                objectNameValuePair(i,1).Object=this.mDataAccessor.getVariable(objectIDs(i));
            end
        end
    end

    methods(Access=public)
        function this=SpecialVarsInfoManager(modelName,varargin)
            this.mModelName=modelName;



            this.mDataAccessor=Simulink.data.DataAccessor.createForExternalData(modelName);
            this.setMapsToDefault();
        end

        function delete(this)
            this.setMapsToDefault();
        end

        function setMapsToDefault(this)


            this.mVarIDMap=containers.Map('keyType','char','valueType','any');
            this.mIsVariableMap=containers.Map('keyType','char','valueType','logical');
            this.mIsVariableWithClassMap=containers.Map('keyType','char','valueType','any');
            this.mAllVarsNamesValuesMap=containers.Map('keyType','char','valueType','any');
            this.mAllVarsNamesSourceMap=containers.Map('keyType','char','valueType','any');
            this.mSimulinkVariantObjectsConditionMap=containers.Map('keyType','char','valueType','char');
            this.mSimulinkParameterIsExpValueMap=containers.Map('keyType','char','valueType','logical');
            this.mSLVarCtrlIsExpValueMap=containers.Map('keyType','char','valueType','logical');
            this.mSimulinkParameterExpressionMap=containers.Map('keyType','char','valueType','any');
            this.mSLVarCtrlExpressionMap=containers.Map('keyType','char','valueType','any');
        end


        function setUseRestrictedDataForSimulinkParameterIsExpValueMap(this,controlVariableNameValuePairs)
            this.mUseRestrictedDataForIsSlexprValueMap=true;
            this.mSimulinkParameterIsExpValueMap.remove(this.mSimulinkParameterIsExpValueMap.keys);
            this.mSLVarCtrlIsExpValueMap.remove(this.mSLVarCtrlIsExpValueMap.keys);
            for i=1:2:numel(controlVariableNameValuePairs)-1
                varName=controlVariableNameValuePairs{i};
                varValue=controlVariableNameValuePairs{i+1};
                if numel(varValue)>1
                    varValue=varValue(1);
                end
                if isa(varValue,'Simulink.Parameter')&&isa(varValue.Value,'Simulink.data.Expression')
                    this.mSimulinkParameterIsExpValueMap(varName)=true;
                    this.mSimulinkParameterExpressionMap(varName)=char(varValue.Value.ExpressionString);
                elseif isa(varValue,'Simulink.VariantControl')&&...
                    isa(varValue.Value,'Simulink.Parameter')&&...
                    isa(varValue.Value.Value,'Simulink.data.Expression')
                    this.mSLVarCtrlIsExpValueMap(varName)=true;
                    this.mSLVarCtrlExpressionMap(varName)=char(varValue.Value.Value.ExpressionString);
                end
            end
        end


        function performGlobalWksCheck=doPerformGlobalWksCheckForExprValueParam(this,varName)
            if this.mUseRestrictedDataForIsSlexprValueMap
                performGlobalWksCheck=false;
            else
                performGlobalWksCheck=this.getIsSimulinkParameter(varName)&&~this.mSLVarCtrlIsExpValueMap.isKey(varName);
            end
        end


        function performGlobalWksCheck=doPerformGlobalWksCheckForExprValueSLVarCtrl(this,varName)
            if this.mUseRestrictedDataForIsSlexprValueMap
                performGlobalWksCheck=false;
            else
                performGlobalWksCheck=this.getIsSLVarCtrl(varName)&&~this.mSimulinkParameterIsExpValueMap.isKey(varName);
            end
        end


        function[isVariable,variableClass]=getIsVariableWithClass(this,varName)
            if~this.mIsVariableWithClassMap.isKey(varName)
                isVariable=this.getIsVariable(varName);
                if isVariable


                    try
                        variableClass=evalinGlobalScope(this.mModelName,['class(',varName,')']);
                    catch









                        variableClass='Simulink.data.dictionary.EnumTypeDefinition';
                    end
                else
                    variableClass='';
                end
                this.mIsVariableWithClassMap(varName)=struct('IsVariable',isVariable,'VariableClass',variableClass);
            end
            isVariable=this.mIsVariableWithClassMap(varName).IsVariable;
            variableClass=this.mIsVariableWithClassMap(varName).VariableClass;
        end


        function isVariable=getIsVariable(this,varName)
            if~this.mIsVariableMap.isKey(varName)
                isVariable=existsInGlobalScope(this.mModelName,varName);
                this.mIsVariableMap(varName)=isVariable;


            end
            isVariable=this.mIsVariableMap(varName);
        end


        function value=getVariableValue(this,varName)
            if this.getIsVariable(varName)

                if~this.mAllVarsNamesValuesMap.isKey(varName)

                    this.mAllVarsNamesValuesMap(varName)=this.getVariableValueImpl(varName);
                end
                value=this.mAllVarsNamesValuesMap(varName);
            else

                value=[];
            end
        end


        function source=getVariableSource(this,varName)
            if~this.mAllVarsNamesSourceMap.isKey(varName)
                ddSpec=get_param(this.mModelName,'DataDictionary');
                if this.getIsVariable(varName)
                    if~isempty(ddSpec)


                        ddSec=getSection(Simulink.data.dictionary.open(ddSpec),'Design Data');
                        try


                            entry=ddSec.getEntry(varName);
                            source=entry.DataSource;
                        catch ME


                            Simulink.variant.utils.assert(strcmp(ME.identifier,'SLDD:sldd:EntryNotFound'));
                            source=this.getSourceInBaseWksAndLibraryLinkedDDs(varName,ddSpec);
                        end
                    else
                        source=this.getSourceInBaseWksAndLibraryLinkedDDs(varName,ddSpec);
                    end
                else


                    source=slvariants.internal.config.utils.getGlobalWorkspaceName(ddSpec);
                end
                this.mAllVarsNamesSourceMap(varName)=source;
            end
            source=this.mAllVarsNamesSourceMap(varName);
        end


        function isExpValueSimulinkParameter=getIsExpValueSimulinkParameter(this,varName)
            if this.doPerformGlobalWksCheckForExprValueParam(varName)
                this.mSimulinkParameterIsExpValueMap(varName)=...
                isa(this.getVariableValueImpl(varName).Value,'Simulink.data.Expression');
            end
            isExpValueSimulinkParameter=this.mSimulinkParameterIsExpValueMap.isKey(varName)&&this.mSimulinkParameterIsExpValueMap(varName);
        end



        function isExprValue=getIsExpValue(this,varName)
            if this.doPerformGlobalWksCheckForExprValueParam(varName)
                this.mSimulinkParameterIsExpValueMap(varName)=...
                isa(this.getVariableValueImpl(varName).Value,'Simulink.data.Expression');
            end
            if this.doPerformGlobalWksCheckForExprValueSLVarCtrl(varName)
                value=this.getVariableValueImpl(varName).Value;
                this.mSLVarCtrlIsExpValueMap(varName)=isa(value,'Simulink.Parameter')&&isa(value.Value,'Simulink.data.Expression');
            end
            isExprValue=(this.mSimulinkParameterIsExpValueMap.isKey(varName)&&this.mSimulinkParameterIsExpValueMap(varName))||...
            (this.mSLVarCtrlIsExpValueMap.isKey(varName)&&this.mSLVarCtrlIsExpValueMap(varName));
        end


        function condition=getConditionIfSimulinkVariant(this,varName)
            condition='';
            if this.getIsSimulinkVariantObject(varName)
                if~this.mSimulinkVariantObjectsConditionMap.isKey(varName)
                    simulinkVariantObject=this.getVariableValue(varName);
                    this.mSimulinkVariantObjectsConditionMap(varName)=simulinkVariantObject.Condition;
                end
                condition=this.mSimulinkVariantObjectsConditionMap(varName);
            end
        end


        function expression=getExpressionIfSimulinkParameterIsExpValue(this,varName)
            expression='';
            if this.getIsExpValueSimulinkParameter(varName)
                if~this.mSimulinkParameterExpressionMap.isKey(varName)
                    this.mSimulinkParameterExpressionMap(varName)=char(this.getVariableValueImpl(varName).Value.ExpressionString);
                end
                expression=this.mSimulinkParameterExpressionMap(varName);
            end
        end


        function expression=getExpressionIfExpValue(this,varName)
            expression='';
            if this.getIsExpValueSimulinkParameter(varName)
                if~this.mSimulinkParameterExpressionMap.isKey(varName)
                    this.mSimulinkParameterExpressionMap(varName)=char(this.getVariableValueImpl(varName).Value.ExpressionString);
                end
                expression=this.mSimulinkParameterExpressionMap(varName);
            elseif this.getIsExpValue(varName)
                if~this.mSLVarCtrlExpressionMap.isKey(varName)
                    this.mSLVarCtrlExpressionMap(varName)=char(this.getVariableValueImpl(varName).Value.Value.ExpressionString);
                end
                expression=this.mSLVarCtrlExpressionMap(varName);
            end
        end


        function isEnumTypeDefinitioninDD=getIsEnumTypeDefinitioninDD(this,varName)
            [isVariable,variableClass]=this.getIsVariableWithClass(varName);
            isEnumTypeDefinitioninDD=isVariable&&strcmp(variableClass,'Simulink.data.dictionary.EnumTypeDefinition');

        end


        function isSimulinkParameter=getIsSimulinkParameter(this,varName)
            [isVariable,variableClass]=this.getIsVariableWithClass(varName);
            isSimulinkParameter=isVariable&&strcmp(variableClass,'Simulink.Parameter');
        end


        function isSLVarCtrl=getIsSLVarCtrl(this,varName)
            [isVariable,variableClass]=this.getIsVariableWithClass(varName);
            isSLVarCtrl=isVariable&&strcmp(variableClass,'Simulink.VariantControl');
        end


        function isSimulinkVariantObject=getIsSimulinkVariantObject(this,varName)
            [isVariable,variableClass]=this.getIsVariableWithClass(varName);
            isSimulinkVariantObject=isVariable&&strcmp(variableClass,'Simulink.Variant');
        end


        function variantObjsInGlobalScope=getSimulinkVariants(this)
            if isempty(this.mSimulinkVariantIDs)
                this.mSimulinkVariantIDs=this.mDataAccessor.identifyVisibleVariablesByClass('Simulink.Variant');
            end
            variantObjsInGlobalScope=this.getNameValuePairs(this.mSimulinkVariantIDs);
        end


        function variantParamsInGlobalScope=getVariantParameters(this)
            if isempty(this.mVariantParameterIDs)
                this.mVariantParameterIDs=this.mDataAccessor.identifyVisibleVariablesByClass('Simulink.VariantVariable');
            end
            variantParamsInGlobalScope=this.getNameValuePairs(this.mVariantParameterIDs);
        end


        function hasParameters=hasVariantParameters(this)
            if isempty(this.mVariantParameterIDs)
                this.mVariantParameterIDs=this.mDataAccessor.identifyVisibleVariablesByClass('Simulink.VariantVariable');
            end
            hasParameters=~isempty(this.mVariantParameterIDs);
        end


        function aliasTypeIDsInGlobalScope=getSimulinkAliasType(this)
            if isempty(this.mAliasTypeIDs)
                this.mAliasTypeIDs=this.mDataAccessor.identifyVisibleVariablesByClass('Simulink.AliasType');
            end
            aliasTypeIDsInGlobalScope=this.getNameValuePairs(this.mAliasTypeIDs);
        end


        function numericTypeIDsInGlobalScope=getSimulinkNumericType(this)
            if isempty(this.mNumericTypeIDs)
                this.mNumericTypeIDs=this.mDataAccessor.identifyVisibleVariablesByClass('Simulink.NumericType');
            end
            numericTypeIDsInGlobalScope=this.getNameValuePairs(this.mNumericTypeIDs);
        end
    end
end


