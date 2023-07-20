classdef Util






    properties(Constant)
        VarlengthInfoBusName='SL_Bus_DDSVariableLengthArrayInfo'
        AnnotationName='SL_Annotation'
        UnknownAttribTag='UnknownAttributes'
    end


    methods(Static)
        function infostruct=getArrayInfoStructMetadata()

            infostruct.PropertySuffix='_SL_Info';
            infostruct.CurLengthProp='CurrentLength';
            infostruct.MaxLengthProp='MaxLength';
            infostruct.LengthTypeSL='uint32';
            infostruct.LengthTypeCpp='uint32_T';
        end


        function arrayInfoElemName=getArrayInfoElementName(arrayElemName)

            infostruct=dds.internal.simulink.Util.getArrayInfoStructMetadata();
            arrayInfoElemName=[arrayElemName,infostruct.PropertySuffix];
        end

        function[datatype,busName]=varlenInfoBusDataTypeStr()

            busName=dds.internal.simulink.Util.VarlengthInfoBusName;
            datatype=['Bus: ',busName];
        end

        function addVarlenInfoBusIfNeeded(map)%#ok<INUSD>


            return;
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
        end

        function warningNoBacktrace(varargin)


            oldWarnState=warning('query','backtrace');
            cleanup=onCleanup(@()warning(oldWarnState));
            warning('off','backtrace');
            warning(varargin{:});
        end

        function importFromDDSToSimulink(dictionaryConnection)


            ds=dictionaryConnection.getSection('Design Data');
            source=dictionaryConnection.filepath;
            dd=Simulink.dd.open(source);
            tmpMdl=mf.zero.Model.createTransientModel;

            mf0Model=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(source);
            catalogContainer=sldd.mapping.CatalogContainer.getCatalogContainer(source);
            ddsMap=catalogContainer.catalog;
            simObjectVisitor=dds.internal.simulink.GetSimObjectsVisitor;
            while simObjectVisitor.NeedToVisit
                status=simObjectVisitor.visitModel(mf0Model);
                if~status
                    break;
                end
                keys=simObjectVisitor.getObjectNamesToAdd;
                for idx=1:numel(keys)
                    entry=simObjectVisitor.ObjectMap(keys{idx});
                    dd_entry=ds.addEntry(entry.Name,entry.Obj);
                    dd.setIsEntryDerived(dd_entry.ID,true);
                    if~isempty(ddsMap)
                        slddVarId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,dd_entry.UUID,'','SLDD');
                        ddsVarId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,entry.UUID,'','DDS');
                        ddsMap.addAssociation(ddsVarId,slddVarId);
                    end
                    simObjectVisitor.updateAdded(keys{idx},true);
                end
            end
            simObjectVisitor.reset();
            dd.close();


            dds.internal.simulink.DDSModelToSimulinkListener(mf0Model,dictionaryConnection.filepath);
        end

        function[ddConn,importedModel]=createFromDefaultDDSXml(newDDName)


            defaultdds='defaultdds_cpp.xml';
            xmlFileList={fullfile(matlabroot,'toolbox','dds','src',defaultdds)};
            [ddConn,importedModel]=dds.internal.simulink.Util.importDDSXml(xmlFileList,newDDName);
        end

        function ddsMf0Model=importXmlFiles(xmlFileList,inModel,annotationKey)



            par=dds.datamodel.io.XmlParser;
            if nargin>2&&~isempty(annotationKey)
                par.annotationName=annotationKey;
            end
            if nargin>1&&~isempty(inModel)
                par.Model=inModel;
            end
            if iscell(xmlFileList)
                xmlFile=xmlFileList{1};
            else
                xmlFile=xmlFileList;
            end
            par.parseFile(xmlFile);
            if iscell(xmlFileList)&&numel(xmlFileList)>1
                for i=2:numel(xmlFileList)
                    par.parseFile(xmlFileList{i});
                end
            end
            ddsMf0Model=par.Model;
        end

        function[ddConn,importedModel]=importDDSXml(xmlFileList,newDDName,vendorKey,inClonedModel)


            importedModel=[];%#ok<NASGU>
            annotationKey='omg';
            if nargin>2&&~isempty(vendorKey)
                reg=dds.internal.vendor.DDSRegistry;
                ent=reg.getEntryFor(vendorKey);
                if isfield(ent,'ImportXMLAndIDL')&&~isempty(ent.ImportXMLAndIDL)
                    importFunc=ent.ImportXMLAndIDL;
                else
                    importFunc=ent.ImportXML;
                end
                annotationKey=ent.AnnotationKey;
            else
                importFunc=@dds.internal.simulink.Util.importXmlFiles;
            end

            if nargin>3
                ddsMf0Model=inClonedModel;
            else
                ddsMf0Model=mf.zero.Model;
            end

            setUseShortName=dds.internal.isSystemUsingShortName(ddsMf0Model);

            importTxn=ddsMf0Model.beginRevertibleTransaction();

            oldWarnState=warning('query','backtrace');
            cleanup=onCleanup(@()warning(oldWarnState));
            warning('off','backtrace');

            ddsMf0Model=importFunc(xmlFileList,ddsMf0Model,annotationKey);


            if setUseShortName
                dds.internal.setSystemToUseShortName(ddsMf0Model,true);
            end


            if(nargin<2)||(nargin>1&&isempty(newDDName))
                if iscell(xmlFileList)
                    xmlFile=xmlFileList{1};
                else
                    xmlFile=xmlFileList;
                end
                [~,ddname,~]=fileparts(xmlFile);
                ddname=strrep(ddname,'.','_');
                newDDName=fullfile(pwd,[ddname,'.sldd']);
            end
            if~isfile(newDDName)
                ddConn=Simulink.data.dictionary.create(newDDName);
            else
                ddConn=Simulink.data.dictionary.open(newDDName);
            end


            fullNameVisitor=dds.internal.GetFullNamesVisitor;
            fullNameVisitor.AllowConflicts=true;
            fullNameVisitor.IgnoreModuleConflicts=true;
            fullNameVisitor.visitModel(ddsMf0Model);
            if isempty(fullNameVisitor.TypesMap)
                hasConflict=false;
            else
                typeNames=fullNameVisitor.TypesMap.keys;
                hasConflict=dds.internal.simulink.Util.checkForConflictsInSLDD(ddConn,typeNames);
            end
            if hasConflict||~isempty(fullNameVisitor.ConflictsInTypesMap)
                if~isempty(fullNameVisitor.ConflictsInTypesMap)
                    keys=fullNameVisitor.ConflictsInTypesMap.keys;
                    numConflicts=numel(keys);
                    modelConflictList=struct('id',zeros(1,numConflicts),...
                    'UUIDs',zeros(1,numConflicts),...
                    'className',zeros(1,numConflicts));
                    for i=1:numConflicts
                        modelConflictList(i).id=keys{i};
                        modelConflictList(i).UUIDs=fullNameVisitor.ConflictsInTypesMap(keys{i});
                    end
                else
                    modelConflictList=[];
                end
                dds.internal.simulink.Util.askUserToResolveConflict(ddConn,typeNames,xmlFileList,modelConflictList,importTxn,ddsMf0Model);
            else
                importTxn.commit();
            end

            hasDDSpart=Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath);
            if hasDDSpart

                existingModel=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(ddConn.filepath);
                updateTxn=existingModel.beginRevertibleTransaction();

                dds.internal.updateModel(existingModel,ddsMf0Model);

                upd=dds.internal.UpdateTypeMapVisitor();
                status=upd.visitModel(existingModel);
                assert(status);
                updateTxn.commit();

                ddConn.saveChanges;
                importedModel=existingModel;
            else

                Simulink.DDSDictionary.ModelRegistry.registerWithDD(ddsMf0Model,ddConn.filepath);
                dds.internal.simulink.Util.importFromDDSToSimulink(ddConn);

                ddConn.saveChanges;
                importedModel=ddsMf0Model;
            end

        end

        function continueImport(ddConn,sourceFile,bOverwrite,hasCheckbox,varargin)%#ok<INUSL>
            function moveRefs(from,to)


                clz=class(from);
                switch(clz)
                case 'dds.datamodel.types.Alias'
                    refProperties={'AliasRefs','RegisterTypeRefs','StructMemberRefs','ConstRefs','MapKeyMemberRefs'};
                    toProperties={'TypeRef','TypeRef','TypeRef','TypeRef','TypeRef'};
                case 'dds.datamodel.types.Const'
                    refProperties={'ConstRefs','ValueOrConstRefs'};
                    toProperties={'TypeRef','ValueConst'};
                case 'dds.datamodel.types.Enum'
                    refProperties={'ConstRefs','AliasRefs','RegisterTypeRefs'};
                    toProperties={'TypeRef','TypeRef','TypeRef'};
                otherwise
                    refProperties={};
                    toProperties={};
                end
                if isempty(refProperties)
                    return;
                end
                for propIdx=1:numel(refProperties)
                    refs=from.(refProperties{propIdx});

                    references=cell(1,refs.Size);
                    for refPropIdx=1:refs.Size
                        references{refPropIdx}=refs(refPropIdx);
                    end
                    for refIdx=1:numel(references)
                        references{refIdx}.(toProperties{propIdx})=to;



...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
                    end
                end
            end

            function destroyEmptyModules(modObj)
                if isa(modObj,'dds.datamodel.types.Module')
                    if modObj.Elements.Size<1
                        thisModparent=modObj.Container;
                        modObj.destroy();
                        destroyEmptyModules(thisModparent);
                    end
                end
            end

            importTxn=varargin{1};
            modelConflictList=varargin{2};
            ddsMf0Model=varargin{3};
            if bOverwrite

                for i=1:numel(modelConflictList)
                    objIds=modelConflictList(i).UUIDs;
                    for j=1:numel(objIds)-1
                        el=ddsMf0Model.findElement(objIds{j});
                        if~isempty(el)
                            moveToEl=ddsMf0Model.findElement(objIds{end});


                            moveRefs(el,moveToEl);
                            parent=el.Container;
                            el.destroy();
                            destroyEmptyModules(parent);
                        end
                    end
                end

                tpe=ddsMf0Model.topLevelElements;
                elToDestroy={};
                for idx=1:numel(tpe)
                    if isa(tpe(idx),'dds.datamodel.system.System')
                        systemObj=tpe(idx);

                        typeLibs=systemObj.TypeLibraries;
                        for tIdx=1:typeLibs.Size
                            if typeLibs(tIdx).Elements.Size<1
                                elToDestroy{end+1}=typeLibs(tIdx);%#ok<AGROW> 
                            end
                        end
                    end
                end
                for nIdx=1:numel(elToDestroy)
                    elToDestroy{nIdx}.destroy();
                end
                importTxn.commit();
            else
                importTxn.rollBack();
            end
        end

        function exportToXmlFile(ddsMf0Model,xmlFileName,requiredApplicationPath,annotationKey)


            clonedModel=dds.internal.simulink.Util.cloneModel(ddsMf0Model);

            filteredModel=dds.internal.simulink.Util.removeOtherApplications(clonedModel,requiredApplicationPath);

            ddsser=dds.datamodel.io.XmlSerializer;
            if nargin>3
                ddsser.annotationName=annotationKey;
            end
            ddsser.serializeToFile(filteredModel,xmlFileName);

        end

        function exportDDSXml(ddsMf0Model,xmlFileName,requiredApplicationPath,vendorKey)


            if nargin>3
                reg=dds.internal.vendor.DDSRegistry;
                ent=reg.getEntryFor(vendorKey);
                exportFunc=ent.ExportToXML;
            else
                exportFunc=@dds.internal.simulink.Util.exportToXmlFile;
            end

            exportFunc(ddsMf0Model,xmlFileName,requiredApplicationPath);
        end

        function hasConflict=checkForConflictsInSLDD(dictionaryConnection,ddsTypeNames)


            hasConflict=false;
            ds=dictionaryConnection.getSection('Design Data');
            catalogContainer=sldd.mapping.CatalogContainer.getCatalogContainer(dictionaryConnection.filepath);
            ddsMap=catalogContainer.catalog;
            tmpMdl=mf.zero.Model.createTransientModel;




            if numel(unique(ddsTypeNames))~=numel(ddsTypeNames)
                hasConflict=true;
                return;
            end

            for ddsName=ddsTypeNames
                if ds.exist(ddsName{1})
                    isDDSEntry=false;
                    entry=ds.getEntry(ddsName{1});
                    slddVarId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,entry.UUID,'','SLDD');
                    associations=ddsMap.getAssociations(slddVarId);
                    for association=associations
                        if strcmpi('DDS',association.sectionName)
                            isDDSEntry=true;
                            break;
                        end
                    end

                    if~isDDSEntry
                        hasConflict=true;
                        break;
                    end
                end
            end
        end

        function conflictListStruct=getConflictsInSLDD(dictionaryConnection,ddsTypeNames)




            ds=dictionaryConnection.getSection('Design Data');
            catalogContainer=sldd.mapping.CatalogContainer.getCatalogContainer(dictionaryConnection.filepath);
            ddsMap=catalogContainer.catalog;
            tmpMdl=mf.zero.Model.createTransientModel;

            conflictList={};


            [uniqueNames,~,ic]=unique(ddsTypeNames);
            if numel(uniqueNames)~=numel(ddsTypeNames)
                conflictList=uniqueNames(histcounts(ic)>1);
            end

            for ddsName=ddsTypeNames
                if ds.exist(ddsName{1})
                    isDDSEntry=false;
                    entry=ds.getEntry(ddsName{1});
                    slddVarId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,entry.UUID,'','SLDD');
                    associations=ddsMap.getAssociations(slddVarId);
                    for association=associations
                        if strcmpi('DDS',association.sectionName)
                            isDDSEntry=true;
                            break;
                        end
                    end

                    if~isDDSEntry
                        conflictList=unique([conflictList,ddsName]);
                    end
                end
            end

            numOfConflicts=numel(conflictList);
            if numOfConflicts>0
                conflictListStruct=struct('id',zeros(1,numOfConflicts),...
                'UUID',zeros(1,numOfConflicts),...
                'className',zeros(1,numOfConflicts));

                for i=1:numOfConflicts
                    conflictListStruct(i).id=conflictList{i};
                    entry=ds.getEntry(conflictList{i});
                    conflictListStruct(i).UUID=entry.UUID;
                    conflictListStruct(i).className=class(entry.getValue());
                end
            else
                conflictListStruct=struct([]);
            end
        end

        function askUserToResolveConflict(ddConn,typeNames,xmlFileList,modelConflictList,importTxn,ddsMf0Model)
            conflictsStructList=dds.internal.simulink.Util.getConflictsInSLDD(ddConn,typeNames);
            numSlddConflicts=numel(conflictsStructList);
            numMdlConflicts=numel(modelConflictList);
            conflictsList=cell(numSlddConflicts+numMdlConflicts,2);
            for i=1:numSlddConflicts
                conflictsList{i,1}=conflictsStructList(i).id;
                conflictsList{i,2}='Design_Data';
            end
            for i=1:numMdlConflicts
                conflictsList{numSlddConflicts+i,1}=modelConflictList(i).id;
                conflictsList{numSlddConflicts+i,2}='Model';
            end
            bAllowOverwriteOption='always';
            if iscell(xmlFileList)
                sourceFile=xmlFileList{1};
            else
                sourceFile=xmlFileList;
            end
            dlg=Simulink.dd.DictionaryPreImport(ddConn,conflictsList,sourceFile,bAllowOverwriteOption,@dds.internal.simulink.Util.continueImport,importTxn,modelConflictList,ddsMf0Model);
            mydlg=DAStudio.Dialog(dlg,'','DLG_STANDALONE');
            waitfor(mydlg);
        end

        function[attached,dictionary,ddConn]=isModelAttachedToDDSDictionary(modelName)


            attached=false;
            dictionary=get_param(modelName,'DataDictionary');


            ddConn=[];
            if~isempty(dictionary)
                try
                    ddConn=Simulink.data.dictionary.open(dictionary);
                    attached=Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath);
                catch ex
                    dds.internal.simulink.Util.warningNoBacktrace(ex.message);
                end
            end
        end

        function[compName,vendorName,vendorKey,ddConn]=getCurrentMapSetting(modelName)



            appName=dds.internal.simulink.Util.getApplicationName(modelName);
            if isempty(appName)
                compName=get_param(modelName,'Name');
            else
                compName=appName;
            end

            toolchain=get_param(modelName,'Toolchain');
            reg=dds.internal.vendor.DDSRegistry;
            lst=reg.getVendorList;
            defEnt=lst(startsWith({lst(:).Key},'rticonnext'));
            vendorName=defEnt.DisplayName;
            vendorKey=defEnt.Key;
            for i=1:numel(lst)
                ent=reg.getEntryFor(lst(i).Key);
                if isequal(ent.DefaultToolchain,toolchain)
                    vendorName=lst(i).DisplayName;
                    vendorKey=lst(i).Key;
                    break;
                end
            end
            [attached,~,ddConn]=dds.internal.simulink.Util.isModelAttachedToDDSDictionary(modelName);
            if~attached
                ddConn=[];
            end
        end

        function[attached,dictName,curDictName]=attachDDSDictionaryToModel(modelName,dictionaryPath)


            ddConn=Simulink.data.dictionary.open(dictionaryPath);
            [folder,fname,fext]=fileparts(ddConn.filepath);
            dictName=[fname,fext];
            curDictName=get_param(modelName,'DataDictionary');

            if Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath)
                curDir=cd(folder);
                clnUp=onCleanup(@()cd(curDir));
                set_param(modelName,'DataDictionary',[fname,fext]);
                attached=true;
            else
                attached=false;
            end
        end

        function ret=setupModelMappingToDDS(modelName,componentName)




            if slfeature("CppIOCustomization")~=1
                ret=false;
                return;
            end


            mapping=Simulink.CodeMapping.getCurrentMapping(modelName);
            if isempty(mapping)
                out=Simulink.CodeMapping.create(modelName,'init','CppModelMapping');
                if~out
                    ret=false;
                    return;
                end
                mapping=Simulink.CodeMapping.getCurrentMapping(modelName);
            end
            mapping.DeploymentType='Application';


            if isempty(componentName)
                componentName=modelName;
            end
            mapping.SoftwareArtifactName=componentName;

            ret=true;
        end

        function setupModelForDDS(modelName,dictPath,componentName,vendorKey,setupMapping)

            function cleanup


                if~isequal(curStf,'ert.tlc')
                    set_param(modelName,'SystemTargetFile',curStf);
                end
                if~isequal(dictName,curDictName)
                    set_param(modelName,'DataDictionary',curDictName);
                end
                set_param(modelName,'Dirty','off');
            end

            if nargin<5
                setupMapping=true;
            end


            set_param(modelName,'CodeGenBehavior','Default');

            curStf=get_param(modelName,'SystemTargetFile');
            if~isequal(curStf,'ert.tlc')
                set_param(modelName,'SystemTargetFile','ert.tlc');
            end





            solverType=get_param(modelName,'SolverType');
            if~isequal(solverType,'Fixed-Step')
                set_param(modelName,'SolverType','Fixed-Step');
            end


            try
                set_param(modelName,'EmbeddedCoderDictionary','');
                set_param(modelName,'TargetLang','C++');
            catch ex
                rethrow(ex.cause{1});
            end


            set_param(modelName,'TargetLangStandard','C++11 (ISO)');


            set_param(modelName,'GenerateSampleERTMain','off');


            set_param(modelName,'SimGenImportedTypeDefs','on');

            reg=dds.internal.vendor.DDSRegistry;
            ent=reg.getEntryFor(vendorKey);
            setupFunc=ent.SetupModel;
            setupFunc(modelName);


            [~,dictName,dictExt]=fileparts(dictPath);
            [attached,dictName,curDictName]=dds.internal.simulink.Util.attachDDSDictionaryToModel(modelName,[dictName,dictExt]);
            if~attached

                cleanup();
                error(message('dds:adaptor:CouldNotAttachDict',modelName));
            end

            if setupMapping
                try
                    ret=dds.internal.simulink.Util.setupModelMappingToDDS(modelName,componentName);
                    if~ret
                        error(message('dds:adaptor:CouldNotSetupModelForDDS',modelName));
                    end

                    cp=simulinkcoder.internal.CodePerspective.getInstance;
                    cp.turnOnPerspective(modelName);
                catch ex
                    cleanup();
                    rethrow(ex);
                end
            end
        end

        function appName=getApplicationName(modelName)



            try
                mapping=Simulink.CodeMapping.getCurrentMapping(modelName);
                if isempty(mapping)||(~isempty(mapping)&&~isprop(mapping,'SoftwareArtifactName'))



                    mapping=coder.mapping.internal.MappingUtils.getModelMapping(...
                    modelName,'EmbeddedCoderCPP','CppModelMapping');

                    if isempty(mapping)||(~isempty(mapping)&&~isprop(mapping,'SoftwareArtifactName'))
                        appName=modelName;
                    else
                        appName=mapping.SoftwareArtifactName;
                    end
                else
                    appName=mapping.SoftwareArtifactName;
                end
            catch ex %#ok<NASGU> %For debugging

                appName=modelName;
            end
        end

        function ret=checkIfModelMappingIsSetToDDS(modelName)

            if slfeature("CppIOCustomization")~=1
                ret=false;
                return;
            end



            if~configset.internal.util.isConfigSetResolved(modelName)
                ret=false;
                return
            end


            if~strcmp(get_param(modelName,'TargetLang'),'C++')
                ret=false;
                return;
            end


            mapping=Simulink.CodeMapping.getCurrentMapping(modelName);
            if isempty(mapping)
                ret=false;
                return;
            end

            if~isa(mapping,'Simulink.CppModelMapping.ModelMapping')
                ret=false;
                return;
            end

            if~strcmp(mapping.DeploymentType,'Application')
                ret=false;
                return;
            end

            attached=dds.internal.simulink.Util.isModelAttachedToDDSDictionary(modelName);
            if~attached
                ret=false;
                return;
            end


            if strcmp(get_param(modelName,'GenerateSampleERTMain'),'on')
                ret=false;
                return;
            end

            ret=true;
        end

        function strVal=convertToStr(value,precision)

            if nargin<2
                precision=100;
            end
            if isnumeric(value)
                strVal=num2str(value,precision);
            else
                strVal=value;
            end
        end

        function theMember=findOrCreateAnnnontationMember(ddsObject,create,memberName)

            theAnon=[];
            theMember=[];
            for i=1:ddsObject.Annotations.Size
                if isequal(ddsObject.Annotations(i).Name,dds.internal.simulink.Util.AnnotationName)
                    theAnon=ddsObject.Annotations(i);
                    break;
                end
            end
            if isempty(theAnon)
                if create
                    theAnon=ddsObject.createIntoAnnotations(...
                    struct('metaClass','dds.datamodel.types.Annotation',...
                    'Name',dds.internal.simulink.Util.AnnotationName));
                else
                    return;
                end
            end
            memKeys=theAnon.Members.keys;
            if isempty(memberName)
                memberName=dds.internal.simulink.Util.AnnotationName;
            end
            for i=1:numel(memKeys)
                if isequal(theAnon.Members{memKeys(i)}.Name,memberName)
                    theMember=theAnon.Members{memKeys(i)};
                    break;
                end
            end
            if isempty(theMember)
                if create
                    if isempty(memKeys)
                        nextId=uint64(1);
                    else
                        nextId=memKeys(end)+uint64(1);
                    end
                    theMember=theAnon.createIntoMembers(...
                    struct('metaClass','dds.datamodel.types.AnnotationMember',...
                    'Idx',nextId,...
                    'Name',memberName));
                end
            end
        end

        function createOrReplaceAnnotationOnNamedElement(ddsObject,simObject,fldsToEncode,memberName)

            structToEncode=struct();
            for i=1:numel(fldsToEncode)
                try
                    structToEncode.(fldsToEncode{i})=simObject.(fldsToEncode{i});
                catch
                end
            end
            jsonStr=jsonencode(structToEncode);
            theMember=dds.internal.simulink.Util.findOrCreateAnnnontationMember(ddsObject,true,memberName);
            theMember.ValueType=dds.internal.simulink.Util.createBasicTypeIn(theMember,'createIntoValueType','string');
            theMember.ValueStr=jsonStr;
        end

        function simObject=getEncodedAnnotationOnNamedElement(ddsObject,simObject,memberName)

            theMember=dds.internal.simulink.Util.findOrCreateAnnnontationMember(ddsObject,false,memberName);
            if~isempty(theMember)
                theStruct=jsondecode(theMember.ValueStr);
                fieldsInStruct=fields(theStruct);
                for i=1:numel(fieldsInStruct)
                    try
                        simObject.(fieldsInStruct{i})=theStruct.(fieldsInStruct{i});
                    catch
                    end
                end
            end
        end

        function typeObj=findType(ddsObject,typeName)

            systemObject=ddsObject;
            while~isa(systemObject,'dds.datamodel.system.System')
                systemObject=systemObject.Container;
            end
            typeObj=[];
            splitName=strsplit(typeName,'::');
            for i=1:systemObject.TypeLibraries.Size
                try
                    inter=systemObject.TypeLibraries(i);
                    for j=1:numel(splitName)-1
                        inter=inter.Elements{splitName{j}};
                    end
                    typeObj=inter.Elements{splitName{end}};
                    if~isempty(typeObj)
                        return;
                    end
                catch
                end
            end
        end

        function isBasic=isBasicType(matTypeClass)

            isBasic=ismember(matTypeClass,{...
            'boolean','logical','char',...
            'int8','uint8',...
            'int16','uint16',...
            'int32','uint32',...
            'int64','uint64',...
            'single','double',...
            'string'});
        end

        function typeObj=createBasicTypeIn(ddsObject,methodName,matTypeClass)


            switch(matTypeClass)
            case{'boolean','logical'}
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Boolean'...
                ));
            case 'char'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Char',...
                'Wide',false...
                ));
            case 'int8'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Integer',...
                'NumBits',uint32(8),...
                'Signed',true...
                ));
            case 'uint8'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Integer',...
                'NumBits',uint32(8),...
                'Signed',false...
                ));
            case 'int16'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Integer',...
                'NumBits',uint32(16),...
                'Signed',true...
                ));
            case 'uint16'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Integer',...
                'NumBits',uint32(16),...
                'Signed',false...
                ));
            case 'int32'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Integer',...
                'NumBits',uint32(32),...
                'Signed',true...
                ));
            case 'uint32'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Integer',...
                'NumBits',uint32(32),...
                'Signed',false...
                ));
            case 'int64'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Integer',...
                'NumBits',uint32(64),...
                'Signed',true...
                ));
            case 'uint64'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Integer',...
                'NumBits',uint32(64),...
                'Signed',false...
                ));
            case 'single'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Floating',...
                'NumBits',uint32(32)...
                ));
            case 'double'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.Floating',...
                'NumBits',uint32(64)...
                ));
            case 'string'
                typeObj=ddsObject.(methodName)(...
                struct(...
                'metaClass','dds.datamodel.types.String',...
                'Wide',false...
                ));
            end
        end

        function ddsMf0Model=getMf0ModelFromSimulinkModel(modelName)


            ddsMf0Model=[];
            dd=get_param(modelName,'DataDictionary');
            if isempty(dd)
                return;
            end

            ddConn=Simulink.data.dictionary.open(dd);
            if~Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath)
                return;
            end

            ddsMf0Model=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(ddConn.filepath);
        end

        function topicPath=getTopicPath(ddsMf0Model,topicRef)

            systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
            domainLibs=systemInModel(1).DomainLibraries;
            domainLibNames=keys(domainLibs);
            topicPath='';
            for ii=1:numel(domainLibNames)
                domainLibName=domainLibNames{ii};
                domainLib=domainLibs{domainLibName};
                domains=domainLib.Domains;
                domainNames=keys(domains);
                for jj=1:numel(domainNames)
                    domainName=domainNames{jj};
                    domain=domains{domainName};
                    topics=domain.Topics;
                    topicNames=keys(topics);
                    for kk=1:numel(topicNames)
                        topicName=topicNames{kk};
                        topic=topics{topicName};
                        if topic==topicRef
                            topicPath=[domainLibName,'/',domainName,'/',topicName];
                            return;
                        end
                    end
                end
            end
        end

        function qosPath=getQoSPath(ddsMf0Model,qosRef)


            systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
            qosLibs=systemInModel(1).QosLibraries;
            qosLibNames=keys(qosLibs);
            qosPath='';
            for ii=1:numel(qosLibNames)
                qosLibName=qosLibNames{ii};
                qosLib=qosLibs{qosLibName};
                qosProfiles=qosLib.QosProfiles;
                qosProfileNames=keys(qosProfiles);
                for jj=1:numel(qosProfileNames)
                    qosProfileName=qosProfileNames{jj};
                    qosProfile=qosProfiles{qosProfileName};
                    dataWriterQoses=qosProfile.DataWriterQoses;
                    dataWriterQosNames=keys(dataWriterQoses);
                    for kk=1:numel(dataWriterQosNames)
                        dataWriterQosName=dataWriterQosNames{kk};
                        dataWriterQos=dataWriterQoses{dataWriterQosName};
                        if dataWriterQos==qosRef
                            qosPath=[qosLibName,'/',qosProfileName,'/',dataWriterQosName];
                            return;
                        end
                    end
                    dataReaderQoses=qosProfile.DataReaderQoses;
                    dataReaderQosNames=keys(dataReaderQoses);
                    for kk=1:numel(dataReaderQosNames)
                        dataReaderQosName=dataReaderQosNames{kk};
                        dataReaderQos=dataReaderQoses{dataReaderQosName};
                        if dataReaderQos==qosRef
                            qosPath=[qosLibName,'/',qosProfileName,'/',dataReaderQosName];
                            return;
                        end
                    end
                end

                dataWriterQoses=qosLib.DataWriterQoses;
                dataWriterQosNames=keys(dataWriterQoses);
                for kk=1:numel(dataWriterQosNames)
                    dataWriterQosName=dataWriterQosNames{kk};
                    dataWriterQos=dataWriterQoses{dataWriterQosName};
                    if dataWriterQos==qosRef
                        qosPath=[qosLibName,'/',dataWriterQosName];
                        return;
                    end
                end
                dataReaderQoses=qosLib.DataReaderQoses;
                dataReaderQosNames=keys(dataReaderQoses);
                for kk=1:numel(dataReaderQosNames)
                    dataReaderQosName=dataReaderQosNames{kk};
                    dataReaderQos=dataReaderQoses{dataReaderQosName};
                    if dataReaderQos==qosRef
                        qosPath=[qosLibName,'/',dataReaderQosName];
                        return;
                    end
                end
            end
        end

        function modelTree=replaceOrCreateModelTree(inModel)

            txn=inModel.beginTransaction();
            dds.internal.simulink.Util.deleteAllModelTrees(inModel);
            modelTree=dds.datamodel.modeltree.Tree(inModel);
            txn.commit();
        end

        function deleteAllModelTrees(inModel)

            txn=inModel.beginTransaction();
            tpe=inModel.topLevelElements;
            for el=tpe
                if isa(el,'dds.datamodel.modeltree.Tree')
                    el.destroy();
                end
            end
            txn.commit();
        end

        function otherModel=cloneModel(inModel)

            jsonSer=mf.zero.io.JSONSerializer;
            jsonStr=jsonSer.serializeToString(inModel);
            jsonPar=mf.zero.io.JSONParser;
            jsonPar.parseString(jsonStr);
            otherModel=jsonPar.Model;
        end

        function model=removeOtherApplications(model,requiredApplicationPath)

            function removeAllBut(theMap,reqdKey)
                keys=theMap.keys;
                match=find(strcmp(keys,reqdKey),1);
                keysToErase=keys;
                if~isempty(match)


                    keysToErase(match)=[];
                end
                for aki=1:numel(keysToErase)
                    item=theMap{keysToErase{aki}};
                    item.destroy;
                end
            end
            function filterAppLib(tpe,requiredApplicationPath)
                if isempty(requiredApplicationPath)
                    tpe.ApplicationLibraries.clear();
                    return;
                end
                splitPath=strsplit(requiredApplicationPath,'/');
                removeAllBut(tpe.ApplicationLibraries,splitPath{1});
                theAppLib=tpe.ApplicationLibraries{splitPath{1}};
                if~isempty(theAppLib)
                    removeAllBut(theAppLib.Applications,splitPath{2});
                end
            end
            tpe=model.topLevelElements;
            if isempty(tpe)
                return;
            end
            for i=1:numel(tpe)
                elem=tpe(i);
                switch(class(elem))
                case 'dds.datamodel.system.System'
                    filterAppLib(elem,requiredApplicationPath);
                end
            end

        end

        function isDDSType=isDDSType(modelName,typeName)

            ddsType=dds.internal.simulink.Util.getDDSType(modelName,typeName);
            isDDSType=~isempty(ddsType);
        end

        function isRTIDDSType=isRTIDDSType(modelName,typeName)

            isRTIDDSType=startsWith(get_param(bdroot,'Toolchain'),'RTI ')&&...
            dds.internal.simulink.Util.isDDSType(modelName,typeName);
        end


        function isDDSType=isDDSTypeInCurModel(typeName)

            if(slsvTestingHook('DDSStructAccessFcnTx')>0)
                isDDSType=true;
            elseif dds.internal.coder.isDDSApp(bdroot)
                isDDSType=dds.internal.simulink.Util.isDDSType(bdroot,typeName);
            else
                isDDSType=false;
            end
        end

        function ddsTypes=getAllDDSTypes(modelName)

            ddsTypes={};
            ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
            if isempty(ddsMf0Model)
                return;
            end
            system=dds.internal.getSystemInModel(ddsMf0Model);
            if~isempty(system)
                typeLibs=system(1).TypeLibraries;
                for libs=1:typeLibs.Size
                    ddsTypes=[ddsTypes,dds.internal.simulink.Util.getAllDDSTypesHelper(typeLibs(libs).Elements)];%#ok<AGROW> 
                end
            end
        end

        function ddsTypes=getAllDDSTypesHelper(elements)
            ddsTypes={};
            elemKeys=keys(elements);
            for i=1:numel(elemKeys)
                elem=elements{elemKeys{i}};
                if isa(elem,'dds.datamodel.types.Module')
                    ddsTypes=[ddsTypes,dds.internal.simulink.Util.getAllDDSTypesHelper(elem.Elements)];%#ok<AGROW> 
                else
                    ddsTypes{end+1}=elem;%#ok<AGROW> 
                end
            end
        end

        function ddsType=getDDSType(modelName,typeName)

            ddsType=[];
            ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
            if isempty(ddsMf0Model)
                return;
            end
            ddsType=dds.internal.getTypeBasedOnFullName(typeName,ddsMf0Model);
        end

        function ddstypes=getDDSTypeNamesHelper(elements)
            ddstypes=[];
            elemKeys=keys(elements);
            for i=1:numel(elemKeys)
                elem=elements{elemKeys{i}};
                if isa(elem,'dds.datamodel.types.Module')
                    ddstypes=[ddstypes,dds.internal.simulink.Util.getDDSTypeNamesHelper(elem.Elements)];%#ok<AGROW> 
                else
                    fullName=dds.internal.getFullNameForType(elem);
                    ddstypes{end+1}=fullName;%#ok<AGROW> 
                end
            end
        end

        function ddsTypedefPairs=getDDSTypedefPairs(modelName)




            ddsTypedefPairs=[];
            ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
            if isempty(ddsMf0Model)
                return;
            end
            fullNameVisitor=dds.internal.GetFullNamesVisitor('::');
            fullNameVisitor.visitModel(ddsMf0Model);
            keys=fullNameVisitor.TypesMap.keys;



            keysToUse=keys(contains(keys,fullNameVisitor.TypeSep));
            for idx=1:numel(keysToUse)
                elem=ddsMf0Model.findElement(fullNameVisitor.TypesMap(keysToUse{idx}));
                if~isa(elem,'dds.datamodel.types.Module')
                    nameWithSep=dds.internal.getFullNameForType(elem);
                    ent=struct('destType',nameWithSep,...
                    'origType',keysToUse{idx},...
                    'origTypeWithUnderScore',strrep(keysToUse{idx},'::','_'),...
                    'class',class(elem));
                    if isempty(ddsTypedefPairs)
                        ddsTypedefPairs=ent;
                    else
                        ddsTypedefPairs=[ddsTypedefPairs,ent];%#ok<AGROW>
                    end
                end
            end
        end

        function namespaces=getNamespaces(modelName)
            namespaces={};
            ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
            if isempty(ddsMf0Model)
                return;
            end
            system=dds.internal.getSystemInModel(ddsMf0Model);
            if~isempty(system)
                typeLibs=system(1).TypeLibraries;
                for libs=1:typeLibs.Size
                    namespaces=[namespaces,dds.internal.simulink.Util.getNamespacesHelper(...
                    typeLibs(libs).Elements,'')];%#ok<AGROW>
                end
            end
        end

        function namespaces=getNamespacesHelper(elements,curNamespace)
            elemKeys=keys(elements);
            namespaces={};
            for i=1:numel(elemKeys)
                elem=elements{elemKeys{i}};
                if isa(elem,'dds.datamodel.types.Module')
                    if~isempty(curNamespace)
                        namespace=[curNamespace,'::',elem.Name];
                    else
                        namespace=elem.Name;
                    end
                    namespaces{end+1}=namespace;%#ok<AGROW>
                    namespaces=[namespaces,...
                    dds.internal.simulink.Util.getNamespacesHelper(elem.Elements,namespace)];%#ok<AGROW>
                end
            end
        end

        function key=isKeyInDescription(descriptionField)
            key=contains(descriptionField,'@Key','IgnoreCase',true);
        end

        function optional=isOptionalInDescription(descriptionField)
            optional=contains(descriptionField,'@Optional','IgnoreCase',true);
        end

        function descriptionField=updateDescription(descriptionField,theObj)
            if theObj.Key
                if~dds.internal.simulink.Util.isKeyInDescription(descriptionField)
                    if isempty(descriptionField)
                        descriptionField='@Key';
                    else
                        descriptionField=['@Key ',descriptionField];
                    end
                end
            else
                if dds.internal.simulink.Util.isKeyInDescription(descriptionField)
                    descriptionField=regexprep(descriptionField,'^@[kK][eE][yY]\s*','');
                end
            end
            if~isempty(theObj.RoundTripInfo)&&theObj.RoundTripInfo.Optional
                if~dds.internal.simulink.Util.isOptionalInDescription(descriptionField)
                    if isempty(descriptionField)
                        descriptionField='@Optional';
                    else
                        descriptionField=['@Optional ',descriptionField];
                    end
                end
            else
                if dds.internal.simulink.Util.isOptionalInDescription(descriptionField)
                    descriptionField=regexprep(descriptionField,'^@[oO][pP][tT][iI][oO][nN][aA][lL]\s*','');
                end
            end
        end

        function stripped=stripParenInStr(instr)
            stripped=regexprep(instr,'(^\s*\()*([^\)]*)(\))*','$2');
        end

        function type=getTypeFromDict(modelName,typeName)
            type={};
            dictName=get_param(modelName,'DataDictionary');
            dictObj=Simulink.data.dictionary.open(dictName);
            sectionObj=dictObj.getSection('Design Data');
            if sectionObj.exist(typeName)
                type=sectionObj.getEntry(typeName).getValue;
            end
            dictObj.close();
        end

        function ddsTypesHeaderFileName=getDDSTypesHeaderFileName()

            ddsTypesHeaderFileName='ddstypes.hpp';
        end

        function isBuiltIn=isBuiltInQoS(ddsMf0Model,qosPath,annotationKey)
            isBuiltIn=false;
            entities=split(qosPath,"/");
            qosLibName=entities{1};
            systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
            qosLib=systemInModel(1).QosLibraries{qosLibName};
            if isempty(qosLib)
                return;
            end
            annotations=qosLib.Annotations;
            if isempty(annotations)
                return;
            end

            attribName=[annotationKey,dds.internal.simulink.Util.UnknownAttribTag];
            members=[];
            for i=1:annotations.Size
                if isequal(annotations(i).Name,attribName)
                    members=annotations(i).Members;
                    break;
                end
            end
            if isempty(members)
                return;
            end
            for i=0:members.Size
                theAnnon=members{uint64(i)};
                if isequal(theAnnon.Name,dds.internal.simulink.Util.UnknownAttribTag)
                    theVal=jsondecode(theAnnon.ValueStr);
                    if isfield(theVal,'is_built_in')
                        isBuiltIn=isequal(lower(theVal.is_built_in),'true');

                        return;
                    end
                end
            end
        end

        function qos=getQoS(modelName,qosPath,isReader)
            qos={};
            entities=split(qosPath,"/");
            if length(entities)~=2&&length(entities)~=3
                return;
            end
            isProfileInPath=(length(entities)==3);
            qosLibName=entities{1};
            qosName=entities{end};
            if isProfileInPath
                qosProfileName=entities{2};
            end
            ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
            if isempty(ddsMf0Model)
                return;
            end
            systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
            qosLib=systemInModel(1).QosLibraries{qosLibName};
            if isempty(qosLib)
                return;
            end
            if isProfileInPath
                qosProfile=qosLib.QosProfiles{qosProfileName};
                if isempty(qosProfile)
                    return;
                end
                if isReader
                    qos=qosProfile.DataReaderQoses{qosName};
                else
                    qos=qosProfile.DataWriterQoses{qosName};
                end
            else
                if isReader
                    qos=qosLib.DataReaderQoses{qosName};
                else
                    qos=qosLib.DataWriterQoses{qosName};
                end
            end
        end

        function topic=getTopic(modelName,topicPath)
            topic={};
            [domainLibName,domainName,topicName]=...
            dds.internal.simulink.Util.getDDSPartitionedTopics(topicPath);

            domain=dds.internal.simulink.Util.getDomain(...
            modelName,domainLibName,domainName);
            if isempty(domain)
                return;
            end

            topic=domain.Topics{topicName};
        end

        function domainLib=getDomainLib(modelName,domainLibName)
            domainLib='';
            ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
            if isempty(ddsMf0Model)
                return;
            end
            systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
            domainLibs=systemInModel(1).DomainLibraries;
            domainLib=domainLibs{domainLibName};
        end

        function domain=getDomain(modelName,domainLibName,domainName)
            domain='';
            domainLib=dds.internal.simulink.Util.getDomainLib(modelName,domainLibName);
            if isempty(domainLib)
                return;
            end
            domain=domainLib.Domains{domainName};
        end

        function participantLib=getParticipantLib(modelName,participantLibName)
            ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
            if isempty(ddsMf0Model)
                return;
            end
            systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
            theLib=systemInModel(1).DomainParticipantLibraries{participantLibName};




            if~isempty(theLib)
                participantLib=theLib;
            else
                participantLib='';
            end
        end

        function participant=getParticipant(modelName,participantLibName,participantName)
            participant='';
            participantLib=dds.internal.simulink.Util.getParticipantLib(modelName,participantLibName);
            if~isempty(participantLib)
                participant=participantLib.DomainParticipants{participantName};
            end
        end

        function checksum=getDataModelChecksum(modelName)
            checksum='';
            dd=get_param(modelName,'DataDictionary');
            ddConn=Simulink.data.dictionary.open(dd);
            if~Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath)
                return;
            end
            ddsMf0Model=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(ddConn.filepath);

            clonedModel=dds.internal.simulink.Util.cloneModel(ddsMf0Model);

            filteredModel=dds.internal.simulink.Util.removeOtherApplications(clonedModel,'');

            jSer=mf.zero.io.JSONSerializer;
            jsonStr=jSer.serializeToString(filteredModel);
            checksum=regexprep(jsonStr,'\"uuid\"\s*\:\s*\"[a-z0-9\-]+\"','"uuid":""');
        end



        function buildModelRef(models)
            validateattributes(models,{'cell'},{'nonempty'});
            cellfun(@(x)validateattributes(x,{'char','string'},{'nonempty'}),models);
            topModel=models{1};


            [compName,~,vendorKey,ddConn]=dds.internal.simulink.Util.getCurrentMapSetting(topModel);
            for i=2:numel(models)
                mapping=Simulink.CodeMapping.getCurrentMapping(models{i});
                mapping.DeploymentType='Application';
                dds.internal.simulink.Util.setupModelForDDS(models{i},ddConn.filepath,compName,vendorKey,false);
                set_param(models{i},'GenCodeOnly',1);
            end

            set_param(topModel,'GenCodeOnly',1);
            rtwbuild(topModel);


            load(fullfile(RTW.getBuildDir(topModel,'BuildDirectory'),'buildInfo.mat'),'buildInfo');
            xmlOrIdlName=dds.internal.coder.getXmlFileName(topModel,buildInfo);
            [~,InterfaceRootName]=fileparts(xmlOrIdlName);
            for i=2:numel(models)
                [stat,msg,msgid]=copyfile(fullfile(pwd,[topModel,'.pkg'],'src',[InterfaceRootName,'*.*']),fullfile(pwd,'slprj','ert',models{i}));
                if~stat
                    error(msgid,msg);
                end
                [stat,msg,msgid]=copyfile(fullfile(pwd,[topModel,'.pkg'],'src','ddstypes.hpp'),fullfile(pwd,'slprj','ert',models{i}));
                if~stat
                    error(msgid,msg);
                end
            end

            cellfun(@(x)set_param(x,'GenCodeOnly',0),models);
            cellfun(@(x)set_param(x,'Dirty','off'),models);
            rtwbuild(topModel);
        end

        function[domainLib,domain,topic]=getDDSPartitionedTopics(topicPath)
            domainLib=extractBefore(topicPath,'/');
            topicPath=extractAfter(topicPath,'/');
            domain=extractBefore(topicPath,'/');
            topic=extractAfter(topicPath,'/');
        end

    end

end




