classdef(Abstract)ObjectBuilder<m3i.Visitor





    properties(Access=protected)
        ChangeLogger;
    end

    properties(Hidden=true,GetAccess=public,SetAccess=protected)
        m3iModel;
        slTypeBuilder;
        slConstBuilder;
        msgStream;
    end
    methods(Abstract,Access='protected')
        ret=isGlobalMemory(object);
    end
    methods



        function self=ObjectBuilder(m3iModel,typeBuilder,constBuilder,changeLogger)

            self.m3iModel=m3iModel;
            self.slTypeBuilder=typeBuilder;
            self.slConstBuilder=constBuilder;
            self.ChangeLogger=changeLogger;
            self.msgStream=autosar.mm.util.MessageStreamHandler.instance();
        end
    end

    methods(Access='protected')
        function[newObject,isCreated]=createOrUpdateObject(self,objectName,newClassName,isConstOrStaticMemory,forceCreation,targetModelWorkspace)



            if nargin<4
                isConstOrStaticMemory=false;
                assert(isempty(regexp(newClassName,'^AUTOSAR4','ONCE')),'The AUTOSAR4 StorageClass is most commonly used for Const or StaticMemory definitions, please specify explicitly')
            end

            if nargin<5
                forceCreation=false;
            end

            if nargin<6
                targetModelWorkspace=false;
            end

            [varExists,oldObject,existsInModelWorkspace]=self.objectExistsInModelScope(objectName);
            if varExists&&~forceCreation
                isGlobal=self.isGlobalMemory(oldObject);
                objectsAreSameType=strcmp(class(oldObject),newClassName);
                existsInCorrectWorkspace=~xor(existsInModelWorkspace,targetModelWorkspace);
                canUpdate=objectsAreSameType&&existsInCorrectWorkspace;
                if canUpdate||...
                    (isGlobal&&isConstOrStaticMemory&&strcmp(newClassName,'Simulink.Parameter'))
                    if(isa(oldObject,'Simulink.Parameter'))
                        assert(~oldObject.CoderInfo.HasContext||...
                        (oldObject.CoderInfo.HasContext&&strcmp(oldObject.CoderInfo.StorageClass,'Auto')),'Unexpected object found');
                    end
                    [newObject,isCreated]=self.copyFromExisting(oldObject);
                else
                    if existsInCorrectWorkspace
                        self.msgStream.createWarning('RTW:autosar:updateChangeClass',{objectName,class(oldObject),newClassName});
                    else
                        self.msgStream.createWarning('RTW:autosar:updateOverrideClass',{objectName,class(oldObject)});
                    end
                    [newObject,isCreated]=self.createNew(newClassName);
                    self.ChangeLogger.logModification('WorkSpace',...
                    'class',class(oldObject),objectName,class(oldObject),newClassName);
                end
            else
                [newObject,isCreated]=self.createNew(newClassName);
                self.ChangeLogger.logAddition('WorkSpace',newClassName,objectName);
            end
        end

        function[newObject,isCreated]=copyFromExisting(~,oldObject)
            newObject=copy(oldObject);
            isCreated=false;
        end

        function[newObject,isCreated]=createNew(~,newClassName)%#ok<STOUT>
            eval(['newObject = ',newClassName,';']);%#ok<EVLEQ>
            isCreated=true;
        end

        function[newObject,isCreated]=createOrUpdateMatlabVariable(self,variableName,value,forceCreation)


            if nargin<4
                forceCreation=false;
            end

            [varExists,oldObject]=self.objectExistsInModelScope(variableName);
            if varExists&&~forceCreation
                if isobject(oldObject)

                    self.msgStream.createWarning('RTW:autosar:updateChangeClass',{objectName,class(oldObject),class(value)});
                    newObject=value;
                    isCreated=true;
                    self.ChangeLogger.logModification('WorkSpace',...
                    'class',class(oldObject),variableName,class(oldObject),class(value));
                else

                    if value==oldObject
                        newObject=value;
                        isCreated=false;
                    else
                        newObject=value;
                        isCreated=true;
                        self.ChangeLogger.logModification('WorkSpace',...
                        'class',class(oldObject),variableName,class(oldObject),class(value));
                    end
                end
            else
                newObject=value;
                self.ChangeLogger.logAddition('WorkSpace',class(value),variableName);
                isCreated=true;
            end
        end

        function willBeAssigned=getWillBeAssignedBool(self,isCreated,dataObj,name)



            if isCreated
                willBeAssigned=true;
            else
                [~,wsObj]=self.objectExistsInModelScope(name);
                areParamsEqual=autosar.mm.mm2sl.ObjectBuilder.compareAndLogChanges(name,dataObj,wsObj,self.ChangeLogger);
                willBeAssigned=~areParamsEqual;
            end
        end

        function[varExists,object,isModelWorkspace]=objectExistsInModelScope(self,objectName)




            varExists=false;
            object=[];
            isModelWorkspace=false;

            modelWorkSpace=self.slTypeBuilder.ModelWorkSpace;
            sharedWorkSpace=self.slTypeBuilder.SharedWorkSpace;

            if isempty(modelWorkSpace)




                varExistsInSharedWS=evalin(sharedWorkSpace,['exist(''',objectName,''', ''var'')'])==1;
                if varExistsInSharedWS
                    object=evalin(sharedWorkSpace,objectName);
                    varExists=true;
                    return;
                end
            else
                modelName=modelWorkSpace.ownerName;
                [varExists,object,isModelWorkspace]=autosar.utils.Workspace.objectExistsInModelScope(modelName,objectName);
            end
        end

        function variableCreated=createOrUpdateWorkspaceObject(self,workSpace,wsObjName,slObj,changeLogger)


            variableCreated=false;
            varExists=evalin(workSpace,['exist(''',wsObjName,''', ''var'')'])==1;
            if varExists
                wsVar=evalin(workSpace,wsObjName);
                variableNotUpdated=self.compareAndLogChanges(wsObjName,slObj,wsVar,changeLogger);
                if variableNotUpdated
                    return;
                end
            end

            assignin(workSpace,wsObjName,slObj);
            variableCreated=true;
        end
    end

    methods(Static)
        function isEqual=compareAndLogChanges(name,newObject,oldObject,changeLogger)

            warnState=warning('off','Simulink:Data:ChangeOfBehaviorForIsEqual');
            cleanup=onCleanup(@()(warning(warnState)));

            isEqual=true;

            if~isobject(newObject)||~isobject(oldObject)
                isEqual=(newObject==oldObject);
                return;
            end

            fields=fieldnames(newObject);
            for ii=1:numel(fields)
                field=fields{ii};
                if~isprop(oldObject,field)
                    isEqual=false;
                    continue;
                end
                oldField=oldObject.(field);
                newField=newObject.(field);

                if~isequal(newField,oldField)
                    if(ischar(newField)||isStringScalar(newField))&&(ischar(oldField)||isStringScalar(oldField))
                        changeLogger.logModification('WorkSpace',field,class(oldObject),name,oldField,newField);
                    elseif isnumeric(newField)&&isnumeric(oldField)
                        if ismatrix(oldField)&&ismatrix(newField)
                            oldFieldStr=mat2str(double(oldField));
                            newFieldStr=mat2str(double(newField));
                        else
                            oldFieldStr=mat2str(double(oldField(:)));
                            newFieldStr=mat2str(double(newField(:)));
                        end
                        changeLogger.logModification('WorkSpace',field,class(oldObject),name,...
                        oldFieldStr,newFieldStr);
                    else
                        changeLogger.logModification('WorkSpace',field,class(oldObject),name);
                    end
                    isEqual=false;
                elseif isstruct(oldField)
                    isEqual=autosar.api.Utils.areStructsEqual(oldField,newField);
                    if~isEqual
                        changeLogger.logModification('WorkSpace',field,class(oldObject),name);
                    end
                end
            end
        end
    end
end


