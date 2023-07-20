




classdef Float2FixedConstrainerDriver<handle
    properties(Access=private)
        fcnInfoRegisty;
designName





        fillCompiledMxInfo;
compiledExprInfoMap



scriptPathsParsed
    end
    methods
        function this=Float2FixedConstrainerDriver(fcnInfoRegisty,designName)
            this.fcnInfoRegisty=fcnInfoRegisty;
            this.designName=designName;

            this.fillCompiledMxInfo=false;
            this.compiledExprInfoMap=coder.internal.lib.Map();
            this.scriptPathsParsed=coder.internal.lib.Map();
        end









        function[messages,unsupportedFcnInfo]=constrain(this,supportGlobals,doubleToSingle,checkOtherUnSupportFcns,mlfbSID)
            if nargin<3
                doubleToSingle=false;
            end
            if nargin<4
                checkOtherUnSupportFcns=false;
            end
            if nargin<5
                mlfbSID=[];
            end
            messages=coder.internal.lib.Message.empty();
            functionIds=this.fcnInfoRegisty.registry.keys();

            functionIds=this.reorderFcnIds(functionIds);

            unsupportedFcnInfo=[];
            for i=1:length(functionIds)
                functionId=functionIds{i};

                fcnTypeInfo=this.fcnInfoRegisty.getFunctionTypeInfo(functionId);

                fcnMTree=fcnTypeInfo.tree;
                scriptPath=fcnTypeInfo.scriptPath;
                constrainer=coder.internal.Float2FixedConstrainer(fcnMTree,fcnTypeInfo,scriptPath,doubleToSingle,checkOtherUnSupportFcns,mlfbSID);
                constrainer.setGlobalsSupported(supportGlobals);
                if~isempty(this.compiledExprInfoMap)
                    constrainer.setCompiledExprInfo(this.getCompiledFcnExprInfo(fcnTypeInfo.uniqueId));
                end





                if~fcnTypeInfo.isDefinedInAClass()
                    fcnNode=fcnMTree;
                    assert(strcmp(fcnNode.kind,'FUNCTION'));
                    nameMismatchMsg=this.checkFileNameMismatch(fcnTypeInfo.functionName,fcnTypeInfo.specializationName,scriptPath,fcnNode);
                    messages=[messages,nameMismatchMsg];%#ok<AGROW>
                end

                [tmpMsgs,unSupportedFcns]=constrainer.constrain();
                messages=[messages,tmpMsgs];%#ok<AGROW>

                if~isempty(unSupportedFcns)
                    unsupportedFcnInfo=[unsupportedFcnInfo,struct(...
                    'functionName',fcnTypeInfo.functionName,...
                    'file',scriptPath,...
                    'list',{unSupportedFcns})];%#ok<AGROW>
                end
            end
        end




        function msg=checkFileNameMismatch(this,fcnName,fcnSplName,scriptPath,typeInfoFcNnode)
            msg=coder.internal.lib.Message.empty();
            if~this.scriptPathsParsed.isKey(scriptPath)
                this.scriptPathsParsed(scriptPath)=true;


                fcnNodes=this.getSafeMtree(scriptPath);
                if~isempty(fcnNodes)
                    fcnIndices=fcnNodes.indices;
                    fcnNode=fcnNodes.select(fcnIndices(1));
                    fcnNameInFile=string(fcnNode.Fname);



                    [~,functionNameOnPath,~]=fileparts(scriptPath);


                    inferredFcnNameNode=typeInfoFcNnode.Fname;
                    leftPos=inferredFcnNameNode.leftposition;
                    len=length(string(inferredFcnNameNode));


                    if~strcmp(fcnNameInFile,functionNameOnPath)

                        msgId='Coder:FXPCONV:topFcnNameMismatch';
                        msgType=coder.internal.lib.Message.ERR;


                        msgObj=message(msgId,fcnNameInFile,functionNameOnPath);



                        msg=coder.internal.Float2FixedConstrainer...
                        .BuildMessage(fcnName...
                        ,fcnSplName...
                        ,scriptPath...
                        ,msgObj,leftPos,len,msgType);
                    end
                end
            end
        end

        function functionIds=reorderFcnIds(this,functionIds)

            for i=1:length(functionIds)
                functionId=functionIds{i};

                fcnTypeInfo=this.fcnInfoRegisty.getFunctionTypeInfo(functionId);
                functionName=fcnTypeInfo.functionName;
                if strcmp(functionName,this.designName)
                    functionIds(i)=[];
                    designFunctionId=functionId;
                    functionIds={designFunctionId,functionIds{:}};
                    break;
                end
            end
        end

        function setCompiledExprInfoMap(this,val)
            this.compiledExprInfoMap=val;
        end

        function setFillCompiledMxInfo(this,val)
            this.fillCompiledMxInfo=val;
        end
    end

    methods(Access=private)
        function[compiledExprInfo]=getCompiledFcnExprInfo(this,functionId)
            compiledExprInfo=coder.internal.lib.Map.empty();
            if~isempty(this.compiledExprInfoMap)&&isKey(this.compiledExprInfoMap,functionId)
                compiledExprInfo=this.compiledExprInfoMap(functionId);
            end
        end



        function t=getSafeMtree(~,scriptPath)
            t=[];
            try
                t=mtfind(mtree(fileread(scriptPath)),'Kind','FUNCTION');
            catch

            end
        end
    end
end