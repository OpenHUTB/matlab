classdef Helper
    methods(Static)

        function[structPropAssignStmt,protoNumerictypes,protoFimaths]=ConvertToOriginalType(fxpConversionSettings,propVarInfo,lhsFullPropName,rhsFullPropName,protoNumerictypes,protoFimaths)
            origTypeName=propVarInfo.getOriginalTypeClassName();


            if propVarInfo.isEnum()||~propVarInfo.needsFiCast
                structPropAssignStmt=sprintf('%s = %s;\n',lhsFullPropName,rhsFullPropName);
            elseif propVarInfo.needsFiCast||isempty(propVarInfo.annotated_Type)
                structPropAssignStmt=sprintf('%s = %s( %s );\n',lhsFullPropName,origTypeName,rhsFullPropName);
            else






                fmDecl=fxpConversionSettings.fiMathVarName;
                fiwrappedExpr=sprintf('fi(%s, %d, %d, %d, %s)',...
                rhsFullPropName,...
                propVarInfo.annotated_Type.Signed,...
                propVarInfo.annotated_Type.WordLength,...
                propVarInfo.annotated_Type.FractionLength,...
                fmDecl);

                structPropAssignStmt=sprintf('%s = %s ;\n',lhsFullPropName,fiwrappedExpr);
            end

            eval(['protoNumerictypes.',propVarInfo.SymbolName,' = [];']);
            eval(['protoFimaths.',propVarInfo.SymbolName,' = [];']);
        end

        function[structPropAssignStmt,protoNumerictypes,protoFimaths]=ConvertToAnnotatedType(fxpConversionSettings,propVarInfo,rhsVarInfo,lhsFullPropName,rhsFullPropName,protoNumerictypes,protoFimaths,phase)
            if propVarInfo.needsFiCast
                global_fim=eval(fxpConversionSettings.globalFimathStr);
                local_fim=propVarInfo.getFimath();
                fim_diff=coder.internal.Helper.diffFimathString(local_fim,global_fim);
                if~propVarInfo.isFimathSet()||isempty(fim_diff)
                    fmDecl=fxpConversionSettings.fiMathVarName;

                    fim=global_fim;
                else
                    fmDecl=sprintf('%s, %s',fxpConversionSettings.fiMathVarName,fim_diff);

                    fim=local_fim;
                end

                annotationAvil=~isempty(propVarInfo.annotated_Type);
                if annotationAvil
                    prevValue=phase.emittedFiCast;
                    fiwrappedExpr=phase.wrapCodeWithType(rhsFullPropName,propVarInfo.annotated_Type,fmDecl,propVarInfo);
                    if~prevValue




                        phase.emittedFiCast=false;
                    end
                else

                    fiwrappedExpr=sprintf('%s',rhsFullPropName);
                end

                structPropAssignStmt=sprintf('%s = %s',lhsFullPropName,fiwrappedExpr);

                if annotationAvil
                    if fxpConversionSettings.DoubleToSingle&&ischar(propVarInfo.annotated_Type)

                        eval(['protoNumerictypes.',propVarInfo.SymbolName,' = [];']);
                        eval(['protoFimaths.',propVarInfo.SymbolName,' = [];']);
                    else
                        eval(['protoNumerictypes.',propVarInfo.SymbolName,' = numerictype(propVarInfo.annotated_Type.Signed , propVarInfo.annotated_Type.WordLength, propVarInfo.annotated_Type.FractionLength);']);
                        eval(['protoFimaths.',propVarInfo.SymbolName,' = fim;']);
                    end
                else
                    eval(['protoNumerictypes.',propVarInfo.SymbolName,' = [];']);
                    eval(['protoFimaths.',propVarInfo.SymbolName,' = [];']);
                end
            else
                rhsPropVarInfo=rhsVarInfo.getStructPropVarInfo(rhsFullPropName);
                if isequal(propVarInfo.getFimath(),rhsPropVarInfo.getFimath())


                    structPropAssignStmt=sprintf('%s = %s',lhsFullPropName,rhsFullPropName);

                    eval(['protoNumerictypes.',propVarInfo.SymbolName,' = [];']);
                    eval(['protoFimaths.',propVarInfo.SymbolName,' = [];']);
                else


                    roundOverflowModes=sprintf('''RoundingMethod'', ''%s'', ''OverflowAction'', ''%s''',propVarInfo.roundMode,propVarInfo.overflowMode);
                    structPropAssignStmt=sprintf('%s = fi(%s, %s)',lhsFullPropName,rhsFullPropName,roundOverflowModes);

                    fim=propVarInfo.getFimath();
                    eval(['protoNumerictypes.',propVarInfo.SymbolName,' = [];']);
                    eval(['protoFimaths.',propVarInfo.SymbolName,' = fim;']);
                end
            end
        end

        function[structPropAssignStmtList,protoNumerictypes,protoFimaths]=UnrollStructAssignment(fxpConversionSettings,lhsVarInfo,rhsVarInfo,phase,nameService,disableCastOptimization,convertToOriginalTypes)



            protoNumerictypes=[];
            protoFimaths=[];
            fim=eval(fxpConversionSettings.globalFimathStr);
            structPropAssignStmtList={};







            rhsNonNestedFields=rhsVarInfo.getNonNestedLoggedFields;
            nestedStructFieldNames=rhsVarInfo.getImmediateNestedFields();
            explodedNestedStructList={};
            rhsFields=rhsVarInfo.loggedFields;
            for kk=1:length(rhsFields)
                rhsFullPropName=rhsFields{kk};

                if any(strcmp(rhsFullPropName,rhsNonNestedFields))

                    leafPropName=regexprep(rhsFullPropName,[rhsVarInfo.SymbolName,'.'],'','Once');
                    lhsFullPropName=[lhsVarInfo.SymbolName,'.',leafPropName];
                    propVarInfo=lhsVarInfo.getStructPropVarInfo(lhsFullPropName);

                    if convertToOriginalTypes
                        [structPropAssignStmt,protoNumerictypes,protoFimaths]=coder.internal.translator.Helper.ConvertToOriginalType(fxpConversionSettings,propVarInfo,lhsFullPropName,rhsFullPropName,protoNumerictypes,protoFimaths);
                    else
                        [structPropAssignStmt,protoNumerictypes,protoFimaths]=coder.internal.translator.Helper.ConvertToAnnotatedType(fxpConversionSettings,propVarInfo,rhsVarInfo,lhsFullPropName,rhsFullPropName,protoNumerictypes,protoFimaths,phase);
                    end

                    structPropAssignStmtList{end+1}=structPropAssignStmt;%#ok<AGROW>
                else

                    tmp=strsplit(rhsFullPropName,'.');


                    rhsNestedStructName=strjoin(tmp(1:2),'.');


                    if any(strcmp(explodedNestedStructList,rhsNestedStructName))
                        continue;
                    end
                    explodedNestedStructList{end+1}=rhsNestedStructName;%#ok<AGROW>
                    nestedRhsVarInfo=rhsVarInfo.getStructPropVarInfo(rhsNestedStructName);

                    tmpBaseNestedStructName=strrep(rhsNestedStructName,[rhsVarInfo.SymbolName,'.'],'');
                    lhsNestedStructName=[lhsVarInfo.SymbolName,'.',tmpBaseNestedStructName];
                    nestedLhsVarInfo=lhsVarInfo.getStructPropVarInfo(lhsNestedStructName);





                    [isCastNeeded,fcnStr,fcnName,propProtoNumtypes,propProtoFimaths]=coder.internal.translator.Helper.CreateCopyStructFunction(fxpConversionSettings,nestedLhsVarInfo,nestedRhsVarInfo,phase,nameService,disableCastOptimization,convertToOriginalTypes);%#ok<ASGLU>
                    if isCastNeeded
                        structPropAssignStmtList{end+1}=[lhsNestedStructName,' = ',fcnName,'( ',rhsNestedStructName,' )'];%#ok<AGROW>
                        phase.structCopyHandler.addCopyStruct(fcnName,fcnStr);

                        eval(['protoNumerictypes.',lhsNestedStructName,' = propProtoNumtypes.',lhsNestedStructName,';']);
                        eval(['protoFimaths.',lhsNestedStructName,' =  propProtoFimaths.',lhsNestedStructName,';']);
                    else
                        structPropAssignStmtList{end+1}=sprintf('%s = %s',lhsNestedStructName,rhsNestedStructName);%#ok<AGROW>
                    end
                end
            end


            structPropAssignStmtList=strjoin(structPropAssignStmtList,[';',char(10)]);
        end




















        function[explodedStmtStr,protoNumerictypes,protoFimaths]=ExplodeStructArrayAssignment(fxpConversionSettings,lhsVarInfo,rhsVarInfo,phase,nameService,disableCastOptimization,convertToOriginalTypes)
            if nargin<5
                assert(nargin<=4);
                nameService=phase.uniqueNamesService;
            end
            explodedStmtStr='';protoNumerictypes=[];protoFimaths=[];
            structPropAssignStmtList={};
            isVarDims=any(lhsVarInfo.inferred_Type.SizeDynamic);


            tmpRhsInfo=rhsVarInfo.getClonedNonArrayOfStruct();

            tmpLhsInfo=lhsVarInfo.getClonedNonArrayOfStruct();
            newtmpLhsName=nameService.distinguishName(['f_',tmpLhsInfo.SymbolName]);
            tmpLhsInfo.setSymbolName(newtmpLhsName);

            [isCastNeeded,fcnStr,fcnName,tmpNumerictypes,tmpFimaths]=coder.internal.translator.Helper.CreateCopyStructFunction(fxpConversionSettings,tmpLhsInfo,tmpRhsInfo,phase,nameService,disableCastOptimization,convertToOriginalTypes);%#ok<ASGLU>
            if isCastNeeded
                phase.structCopyHandler.addCopyStruct(fcnName,fcnStr);

                if isVarDims
                    structPropAssignStmtList{end+1}=[newtmpLhsName,' = [];'];
                    structPropAssignStmtList{end+1}=['if ~isempty(',rhsVarInfo.SymbolName,')'];
                    structPropAssignStmtList{end+1}=[newtmpLhsName,' = [ ',newtmpLhsName,' ',fcnName,'(',rhsVarInfo.SymbolName,'(1) ) ];'];
                    structPropAssignStmtList{end+1}='end';
                else
                    structPropAssignStmtList{end+1}=[newtmpLhsName,' = ',fcnName,'(',rhsVarInfo.SymbolName,'(1) );'];
                end
            else
                try



                    evalNumericTypeFimath();
                catch

                end
                return;
            end

            evalNumericTypeFimath();
            function evalNumericTypeFimath()
                eval(['protoNumerictypes.',lhsVarInfo.SymbolName,' = tmpNumerictypes.',newtmpLhsName,';']);
                eval(['protoFimaths.',lhsVarInfo.SymbolName,' = tmpFimaths.',newtmpLhsName,';']);
            end


            structPropAssignStmtList{end+1}=[lhsVarInfo.SymbolName,' =  coder.nullcopy(repmat( ',newtmpLhsName,', size( ',rhsVarInfo.SymbolName,' ) ));'];


            indexName=nameService.distinguishName('ii');
            structPropAssignStmtList{end+1}=['for ',indexName,' = 1:numel( ',lhsVarInfo.SymbolName,' )'];

            structPropAssignStmtList{end+1}=[lhsVarInfo.SymbolName,'(',indexName,') = ',fcnName,'(',rhsVarInfo.SymbolName,'(',indexName,'));'];

            structPropAssignStmtList{end+1}='end';

            explodedStmtStr=strjoin(structPropAssignStmtList,char(10));
        end









        function[isCastNeeded,fcntionStr,fcnName,protoNumerictypes,protoFimaths]=CreateCopyStructFunction(fxpConversionSettings,lhsVarInfo,rhsVarInfo,phase,nameService,disableCastOptimization,convertToOriginalTypes)%#ok<STOUT>
            if nargin<6
                disableCastOptimization=false;
            end
            if nargin<7
                convertToOriginalTypes=false;
            end


            isCastNeeded=true;fcntionStr='';fcnName='';protoNumerictypes=[];protoFimaths=[];
            if(~disableCastOptimization&&~isCastNecessary(lhsVarInfo,rhsVarInfo))||...
                rhsVarInfo.isVarInSrcEmpty()
                isCastNeeded=false;
                return;
            end



            origLhsSymbolName=lhsVarInfo.SymbolName;
            tmpNewLhsName=matlab.lang.makeValidName(origLhsSymbolName);
            if~strcmp(tmpNewLhsName,lhsVarInfo.SymbolName)
                lhsVarInfo=lhsVarInfo.clone();
                lhsVarInfo.setSymbolName(tmpNewLhsName);
            end



            tmpNewRhsName=matlab.lang.makeValidName(rhsVarInfo.SymbolName);
            if~strcmp(tmpNewRhsName,rhsVarInfo.SymbolName)
                rhsVarInfo=rhsVarInfo.clone();
                rhsVarInfo.setSymbolName(tmpNewRhsName);
            end


            tmp=matlab.lang.makeValidName(['copyTo_',lhsVarInfo.SymbolName]);
            fcnName=nameService.distinguishName(tmp);

            isArrayofStructs=~all(ones(1,length(lhsVarInfo.inferred_Type.Size))==lhsVarInfo.inferred_Type.Size');

            functionStrList={};
            functionStrList{end+1}=['function ',lhsVarInfo.SymbolName,' = ',fcnName,'( ',rhsVarInfo.SymbolName,' )'];
            functionStrList{end+1}='coder.inline(''always'');';

            if isArrayofStructs
                [structExplosionStmtStr,tmpNumerictypes,tmpFimaths]=coder.internal.translator.Helper.ExplodeStructArrayAssignment(fxpConversionSettings,lhsVarInfo,rhsVarInfo,phase,nameService,disableCastOptimization,convertToOriginalTypes);%#ok<ASGLU>
            else
                [structExplosionStmtStr,tmpNumerictypes,tmpFimaths]=coder.internal.translator.Helper.UnrollStructAssignment(fxpConversionSettings,lhsVarInfo,rhsVarInfo,phase,nameService,disableCastOptimization,convertToOriginalTypes);%#ok<ASGLU>

                if fxpConversionSettings.DoubleToSingle

                else

                    for kk=1:numel(rhsVarInfo.loggedFields)
                        isFiType=strcmp(rhsVarInfo.loggedFieldsInferred_Types{kk}.Class,'embedded.fi');
                        if(~isFiType)

                            functionStrList{end+1}=phase.emitFiMathStr();
                            phase.emitFiMathFcn=true;
                            break;
                        end
                    end
                end

            end
            if isempty(structExplosionStmtStr)


                isCastNeeded=false;fcntionStr='';fcnName='';%#ok<NASGU>
                try



                    evalNumericTypesFimath();
                catch

                end
                return;
            end
            functionStrList{end+1}=[structExplosionStmtStr,';'];
            functionStrList{end+1}='end';

            fcntionStr=strjoin(functionStrList,char(10));
            evalNumericTypesFimath();

            function evalNumericTypesFimath()



                eval(['protoNumerictypes.',origLhsSymbolName,' = tmpNumerictypes.',tmpNewLhsName,';']);
                eval(['protoFimaths.',origLhsSymbolName,' = tmpFimaths.',tmpNewLhsName,';']);
            end

            function result=isCastNecessary(lhsVarInfo,rhsVarInfo)
                result=false;
                if~isempty(rhsVarInfo.loggedFields)&&(isempty(lhsVarInfo.annotated_Type)||isempty(rhsVarInfo.annotated_Type))

                    return;
                end
                for ii=1:length(rhsVarInfo.loggedFields)
                    rhsFullFieldName=rhsVarInfo.loggedFields{ii};
                    leafPropName=regexprep(rhsFullFieldName,[rhsVarInfo.SymbolName,'.'],'','Once');
                    rhsType=rhsVarInfo.annotated_Type{ii};
                    rfm=rhsVarInfo.getFimathForStructField(ii);

                    lhsFullFieldName=[lhsVarInfo.SymbolName,'.',leafPropName];
                    idx=strcmp(lhsVarInfo.loggedFields,lhsFullFieldName);
                    lhsType=lhsVarInfo.annotated_Type(idx);
                    lhsType=lhsType{1};

                    lfm=rhsVarInfo.getFimathForStructField(idx);

                    if~isequal(lhsType,rhsType)||~isequal(rfm,lfm)
                        result=true;
                        break;
                    end
                end
            end
        end
    end
end