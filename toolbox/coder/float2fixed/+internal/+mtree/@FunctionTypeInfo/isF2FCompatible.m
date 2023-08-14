

function[compatible,messages]=isF2FCompatible(this,messages,runDMMChecks,dvoCfg,processedClasses,doubleToSingle,arrayOfStructSupport,isMLFBApply,dvoNonScalarSupport)



    compatible=true;
    varDefnsList=this.symbolTable.values();
    reported=containers.Map();

    sysObjs=coder.internal.getSupportedSystemObjects();
    supportedSystemObjects=containers.Map();
    for ii=1:length(sysObjs)
        sysObjClassName=sysObjs{ii};
        supportedSystemObjects(sysObjClassName)=true;
    end



    if this.isDesign
        rCalls=this.getRecursiveCalls();



        for cc=1:numel(rCalls)
            rCall=rCalls(cc);
            m=getMessage(rCall.Caller,coder.internal.lib.Message.ERR,'Coder:FXPCONV:RecursiveFunctionCall',{rCall.Callee.functionName},rCall.Node);
            messages(end+1)=m;
        end
    end

    if this.isASpecializedFunction()&&this.hasPersistentVariables()
        if doubleToSingle
            errID='Coder:FXPCONV:DTS_FcnSpecialzedWithPersistent';
        else
            errID='Coder:FXPCONV:FcnSpecialzedWithPersistent';
        end
        fcnNode=this.tree.root;
        messages=[messages,this.getMessage(coder.internal.lib.Message.ERR,errID,{this.functionName,strjoin(this.persistentVarNames,', '),this.specializationName},fcnNode)];
    end

    if~isempty(this.className)&&~processedClasses.isKey(this.className)
        processedClasses(this.className)=true;

        classdefNode=this.tree.root;
        while~isempty(classdefNode)&&~strcmp(classdefNode.kind,'CLASSDEF')
            classdefNode=classdefNode.Next;
        end
        if isempty(classdefNode)
            messages=this.addClassConstraintFailureMessage(messages,...
            classdefNode,'Coder:FXPCONV:UnsupportedClassFolder',this.className);
            compatible=false;
            return;
        end

        messages=this.checkSpecialFunctionSpecializations(messages,classdefNode);

        if isMLFBApply
            if doubleToSingle
                msgID='Coder:FXPCONV:MLFB_UnSupportedMCOS_DTS';
            else
                msgID='Coder:FXPCONV:MLFB_UnSupportedMCOS';
            end
            messages=this.addClassConstraintFailureMessage(messages,...
            classdefNode,msgID,this.className);
            compatible=false;
            return;
        end

        [packageError,messages]=this.checkDefiningClassPackage(classdefNode,messages);
        if packageError
            compatible=false;
            return;
        end

        [inheritanceError,messages]=this.checkDefiningClassInheritance(classdefNode,messages);
        if inheritanceError
            compatible=false;
            return;
        end

        [propertiesSectionError,messages]=this.checkDefiningClassPropertiesSection(classdefNode,messages,doubleToSingle);
        if propertiesSectionError
            compatible=false;
            return;
        end
    end

    for ii=1:length(varDefnsList)
        varDefns=varDefnsList{ii};

        varInfo=varDefns{1};

        if reported.isKey(varInfo.SymbolName)

            continue;
        end

        if varInfo.isStruct()||varInfo.isVarInSrcCppSystemObj()
            checkStructCompatibility(varInfo,arrayOfStructSupport);
        else
            checkCompatibility(varInfo,arrayOfStructSupport);
        end

        if doubleToSingle
            if varInfo.isCoderConst
                if any(ismember(this.globalVarNames,varInfo.SymbolName))
                    addMessage(message('Coder:FXPCONV:DTS_CoderConstantGlobalVar',varInfo.SymbolName));
                    compatible=false;
                end
            end
        end

        if(runDMMChecks)
            checkDMMCompatibility(varInfo,dvoNonScalarSupport);
        end
    end

    function checkStructCompatibility(varInfo,arrayOfStructSupport)

        if varInfo.isRootStruct()
            if checkIfStructWithinMCOS(varInfo)
                compatible=false;
                return;
            end

            if checkIfStructContainsMCOS(varInfo)
                compatible=false;
                return;
            end
        end


        structs=varInfo.nestedStructuresInferredTypes.keys;
        for jj=1:length(structs)
            field=structs{jj};
            fieldVarInfo=varInfo.getStructPropVarInfo(field);
            checkCompatibility(fieldVarInfo,arrayOfStructSupport);
        end

        for jj=1:length(varInfo.loggedFields)
            field=varInfo.loggedFields{jj};
            fieldVarInfo=varInfo.getStructPropVarInfo(field);
            checkCompatibility(fieldVarInfo,arrayOfStructSupport);
        end
    end

    function checkCompatibility(varInfo,arrayOfStructSupport)
        if isempty(varInfo.inferred_Type)

            compatible=false;
            reason='Internal Error: No inferred type.';
            return;
        end

        if this.isDesign()&&(varInfo.isInputArg||varInfo.isOutputArg)...
            &&varInfo.isMCOSClass()
            compatible=false;
            if doubleToSingle
                addMessage(message('Coder:FXPCONV:MCOSClassIO_DTS',varInfo.SymbolName));
            else
                addMessage(message('Coder:FXPCONV:MCOSClassIO',varInfo.SymbolName));
            end
            return;
        end

        if~arrayOfStructSupport&&varInfo.isStruct()...
            &&~all(ones(1,length(varInfo.inferred_Type.Size))==varInfo.inferred_Type.Size')
            compatible=false;
            if doubleToSingle
                addMessage(message('Coder:FXPCONV:F2FArrayOfStructs_DTS',varInfo.SymbolName));
            else
                addMessage(message('Coder:FXPCONV:F2FArrayOfStructs',varInfo.SymbolName));
            end
            return;
        end


        if varInfo.isCell()&&~strcmp(varInfo.SymbolName,'varargin')...
            &&~strcmp(varInfo.SymbolName,'varargout')
            compatible=false;
            if doubleToSingle
                addMessage(message('Coder:FXPCONV:UnsupportedCellArrays_DTS',varInfo.SymbolName));
            else
                addMessage(message('Coder:FXPCONV:UnsupportedCellArrays',varInfo.SymbolName));
            end
            return;
        end

        if varInfo.isCell()&&this.isDesign
            compatible=false;

            if doubleToSingle
                addMessage(message('Coder:FXPCONV:UnsupportedVarargs_DTS'));
            else
                addMessage(message('Coder:FXPCONV:UnsupportedVarargs'));
            end
            return;
        end

        if varInfo.isSparse()
            compatible=false;

            if doubleToSingle
                addMessage(message('Coder:FXPCONV:UnsupportedSparse_DTS',varInfo.SymbolName));
            else
                addMessage(message('Coder:FXPCONV:UnsupportedSparse',varInfo.SymbolName));
            end
            return;
        end
    end

    function checkDMMCompatibility(varInfo,dvoNonScalarSupport)
        if runDMMChecks
            if any(varInfo.inferred_Type.MCOSClass)


                clsName=varInfo.inferred_Type.Class;
                if~isempty(dvoCfg.getSystemObjectReplacementFunction(clsName))
                    return;
                end

                if matlab.system.isSystemObjectName(clsName)



                    sysObjPath=which(clsName);
                    toolboxPath=fullfile(matlabroot,'toolbox');
                    if~contains(sysObjPath,toolboxPath)

                        return;
                    end



                    compatible=false;
                    clsName=matlab.system.internal.getClassNameForWrappedSystemObject(clsName);
                    addMessage(message('Coder:FXPCONV:DvoSystemObject',varInfo.SymbolName,clsName));
                    return;
                end



                compatible=false;
                addMessage(message('Coder:FXPCONV:DvoMCOSClass',varInfo.SymbolName));
                return;
            end

            if~dvoNonScalarSupport&&~varInfo.isScalar()
                compatible=false;
                addMessage(message('Coder:FXPCONV:DvoNonScalarType',varInfo.SymbolName));
                return;
            end

            if any(varInfo.inferred_Type.Size(:)==-1)
                compatible=false;
                addMessage(message('Coder:FXPCONV:DvoUnboundedSize',varInfo.SymbolName));
                return;
            end

            if any(varInfo.inferred_Type.SizeDynamic)
                compatible=false;
                addMessage(message('Coder:FXPCONV:DvoVariableSize',varInfo.SymbolName));
                return;
            end

            for jj=2:length(varDefns)
                varInfoAtAnotherLoc=varDefns{jj};
                if varInfoAtAnotherLoc.isVarInSrcCppSystemObj()


                    compatible=false;



                    return;
                end
                if varInfoAtAnotherLoc.inferred_Type.Size~=varInfo.inferred_Type.Size
                    compatible=false;
                    addMessage(message('Coder:FXPCONV:DvoChangingSize',varInfo.SymbolName));
                    return;
                end
            end

            if varInfo.isStruct()||varInfo.isVarInSrcCppSystemObj()

                compatible=false;
                addMessage(message('Coder:FXPCONV:DvoStructureType',varInfo.SymbolName));
                return;
            end

            if dvoCfg.hasDesignRangeSpecification(this.specializationName,varInfo.SymbolName)
                designRange=dvoCfg.getDesignRangeSpecification(this.specializationName,varInfo.SymbolName);
                designMin=designRange.DesignMin;
                designMax=designRange.DesignMax;
                if~isempty(varInfo.inferred_Type)
                    type=varInfo.inferred_Type.Class;
                    rangeMin=[];
                    rangeMax=[];
                    switch type
                    case{'uint8','uint16','uint32','uint64',...
                        'int8','int16','int32','int64'}
                        rangeMin=double(intmin(type));
                        rangeMax=double(intmax(type));
                    case{'logical'}
                        rangeMin=0;
                        rangeMax=1;

                    case{'embedded.fi'}
                        r=double(range(fi(0,varInfo.inferred_Type.NumericType)));
                        rangeMin=r(1);
                        rangeMax=r(2);
                    end

                    if~isempty(rangeMax)&&~isempty(designMax)&&designMax>rangeMax
                        addMessage(message('Coder:FXPCONV:DvoDesignMaxOutOfBounds',coder.internal.compactButAccurateNum2Str(designMax),type,varInfo.SymbolName));
                        compatible=false;
                        return;
                    end

                    if~isempty(rangeMin)&&~isempty(designMin)&&designMin<rangeMin
                        addMessage(message('Coder:FXPCONV:DvoDesignMinOutOfBounds',coder.internal.compactButAccurateNum2Str(designMin),type,varInfo.SymbolName));
                        compatible=false;
                        return;
                    end

                    if~isempty(designMin)&&~isempty(designMax)&&designMin>designMax
                        addMessage(message('Coder:FXPCONV:DvoDesignMinGreaterThanDesignMax',varInfo.SymbolName));
                        compatible=false;
                        return;
                    end
                end
            end
        end
    end

    function result=checkIfStructWithinMCOS(varInfo)


        result=false;
        assert(varInfo.isStruct());


        rootVarName=this.getRootVarName(varInfo.SymbolName);
        rootVarInfos=this.getVarInfosByName(rootVarName);
        for kk=1:numel(rootVarInfos)
            if rootVarInfos{kk}.isMCOSClass
                names=strsplit(varInfo.SymbolName,'.');
                leafPropName=names{end};
                addMessage(message('Coder:FXPCONV:MCOSClass_StructProperties',leafPropName,rootVarInfos{kk}.getOriginalTypeClassName));
                result=true;
                return;
            end
        end
    end

    function result=checkIfStructContainsMCOS(varInfo)


        assert(varInfo.isStruct());

        [result,fieldNames,mcosClassNames]=coder.internal.VarTypeInfo.CheckIfStructContainsMCOS(varInfo);
        if result
            cellfun(@(fieldN,mcosClassName)addMessage(message('Coder:FXPCONV:Struct_MCOSClassFields',fieldN,mcosClassName))...
            ,fieldNames,mcosClassNames);
        end
    end



    function addMessage(message)

        i=length(messages)+1;
        msg=varInfo.getMessage(message,coder.internal.lib.Message.ERR);
        messages(i)=msg;
        reported(varInfo.SymbolName)=true;
    end
end


