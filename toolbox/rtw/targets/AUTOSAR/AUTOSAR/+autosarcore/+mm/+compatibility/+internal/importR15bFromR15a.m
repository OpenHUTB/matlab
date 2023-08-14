function importR15bFromR15a(transformer)



    function m3iModel=postModelTransform(m3iModel)


        childSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(m3iModel,...
        Simulink.metamodel.arplatform.common.DataTypeMappingSet.MetaClass,true);
        for id=1:childSeq.size()
            dtMapVec=childSeq.at(id).dataTypeMap;
            for idx=1:dtMapVec.size
                dtMap=dtMapVec.at(idx);
                appType=dtMap.ApplicationType;

                if isa(appType,'Simulink.metamodel.types.LookupTableType')
                    appType.BaseType.IsApplication=true;
                elseif isa(appType,'Simulink.metamodel.types.SharedAxisType')
                    appType.Axis.BaseType.IsApplication=true;
                else
                    appType.IsApplication=true;
                end
                while isa(appType,'Simulink.metamodel.types.Matrix')
                    appType=appType.BaseType;
                    appType.IsApplication=true;
                end
            end
        end


        childSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(m3iModel,...
        Simulink.metamodel.types.DataConstr.MetaClass,true);
        for id=1:childSeq.size()
            dataConstr=childSeq.at(id);
            if dataConstr.PrimitiveType.size()>0&&~dataConstr.PrimitiveType.at(1).IsApplication
                if m3iModel.RootPackage.size()>0
                    arRoot=m3iModel.RootPackage.front();
                    arRoot.setExternalToolInfo(M3I.ExternalToolInfo('ARXML_InternalDataConstraintExport','true#Logical'));
                end
                break;
            end
        end
    end
    transformer.setPostModelTransform(@postModelTransform);
    transformer.renameAttribute('packagedElement','Simulink.metamodel.types.CompuMethod','Enumeration','PrimitiveType');
    transformer.renameAttribute('packagedElement','Simulink.metamodel.types.Enumeration','GroundValue','DefaultValue');
end


