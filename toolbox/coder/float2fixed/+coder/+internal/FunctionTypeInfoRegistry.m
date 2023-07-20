classdef FunctionTypeInfoRegistry<handle




    properties(Access=public)
registry
mxInfos
mxArrays
        classMap;




globalVarMap
    end

    properties(Access=private)
fimath
    end

    methods(Access=public)
        function this=FunctionTypeInfoRegistry()
            this.registry=coder.internal.lib.Map();
            this.classMap=[];
            this.globalVarMap=coder.internal.lib.Map();
            this.fimath=[];
        end

        function fm=getFimath(this)
            fm=this.fimath;
        end

        function setFimath(this,val)
            assert(isfimath(val));
            this.fimath=val;
        end

        function addFunctionTypeInfo(this,functionTypeInfo)

            functionTypeInfo.setFcnInfoRegistry(this);

            uniqueId=functionTypeInfo.uniqueId;
            this.registry(uniqueId)=functionTypeInfo;
        end

        function info=getFunctionTypeInfo(this,uniqueId)
            if~this.registry.isKey(uniqueId)
                info=[];
            else
                info=this.registry(uniqueId);
            end
        end

        function infos=getFunctionTypeInfosByName(this,functionName)
            infos={};
            fcns=this.registry.values();
            for ii=1:length(fcns)
                fcn=fcns{ii};
                if strcmp(fcn.functionName,functionName)||strcmp(fcn.specializationName,functionName)
                    infos{end+1}=fcn;%#ok<AGROW>
                end
            end
        end

        function fcnTypeInfo=getFunctionTypeInfoByNameAndIDs(this,functionName,classdefUID,specializationID)
            fcnTypeInfos=getFunctionTypeInfosByName(this,functionName);
            if isempty(fcnTypeInfos)
                return;
            end
            fcnTypeInfos=[fcnTypeInfos{:}];
            idx=[fcnTypeInfos.specializationId]==specializationID;
            fcnTypeInfos=fcnTypeInfos(idx);
            idx=[fcnTypeInfos.classdefUID]==classdefUID;
            fcnTypeInfo=fcnTypeInfos(idx);
        end

        function fcnTypeInfo=getFunctionTypeInfoBySpecializationAndPath(this,scriptPath,fcnName,specializationID)
            fcnTypeInfo=internal.mtree.FunctionTypeInfo.empty();
            fcnTypeInfos=this.getFunctionTypeInfosByName(fcnName);
            if isempty(fcnTypeInfos)
                return;
            end
            fcnTypeInfos=[fcnTypeInfos{:}];
            idx=[fcnTypeInfos.specializationId]==specializationID;
            fcnTypeInfos=fcnTypeInfos(idx);
            idx=strcmp({fcnTypeInfos.scriptPath},scriptPath);
            fcnTypeInfo=fcnTypeInfos(idx);
        end

        function fcnTypeInfos=getAllFunctionTypeInfos(this)
            fcnTypeInfos=this.registry.values;
        end


        function fcnNames=getAllFunctions(this)
            fcnNames=this.registry.keys;
        end


        function buildGlobalVarMap(this)
            if isempty(this.registry)
                return;
            end

            fcns=this.registry.keys;
            for ii=1:length(fcns)
                fcn=fcns{ii};
                fcnInfo=this.registry(fcn);
                glbVarNames=fcnInfo.globalVarNames;

                infos=cellfun(@(varN)fcnInfo.getVarInfosByName(varN)...
                ,glbVarNames...
                ,'UniformOutput',false);
                cellfun(@(v)v.setIsGlobal(true)...
                ,coder.internal.lib.ListHelper.flatten(infos));
                cellfun(@(varName)this.addGlobalVar(varName,fcnInfo.uniqueId),glbVarNames);
            end
        end



        function addGlobalVar(this,globalVarName,fcnUniqueIDs)
            assert(~isempty(this.registry));
            if ischar(fcnUniqueIDs)
                fcnUniqueIDs={fcnUniqueIDs};
            end
            if this.globalVarMap.isKey(globalVarName)
                currList=this.globalVarMap.get(globalVarName);
                currList=[currList,fcnUniqueIDs{:}];
            else
                currList=fcnUniqueIDs;
            end
            this.globalVarMap(globalVarName)=currList;
        end


        function vars=getGlobalVars(this)
            assert(~isempty(this.registry));
            vars=this.globalVarMap.keys;
        end



        function msgs=checkForUnAssignedGlobals(this)
            import coder.internal.lib.ListHelper;
            msgs=coder.internal.lib.Message.empty();
            glbVars=this.getGlobalVars();
            for ii=1:length(glbVars)
                glbVar=glbVars{ii};
                uniqIDs=this.globalVarMap(glbVar);
                glbFcnInfos=cellfun(@(id)this.getFunctionTypeInfo(id),uniqIDs,'UniformOutput',false);
                glbFcnInfos=[glbFcnInfos{:}];


                glbVarInfosList=ListHelper.flatten(arrayfun(@(fcnInfo)fcnInfo.getVarInfosByName(glbVar),glbFcnInfos,'UniformOutput',false));

                glbVarInfos=[glbVarInfosList{:}];
                checkEmptyRanges(glbVarInfos);
            end

            function checkEmptyRanges(varInfos)
                if isempty(varInfos)
                    return;
                end

                nonEmptyIdx=arrayfun(@(v)~v.isSimRangeNotAvailable(),varInfos);
                annotatedGlbVars=varInfos(nonEmptyIdx);





                if isempty(annotatedGlbVars)&&~varInfos(1).isCoderConst
                    v=varInfos(end);
                    varN=v.SymbolName;
                    msgs(end+1)=v.buildMessage(coder.internal.lib.Message.WARN,'Coder:FXPCONV:GlobalVarUnAssigned',{varN});
                end
            end
        end


        function updateAnnotationsForGlobals(this)
            import coder.internal.lib.ListHelper;
            glbVars=this.getGlobalVars();
            for ii=1:length(glbVars)
                glbVar=glbVars{ii};
                uniqIDs=this.globalVarMap(glbVar);
                glbFcnInfos=cellfun(@(id)this.getFunctionTypeInfo(id),uniqIDs,'UniformOutput',false);
                glbFcnInfos=[glbFcnInfos{:}];

                glbVarInfosList=ListHelper.flatten(arrayfun(@(fcnInfo)fcnInfo.getVarInfosByName(glbVar),glbFcnInfos,'UniformOutput',false));

                glbVarInfos=[glbVarInfosList{:}];



                if~isempty(glbVarInfos)
                    normalizeAnnotatedTypes(glbVarInfos);
                end
            end





            function normalizeAnnotatedTypes(varInfos)

                nonEmptyIdx=arrayfun(@(x)~isempty(x),{varInfos.annotated_Type});
                annotatedGlbVars=varInfos(nonEmptyIdx);



                if~isempty(annotatedGlbVars)
                    annType=annotatedGlbVars(end).annotated_Type;
                    arrayfun(@(varInfo)varInfo.setAnnotatedType(annType),varInfos);
                end
            end
        end



        function[numerictypeList,fimathList]=getGlobalVarNumerictypes(this,globalVars)
            assert(~isempty(this.registry));
            numerictypeList=cell(1,length(globalVars));
            fimathList=cell(1,length(globalVars));
            for ii=1:length(globalVars)
                varName=globalVars{ii};
                uniqueIDs=this.globalVarMap.get(varName);


                fcnInfo=this.getFunctionTypeInfo(uniqueIDs{1});

                if isempty(fcnInfo)
                    continue;
                end

                varInfo=fcnInfo.getVarInfo(varName);
                if isempty(varInfo)
                    continue;
                end

                if varInfo.isStruct()
                    flds=varInfo.loggedFields;
                    for jj=1:length(flds)
                        fieldName=flds{jj};
                        eval(['tmp.',fieldName,'= varInfo.annotated_Type{jj};']);
                        eval(['fmTmp.',fieldName,'= varInfo.getFimathForStructField(jj);']);
                    end
                    s=tmp.(varInfo.SymbolName);
                    fm=fmTmp.(varInfo.SymbolName);
                else
                    s=varInfo.annotated_Type;
                    fm=varInfo.getFimath();
                end
                numerictypeList{ii}=s;
                fimathList{ii}=fm;
            end
        end





        function glbFcnIDs=getFcnsContainingGlobals(this,globalName)
            import coder.internal.lib.ListHelper
            if nargin<2
                glbFcnIDs=unique(ListHelper.flatten(this.globalVarMap.values));
            else
                glbFcnIDs=this.globalVarMap(globalName);
            end
        end








        function glbCopyNamesMap=getUniqGlobalNameMapping(this)
            import coder.internal.lib.DistinctNameService
            glbCopyNamesMap=coder.internal.lib.Map();

            glbVars=this.getGlobalVars();
            glbFcnIDs=this.getFcnsContainingGlobals();

            nonConstantGlobals={};

            allVarNames={};
            for ii=1:length(glbFcnIDs)
                fcnID=glbFcnIDs{ii};
                fcnInfo=this.getFunctionTypeInfo(fcnID);
                fcnGlbVars=fcnInfo.getGlobalVars();
                for jj=1:length(fcnGlbVars)
                    ginfo=fcnInfo.getVarInfo(fcnGlbVars{jj});
                    if~isempty(ginfo)&&~ginfo.isCoderConst
                        nonConstantGlobals{end+1}=fcnGlbVars{jj};%#ok<AGROW>
                    end
                end
                varInfosCell=fcnInfo.getAllVarInfos();

                varInfos=[varInfosCell{:}];
                allVarNames={allVarNames{:},varInfos.SymbolName};
            end

            allVarNames={allVarNames{:},glbVars{:}};

            uniqNameService=DistinctNameService();
            uniqNameService.addNames(unique(allVarNames));
            cellfun(@(n)glbCopyNamesMap.add(n,uniqNameService.distinguishName([n,'_g'])),unique(nonConstantGlobals),'UniformOutput',false);

            assert(isempty(intersect(glbCopyNamesMap.values,glbVars)));

        end

        function res=hasGlobals(this)
            res=~isempty(this.getGlobalVars);
        end
    end
end


