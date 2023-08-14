




classdef EmitterDb<handle

    properties(SetAccess=protected,GetAccess=public)

CodeDb



CoverageInfos



        OriginalModel=''
AnalysisMode


        SimulationMode SlCov.CovMode=SlCov.CovMode.Normal
    end

    methods




        function this=EmitterDb()

        end




        function[cppData,irInfo,translationLog,analysisInfo]=getCppDataFromHandle(this,slHandle)
            try
                [analysisInfo,instanceInfo]=getEntryInfoFromHandle(this,slHandle);
                if~isempty(instanceInfo)&&~isempty(analysisInfo)
                    cppData=instanceInfo.IRMapping;
                    irInfo=analysisInfo.FullIR;
                    translationLog=analysisInfo.FullLog;
                    if isempty(irInfo)
                        irInfo=analysisInfo.SummaryIR;
                        translationLog=analysisInfo.SummaryLog;
                    end
                else
                    analysisInfo=[];
                    cppData=[];
                    irInfo=[];
                    translationLog=[];
                end
            catch Mex
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(Mex);
                end
                analysisInfo=[];
                cppData=[];
                irInfo=[];
                translationLog=[];
            end
        end




        function label=getDecisionLabel(this,covStruct,covId,isTrue)
            try
                codeTr=covStruct.codeTr;

                instrPt=codeTr.getInstrumentationPoint(covId);
                if instrPt.node.kind~=internal.cxxfe.instrum.ProgramNodeKind.DECISION
                    label=this.getDecisionOutcomeLabel(covStruct,covId);
                else
                    decCovPt=instrPt.Container;
                    decisionSource=decCovPt.getSourceCode();
                    firstLine=decCovPt.node.startLocation.lineNum;

                    [functionName,functionFile,fileId]=sldv.code.internal.EmitterDb.getFunctionInfo(...
                    decCovPt.node.function);

                    if isTrue
                        msgId='sldv_sfcn:sldv_sfcn:decisionLabelTrue';
                    else
                        msgId='sldv_sfcn:sldv_sfcn:decisionLabelFalse';
                    end
                    codeLnk=this.makeCodeLink(covStruct,fileId,firstLine);

                    locDecIdx=find(codeTr.getDecisionPoints(decCovPt.node.function)==decCovPt,1);
                    outcomeIdx=1+isTrue;
                    codeFilt=this.makeCodeFilterInfo(functionFile,functionName,...
                    decisionSource,[locDecIdx,outcomeIdx],1);

                    msg=message(msgId,functionName,decisionSource,functionFile,firstLine);
                    label=[msg.getString(),this.makeCodeInfo(codeLnk,codeFilt)];
                end
            catch ME
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(ME);
                end
                msg=message('sldv_sfcn:sldv_sfcn:unknownDecisionLabel',covId);
                label=msg.getString();
            end
        end




        function hasInfo=hasConditionInfo(~,covStruct,covId)
            codeTr=covStruct.codeTr;
            instrPt=codeTr.getInstrumentationPoint(covId);
            hasInfo=(~isempty(instrPt)&&isa(instrPt.Container,'internal.cxxfe.instrum.ConditionPoint'));
        end




        function label=getConditionLabel(this,covStruct,covId,isTrue)
            try
                codeTr=covStruct.codeTr;

                instrPt=codeTr.getInstrumentationPoint(covId);
                condCovPt=instrPt.Container;
                conditionSource=condCovPt.getSourceCode();
                firstLine=condCovPt.node.startLocation.lineNum;

                [functionName,functionFile,fileId]=sldv.code.internal.EmitterDb.getFunctionInfo(...
                condCovPt.node.function);
                if isTrue
                    msgId='sldv_sfcn:sldv_sfcn:conditionLabelTrue';
                else
                    msgId='sldv_sfcn:sldv_sfcn:conditionLabelFalse';
                end
                codeLnk=this.makeCodeLink(covStruct,fileId,firstLine);

                locDecIdx=[];
                exprSource=conditionSource;
                if isempty(condCovPt.parentDecision)

                    locCondIdx=find(codeTr.getStandaloneConditionPoints(condCovPt.node.function)==condCovPt,1);
                else

                    locDecIdx=find(codeTr.getDecisionPoints(condCovPt.node.function)==condCovPt.parentDecision,1);
                    locCondIdx=find(condCovPt.parentDecision.subConditions.toArray()==condCovPt,1);
                    exprSource=condCovPt.parentDecision.getSourceCode();
                end
                outcomeIdx=1+isTrue;
                codeFilt=this.makeCodeFilterInfo(functionFile,functionName,...
                exprSource,[locCondIdx,outcomeIdx,locDecIdx],0);

                msg=message(msgId,functionName,conditionSource,functionFile,firstLine);
                label=[msg.getString(),this.makeCodeInfo(codeLnk,codeFilt)];
            catch ME
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(ME);
                end
                msg=message('sldv_sfcn:sldv_sfcn:unknownConditionLabel',covId);
                label=msg.getString();
            end
        end




        function label=getFunctionEnterLabel(this,covStruct,covId)
            try
                codeTr=covStruct.codeTr;

                instrPt=codeTr.getInstrumentationPoint(covId);
                [functionName,functionFile,fileId,startLine]=sldv.code.internal.EmitterDb.getFunctionInfo(...
                instrPt.node.function);
                codeLnk=this.makeCodeLink(covStruct,fileId,startLine);
                msg=message('sldv_sfcn:sldv_sfcn:entryPointLabel',functionName,functionFile,startLine);
                label=[msg.getString(),this.makeCodeInfo(codeLnk,[])];
            catch ME
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(ME);
                end
                msg=message('sldv_sfcn:sldv_sfcn:unknownEntryPointLabel',covId);
                label=msg.getString();
            end
        end




        function label=getFunctionExitLabel(this,covStruct,covId)
            try
                codeTr=covStruct.codeTr;

                instrPt=codeTr.getInstrumentationPoint(covId);
                exitPos=[instrPt.node.startLocation.lineNum,instrPt.node.startLocation.colNum...
                ,instrPt.node.endLocation.lineNum,instrPt.node.endLocation.colNum];
                [functionName,functionFile,fileId]=sldv.code.internal.EmitterDb.getFunctionInfo(...
                instrPt.node.function);

                codeLnk=this.makeCodeLink(covStruct,fileId,exitPos(1));
                msg=message('sldv_sfcn:sldv_sfcn:exitPointLabel',functionName,functionFile,exitPos);
                label=[msg.getString(),this.makeCodeInfo(codeLnk,[])];
            catch ME
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(ME);
                end
                msg=message('sldv_sfcn:sldv_sfcn:unknownExitPointLabel',covId);
                label=msg.getString();
            end
        end




        function label=getRelationalBoundaryLabel(this,covStruct,covId,~,baseCovId)
            try
                codeTr=covStruct.codeTr;

                instrPt=codeTr.getInstrumentationPoint(covId);
                relOpPt=instrPt.Container;

                lhsSource=relOpPt.getLhsSourceCode();
                rhsSource=relOpPt.getRhsSourceCode();
                firstLine=relOpPt.node.startLocation.lineNum;

                [functionName,functionFile,fileId]=sldv.code.internal.EmitterDb.getFunctionInfo(...
                instrPt.node.function);

                if relOpPt.outcomes.Size()==3
                    expectedValue=covId-baseCovId-1;

                    codeLnk=this.makeCodeLink(covStruct,fileId,firstLine);
                    msg=message('sldv_sfcn:sldv_sfcn:relationalBoundaryInt',functionName,...
                    lhsSource,rhsSource,expectedValue,functionFile,firstLine);
                    label=msg.getString();


                    if expectedValue<0
                        outcomeIdx=1;
                    elseif expectedValue>0
                        outcomeIdx=2;
                    else
                        outcomeIdx=3;
                    end
                else



                    zeroIncluded=false(1,2);

                    switch relOpPt.node.kind
                    case{internal.cxxfe.instrum.ProgramNodeKind.FLOAT_NE,...
                        internal.cxxfe.instrum.ProgramNodeKind.FLOAT_EQ}
                        zeroIncluded(1)=false;
                        zeroIncluded(2)=false;
                    case{internal.cxxfe.instrum.ProgramNodeKind.FLOAT_GT,...
                        internal.cxxfe.instrum.ProgramNodeKind.FLOAT_LE}
                        zeroIncluded(1)=true;
                        zeroIncluded(2)=false;
                    case{internal.cxxfe.instrum.ProgramNodeKind.FLOAT_LT,...
                        internal.cxxfe.instrum.ProgramNodeKind.FLOAT_GE}
                        zeroIncluded(1)=false;
                        zeroIncluded(2)=true;
                    end

                    if covId==baseCovId

                        if zeroIncluded(1)
                            msgId='sldv_sfcn:sldv_sfcn:relationalBoundaryFloatLessZeroIncluded';
                        else
                            msgId='sldv_sfcn:sldv_sfcn:relationalBoundaryFloatLessZeroExcluded';
                        end
                        outcomeIdx=1;
                    else

                        if zeroIncluded(2)
                            msgId='sldv_sfcn:sldv_sfcn:relationalBoundaryFloatGreaterZeroIncluded';
                        else
                            msgId='sldv_sfcn:sldv_sfcn:relationalBoundaryFloatGreaterZeroExcluded';
                        end
                        outcomeIdx=2;
                    end
                    codeLnk=this.makeCodeLink(covStruct,fileId,firstLine);
                    msg=message(msgId,functionName,lhsSource,rhsSource,functionFile,firstLine);
                    label=msg.getString();
                end


                if isa(relOpPt.parentDecisionOrCondition,'internal.cxxfe.instrum.ConditionPoint')

                    condCovPt=relOpPt.parentDecisionOrCondition;
                    if isempty(condCovPt.parentDecision)

                        locCondIdx=find(codeTr.getStandaloneConditionPoints(condCovPt.node.function)==condCovPt,1);
                        exprSource=condCovPt.node.getSourceCode();
                        exprIdx=[locCondIdx,outcomeIdx];
                    else

                        decCovPt=condCovPt.parentDecision;
                        locDecIdx=find(codeTr.getDecisionPoints(decCovPt.node.function)==decCovPt,1);
                        locCondIdx=find(decCovPt.subConditions.toArray()==condCovPt,1);
                        exprSource=decCovPt.node.getSourceCode();
                        exprIdx=[locDecIdx,outcomeIdx,locCondIdx];
                    end
                else

                    decCovPt=relOpPt.parentDecisionOrCondition;
                    locDecIdx=find(codeTr.getDecisionPoints(decCovPt.node.function)==decCovPt,1);
                    exprSource=decCovPt.node.getSourceCode();
                    exprIdx=[locDecIdx,outcomeIdx];
                end


                codeFilt=this.makeCodeFilterInfo(functionFile,functionName,...
                exprSource,exprIdx,3);
                label=[label,this.makeCodeInfo(codeLnk,codeFilt)];

            catch ME
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(ME);
                end
                msg=message('sldv_sfcn:sldv_sfcn:unknownRelationalBoundaryLabel',covId);
                label=msg.getString();
            end
        end




        function label=getMCDCLabel(this,covStruct,decId,isTrue,condId)
            try
                codeTr=covStruct.codeTr;

                instrPt=codeTr.getInstrumentationPoint(condId);
                condCovPt=instrPt.Container;
                decCovPt=condCovPt.parentDecision;
                decisionSource=decCovPt.getSourceCode();
                firstLine=decCovPt.node.startLocation.lineNum;

                conditionSource=instrPt.getSourceCode();

                [functionName,functionFile,fileId]=sldv.code.internal.EmitterDb.getFunctionInfo(...
                instrPt.node.function);

                if isTrue
                    msgId='sldv_sfcn:sldv_sfcn:mcdcLabelWithT';
                else
                    msgId='sldv_sfcn:sldv_sfcn:mcdcLabelWithF';
                end

                codeLnk=this.makeCodeLink(covStruct,fileId,firstLine);

                locDecIdx=find(codeTr.getDecisionPoints(decCovPt.node.function)==decCovPt,1);
                locCondIdx=find(decCovPt.subConditions.toArray()==condCovPt,1);
                codeFilt=this.makeCodeFilterInfo(functionFile,functionName,...
                decisionSource,[locDecIdx,locCondIdx],2);

                msg=message(msgId,functionName,decisionSource,...
                conditionSource,functionFile,firstLine);
                label=[msg.getString(),this.makeCodeInfo(codeLnk,codeFilt)];
            catch ME
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(ME);
                end
                msg=message('sldv_sfcn:sldv_sfcn:unknownMCDCLabel',decId);
                label=msg.getString();
            end
        end




        function sharedInfo=getSharedCodeCoverageInfo(this)%#ok<MANU>
            sharedInfo=[];
        end
    end

    methods(Access=protected)




        function label=getDecisionOutcomeLabel(this,covStruct,covId)

            codeTr=covStruct.codeTr;

            instrPt=codeTr.getInstrumentationPoint(covId);
            decCovPt=instrPt.Container;
            caseDesc=instrPt.getSourceCode();
            line=instrPt.node.startLocation.lineNum;

            decisionExpr=decCovPt.getSourceCode();
            [functionName,functionFile,fileId]=sldv.code.internal.EmitterDb.getFunctionInfo(...
            instrPt.node.function);

            codeLnk=this.makeCodeLink(covStruct,fileId,line);

            locDecIdx=find(codeTr.getDecisionPoints(decCovPt.node.function)==decCovPt,1);
            locOutcomeIdx=find(decCovPt.outcomes.toArray()==instrPt,1);
            codeFilt=this.makeCodeFilterInfo(functionFile,functionName,...
            decisionExpr,[locDecIdx,locOutcomeIdx],1);

            msg=message('sldv_sfcn:sldv_sfcn:outcomeDecisionLabel',functionName,decisionExpr,...
            caseDesc,functionFile,line);
            label=[msg.getString(),this.makeCodeInfo(codeLnk,codeFilt)];
        end




        function codeLnk=makeCodeLink(this,covStruct,fileId,firstLine)%#ok<INUSD>
            codeLnk=[];
        end




        function codeFilt=makeCodeFilterInfo(this,fileName,funName,expr,exprIdx,kind)
            codeFilt=struct(...
            'fileName',fileName,...
            'funName',funName,...
            'expr',expr,...
            'exprIdx',exprIdx,...
            'kind',kind,...
            'codeKind',this.getCodeKind());
        end




        function codeInfoStr=makeCodeInfo(~,codeLnkInfo,codeFiltInfo)
            codeInfoStr=sldv.code.internal.CodeInfoUtils.encodeCodeInfo(codeLnkInfo,codeFiltInfo);
        end
    end

    methods(Abstract)





        covStruct=getCodeCoverageInfo(this,slHandle,moduleName)





        moduleH=getModuleHandle(this,slHandle,moduleName)

        codeKind=getCodeKind(this)
    end

    methods(Abstract,Access=protected)




        extractAnalysisInfo(this,varargin)
























        [analysis,info]=getEntryInfoFromHandle(this,slHandle)

    end

    methods(Access=protected,Static=true)



        function[funName,funFile,fileId,startLine]=getFunctionInfo(fcn)
            funName=fcn.name;
            funFile=fcn.location.file.shortPath;
            fileId=sldv.code.internal.computeFileKey(fcn.location.file);
            startLine=fcn.location.lineNum;
        end
    end

end


