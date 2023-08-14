classdef FunctionTypeInfo<handle





    properties(Access=public)


        functionName(1,:)char=''


        specializationName(1,:)char=''

        specializationId(1,1)double=...
        internal.mtree.FunctionTypeInfo.DEFAULTSPECIALIZATIONID


        uniqueId(1,:)char=''


        scriptPath(1,:)char=''


        isDesign(1,1)logical=false

        inputVarNames(1,:)cell={}
        outputVarNames(1,:)cell={}
        globalVarNames(1,:)cell={}
        persistentVarNames(1,:)cell={}


        symbolTable containers.Map


        callSites(1,:)cell={}

        isDead(1,1)logical=false
        isConstantFolded(1,1)logical=false
        isPCoded(1,1)logical=false

        tree(1,1)coder.internal.translator.F2FMTree=coder.internal.translator.F2FMTree('')


        treeAttributes(1,1)coder.internal.translator.MTreeAttributes=...
        coder.internal.translator.MTreeAttributes(coder.internal.translator.F2FMTree(''))

        scriptText(1,:)char=''


        unicodeMap(1,:)double=[]


        inferenceId(1,1)double=-1

        className(1,:)char=''






        classdefUID(1,1)double=-1

        isStaticMethod(1,1)logical=false

        classSpecializationName(1,:)char=''

        expressionTypes containers.Map
        typesTableName(1,:)char='T'

        emitted(1,1)logical=false







        convertedFunctionInterface(1,1)struct=...
        struct('convertedName','',...
        'isConverted',false,...
        'inputParams',{{}},...
        'outputParams',{{}},...
        'convertedFilePath','',...
        'convertedSpecializationID',internal.mtree.FunctionTypeInfo.DEFAULTSPECIALIZATIONID);


        chartData(1,1)internal.mtree.mlfb.IOInfo=internal.mtree.mlfb.IOInfo



        treeAttributesMap containers.Map



        treeAttributesAggregate(1,1)coder.internal.translator.MTreeAttributes=...
        coder.internal.translator.MTreeAttributes(coder.internal.translator.F2FMTree(''))
    end

    properties(Access=private)
fimath
fcnRegistry


        Debug=false;
    end

    properties(Constant)
        DEFAULTSPECIALIZATIONID=-1;
    end

    methods
        function this=FunctionTypeInfo(fName,sName,uniqueId,mxLocationInfo,scriptText,scriptPath,unicodeMap,chartData)
            if nargin<8
                chartData=internal.mtree.mlfb.IOInfo;
            end

            this.functionName=fName;
            this.specializationName=sName;
            this.uniqueId=uniqueId;

            this.symbolTable=containers.Map();

            this.tree=this.getMtreeFromFunctionScript(scriptText,mxLocationInfo);
            this.treeAttributes=coder.internal.translator.MTreeAttributes(this.tree);

            if~isempty(this.tree)
                [this.inputVarNames,this.outputVarNames]=coder.internal.MTREEUtils.fcnInputOutputParamNames(this.tree);
                this.globalVarNames=strings(coder.internal.MTREEUtils.getGlobalNodes(this.tree.subtree));
                this.persistentVarNames=strings(coder.internal.MTREEUtils.getPersistentNodes(this.tree.subtree));
            end

            this.scriptText=scriptText;
            this.scriptPath=scriptPath;
            this.unicodeMap=unicodeMap;

            [~,fileName,~]=fileparts(this.scriptPath);
            if exist(fileName,'class')
                this.className=fileName;
            end

            this.expressionTypes=containers.Map;
            this.emitted=false;

            this.setFimath([]);

            this.convertedFunctionInterface.inputParams=cell(1,length(this.inputVarNames));
            this.convertedFunctionInterface.outputParams=cell(1,length(this.outputVarNames));

            this.treeAttributes=internal.mtree.MTreeAttributes(this.tree);
            this.treeAttributesAggregate=copy(this.treeAttributes);

            this.chartData=chartData;


            this.treeAttributesMap=containers.Map('KeyType','char','ValueType','any');
        end

        function set.fcnRegistry(this,val)


            assert(isempty(this.fcnRegistry));
            this.fcnRegistry=val;
        end
    end

    methods(Access=public)

        function setFcnInfoRegistry(this,val)
            this.fcnRegistry=val;
        end

        function fm=getFimath(this)
            if~isempty(this.fimath)
                fm=this.fimath;
            else
                fm=this.fcnRegistry.getFimath();
            end
        end

        function setFimath(this,val)
            this.fimath=val;
        end

        function gVars=getGlobalVars(this)
            gVars=this.globalVarNames;
        end


        function res=hasGlobals(this)
            res=~isempty(this.globalVarNames);
        end


        function res=hasPersistents(this)
            res=~isempty(this.persistentVarNames);
        end

        function b=isDefinedInAClass(this)
            b=~isempty(this.className);
        end

        function c=getDefiningClass(this)
            c=this.className;
        end

        function res=hasPersistentVariables(this)
            res=~isempty(this.persistentVarNames);
        end

        function res=isASpecializedFunction(this)
            res=(this.specializationId~=internal.mtree.FunctionTypeInfo.DEFAULTSPECIALIZATIONID);
        end

        function name=getNameInInferenceReport(this)
            if this.specializationId==internal.mtree.FunctionTypeInfo.DEFAULTSPECIALIZATIONID
                name=this.functionName;
            else
                name=sprintf('%s>%d',this.functionName,this.specializationId);
            end
        end

        function addVarInfo(this,varName,type)
            this.addVarDefn(varName,type);
        end

        function addCallSite(this,callNode,calleeFcnInfo)
            allCalledFcns=this.treeAttributes(callNode).AllCalledFunctions;

            if~isempty(allCalledFcns)
                if~ismember(calleeFcnInfo,allCalledFcns)


                    this.treeAttributes(callNode).AllCalledFunctions=...
                    [allCalledFcns,calleeFcnInfo];

                    if this.Debug


                        disp(message('Coder:FxpConvDisp:FXPCONVDISP:callsiteDuplicate',...
                        callNode.tree2str(0,1,{}),this.specializationName).getString);%#ok<*DSPS>
                    end
                end
            else
                this.callSites{end+1}={callNode,calleeFcnInfo};
                this.treeAttributes(callNode).CalledFunction=calleeFcnInfo;
                this.treeAttributes(callNode).AllCalledFunctions=calleeFcnInfo;
            end
        end

        function cNodes=getCallNodes(this)
            tmp=this.callSites;
            tmp=coder.internal.lib.ListHelper.flatten(tmp);
            cNodes=tmp(1:2:end);
        end

        function val=uniqueFullName(this)
            val=internal.mtree.FunctionTypeInfo.BuildUniqueFullName(this.scriptPath,this.functionName,this.specializationId);
        end

        function setDebug(this,value)
            this.Debug=value;
        end

        function tree=getMTree(this)
            tree=this.tree;
        end

        function varNames=getAllVarNames(this)
            varNames=this.symbolTable.keys;
        end

        function varInfosFlat=getAllVarInfos(this)
            varInfos=this.symbolTable.values;
            varInfosFlat={};
            for ii=1:length(varInfos)
                vi=varInfos{ii};
                for jj=1:length(vi)
                    varInfosFlat{end+1}=vi{jj};%#ok<AGROW>
                end
            end
        end

        function calleeFcnInfo=getCalledFcnInfo(this,callSiteNode)
            calleeFcnInfo=this.treeAttributes(callSiteNode).CalledFunction;
        end


        function setConvertedFilePath(this,fileP)
            this.convertedFunctionInterface.convertedFilePath=fileP;
        end

        function varName=getRootVarName(~,fullVarName)
            [varName,~]=strtok(fullVarName,'.');
        end

        function messages=addClassConstraintFailureMessage(this,messages,node,errorId,varargin)
            errParams=varargin;
            msgType=coder.internal.lib.Message.ERR;
            messages(end+1)=this.getMessage(msgType,errorId,errParams,node);
        end

    end

    methods(Access=private)
        addVarDefn(this,varName,type)
        fcnTree=getMtreeFromFunctionScript(this,scriptText,fcnMxLocations)
    end

    methods(Static)

        function[scriptPath,fcnName,specializationNumber]=SplitFullUniqueName(name)
            scriptPath='';fcnName='';specializationNumber=[];


            [t,~]=regexp(name,'^(.*):(.+):(-?\d+)','tokens','match');
            if~isempty(t)&&length(t{1})>=3
                scriptPath=t{1}{1};
                fcnName=t{1}{2};
                specializationNumber=str2double(t{1}{3});
            end
        end

        function id=BuildUniqueFullName(scriptPath,fcnName,specializationNumber)
            id=[scriptPath,':',fcnName,':',num2str(specializationNumber)];
        end
    end

end


