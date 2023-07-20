classdef UpdateSimObjectsVisitor<dds.internal.BaseVisitor








    properties
ObjectMap
UseShortNameForType
SystemTypeMap
Dependents
    end

    properties(Hidden)
NameChecker
    end

    methods
        function h=UpdateSimObjectsVisitor()
            h@dds.internal.BaseVisitor();
            h.reset();
            h.NameChecker=dds.internal.simulink.ReservedNamesChecker.getInstance;
        end

        function reset(h)
            reset@dds.internal.BaseVisitor(h);
            h.ObjectMap=containers.Map();
            h.UseShortNameForType=false;
            h.SystemTypeMap=[];
            h.Dependents=containers.Map();
        end

        function addSimObject(h,theObj,theSimObject,clear)
            if nargin>3
                if clear
                    h.ObjectMap.remove(h.ObjectMap.keys);
                    h.Dependents.remove(h.Dependents.keys);
                end
            end
            entry=struct('Obj',theObj,'SimObj',theSimObject);
            h.ObjectMap(theObj.UUID)=entry;
            h.addDependents(theObj);
        end

        function status=visitModel(h,mf0Model)
            status=false;
            if isempty(h.ObjectMap)
                return;
            end
            h.UseShortNameForType=dds.internal.isSystemUsingShortName(mf0Model);
            if h.UseShortNameForType
                syselem=dds.internal.getSystemInModel(mf0Model);
                h.SystemTypeMap=syselem.TypeMap;
            end
            txn=mf0Model.beginTransaction;
            objIds=h.ObjectMap.keys;
            for i=1:numel(objIds)
                theObj=mf0Model.findElement(objIds{i});
                if isempty(theObj)
                    return;
                end
                status=theObj.acceptVisitor(h);
                if~status
                    return;
                end
            end
            depIds=h.Dependents.keys;
            for i=1:numel(depIds)
                theObj=mf0Model.findElement(depIds{i});
                if isempty(theObj)
                    return;
                end
                status=h.touchTypeObject(theObj);
                if~status
                    return;
                end
            end
            txn.commit();
            status=true;
        end

        function status=touchTypeObject(~,theObj)
            status=true;
            if isa(theObj,'dds.datamodel.types.Struct')

                curSize=theObj.Verbatims.Size;
                theObj.createIntoVerbatims(struct('Text',char(datetime('now'))));
                theObj.Verbatims(curSize+1).destroy();
            end
        end

        function status=visitSystem(h,syselem)
            h.UseShortNameForType=dds.internal.isSystemUsingShortName(mf.zero.getModel(syselem),syselem);
            if h.UseShortNameForType
                h.SystemTypeMap=syselem.TypeMap;
            end

            status=h.visitTypeLibraries(syselem);
        end

        function status=updateTypeMap(h,theObj)
            status=true;
            if h.UseShortNameForType
                fullName=dds.internal.getFullNameForType(theObj);
                if isempty(theObj.TypeMapEntryRef)
                    h.SystemTypeMap.createIntoMap(struct('FullName',fullName,'Element',theObj));
                elseif~isequal(theObj.TypeMapEntryRef.FullName,fullName)

                    theObj.TypeMapEntryRef.destroy();
                    h.SystemTypeMap.createIntoMap(struct('FullName',fullName,'Element',theObj));
                end
            end
        end

        function status=visitConst(h,theObj)
            status=visitConst@dds.internal.BaseVisitor(h,theObj);
            if status
                status=h.updateTypeMap(theObj);
            end
            if status&&h.ObjectMap.isKey(theObj.UUID)
                simObject=h.ObjectMap(theObj.UUID).SimObj;
                if~isprop(simObject,'Value')

                    value=simObject;
                else
                    validateattributes(simObject,{'Simulink.Parameter'},{'scalar'});
                    value=simObject.Value;
                end

                if ismethod(simObject,'getPreferredProperties')
                    dds.internal.simulink.Util.createOrReplaceAnnotationOnNamedElement(theObj,simObject,simObject.getPreferredProperties,'');
                end
                if dds.internal.simulink.Util.isBasicType(class(value))
                    theObj.Type=dds.internal.simulink.Util.createBasicTypeIn(theObj,'createIntoType',class(value));
                    valueStr=dds.internal.simulink.Util.convertToStr(value);
                    if~isequal(theObj.ValueStr,valueStr)
                        theObj.ValueStr=valueStr;
                    end


                    theObj.setPropertyValue('TypeRef',dds.internal.simulink.ui.internal.dds.datamodel.types.Module.empty());
                else

                    theObj.setPropertyValue('Type',dds.datamodel.types.String.empty());
                    if~isempty(theObj.TypeRef)&&isequal(class(value),dds.internal.getFullNameForType(theObj.TypeRef))
                        theObj.ValueStr=char(value);
                    else
                        mdl=mf.zero.getModel(theObj);

                        typeRef=dds.internal.getTypeBasedOnFullName(class(value),mdl);
                        if isempty(typeRef)
                            error(...
                            message('dds:adaptor:ConstTypeNotSupported',...
                            theObj.Name,class(value),'double'));
                        end
                        theObj.TypeRef=typeRef;
                        theObj.ValueStr=char(value);
                    end
                end
                status=true;
            end
        end

        function status=visitEnum(h,theObj)
            status=visitEnum@dds.internal.BaseVisitor(h,theObj);
            if status
                status=h.updateTypeMap(theObj);
            end
            if status&&h.ObjectMap.isKey(theObj.UUID)
                simObject=h.ObjectMap(theObj.UUID).SimObj;
                validateattributes(simObject,{'Simulink.data.dictionary.EnumTypeDefinition'},{'scalar'});
                dds.internal.simulink.Util.createOrReplaceAnnotationOnNamedElement(theObj,simObject,...
                {'Description'},'');
                simObjMemberNames=arrayfun(@(x){x.Name},simObject.Enumerals);
                h.moveMembers(theObj,simObjMemberNames,'dds.datamodel.types.EnumMember');
                assert(theObj.Members.Size==numel(simObject.Enumerals));
                keys=theObj.Members.keys;
                for i=1:numel(keys)
                    theObj.Members{keys(i)}.Name=simObject.Enumerals(i).Name;
                    theObj.Members{keys(i)}.ValueStr=simObject.Enumerals(i).Value;
                    dds.internal.simulink.Util.createOrReplaceAnnotationOnNamedElement(theObj,simObject.Enumerals(i),...
                    {'Description'},simObject.Enumerals(i).Name);
                    h.setOptional(theObj.Members{keys(i)},simObject.Enumerals(i).Description);
                end
                status=true;
            end
        end

        function moveMembers(~,theObj,simObjMemberNames,classToInstantiate)


            keys=theObj.Members.keys;
            if isempty(simObjMemberNames)
                for i=1:numel(keys)
                    theObj.Members{keys(i)}.destroy;
                end
                return;
            end




            objMemberNames=arrayfun(@(x){theObj.Members{x}.Name},keys);
            if isempty(objMemberNames)
                objMemberNames={};
            end
            [~,newIdx]=ismember(objMemberNames,simObjMemberNames);
            [~,changedIdx]=ismember(simObjMemberNames,objMemberNames);




            assert((2*theObj.Members.Size+1)<intmax('uint64'));



            for i=1:numel(keys)

                if newIdx(i)==0
                    theObj.Members{keys(i)}.destroy;
                else
                    tempIdx=intmax('uint64')-keys(i);
                    theObj.Members{keys(i)}.Index=tempIdx;
                end
            end
            for i=1:numel(changedIdx)
                if changedIdx(i)==0
                    theObj.createIntoMembers(...
                    struct('metaClass',classToInstantiate,...
                    'Index',uint64(i)));
                else


                    movedIdx=intmax('uint64')-changedIdx(i);
                    theObj.Members{movedIdx}.Index=newIdx(changedIdx(i));
                end
            end
        end

        function status=addDependents(h,theObj)

            status=true;
            if isa(theObj,'dds.datamodel.types.Struct')
                for i=1:theObj.StructRefs.Size()
                    theDep=theObj.StructRefs(i);
                    if isempty(intersect(h.Dependents.keys,theDep.UUID))
                        h.Dependents(theDep.UUID)=theDep;
                        h.addDependents(theDep);
                    end
                end
            end
        end

        function status=visitStruct(h,theObj)
            status=visitStruct@dds.internal.BaseVisitor(h,theObj);
            if status
                status=h.updateTypeMap(theObj);
            end
            if status&&h.ObjectMap.isKey(theObj.UUID)
                simObject=h.ObjectMap(theObj.UUID).SimObj;
                validateattributes(simObject,{'Simulink.Bus'},{'scalar'});
                dds.internal.simulink.Util.createOrReplaceAnnotationOnNamedElement(theObj,simObject,...
                {'Alignment','Description','DataScope','HeaderFile'},'');
                simObjMemberNames=arrayfun(@(x){x.Name},simObject.Elements);
                h.moveMembers(theObj,simObjMemberNames,'dds.datamodel.types.StructMember');
                assert(theObj.Members.Size==numel(simObject.Elements));


                if~isempty(theObj.BaseRef)

                    for ii=1:theObj.StructRefs.Size()
                        refObj=theObj.StructRefs(ii);
                        h.checkStructForCircularDeps(refObj,theObj);
                    end

                    h.checkStructElementNamesForDups(theObj.BaseRef,simObjMemberNames);
                end
                h.checkStructElementNamesForDupsInDeps(theObj,simObjMemberNames);
                mdl=mf.zero.getModel(theObj);
                keys=theObj.Members.keys;
                for i=1:numel(keys)
                    status=h.updateStructElements(theObj.Members{keys(i)},simObject.Elements(i),mdl);
                    if~status
                        return;
                    end
                end
                status=true;
            end
        end


        function checkStructForCircularDeps(h,refObj,theObj)
            if~isempty(refObj.BaseRef)
                if refObj==theObj||...
                    (refObj.BaseRef==theObj&&theObj.BaseRef==refObj)
                    error(message('dds:io:BaseCausingCircularDependency',...
                    dds.internal.getFullNameForType(theObj.BaseRef,'::',false),...
                    dds.internal.getFullNameForType(theObj,'::',false),...
                    dds.internal.getFullNameForType(refObj,'::',false)));
                end
                for ii=1:refObj.StructRefs.Size()
                    refsRefObj=refObj.StructRefs(ii);
                    h.checkStructForCircularDeps(refsRefObj,theObj);
                end
            end
        end

        function checkStructElementNamesForDups(h,theObj,simObjMemberNames)
            if~isempty(theObj.BaseRef)
                h.checkStructElementNamesForDups(theObj.BaseRef,simObjMemberNames);
            end
            curMemNames=arrayfun(@(x)theObj.Members{uint64(x)}.Name,1:theObj.Members.Size,'UniformOutput',false);
            common=intersect(curMemNames,simObjMemberNames);
            if numel(common)~=0
                error(message('dds:io:AnotherElementWithSameNameThroughDep',common{1},...
                dds.internal.getFullNameForType(theObj,'::',false)));
            end
        end

        function checkStructElementNamesForDupsInDeps(h,theObj,simObjMemberNames)
            if theObj.StructRefs.Size()>0
                for ii=1:theObj.StructRefs.Size()
                    refObj=theObj.StructRefs(ii);
                    h.checkStructElementNamesForDupsInDeps(refObj,simObjMemberNames);
                    curMemNames=arrayfun(@(x)refObj.Members{uint64(x)}.Name,1:refObj.Members.Size,'UniformOutput',false);
                    common=intersect(curMemNames,simObjMemberNames);
                    if numel(common)~=0
                        error(message('dds:io:AnotherElementWithSameNameThroughDep',common{1},...
                        dds.internal.getFullNameForType(refObj,'::',false)));
                    end
                end
            end
        end

        function setOptional(~,theObj,description)
            if dds.internal.simulink.Util.isOptionalInDescription(description)
                if isempty(theObj.RoundTripInfo)
                    theObj.createIntoRoundTripInfo(...
                    struct('metaClass','dds.datamodel.types.MemberRoundTripInfo',...
                    'Optional',true));
                else
                    theObj.RoundTripInfo.Optional=true;
                end
            else
                if~isempty(theObj.RoundTripInfo)
                    theObj.RoundTripInfo.Optional=false;
                end
            end
        end

        function status=updateStructElements(h,theObj,busElement,mdl)
            propertyName=busElement.Name;
            [elemName,~]=h.NameChecker.unmangleNameIfMangled(propertyName);
            dds.internal.simulink.Util.createOrReplaceAnnotationOnNamedElement(theObj.Container,busElement,...
            fields(busElement),elemName);
            theObj.Name=elemName;
            theObj.Key=dds.internal.simulink.Util.isKeyInDescription(busElement.Description);
            h.setOptional(theObj,busElement.Description);

            if dds.internal.simulink.Util.isBasicType(busElement.DataType)
                theObj.Type=dds.internal.simulink.Util.createBasicTypeIn(theObj,'createIntoType',busElement.DataType);

                theObj.setPropertyValue('TypeRef',dds.internal.simulink.ui.internal.dds.datamodel.types.Module.empty());
            else

                theObj.setPropertyValue('Type',dds.datamodel.types.String.empty());

                dataTypeStr=regexprep(busElement.DataType,'^(Enum:\s*)|(Bus:\s*)','');
                if isempty(theObj.TypeRef)||(~isempty(theObj.TypeRef)&&~isequal(dataTypeStr,dds.internal.getFullNameForType(theObj.TypeRef)))

                    typeRef=dds.internal.getTypeBasedOnFullName(dataTypeStr,mdl);
                    if isempty(typeRef)
                        error(...
                        message('dds:adaptor:TypeNotSupported',...
                        theObj.Name,theObj.Container.Name,dataTypeStr,'double'));
                    end
                    theObj.TypeRef=typeRef;
                end
            end

            [~,curDimension]=dds.internal.getDimensionAndTypeForNamedElement(theObj,false);
            if~isequal(busElement.Dimensions,curDimension)

                theObj.Dimension=dds.internal.createDimensionObject(theObj,busElement.Dimensions);
            end
            status=true;
        end
    end
end
