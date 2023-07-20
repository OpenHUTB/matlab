classdef ImplicitMappingHelper<handle





    methods(Static)

        function isImplicit=isDataTypeMapImplicit(dtMap)


            dtMapInfo=autosar.mm.Model.getExtraExternalToolInfo(dtMap,...
            'ARXML_IsImplicit',{'IsImplicit'},{'%d'});
            if dtMapInfo.IsImplicit
                isImplicit=true;
            else
                isImplicit=false;
            end
        end

        function reportImplicitMappingClashError(m3iModel,app2ImpTypeQNameMap,appTypeQName,impTypeQName,impTypeQNameInMap,...
            appTypeQNameForError,impTypeQNameForError,impTypeQNameForErrorInMap,isDtMapImplicit,isConflictingDtMapImplicit)
            import autosar.mm.mm2sl.ImplicitMappingHelper


            appType2StructElementObjCellMap=ImplicitMappingHelper.buildAppType2StructElementObjMap(m3iModel);
            appBaseType2ArrayObjMap=ImplicitMappingHelper.buildAppBaseType2ArrayObjMap(m3iModel);


            [badAppParentQName,badImpParentQName]=...
            ImplicitMappingHelper.findQualifiedNamesOfStructElemOrArrayOwningAppType(m3iModel,...
            appTypeQName,impTypeQName,app2ImpTypeQNameMap,appType2StructElementObjCellMap,appBaseType2ArrayObjMap);
            if isDtMapImplicit&&~isConflictingDtMapImplicit


                DAStudio.error('autosarstandard:importer:ImplicitExplicitDataTypeMapClash',...
                appTypeQNameForError,badAppParentQName,impTypeQNameForError,badImpParentQName,impTypeQNameForErrorInMap);
            elseif isDtMapImplicit&&isConflictingDtMapImplicit

                [~,badImpParentQName2]=ImplicitMappingHelper.findQualifiedNamesOfStructElemOrArrayOwningAppType(m3iModel,...
                appTypeQName,impTypeQNameInMap,app2ImpTypeQNameMap,appType2StructElementObjCellMap,appBaseType2ArrayObjMap);
                DAStudio.error('autosarstandard:importer:ImplicitImplicitDataTypeMapClash',...
                appTypeQNameForError,badAppParentQName,impTypeQNameForError,badImpParentQName,impTypeQNameForErrorInMap,badImpParentQName2);
            end
        end

    end

    methods(Static,Access=private)

        function appType2StructElementObjCellMap=buildAppType2StructElementObjMap(m3iModel)


            import Simulink.metamodel.types.Structure

            appType2StructElementObjCellMap=containers.Map();
            structSeq=autosar.mm.Model.findObjectByMetaClass(m3iModel,Structure.MetaClass);
            for i=1:structSeq.size
                structType=structSeq.at(i);
                for j=1:structType.Elements.size
                    structElement=structType.Elements.at(j);
                    if~isempty(structElement.Type)
                        if structElement.Type.IsApplication
                            if appType2StructElementObjCellMap.isKey(structElement)
                                structElementsInMap=appType2StructElementObjCellMap(structElement);
                                appType2StructElementObjCellMap(structElement.Type.qualifiedName)=[structElementsInMap,{structElement}];
                            else
                                appType2StructElementObjCellMap(structElement.Type.qualifiedName)={structElement};
                            end
                        end
                    end
                end
            end
        end

        function appBaseType2ArrayObjMap=buildAppBaseType2ArrayObjMap(m3iModel)


            import Simulink.metamodel.types.Matrix

            appBaseType2ArrayObjMap=containers.Map();
            arraySeq=autosar.mm.Model.findObjectByMetaClass(m3iModel,Matrix.MetaClass);
            for i=1:arraySeq.size
                arrayObj=arraySeq.at(i);
                if~isempty(arrayObj.BaseType)
                    baseTypeObj=arrayObj.BaseType;
                    if baseTypeObj.IsApplication
                        if appBaseType2ArrayObjMap.isKey(baseTypeObj.qualifiedName)
                            arrayObjectsInMap=appBaseType2ArrayObjMap(baseTypeObj.qualifiedName);
                            appBaseType2ArrayObjMap(baseTypeObj.qualifiedName)=[arrayObjectsInMap,{arrayObj}];
                        else
                            appBaseType2ArrayObjMap(baseTypeObj.qualifiedName)={arrayObj};
                        end
                    end
                end
            end
        end

        function[appParentQName,impParentQName]=findQualifiedNamesOfStructElemOrArrayOwningAppType(...
            m3iModel,appTypeQName,impTypeQName,app2ImpTypeQNameMap,appType2StructElementObjCellMap,appBaseType2ArrayObjMap)
            import autosar.mm.mm2sl.ImplicitMappingHelper

            if appType2StructElementObjCellMap.isKey(appTypeQName)

                [appParentQName,impParentQName]=ImplicitMappingHelper.findStructElemTypeCausingImplicitMappingClash(...
                m3iModel,appTypeQName,impTypeQName,app2ImpTypeQNameMap,appType2StructElementObjCellMap);
            elseif appBaseType2ArrayObjMap.isKey(appTypeQName)

                [appParentQName,impParentQName]=ImplicitMappingHelper.findArrayTypeCausingImplicitMappingClash(...
                m3iModel,appTypeQName,impTypeQName,app2ImpTypeQNameMap,appBaseType2ArrayObjMap);
            end
        end

        function[appStructElemQName,impStructElemQName]=findStructElemTypeCausingImplicitMappingClash(...
            m3iModel,appTypeQName,impTypeQName,app2ImpTypeQNameMap,appType2StructElementObjCellMap)


            cellOfAppStructElementObjs=appType2StructElementObjCellMap(appTypeQName);
            for i=1:length(cellOfAppStructElementObjs)

                appStructElementObj=cellOfAppStructElementObjs{i};
                appStructObj=appStructElementObj.Structure;
                impStructQName=app2ImpTypeQNameMap(appStructObj.qualifiedName);
                m3iSeq=autosar.mm.Model.findObjectByName(m3iModel,impStructQName);
                impStructObj=m3iSeq.at(1);
                for j=1:impStructObj.Elements.size
                    impStructElementObj=impStructObj.Elements.at(j);
                    if strcmp(impStructElementObj.Type.qualifiedName,impTypeQName)

                        appStructElemQName=autosar.api.Utils.getQualifiedName(appStructElementObj);
                        impStructElemQName=autosar.api.Utils.getQualifiedName(impStructElementObj);
                        break;
                    end
                end
            end
            assert(~isempty(appStructElemQName),'Expect to find the structure element causing implicit mapping clash')
        end

        function[appArrayQName,impArrayQName]=findArrayTypeCausingImplicitMappingClash(...
            m3iModel,appTypeQName,impTypeQName,app2ImpTypeQNameMap,appBaseType2ArrayObjMap)


            cellOfAppArrayObjs=appBaseType2ArrayObjMap(appTypeQName);
            for i=1:length(cellOfAppArrayObjs)

                appArrayObj=cellOfAppArrayObjs{i};
                impArrayQName=app2ImpTypeQNameMap(appArrayObj.qualifiedName);
                m3iSeq=autosar.mm.Model.findObjectByName(m3iModel,impArrayQName);
                impArrayObj=m3iSeq.at(1);
                if strcmp(impArrayObj.BaseType.qualifiedName,impTypeQName)

                    appArrayQName=autosar.api.Utils.getQualifiedName(appArrayObj);
                    impArrayQName=autosar.api.Utils.getQualifiedName(impArrayObj);
                    break;
                end
            end
            assert(~isempty(appArrayQName),'Expect to find the array whos base type is causing implicit mapping clash')
        end
    end
end


