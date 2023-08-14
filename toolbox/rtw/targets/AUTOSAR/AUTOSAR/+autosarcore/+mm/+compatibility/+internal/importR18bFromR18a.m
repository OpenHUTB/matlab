function importR18bFromR18a(transformer)






    SectionTypeTransformMap=containers.Map(...
    {'CALIBRATION-VARIABLES','CALIBRATION-OFFLINE',...
    'CALIBRATION-ONLINE','CALPRM','CODE','CONFIG-DATA','CONST',...
    'EXCLUDE-FROM-FLASH','VAR','VAR-FAST','VAR-NO-INIT',...
    'VAR-POWER-ON-INIT','USER-DEFINED'},...
    {'CalibrationVariables','Calprm','Calprm','Calprm','Code',...
    'ConfigData','Const','ExcludeFromFlash','Var','Var','Var','Var','Var'});
    transformer.transformAttributeValue('packagedElement',...
    'Simulink.metamodel.arplatform.common.SwAddrMethod',...
    'SectionType',SectionTypeTransformMap);

    transformer.setPostModelTransform(@i_postModelTransform);
end

function m3iModel=i_postModelTransform(m3iModel)
    m3iModel=i_migrateArRootXmlOptions(m3iModel);
end



function m3iModel=i_migrateArRootXmlOptions(m3iModel)
    arRoot=m3iModel.RootPackage.front();
    if isempty(arRoot.ComponentQualifiedName)

        return
    end


    route=regexp(arRoot.ComponentQualifiedName,'/','split');
    route(cellfun(@isempty,route))=[];
    m3iRouteList=M3I.SequenceOfString.make(m3iModel);
    for ii=1:numel(route)
        m3iRouteList.append(route{ii});
    end
    m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByName(arRoot,m3iRouteList);
    assert(m3iSeq.size()==1,'Did not find component: %s',arRoot.ComponentQualifiedName);
    m3iComp=m3iSeq.at(1);



    m3iComp.setExternalToolInfo(M3I.ExternalToolInfo(...
    'ARXML_InternalBehaviorQualifiedName',arRoot.InternalBehaviorQualifiedName));
    m3iComp.setExternalToolInfo(M3I.ExternalToolInfo(...
    'ARXML_ImplementationQualifiedName',arRoot.ImplementationQualifiedName));


    arRoot.ComponentQualifiedName='';
    arRoot.InternalBehaviorQualifiedName='';
    arRoot.ImplementationQualifiedName='';
end


