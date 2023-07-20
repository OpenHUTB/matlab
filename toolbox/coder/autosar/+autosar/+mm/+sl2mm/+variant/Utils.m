classdef Utils<handle




    methods(Access=public,Static)
        function isValid=isValidCodeCompileParam(slParam)
            isValid=autosar.mm.sl2mm.variant.Utils.isSystemConstant(slParam)...
            ||autosar.mm.sl2mm.variant.Utils.isSlParamWithCSC(slParam,'Define');
        end

        function isSlParamWithCSC=isSlParamWithCSC(slObj,storageClass)


            isSlParamWithCSC=isa(slObj,'Simulink.Parameter')&&...
            isprop(slObj,'CoderInfo')&&...
            isprop(slObj.CoderInfo,'StorageClass')&&...
            isprop(slObj.CoderInfo,'CustomStorageClass')&&...
            strcmp(slObj.CoderInfo.StorageClass,'Custom')&&...
            strcmp(slObj.CoderInfo.CustomStorageClass,storageClass);
        end

        function isSystemConstant=isSystemConstant(slParam)



            isSystemConstant=isa(slParam,'AUTOSAR.Parameter')&&...
            isprop(slParam,'CoderInfo')&&...
            isprop(slParam.CoderInfo,'StorageClass')&&...
            isprop(slParam.CoderInfo,'CustomStorageClass')&&...
            strcmp(slParam.CoderInfo.StorageClass,'Custom')&&...
            strcmp(slParam.CoderInfo.CustomStorageClass,'SystemConstant');
        end

        function[isSimVarCtrlWithSysConValue,simVarCtrlVal]=isSimulinkVariantControlWithSysConValue(slParam)



            simVarCtrlVal=[];
            isSimVarCtrlWithSysConValue=isa(slParam,'Simulink.VariantControl')&&...
            autosar.mm.sl2mm.variant.Utils.isSystemConstant(slParam.Value);
            if isSimVarCtrlWithSysConValue
                simVarCtrlVal=slParam.Value;
            end
        end

        function[isSimVarVariable,spec]=isSimulinkVariantVariableWithSysConSpec(modelName,slParam)
            isSimVarVariable=isa(slParam,'Simulink.VariantVariable');
            spec=[];
            if isSimVarVariable
                [exists,mlVar,~]=autosar.utils.Workspace.objectExistsInModelScope(modelName,slParam.Specification);
                if exists&&autosar.mm.sl2mm.variant.Utils.isSystemConstant(mlVar)
                    spec=mlVar;
                end
            end
        end

        function isPostBuildVariantCriterion=isPostBuildVariantCriterion(modelName,paramName)


            [exists,mlVar,inModelWS]=autosar.utils.Workspace.objectExistsInModelScope(modelName,paramName);
            supportedObjType=~isobject(mlVar)||isa(mlVar,'Simulink.VariantControl');
            isPostBuildVariantCriterion=exists&&~inModelWS&&supportedObjType;
        end

        function addSymbolicDimensions(symbolicWidth,m3iType,modelName,m3iModel)
















            function newSymbol=syscToARXMLRef(symbol)
                symbol=autosar.mm.sl2mm.variant.Utils.stripRtePrefix(symbol);
                slObj=autosar.mm.util.getValueFromGlobalScope(modelName,symbol);
                [isSimVarVariable,specObj]=autosar.mm.sl2mm.variant.Utils.isSimulinkVariantVariableWithSysConSpec(modelName,slObj);

                if isSimVarVariable
                    slObj=specObj;
                end

                if autosar.mm.sl2mm.variant.Utils.isSystemConstant(slObj)
                    newSymbol=autosar.mm.sl2mm.variant.Utils.getSysConstRefXML(...
                    m3iModel,symbol);
                else
                    numval=str2double(symbol);
                    if isnan(numval)
                        DAStudio.error('autosarstandard:exporter:InvalidParameterForExport',symbol);
                    end
                    newSymbol=symbol;
                end
            end

            invalidChars=['&','<','>'];
            for ii=1:length(invalidChars)
                invalidChar=invalidChars(ii);
                if any(symbolicWidth==invalidChar)
                    DAStudio.error('autosarstandard:exporter:InvalidSymbolForDimensionVariant',invalidChar,symbolicWidth);
                end
            end

            xmlbody=autosar.mm.util.transformFormulaExpression(...
            symbolicWidth,@syscToARXMLRef);

            xmlbody=regexprep(xmlbody,'~','!');

            m3iType.SymbolicDimensions.clear();
            m3iType.SymbolicDimensions.append(xmlbody);
        end


        function id=getDimensionsIdentifier(typeobj,dims)


            if typeobj.isPointer
                id='1';
                return
            end

            if(typeobj.HasSymbolicDimensions)
                assert(iscell(dims),'Expected cell array');
                symbols=strrep(dims,'*','_');
                tmpname=strjoin(symbols,'_');
                tmpname=strrep(tmpname,' ','');
                tmpname=strrep(tmpname,'0x','_0x');
                id=matlab.lang.makeValidName(tmpname,'ReplacementStyle','hex');
            else
                assert(isnumeric(dims),'Expected numeric array');

                id='';
                sep='';
                for ii=1:length(dims)
                    id=[id,sep,int2str(dims(ii))];%#ok<AGROW>
                    sep='x';
                end
            end
        end

        function name=stripRtePrefix(symbol)

            if strncmp('Rte_SysCon_',symbol,11)
                name=symbol(12:end);
            else
                name=symbol;
            end
        end
    end

    methods(Static,Access=private)
        function xmlout=getSysConstRefXML(m3iModel,syscName)







            m3iRoot=m3iModel.RootPackage.front();

            systemConstBuilder=autosar.mm.sl2mm.variant.SystemConstantBuilder(m3iModel,m3iRoot.DataTypePackage);

            m3iSysConst=systemConstBuilder.findOrCreateSystemConstant(syscName);

            sysConstQualifiedName=autosar.api.Utils.getQualifiedName(m3iSysConst);
            xmlout=syscName;
            pat=['\<',syscName,'(?![\."])\>'];
            xmlout=regexprep(xmlout,pat,['<SYSC-REF DEST="SW-SYSTEMCONST">'...
            ,sysConstQualifiedName,'</SYSC-REF>']);
        end
    end

end


