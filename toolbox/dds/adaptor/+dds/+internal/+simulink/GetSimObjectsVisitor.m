classdef GetSimObjectsVisitor<dds.internal.UpdateTypeMapVisitor






    properties(Constant)
        CREATEDBY='Dictionary'
        AUTOMAPREL='R2022a'
    end

    properties
ObjectMap
PendingToAdd
NeedToVisit
IgnoreCheckIfPresent
UseAutoTypeMapping
CreateWithBase
    end

    properties(Hidden)
NameChecker
    end

    methods
        function h=GetSimObjectsVisitor(varargin)
            h@dds.internal.UpdateTypeMapVisitor();
            h.reset(varargin{:});
            h.NameChecker=dds.internal.simulink.ReservedNamesChecker.getInstance;
        end

        function reset(h,varargin)
            reset@dds.internal.UpdateTypeMapVisitor(h);
            h.ObjectMap=containers.Map();
            h.PendingToAdd={};
            h.NeedToVisit=true;
            h.IgnoreCheckIfPresent=false;
            if nargin>1&&~isempty(varargin)&&~isempty(varargin{1})
                h.UseAutoTypeMapping=~h.isReqVerLessThanRef(varargin{1},h.AUTOMAPREL)&&...
                slfeature('TypeMapping')>0;
            else

                h.UseAutoTypeMapping=slfeature('TypeMapping')>0;
            end
            if nargin>2&&~isempty(varargin)&&~isempty(varargin{2})
                h.CreateWithBase=varargin{2};
            else
                h.CreateWithBase=true;
            end
        end

        function ret=isReqVerLessThanRef(~,reqdVersion,refVersion)
            reqV=simulink_version(reqdVersion);
            refV=simulink_version(refVersion);
            ret=reqV<refV;
        end

        function addObjectToMap(h,theObj,theSimObject,fullName)
            if~isempty(theSimObject)
                if h.ObjectMap.isKey(fullName)&&~isequal(theObj.UUID,h.ObjectMap(fullName).UUID)
                    error(message('dds:io:AnotherSimulinkObjectWithSameName',fullName));
                end
                if~h.ObjectMap.isKey(fullName)
                    h.ObjectMap(fullName)=struct('Name',fullName,'Obj',theSimObject,'UUID',theObj.UUID,'Added',false);

                    idx=find(strcmp(h.PendingToAdd,fullName));
                    if~isempty(idx)
                        h.PendingToAdd(idx)=[];
                    end
                end
            end
        end

        function addToPending(h,theObj)
            h.PendingToAdd=unique([h.PendingToAdd,dds.internal.getFullNameForType(theObj)]);
        end

        function updateAdded(h,fullName,added)
            if h.ObjectMap.isKey(fullName)
                entry=h.ObjectMap(fullName);
                entry.Added=added;
                h.ObjectMap(fullName)=entry;
            end
        end

        function keysToAdd=getObjectNamesToAdd(h)
            keysToAdd={};
            keys=h.ObjectMap.keys;
            for i=1:numel(keys)
                if~h.ObjectMap(keys{i}).Added
                    keysToAdd=[keysToAdd,keys{i}];%#ok<AGROW>
                end
            end
        end

        function status=visitModel(h,mf0Model)
            pendingToAddBefore=h.PendingToAdd;
            status=visitModel@dds.internal.UpdateTypeMapVisitor(h,mf0Model);
            if status


                if~isempty(h.PendingToAdd)
                    status=~isequal(h.PendingToAdd,pendingToAddBefore);
                end
                h.NeedToVisit=~isempty(h.PendingToAdd);
            end
        end

        function status=visitModelForOnlyElements(h,mf0Model,objIds)
            h.PendingToAdd=[];
            h.IgnoreCheckIfPresent=true;
            status=visitModelForOnlyElements@dds.internal.UpdateTypeMapVisitor(h,mf0Model);
            if~status
                return;
            end
            for i=1:numel(objIds)
                theObj=mf0Model.findElement(objIds{i});
                if isempty(theObj)
                    return;
                end
                if ismethod(theObj,'acceptVisitor')
                    status=theObj.acceptVisitor(h);
                    if~status
                        return;
                    end
                end
            end
            h.NeedToVisit=~isempty(h.PendingToAdd);
            status=true;
        end

        function status=visitModule(h,theObj)
            status=visitModule@dds.internal.UpdateTypeMapVisitor(h,theObj);
        end

        function status=visitConst(h,theObj)
            status=visitConst@dds.internal.UpdateTypeMapVisitor(h,theObj);
            if status
                fullName=dds.internal.getFullNameForType(theObj);
                if~h.ObjectMap.isKey(fullName)
                    if~isempty(theObj.Type)
                        theSimObject=theObj.Type.getValue(theObj.ValueStr);
                    else

                        if~isa(theObj.TypeRef,'dds.datamodel.types.Enum')
                            error(message('dds:adaptor:ConstTypeNotSupported',theObj.Name,theObj.ValueStr,'double'));
                        end
                        try

                            strippedValue=dds.internal.simulink.Util.stripParenInStr(theObj.ValueStr);

                            splitValue=strsplit(strippedValue,'(::)|(\.)','DelimiterType','RegularExpression');
                            enumElemName=splitValue{end};
                            assert(~isempty(enumElemName));

                            found=false;
                            for idx=1:theObj.TypeRef.Members.Size
                                found=isequal(enumElemName,theObj.TypeRef.Members{idx}.Name);
                                if found
                                    break;
                                end
                            end
                            assert(found);
                            fullNameOfTypeRef=dds.internal.getFullNameForType(theObj.TypeRef);








                            if h.IgnoreCheckIfPresent||...
                                ~isempty(Simulink.findIntEnumType(fullNameOfTypeRef,h.CREATEDBY))
                                theSimObject=eval([fullNameOfTypeRef,'.',enumElemName]);
                            else
                                h.addToPending(theObj);
                                return;
                            end
                        catch ex %#ok<NASGU>
                            dds.internal.simulink.Util.warningNoBacktrace(...
                            message('dds:adaptor:ConstTypeNotSupported',...
                            theObj.Name,theObj.ValueStr,'double'));
                            theSimObject=double(0);
                        end
                    end
                    h.addObjectToMap(theObj,theSimObject,fullName);
                end
            end
        end

        function status=visitEnum(h,theObj)
            status=visitEnum@dds.internal.UpdateTypeMapVisitor(h,theObj);
            if status
                fullName=dds.internal.getFullNameForType(theObj);
                if~h.ObjectMap.isKey(fullName)
                    members=theObj.Members;
                    theEnumObject=Simulink.data.dictionary.EnumTypeDefinition;
                    theEnumObject.removeEnumeral(1);
                    theEnumObject=dds.internal.simulink.Util.getEncodedAnnotationOnNamedElement(theObj,theEnumObject,'');
                    if h.UseAutoTypeMapping
                        theEnumObject.DataScope='Auto';
                        theEnumObject.HeaderFile='';
                    else
                        theEnumObject.DataScope='Imported';
                        theEnumObject.HeaderFile=dds.internal.simulink.Util.getDDSTypesHeaderFileName();
                    end
                    if members.Size>0
                        fieldIds=theObj.Members.keys;
                        for i=1:numel(fieldIds)

                            theEnumObject.appendEnumeral(theObj.Members{fieldIds(i)}.Name,theObj.getValue(fieldIds(i)));
                            dds.internal.simulink.Util.getEncodedAnnotationOnNamedElement(theObj,theEnumObject.Enumerals(i),theEnumObject.Enumerals(i).Name);
                        end
                    end
                    h.addObjectToMap(theObj,theEnumObject,fullName);
                end
            end
        end

        function status=visitStruct(h,theObj)
            status=visitStruct@dds.internal.UpdateTypeMapVisitor(h,theObj);
            if status
                fullName=dds.internal.getFullNameForType(theObj);
                if~h.ObjectMap.isKey(fullName)
                    busObj=Simulink.Bus;
                    busObj=dds.internal.simulink.Util.getEncodedAnnotationOnNamedElement(theObj,busObj,'');
                    if h.UseAutoTypeMapping
                        busObj.DataScope='Auto';
                        busObj.HeaderFile='';
                    else
                        busObj.DataScope='Imported';
                        busObj.HeaderFile=dds.internal.simulink.Util.getDDSTypesHeaderFileName();
                    end
                    busElements=Simulink.BusElement.empty;
                    busElements=h.visitStructMembers(theObj,busElements);
                    busObj.Elements=busElements;
                    h.addObjectToMap(theObj,busObj,fullName);
                end
            end
        end

        function busElements=visitStructMembers(h,theObj,busElements)
            if h.CreateWithBase&&~isempty(theObj.BaseRef)

                busElements=h.visitStructMembers(theObj.BaseRef,busElements);
            end
            members=theObj.Members;
            if members.Size>0


                keys=theObj.Members.keys;
                for pIdx=1:members.Size
                    member=theObj.Members{keys(pIdx)};
                    busElements=h.addBusElements(member,busElements);
                end
            end
        end

        function busElements=addBusElements(h,theObj,busElements)
            if~isempty(busElements)
                curNames=arrayfun(@(x)x.Name,busElements,'UniformOutput',false);
                idx=cellfun(@(x)isequal(x,theObj.Name),curNames);
                if any(idx)
                    dds.internal.simulink.Util.warningNoBacktrace(message('dds:io:AnotherElementWithSameName',theObj.Name));
                    return;
                end
            end
            propertyName=theObj.Name;
            parentName=theObj.Container.Name;

            [elemName,isReservedName]=h.NameChecker.mangleNameIfNeeded(propertyName);

            elem=Simulink.BusElement;
            elem.Name=elemName;
            elem.Dimensions=1;
            elem.SampleTime=-1;
            elem.Complexity='real';
            elem.SamplingMode='Sample based';
            elem.Min=[];
            elem.Max=[];
            elem.DocUnits='';
            elem.Description='';
            elem=dds.internal.simulink.Util.getEncodedAnnotationOnNamedElement(theObj.Container,elem,theObj.Name);

            elemInfo=dds.internal.simulink.BusItemInfo;

            if isReservedName

                elemInfo.PropName=propertyName;
            end
            [type,dimension]=dds.internal.getDimensionAndTypeForNamedElement(theObj);
            [elem,elemInfo]=h.processStructMemberType(propertyName,parentName,type,elem,elemInfo);
            elem.Description=dds.internal.simulink.Util.updateDescription(elem.Description,theObj);

            isVarsizeArray=false;
            busElements=dds.internal.simulink.setBusDimensions(elemInfo,elem,busElements,dimension,~isVarsizeArray);
        end

        function[elem,elemInfo]=processStructMemberType(h,propertyName,parentName,type,elem,elemInfo)%#ok<INUSD>

            isNumeric=isa(type,'dds.datamodel.types.Numeric');
            isLogical=isa(type,'dds.datamodel.types.Boolean');
            isStringType=isa(type,'dds.datamodel.types.String');
            isChar=isa(type,'dds.datamodel.types.Char');
            isWideChar=isChar&&type.Wide;
            isEnum=isa(type,'dds.datamodel.types.Enum');
            isStruct=isa(type,'dds.datamodel.types.Struct');



            if(isNumeric||isLogical||isChar)
                dummyVal=type.getValue('0');
                if isLogical
                    elem.DataType='boolean';
                else
                    elem.DataType=class(dummyVal);
                end
                if isChar
                    elem.DataType='uint8';
                    elemInfo.OrigType=type.getDDSType;
                    dds.internal.simulink.Util.warningNoBacktrace(...
                    message('dds:adaptor:TypeNotSupported',...
                    propertyName,parentName,char(elemInfo.OrigType),'uint8'));
                elseif isWideChar
                    elem.DataType='uint16';
                    elemInfo.OrigType=type.getDDSType;
                    dds.internal.simulink.Util.warningNoBacktrace(...
                    message('dds:adaptor:TypeNotSupported',...
                    propertyName,parentName,char(elemInfo.OrigType),'uint16'));
                end
            elseif isStringType
                elem.DataType='string';
                elemInfo.PrimitiveType='string';
            elseif isEnum
                elem.DataType=strcat("Enum: ",dds.internal.getFullNameForType(type));
            elseif isStruct
                elem.DataType=strcat("Bus: ",dds.internal.getFullNameForType(type));
            else
                if~isempty(type)


                    elem.DataType='double';
                    dds.internal.simulink.Util.warningNoBacktrace(...
                    message('dds:adaptor:TypeNotSupported',...
                    propertyName,parentName,char(elemInfo.OrigType),'double'));
                end
            end
        end
    end
end
