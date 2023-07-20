


classdef VarTypeInfo<coder.internal.BaseVarInfo

    properties(Access=public)

SymbolName
IntegerId
SpecializationName
SpecializationId


DesignMin
DesignMax
DesignRangeSpecified
DesignIsInteger


DerivedMin
DerivedMax
DerivedMinMaxComputed

        isInputArg;
        isOutputArg;
        isCoderConst;
        isGlobal;
        isLiteralDoubleConstant;



loggedFields


inferred_Type
loggedFieldsInferred_Types

nestedStructuresInferredTypes

functionInfo

TextStart
TextLength
        MxInfoLocationId;


        cppSystemObjectLoggedPropertiesInfo;



Synthesized

MxInfoID
loggedFieldsMxInfoIDs
nestedStructuresMxInfoIDs


instrumentedForLogging
    end

    properties(Access=private)
fimath
    end

    properties(Dependent)

annotated_Type
    end

    properties(Constant)
        MLNUMERICTYPES={'double','single','embedded.fi',...
        'int8','int16','int32','int64',...
        'uint8','uint16','uint32','uint64'};
    end

    methods
        function t=get.annotated_Type(this)
            t=this.userSpecifiedAnnotation;

            if this.isStruct()
                if isempty(t)
                    t=this.proposed_Type;
                else


                    for ii=1:length(this.loggedFields)
                        if isempty(t{ii})&&~isempty(this.proposed_Type)&&~isempty(this.proposed_Type{ii})
                            t{ii}=this.proposed_Type{ii};
                        end
                    end
                end
            else


                if isempty(t)
                    t=this.proposed_Type;
                end
            end
            if ischar(t)&&strcmp(t,coder.internal.MLFcnBlock.F2FDriver.NA_TYPE)
                t=[];
            end
        end

        function set.annotated_Type(this,t)
            this.userSpecifiedAnnotation=t;
        end

        function setIsGlobal(this,value)
            this.isGlobal=value;
        end

        function setIsCoderConst(this,value)
            this.isCoderConst=value;
        end

        function set.isInputArg(this,value)
            this.isInputArg=value;
        end
    end


    properties(Constant,Hidden)
        DEFAULT_IS_INTEGER=logical.empty();


        NON_EMPTY_DEFAULT_IS_INTEGER=false;
        UNKNOWN_STR='Unknown';
        DEFAULT_SPL_ID=-1;
    end

    methods(Static)

        function varInfo=buildStructVarInfo(structVarInfo,fieldIndices,propName)
            varInfo=coder.internal.VarTypeInfo();
            varInfo.functionInfo=structVarInfo.functionInfo;
            varInfo.SymbolName=propName;char(strcat(structVarInfo.SymbolName,'.',propName));
            varInfo.SpecializationName=varInfo.SymbolName;

            varInfo.TextStart=[];
            varInfo.TextLength=[];
            varInfo.MxInfoLocationId=[];

            varInfo.inferred_Type=structVarInfo.nestedStructuresInferredTypes(propName);
            varInfo.MxInfoID=structVarInfo.nestedStructuresMxInfoIDs(propName);


            fieldsWithDefFimath=arrayfun(@(idx)~structVarInfo.isFimathSetForStructField(idx),fieldIndices,'UniformOutput',true);
            fieldsFimath=arrayfun(@(idx)structVarInfo.getFimathForStructField(idx),fieldIndices,'UniformOutput',false);
            for ii=1:length(fieldsWithDefFimath)
                if fieldsWithDefFimath(ii)
                    fieldsFimath{ii}=[];
                end
            end
            varInfo.setFimath(fieldsFimath);


            varInfo.isInputArg=false;
            varInfo.isOutputArg=false;
            varInfo.isCoderConst=structVarInfo.isCoderConst;
            varInfo.isGlobal=structVarInfo.isGlobal;

            varInfo.loggedFieldsMxInfoIDs={structVarInfo.loggedFieldsMxInfoIDs{fieldIndices}};


            varInfo.loggedFields=structVarInfo.loggedFields(fieldIndices);

            varInfo.loggedFieldsInferred_Types={structVarInfo.loggedFieldsInferred_Types{fieldIndices}};

            strctNames=structVarInfo.nestedStructuresInferredTypes.keys;
            patternMatch=['^',strrep(propName,'.','\.'),'\..+'];
            matches=regexp(strctNames,patternMatch);
            assert(length(matches)==length(strctNames));
            nestedStructNames={};
            for ii=1:length(matches)
                match=matches{ii};
                if~isempty(match)
                    assert(1==match);
                    nestedStructNames{end+1}=strctNames{ii};
                end
            end
            cellfun(@(name)varInfo.nestedStructuresInferredTypes.add(name,structVarInfo.nestedStructuresInferredTypes.get(name))...
            ,nestedStructNames);
            cellfun(@(name)varInfo.nestedStructuresMxInfoIDs.add(name,structVarInfo.nestedStructuresMxInfoIDs.get(name))...
            ,nestedStructNames);
            varInfo.assignStructRoot(fieldIndices,structVarInfo);
        end

        function varInfo=buildScalarVarInfo(structVarInfo,index)
            varInfo=coder.internal.VarTypeInfo();
            varInfo.functionInfo=structVarInfo.functionInfo;
            varInfo.SymbolName=structVarInfo.loggedFields{index};
            varInfo.SpecializationName=varInfo.SymbolName;

            varInfo.TextStart=structVarInfo.TextStart;
            varInfo.TextLength=structVarInfo.TextLength;
            varInfo.MxInfoLocationId=structVarInfo.MxInfoLocationId;

            varInfo.MxInfoID=structVarInfo.loggedFieldsMxInfoIDs{index};
            varInfo.inferred_Type=structVarInfo.loggedFieldsInferred_Types{index};
            if structVarInfo.isFimathSetForStructField(index)
                fm=structVarInfo.getFimathForStructField(index);
            else
                fm=[];
            end
            varInfo.setFimath(fm);

            varInfo.isInputArg=structVarInfo.isInputArg;
            varInfo.isOutputArg=structVarInfo.isOutputArg;
            varInfo.isCoderConst=structVarInfo.isCoderConst;
            varInfo.isGlobal=structVarInfo.isGlobal;
            varInfo.loggedFields=[];
            varInfo.loggedFieldsInferred_Types=[];
            varInfo.assignStructRoot(index,structVarInfo);
        end





        function[simMin,simMax]=ResetImposibleSimData(simMin,simMax)
            UNKNOWN=coder.internal.VarTypeInfo.UNKNOWN_STR;
            if coder.internal.VarTypeInfo.isImpossibleRangeData(simMin,simMax)
                if length(simMin)>1
                    infIdx=(simMin==Inf);
                    mn=num2cell(simMin);
                    mn{infIdx}=UNKNOWN;

                    infIdx=(simMax==-Inf);
                    mx=num2cell(simMax);
                    mx{infIdx}=UNKNOWN;

                    simMin=mn;
                    simMax=mx;
                else
                    simMin=UNKNOWN;
                    simMax=UNKNOWN;
                end
            end
        end

        function res=isImpossibleRangeData(min,max)
            res=~isempty(min)&&~isempty(max)...
            &&any(min==Inf)&&any(max==-Inf);
        end

        function[result,fieldNames,classNames]=CheckIfStructContainsMCOS(varInfo)
            fieldNames='';
            classNames='';
            assert(varInfo.isStruct());

            fieldInferredTypes=varInfo.loggedFieldsInferred_Types;

            idx=cellfun(@(inferredType)(inferredType.MCOSClass||inferredType.SystemObj||inferredType.CppSystemObj)...
            ,fieldInferredTypes);
            result=any(idx);
            if result

                mcosInferredType=fieldInferredTypes(idx);
                classNames=cellfun(@(inferredType)inferredType.Class,mcosInferredType,'UniformOutput',false);

                fieldNames=varInfo.loggedFields(idx);
            end
        end
    end

    methods(Access=public)

        function this=VarTypeInfo(varLogInfo,inferredType,isCoderConst)
            this=this@coder.internal.BaseVarInfo();

            this.isLiteralDoubleConstant=false;
            this.nestedStructuresInferredTypes=coder.internal.lib.Map();
            this.nestedStructuresMxInfoIDs=coder.internal.lib.Map();
            this.SpecializationId=coder.internal.VarTypeInfo.DEFAULT_SPL_ID;
            this.instrumentedForLogging=false;
            if(nargin>=3)
                this.SymbolName=varLogInfo.SymbolName;
                this.IntegerId=0;
                this.SpecializationName=this.SymbolName;
                this.DesignRangeSpecified=false;
                this.DerivedMinMaxComputed=false;
                this.SimMin=varLogInfo.SimMin;
                this.SimMax=varLogInfo.SimMax;

                if isfield(varLogInfo,'HistogramOfNegativeValues')
                    this.HistogramOfNegativeValues=varLogInfo.HistogramOfNegativeValues;
                    this.HistogramOfPositiveValues=varLogInfo.HistogramOfPositiveValues;
                end

                this.IsAlwaysInteger=varLogInfo.IsAlwaysInteger;
                this.TextStart=[];
                this.TextLength=[];
                this.MxInfoLocationId=[];
                this.inferred_Type=inferredType;
                this.isInputArg=varLogInfo.IsArgin;
                this.isOutputArg=varLogInfo.IsOutputArg;
                this.isCoderConst=isCoderConst;

                this.isGlobal=false;

                this.proposed_Type=[];
                this.annotated_Type=[];

                if(strcmp(inferredType.Class,'struct'))||inferredType.CppSystemObj
                    this.loggedFields=varLogInfo.LoggedFieldNames;
                    numFields=length(this.loggedFields);
                    this.setFimath(cell(1,numFields));
                    this.RatioOfRange=cell(1,numFields);
                    this.loggedFieldsInferred_Types=varLogInfo.LoggedFieldsInferredTypes;
                    this.nestedStructuresInferredTypes=varLogInfo.nestedStructuresInferredTypes;
                    if inferredType.CppSystemObj
                        this.cppSystemObjectLoggedPropertiesInfo=varLogInfo.cppSystemObjectLoggedPropertiesInfo;
                    end
                    this.loggedFieldsMxInfoIDs=varLogInfo.LoggedFieldMxInfoIDs;
                    this.nestedStructuresMxInfoIDs=varLogInfo.nestedStructuresMxInfoIDs;
                else
                    this.setFimath([]);
                    this.RatioOfRange={[]};
                    this.loggedFields={};
                    this.nestedStructuresInferredTypes=coder.internal.lib.Map();
                    this.nestedStructuresMxInfoIDs=coder.internal.lib.Map();
                    this.loggedFieldsMxInfoIDs={};
                end

                if this.isStruct()||inferredType.CppSystemObj
                    feildCount=length(varLogInfo.LoggedFieldNames);
                    this.DesignMin=-Inf(1,feildCount);
                    this.DesignMax=Inf(1,feildCount);

                    this.DerivedMin=-Inf(1,feildCount);
                    this.DerivedMax=Inf(1,feildCount);

                    this.DesignIsInteger=Inf(1,feildCount);
                else
                    this.DesignMin=[];
                    this.DesignMax=[];

                    this.DerivedMin=[];
                    this.DerivedMax=[];

                    this.DesignIsInteger=[];
                end


                this.functionInfo=[];
                this.Synthesized=false;

                this.MxInfoID=varLogInfo.MxInfoID;
            end
        end

        function setIsLiteralDoubleConstant(this,val)
            this.isLiteralDoubleConstant=val;
        end



        function setSymbolName(this,val)
            origSymbol=this.SymbolName;
            this.SymbolName=val;
            this.SpecializationName=val;
            if this.isStruct()||this.isVarInSrcCppSystemObj()
                this.loggedFields=cellfun(@(x)regexprep(x,origSymbol,val,'Once'),this.loggedFields,'UniformOutput',false);


                tmp=this.nestedStructuresInferredTypes;
                newNestedTypesMap=coder.internal.lib.Map();
                tmpKeys=tmp.keys;
                for ii=1:length(tmpKeys)
                    k=tmpKeys{ii};
                    kv=tmp(k);
                    newNestedTypesMap(regexprep(k,origSymbol,val,'Once'))=kv;
                end
                this.nestedStructuresInferredTypes=newNestedTypesMap;

                tmp=this.nestedStructuresMxInfoIDs;
                newNestedMxInfoIDs=coder.internal.lib.Map();
                tmpKeys=tmp.keys;
                for ii=1:length(tmpKeys)
                    k=tmpKeys{ii};
                    kv=tmp(k);
                    newNestedMxInfoIDs(regexprep(k,origSymbol,val,'Once'))=kv;
                end
                this.nestedStructuresMxInfoIDs=newNestedMxInfoIDs;
            end
        end



        function bVal=hasOrigScaledDouble(this)
            bVal=false;
            if this.isStruct()||this.isVarInSrcCppSystemObj()
                for ii=1:length(this.loggedFields)
                    prop=this.loggedFields{ii};
                    proVarInfo=this.getStructPropVarInfo(prop);
                    if proVarInfo.isVarInSrcFixedPoint()
                        bVal=proVarInfo.inferred_Type.NumericType.isscaleddouble;
                    end
                    if bVal
                        break;
                    end
                end
            else
                if this.isVarInSrcFixedPoint()
                    bVal=this.inferred_Type.NumericType.isscaleddouble;
                end
            end
        end


        function clearSimulationData(this)
            this.SimMin=[];
            this.SimMax=[];

            this.HistogramOfNegativeValues=[];
            this.HistogramOfPositiveValues=[];

            this.IsAlwaysInteger=coder.internal.VarTypeInfo.DEFAULT_IS_INTEGER;

            this.proposed_Type=[];
            this.annotated_Type=[];
        end

        function clearStaticAnalysisData(this)
            if this.isStruct()||this.isVarInSrcCppSystemObj()
                feildCount=length(this.loggedFields);
                this.DesignMin=-Inf(1,feildCount);
                this.DesignMax=Inf(1,feildCount);



                this.DerivedMin=-Inf(1,feildCount);
                this.DerivedMax=Inf(1,feildCount);
            else
                this.DesignMin=[];
                this.DesignMax=[];

                this.DerivedMin=[];
                this.DerivedMax=[];
            end

            this.DesignRangeSpecified=false;

            this.DerivedMinMaxComputed=false;
        end

        function clearAnnotations(this)
            if this.isStruct()||this.isVarInSrcCppSystemObj()
                fieldCount=length(this.loggedFields);
                this.setFimath(cell(1,fieldCount));
                this.userSpecifiedAnnotation=[];
                this.DesignMin=-Inf(1,fieldCount);
                this.DesignMax=Inf(1,fieldCount);
                this.DesignIsInteger=Inf(1,fieldCount);
            else
                this.setFimath([]);
                this.userSpecifiedAnnotation=[];
                this.DesignMin=[];
                this.DesignMax=[];
                this.DesignIsInteger=[];
            end
        end

        function clearDesignRangeSpecifications(this)
            if this.isStruct()||this.isVarInSrcCppSystemObj()
                feildCount=length(this.loggedFields);
                this.DesignMin=-Inf(1,feildCount);
                this.DesignMax=Inf(1,feildCount);
            else
                this.DesignMin=[];
                this.DesignMax=[];
            end
            this.DesignRangeSpecified=false;
        end

        function[acceptedMin,acceptedMax,acceptedIsInt,msg]=getAcceptedMinMax(this,useSimulationRanges,useDerivedRanges,ii)
            acceptedMin=[];
            acceptedMax=[];
            msg=coder.internal.lib.Message.empty();


            this.coerceIncorrectDerivedRangeToInfs(ii);




            if useSimulationRanges
                if exists(this.SimMin,ii)&&exists(this.SimMax,ii)
                    acceptedMin=this.SimMin(ii);
                    acceptedMax=this.SimMax(ii);
                end
            end

            if useDerivedRanges
                if~exists(this.DerivedMin,ii)
                    useDerivedRanges=false;
                elseif exists(this.SimMin,ii)&&useSimulationRanges&&(this.DerivedMin(ii)>this.SimMin(ii))

                    useDerivedRanges=false;
                end
                if~exists(this.DerivedMax,ii)
                    useDerivedRanges=false;
                elseif exists(this.SimMax,ii)&&useSimulationRanges&&(this.DerivedMax(ii)<this.SimMax(ii))

                    useDerivedRanges=false;
                end
            end

            if useDerivedRanges
                acceptedMin=this.DerivedMin(ii);
                acceptedMax=this.DerivedMax(ii);
            end

            if true
                if exists(this.DesignMin,ii)&&exists(this.DesignMax,ii)
                    acceptedMin=this.DesignMin(ii);
                    acceptedMax=this.DesignMax(ii);

                    if exists(this.SimMin,ii)&&exists(this.SimMax,ii)&&...
                        (this.SimMin(ii)<this.DesignMin(ii)||this.SimMax(ii)>this.DesignMax(ii))
                        if this.isStruct()||this.isVarInSrcCppSystemObj()
                            varName=this.loggedFields{ii};
                        else
                            varName=this.SymbolName;
                        end

                        mlMessage=message('Coder:FXPCONV:DesignRangeSmaller',varName);
                        msg=this.getMessage(mlMessage,coder.internal.lib.Message.WARN);
                    end
                end
            end

            if(~isempty(acceptedMin)&&~isempty(acceptedMax))&&(acceptedMin==acceptedMax&&floor(acceptedMin)==acceptedMin)
                this.IsAlwaysInteger(ii)=true;
            end

            if exists(this.DesignIsInteger,ii)
                acceptedIsInt=this.DesignIsInteger(ii);
            elseif useSimulationRanges&&exists(this.IsAlwaysInteger,ii)
                acceptedIsInt=this.IsAlwaysInteger(ii);
            else
                acceptedIsInt=coder.internal.VarTypeInfo.NON_EMPTY_DEFAULT_IS_INTEGER;
            end

            function b=exists(bound,ii)
                if iscell(bound)
                    b=~isempty(bound)&&~isempty(bound{ii})&&(abs(real(bound{ii}))~=Inf);
                else
                    b=~isempty(bound)&&~isempty(bound(ii))&&(abs(real(bound(ii)))~=Inf);
                end
            end
        end


        function coerceIncorrectDerivedRangeToInfs(this,ii)
            incorrectRange=false;
            if ii<=length(this.SimMin)

                if ii>length(this.DerivedMin)

                elseif this.DerivedMin(ii)>this.SimMin(ii)

                    incorrectRange=true;
                end
            end
            if ii<=length(this.SimMax)

                if ii>length(this.DerivedMax)

                elseif this.DerivedMax(ii)<this.SimMax(ii)

                    incorrectRange=true;
                end
            end

            if incorrectRange
                this.DerivedMin(ii)=-Inf;
                this.DerivedMax(ii)=Inf;
            end
        end


        function coerceIncorrectDerivedRangesToInfs(this)
            for ii=1:length(this.SimMin)
                this.coerceIncorrectDerivedRangeToInfs(ii);
            end
        end



        function result=isNumericTypeWithInfSimRange(this)
            result=false;
            assert(~this.isRootStruct);
            if this.isNumericVar&&~coder.internal.VarTypeInfo.isImpossibleRangeData(this.SimMin,this.SimMax)
                if~isempty(this.SimMin)&&(this.SimMin==Inf||this.SimMin==-Inf)
                    result=true;
                elseif~isempty(this.SimMin)&&(this.SimMax==-Inf||this.SimMax==Inf)
                    result=true;
                end
            end
        end

        function[val,isField]=getStructScalarProp(this,prop,key)
            val=coder.internal.VarTypeInfo.empty();
            isField=false;
            if this.isStruct()||this.isVarInSrcCppSystemObj()
                truthVals=strcmp(this.loggedFields,[this.SymbolName,'.',prop]);
                if any(truthVals)
                    isField=true;
                    indices=find(truthVals);
                    if length(indices)==1
                        index=indices(1);
                        if strcmp(key,'fimath')
                            val=this.getFimathForStructField(index);
                        else



                            propertyVal=this.(key);
                            if iscell(propertyVal)
                                val=propertyVal{index};
                            else
                                val=propertyVal(index);
                            end
                        end
                    else
                        error('multiple property names not expected');
                    end
                end

            else
                error('not a struct');
            end
        end

        function setStructScalarProp(this,prop,key,val)
            if this.isStruct()||this.isVarInSrcCppSystemObj()
                truthVals=strcmp(this.loggedFields,[this.SymbolName,'.',prop]);
                if any(truthVals)
                    indices=find(truthVals);
                    if length(indices)==1
                        index=indices(1);






                        propertyVal=this.(key);
                        if isempty(propertyVal)
                            propertyVal=cell(1,length(this.loggedFields));
                        end
                        if iscell(propertyVal)
                            propertyVal{index}=val;
                        else
                            propertyVal(index)=val;
                        end
                        this.(key)=propertyVal;
                    else
                        error('multiple property names not expected');
                    end
                end

            else
                error('not a struct');
            end
        end




        function varInfo=getStructPropVarInfo(this,prop)
            varInfo=[];
            if this.isStruct()||this.isVarInSrcCppSystemObj()

                if strcmp(this.SymbolName,prop)
                    varInfo=this;
                    return;
                elseif this.isAStructField()


                    this.getRootStructInfo().getStructPropVarInfo(prop);
                elseif this.hasStructFieldVarInfo(prop)
                    assert(~this.isAStructField());
                    varInfo=this.getStructFieldVarInfo(prop);
                    return;
                end
                truthVals=regexp(this.loggedFields,['^',prop,'$']);
                truthVals=this.cell2mat(truthVals);
                if any(truthVals)
                    indices=find(truthVals);
                    assert(length(indices)==1)
                    index=indices(1);



                    if strcmp(this.loggedFields{index},prop)
                        varInfo=coder.internal.VarTypeInfo.buildScalarVarInfo(this,index);
                    else
                        return;
                    end
                else
                    truthVals=regexp(this.loggedFields,['^',prop]);
                    truthVals=this.cell2mat(truthVals);
                    indices=find(truthVals);

                    if any(truthVals)

                        structFieldIndices=[];
                        for ii=1:length(indices)
                            res=strfind(this.loggedFields{indices(ii)},[prop,'.']);
                            if~isempty(res)&&res(1)==1
                                structFieldIndices=[structFieldIndices,indices(ii)];
                            end
                        end
                        if~isempty(structFieldIndices)
                            varInfo=coder.internal.VarTypeInfo.buildStructVarInfo(this,structFieldIndices,prop);
                        end
                    else





                        if this.nestedStructuresInferredTypes.isKey(prop)
                            varInfo=coder.internal.VarTypeInfo.buildStructVarInfo(this,[],prop);
                        end
                        return;
                    end
                end
                if~isempty(varInfo)&&~this.isAStructField()
                    this.addStructFieldVarInfo(prop,varInfo);
                end
            else
                error('not a struct');
            end
        end

        function r=isEnum(this)
            r=this.inferred_Type.Enum;
        end

        function r=isScalar(this)
            r=all(ones(1,length(this.inferred_Type.Size))==this.inferred_Type.Size');
        end

        function r=isStruct(this)
            r=strcmp(this.inferred_Type.Class,'struct');
        end

        function res=isRootStruct(this)
            res=this.isStruct()&&isRootStruct@coder.internal.BaseVarInfo(this);
        end

        function r=isCell(this)
            r=strcmp(this.inferred_Type.Class,'cell');
        end

        function r=isSparse(this)
            r=this.inferred_Type.Sparse;
        end

        function r=isVarInSrcFixedPoint(this)
            class=this.inferred_Type.Class;
            r=strcmp(class,'embedded.fi');
        end

        function r=isVarInSrcSlopeBiasScalaed(this)
            nt=this.inferred_Type.NumericType;
            r=this.isVarInSrcFixedPoint()&&isslopebiasscaled(nt);
        end

        function r=isVarInSrcInteger(this)
            class=this.inferred_Type.Class;
            r=~isempty(regexp(class,'^int|^uint','once'));
        end

        function r=isVarInSrcDouble(this)
            class=this.inferred_Type.Class;
            r=strcmp(class,'double');
        end

        function r=isVarInSrcBoolean(this)
            class=this.inferred_Type.Class;
            r=strcmp(class,'logical');
        end

        function r=isVarInSrcComplex(this)
            r=this.inferred_Type.Complex;
        end

        function r=isVarInSrcSystemObj(this)
            if(isfield(this.inferred_Type,'SystemObj'))
                r=this.inferred_Type.SystemObj;
            else
                r=false;
            end
        end

        function r=isVarInSrcChar(this)
            class=this.inferred_Type.Class;
            r=strcmp(class,'char');
        end

        function r=isString(this)
            r=strcmp(this.inferred_Type.Class,'string');
        end

        function r=isVarInSrcCppSystemObj(this)
            if(isfield(this.inferred_Type,'CppSystemObj'))
                r=this.inferred_Type.CppSystemObj;
            else
                r=false;
            end
        end

        function r=isMCOSClass(this)
            r=this.inferred_Type.MCOSClass;
        end

        function r=isNumericVar(this)
            if numel(this.inferred_Type)==1
                switch this.inferred_Type.Class
                case coder.internal.VarTypeInfo.MLNUMERICTYPES
                    r=true;
                otherwise
                    r=false;
                end
            else
                r=false;
            end
        end



        function r=isVarInSrcEmpty(this)

            r=any(this.inferred_Type.Size==0);
        end

        function r=isSpecialized(this)
            r=(this.SpecializationId~=coder.internal.VarTypeInfo.DEFAULT_SPL_ID);
        end

        function needCast=needsFiCast(this,fiCastFiVars,fiCastIntVars,fiCastDoubleLiteralVars)
            if(nargin<4)
                fiCastDoubleLiteralVars=true;
            end
            if(nargin<3)
                fiCastIntVars=true;
            end
            if(nargin<2)
                fiCastFiVars=false;
            end

            needCast=true;
            if this.isEnum()
                needCast=false;
            elseif this.isMCOSClass()
                needCast=false;
            elseif this.isVarInSrcFixedPoint()&&~fiCastFiVars


                needCast=false;
            elseif this.isVarInSrcInteger()&&~fiCastIntVars


                needCast=false;
            elseif this.isLiteralDoubleConstant&&~fiCastDoubleLiteralVars
                needCast=false;
            elseif this.isVarInSrcBoolean()||this.isVarInSrcSystemObj

                needCast=false;
            elseif this.isVarInSrcChar()
                needCast=false;
            elseif this.isGlobal&&isempty(this.annotated_Type)



                needCast=false;
            elseif strcmp(this.getOriginalTypeClassName,'embedded.numerictype')
                needCast=false;
            end

            if~this.isNumericVar()

                needCast=false;
            end

            if~needCast
                isMLFBEntryPoint=~isempty(this.functionInfo)...
                &&this.functionInfo.isDesign...
                &&~isempty(strfind(this.functionInfo.scriptPath,'#'));
                if isMLFBEntryPoint









                    outputVar=any(ismember(this.functionInfo.outputVarNames,this.SymbolName));
                    if outputVar
                        if this.isStruct()
                        elseif this.isVarInSrcFixedPoint()
                            needCast=true;
                        end
                    end
                end
            end
        end

        function originalType=getOriginalTypeClassName(this)
            originalType=this.inferred_Type.Class;
        end

        function r=isSupportedVar(this)


            r=~(isVarInSrcSystemObj(this)&&~isVarInSrcCppSystemObj(this));
        end


        function update(this,otherVarInfo,typeProposalSettings)

            checkSameProperties(this,otherVarInfo);









            this.DerivedMin=min(this.DerivedMin,otherVarInfo.DerivedMin);
            this.DerivedMax=max(this.DerivedMax,otherVarInfo.DerivedMax);
            this.DerivedMinMaxComputed=this.DerivedMinMaxComputed||otherVarInfo.DerivedMinMaxComputed;


            this.SimMin=min(this.SimMin,otherVarInfo.SimMin);
            this.SimMax=max(this.SimMax,otherVarInfo.SimMax);
            this.IsAlwaysInteger=this.IsAlwaysInteger&&otherVarInfo.IsAlwaysInteger;

            [acceptedMin,acceptedMax,acceptedIsInt]=this.getAcceptedMinMax(typeProposalSettings.useSimulationRanges,typeProposalSettings.useDerivedRanges);
            this.proposed_Type=coder.internal.getBestNumericTypeForVal(acceptedMin,acceptedMax,acceptedIsInt,typeProposalSettings);

            this.annotated_Type=this.annotated_Type;




            function checkSameProperties(that,otherVarInfo)
                assert(strcmp(that.SymbolName,otherVarInfo.SymbolName)&&...
                that.IntegerId==otherVarInfo.IntegerId&&...
                that.SpecializationId==otherVarInfo.SpecializationId&&...
                strcmp(that.inferred_Type.Class,otherVarInfo.inferred_Type.Class)&&...
areLoggedFieldsEqual...
                ,'Internal Error VarTypeInfos are different');





                function res=areLoggedFieldsEqual
                    res=(isempty(that.loggedFields)&&...
                    isempty(otherVarInfo.loggedFields)...
                    ||all(strcmp(sort(that.loggedFields),...
                    sort(otherVarInfo.loggedFields))));
                end
            end
        end

        function newObj=clone(this)
            newObj=copy(this);
        end

        function newObj=copy(this)
            newObj=coder.internal.VarTypeInfo;
            metaInfo=metaclass(this);
            props=metaInfo.PropertyList;

            for ii=1:length(props)
                prop=props(ii);
                if~prop.NonCopyable
                    newObj.(prop.Name)=this.(prop.Name);
                end
            end


            newObj.fimath=this.fimath;
        end


        function msg=getMessage(this,mlMessage,msgType)
            msg=coder.internal.lib.Message();
            msg.functionName=this.functionInfo.functionName;%#ok<*AGROW>
            msg.specializationName=this.functionInfo.specializationName;
            msg.file=this.functionInfo.scriptPath;
            msg.type=msgType;
            msg.position=this.TextStart-1;
            msg.length=this.TextLength;
            msg.text=mlMessage.getString();
            msg.id=mlMessage.Identifier;
            msg.params=mlMessage.Arguments;
        end

        function setAnnotatedType(this,val)
            this.annotated_Type=val;
        end

        function res=isSimRangeNotAvailable(this)
            min=this.SimMin;max=this.SimMax;
            res=coder.internal.VarTypeInfo.isImpossibleRangeData(min,max)...
            ||(isempty(all(min))&&isempty(all(max)));
        end


        function msg=buildMessage(this,msgType,msgId,msgParams)
            if nargin<4
                msgParams={};
            end

            if~iscell(msgParams)
                msgParams={msgParams};
            end

            msg=coder.internal.lib.Message();
            msg.functionName=this.functionInfo.functionName;%#ok<*AGROW>
            msg.specializationName=this.functionInfo.specializationName;
            msg.file=this.functionInfo.scriptPath;
            msg.type=msgType;



            msg.position=this.TextStart-1;
            msg.length=this.TextLength;

            msg.text=message(msgId,msgParams{:}).getString();
            msg.id=msgId;
            msg.params=msgParams;
        end




        function fm=getFimathForStructField(this,fieldIndex)

            fm=this.functionInfo.getFimath();
            if~isempty(this.fimath{fieldIndex})

                fm=this.fimath{fieldIndex};
            end
        end


        function res=isFimathSetForStructField(this,fieldIndex)
            res=~isempty(this.fimath{fieldIndex});
        end




        function fields=getNonNestedLoggedFields(this)
            allLoggedFields=this.loggedFields;
            nonNestedFieldIndices=cellfun(@(l)2==numel(strsplit(strrep(l,this.SymbolName,' '),'.')),allLoggedFields,'UniformOUtput',true);
            fields=allLoggedFields(nonNestedFieldIndices);
        end






        function fields=getImmediateNestedFields(this)
            allNestedFields=this.nestedStructuresInferredTypes.keys;
            nestedFields=cellfun(@(l)2==numel(strsplit(strrep(l,this.SymbolName,' '),'.')),allNestedFields,'UniformOUtput',true);
            fields=allNestedFields(nestedFields);
        end


        function varInfos=getNestedStructVarInfos(this)
            assert(this.isStruct());
            varInfos=coder.internal.VarTypeInfo.empty();
            nestedStructFields=this.getImmediateNestedFields();
            for ii=1:length(nestedStructFields)
                nestedStructName=nestedStructFields{ii};
                varInfos(end+1)=this.getStructPropVarInfo(nestedStructName);
            end
        end








        function varInfos=getAllNestedStructVarInfos(this)
            assert(this.isStruct());
            varInfos=coder.internal.VarTypeInfo.empty();
            nestedStructNames=this.nestedStructuresInferredTypes.keys;
            for ii=1:length(nestedStructNames)
                nestedStructName=nestedStructNames{ii};
                varInfos(end+1)=this.getStructPropVarInfo(nestedStructName);
            end
        end

        function ret=getClonedNonArrayOfStruct(this)
            assert(this.isStruct());
            ret=this.clone();
            if~this.isScalar()
                origDim=ret.inferred_Type.Size;
                ret.inferred_Type.Size=ones(size(origDim));
            end
        end

        function fm=getFimath(this)
            if this.isStruct()
                assert(iscell(this.fimath));
            end
            if isempty(this.fimath)
                fm=this.functionInfo.getFimath();
            else
                fm=this.fimath;
            end
        end

        function setFimath(this,val)
            if this.isStruct()
                assert(iscell(val));
            end
            this.fimath=val;
        end

        function res=isFimathSet(this)
            res=~isempty(this.fimath);
        end

        function res=hasUserSpecifiedAnnotation(this)

            res=~isempty(this.userSpecifiedAnnotation);
        end

        function res=isInstrumentedForLogging(this)
            res=this.instrumentedForLogging;
        end

        function setIsInstrumentedForLogging(this,value)
            this.instrumentedForLogging=value;
        end

        function res=isLoggableType(this)
            res=true;

            isMethodDefinedInClass=this.functionInfo.isDefinedInAClass();
            isUnboundedSize=any(this.inferred_Type.Size(:)==-1);
            isSizeDynamic=any(this.inferred_Type.SizeDynamic);

            if this.isStruct()
                if isUnboundedSize||isSizeDynamic||isMethodDefinedInClass||~this.isScalar()
                    res=false;
                    return;
                end


                nonStructFields=this.getNonNestedLoggedFields();
                for loggedFieldN=nonStructFields

                    fVarInfo=this.getStructPropVarInfo(loggedFieldN{1});
                    if~fVarInfo.isLoggableType()
                        res=false;
                        return;
                    end
                end


                nestedVarInfos=this.getNestedStructVarInfos();
                for svInfo=nestedVarInfos
                    if~svInfo.isLoggableType()
                        res=false;
                        return;
                    end
                end
            else
                numericLoggable=this.isVarInSrcBoolean()||(this.isNumericVar()&&~this.isVarInSrcSlopeBiasScalaed());
                if isUnboundedSize||isSizeDynamic||isMethodDefinedInClass||~numericLoggable
                    res=false;
                    return;
                end
            end
        end
    end

    methods(Access='private')

        function mat=cell2mat(~,cellArr)
            mat=zeros(size(cellArr));
            for ii=1:length(cellArr)
                if~isempty(cellArr{ii})
                    mat(ii)=1;
                end
            end
        end
    end
end
