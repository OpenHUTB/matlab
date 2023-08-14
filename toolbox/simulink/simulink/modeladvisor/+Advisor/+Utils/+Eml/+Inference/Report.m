
classdef Report<handle

    properties
        blockPath=[];
        stateflowObject=[];
        isValid=false;


        irSummary=[];
        irRootFunctionIDs=[];
        irFunctions=[];
        irScripts=[];
        irMxInfos={};
        irMxArrays={};


        dataIsScriptUserVisible;
        dataScriptType;
        dataScriptPath;
        dataScriptCode;



        dataIsFunctionUserVisible;
        dataFunctionScriptID;
        dataFunctionType;
        dataFunctionName;
        dataFunctionCode;
        dataFunctionOffset;
    end

    methods

        function this=Report(blockPath)
            this.blockPath=blockPath;
            this.stateflowObject=this.getSfObject(blockPath);
            ir=Advisor.Utils.Eml.getEmlReport(this.stateflowObject);
            if~isempty(ir)
                this.isValid=true;

                this.irSummary=ir.summary;
                this.irRootFunctionIDs=ir.inference.RootFunctionIDs;
                this.irFunctions=ir.inference.Functions;
                this.irScripts=ir.inference.Scripts;
                this.irMxInfos=ir.inference.MxInfos;
                this.irMxArrays=ir.inference.MxArrays;



                numScripts=this.getNumScripts();
                this.dataIsScriptUserVisible=false(numScripts,1);
                this.dataScriptType=cell(numScripts,1);
                this.dataScriptPath=cell(numScripts,1);
                this.dataScriptCode=cell(numScripts,1);


                numFunctions=this.getNumFunctions();
                this.dataIsFunctionUserVisible=false(numFunctions,1);
                this.dataFunctionScriptID=ones(numFunctions,1)*(-1);
                this.dataFunctionType=cell(numFunctions,1);
                this.dataFunctionName=cell(numFunctions,1);
                this.dataFunctionCode=cell(numFunctions,1);
                this.dataFunctionOffset=zeros(numFunctions,1);

                this.initializeScriptData();
                this.initializeFunctionData();




            end
        end

        function blockPath=getBlockPath(this)
            blockPath=this.blockPath;
        end

        function stateflowObject=getStateflowObject(this)
            stateflowObject=this.stateflowObject;
        end

        function valid=isReportLoaded(this)
            valid=this.isValid;
        end

        function paths=getCallPaths(this,matchID)
            paths={};
            entryFunctionIDs=this.irRootFunctionIDs;
            for i=1:numel(entryFunctionIDs)
                currentID=entryFunctionIDs(i);
                pos=[currentID,-1,-1];
                newPaths=this.analyze(currentID,matchID,pos,{});

                paths=[paths,newPaths];
            end
        end

        function hyperLink=getPathHyperLink(this,functionID,i1,i2)
            scriptID=this.dataFunctionScriptID(functionID);
            functionType=this.dataFunctionType{functionID};
            scriptType=this.dataScriptType{scriptID};
            functionName=this.dataFunctionName{functionID};
            scriptPath=this.dataScriptPath{scriptID};




            switch scriptType
            case 'Stateflow.Transition'
                switch functionType
                case 'Condition'
                    displayText='condition';
                case 'ConditionAction'
                    displayText='condition action';
                case 'TransitionAction'
                    displayText='transition action';
                otherwise
                    displayText='|unknown|';
                end
            case 'Stateflow.State'
                switch functionType
                case 'EntryAction'
                    displayText='entry action';
                case 'DuringAction'
                    displayText='during action';
                otherwise
                    displayText='|unknown|';
                end
            case 'Stateflow.EMFunction'
                displayText=functionName;
            case 'Stateflow.EMChart'
                displayText=functionName;
            case 'Matlab.File'
                displayText=functionName;
            otherwise
                displayText='|unknown|';
            end
            displayText=sprintf('%s(%d-%d)',displayText,i1,i2);











            prefix='<a href="">';
            postfix='</a>';

            hyperLink=[prefix,displayText,postfix];
        end

        function pathsOut=analyze(this,currentID,matchID,pos,pathsIn)
            pathsOut=pathsIn;
            if currentID==matchID
                new=pos(1:end-1,:);
                pathsOut{end+1}=new;
                return;
            end

            thisFunction=this.irFunctions(currentID);
            callSites=thisFunction.CallSites;

            if~isempty(callSites)

                array=[...
                [callSites.CalledFunctionID]',...
                [callSites.TextStart]',...
                [callSites.TextLength]'];
                array=unique(array,'rows');
                array(:,2)=array(:,2)+1;
                array(:,3)=array(:,2)+array(:,3)-1;

                for i=1:size(array,1)
                    calledID=array(i,1);
                    if this.isFunctionUserVisible(calledID)
                        idx1=array(i,2);
                        idx2=array(i,3);
                        pos(end,2)=idx1;
                        pos(end,3)=idx2;
                        pos=[pos;[calledID,-1,-1]];%#ok<AGROW>
                        pathsOut=this.analyze(calledID,matchID,pos,pathsOut);
                        pos=pos(1:end-1,:);
                    end
                end
            end
        end

        function pathsOut=analyzeOld(this,currentID,matchID,pos,pathsIn)
            pathsOut=pathsIn;
            if currentID==matchID
                pathsOut{end+1}=pos;
                for i=1:size(pos,1)
                    fid=pos(i,1);
                    fname=this.irFunctions(fid).FunctionName;
                    if i==1
                        fprintf(1,'%d %s',fid,fname);
                    else
                        fprintf(1,' - %d %s',fid,fname);
                    end
                end
                fprintf(1,'\n');
                return;
            end

            thisFunction=this.irFunctions(currentID);
            callSites=thisFunction.CallSites;

            if~isempty(callSites)

                array=[...
                [callSites.CalledFunctionID]',...
                [callSites.TextStart]',...
                [callSites.TextLength]'];
                array=unique(array,'rows');
                array(:,2)=array(:,2)+1;
                array(:,3)=array(:,2)+array(:,3)-1;

                for i=1:size(array,1)
                    calledID=array(i,1);
                    if this.isFunctionUserVisible(calledID)
                        pos=[pos;array(i,:)];%#ok<AGROW>
                        pathsOut=this.analyze(calledID,matchID,pos,pathsOut);
                        pos=pos(1:end-1,:);
                    end
                end
            end

        end

        function functionIDs=getUserVisibleFunctionIDs(this)
            numFunctions=numel(this.irFunctions);
            functionIDs=1:numFunctions;
            keep=false(numFunctions,1);
            for functionID=1:numFunctions
                keep(functionID)=this.isFunctionUserVisible(functionID);
            end
            functionIDs=functionIDs(keep);
        end

        function info=getFunctionInfo(this,functionID)
            scriptID=this.getFunctionScriptID(functionID);

            if 1
                info.debug.isFunctionUserVisible=this.isFunctionUserVisible(functionID);
                info.debug.functionScriptID=this.getFunctionScriptID(functionID);
                info.debug.functionType=this.getFunctionType(functionID);
                info.debug.functionName=this.getFunctionName(functionID);
                info.debug.functionCode=this.getFunctionCode(functionID);
                info.debug.functionOffset=this.getFunctionOffset(functionID);
                info.debug.isScriptUserVisible=this.isScriptUserVisible(scriptID);
                info.debug.scriptType=this.getScriptType(scriptID);
                info.debug.scriptPath=this.getScriptPath(scriptID);
                info.debug.scriptCode=this.getScriptCode(scriptID);
            end

            info.isUserVisible=this.isFunctionUserVisible(functionID);
            info.functionName=this.getFunctionName(functionID);
            info.baseType=this.getScriptType(scriptID);
            info.subType=this.getFunctionType(functionID);
            info.sourcePath=this.getScriptPath(scriptID);
            info.codeFragment=this.getFunctionCode(functionID);
        end














































































































































































        function numScriptObjects=getNumScripts(this)
            numScriptObjects=numel(this.irScripts);
        end

        function numFunctionObjects=getNumFunctions(this)
            numFunctionObjects=numel(this.irFunctions);
        end

















        function[mxInfoLocation,mxInfo]=getMxInfo(this,functionID,startIdx,endIdx)
            mxInfoLocation=[];
            mxInfo=[];

            offset=this.getFunctionOffset(functionID);
            startIdx=offset+startIdx;
            endIdx=offset+endIdx;

            thisFunction=this.irFunctions(functionID);
            locs=thisFunction.MxInfoLocations;


            start=[locs.TextStart]'+1;
            stop=start+[locs.TextLength]'-1;
            locID=(1:numel(locs))';
            info=[start,stop,locID];


            keep=info(:,1)==startIdx&info(:,2)==endIdx;
            exact=info(keep,:);
            numExact=size(exact,1);
            if numExact==1

                mxInfoLocation=locs(exact(1,3));
            elseif numExact>1

            else

                keep=info(:,1)>=startIdx&info(:,2)<=endIdx;
                info=info(keep,:);
                numInfo=size(info,1);
                if numInfo==1

                    mxInfoLocation=locs(info(1,3));
                elseif numInfo>1


                    info;
                else

                end
            end

            if~isempty(mxInfoLocation)





                infoID=mxInfoLocation.MxInfoID;
                mxInfo=this.irMxInfos{infoID};
            end
        end

    end

    methods(Access=private)

        function sfObject=getSfObject(~,blockPath)
            rt=sfroot;
            chart=sfprivate('block2chart',blockPath);
            sfObject=rt.idToHandle(chart);
        end

        function object=sid2object(~,sid)
            handle=Simulink.ID.getHandle(sid);
            if isa(handle,'double')
                chartID=sfprivate('block2chart',handle);
                object=idToHandle(sfroot,chartID);
            else
                object=handle;
            end
        end















































































































































































































































































































































































        function initializeScriptData(this)
            numScripts=numel(this.irScripts);
            for scriptID=1:numScripts
                thisScript=this.irScripts(scriptID);
                isUserVisible=thisScript.IsUserVisible;
                rawScriptPath=thisScript.ScriptPath;
                if rawScriptPath(1)=='#'
                    scriptPath=rawScriptPath(2:end);
                    sfObject=this.sid2object(scriptPath);
                    scriptType=class(sfObject);
                    switch scriptType
                    case 'Stateflow.EMFunction'
                        scriptCode=sfObject.Script;
                    case 'Stateflow.EMChart'
                        scriptCode=sfObject.Script;
                    case 'Stateflow.State'
                        scriptCode=sfObject.LabelString;
                    case 'Stateflow.Transition'
                        scriptCode=sfObject.LabelString;
                    otherwise
                        scriptCode='';
                    end
                else
                    scriptPath=rawScriptPath;
                    scriptType='Matlab.File';
                    scriptCode=thisScript.ScriptText;
                end
                this.dataIsScriptUserVisible(scriptID)=isUserVisible;
                this.dataScriptPath{scriptID}=scriptPath;
                this.dataScriptType{scriptID}=scriptType;
                this.dataScriptCode{scriptID}=scriptCode;
            end
        end

        function initializeFunctionData(this)
            numFunctions=numel(this.irFunctions);
            for functionID=1:numFunctions
                thisFunction=this.irFunctions(functionID);
                scriptID=thisFunction.ScriptID;
                userVisible=this.isScriptUserVisible(scriptID);
                functionName=thisFunction.FunctionName;
                functionOffset=thisFunction.TextStart;

                i1=thisFunction.TextStart+1;
                i2=i1+thisFunction.TextLength-1;
                scriptCode=this.getScriptCode(scriptID);
                functionCode=scriptCode(i1:i2);

                scriptType=this.getScriptType(scriptID);
                switch scriptType
                case 'Stateflow.State'
                    functionType=...
                    this.getFunctionTypeOfStateflowStateFunction(...
                    functionName);
                case 'Stateflow.Transition'
                    functionType=...
                    this.getFunctionTypeOfStateflowTransitionFunction(...
                    functionName);
                case{'Stateflow.EMFunction','Stateflow.EMChart','Matlab.File'}
                    functionType=this.getFunctionTypeOfMatlabCode(functionID);
                end

                this.dataIsFunctionUserVisible(functionID)=userVisible;
                this.dataFunctionScriptID(functionID)=scriptID;
                this.dataFunctionType{functionID}=functionType;
                this.dataFunctionName{functionID}=functionName;
                this.dataFunctionCode{functionID}=functionCode;
                this.dataFunctionOffset(functionID)=functionOffset;
            end
        end

        function userVisible=isScriptUserVisible(this,scriptID)
            if scriptID==0
                userVisible=false;
            else
                userVisible=this.dataIsScriptUserVisible(scriptID);
            end
        end

        function scriptPath=getScriptPath(this,scriptID)
            if scriptID==0
                scriptPath='<unknown>';
            else
                scriptPath=this.dataScriptPath{scriptID};
            end
        end

        function scriptType=getScriptType(this,scriptID)
            if scriptID==0
                scriptType='<unknown>';
            else
                scriptType=this.dataScriptType{scriptID};
            end
        end

        function scriptCode=getScriptCode(this,scriptID)
            if scriptID==0
                scriptCode='';
            else
                scriptCode=this.dataScriptCode{scriptID};
            end
        end

        function userVisible=isFunctionUserVisible(this,functionID)
            userVisible=this.dataIsFunctionUserVisible(functionID);
        end

        function functionScriptID=getFunctionScriptID(this,functionID)
            functionScriptID=this.dataFunctionScriptID(functionID);
        end

        function functionType=getFunctionType(this,functionID)
            functionType=this.dataFunctionType{functionID};
        end

        function functionName=getFunctionName(this,functionID)
            functionName=this.dataFunctionName{functionID};
        end

        function functionCode=getFunctionCode(this,functionID)
            functionCode=this.dataFunctionCode{functionID};
        end

        function functionOffset=getFunctionOffset(this,functionID)
            functionOffset=this.dataFunctionOffset(functionID);
        end

























        function subType=getFunctionTypeOfStateflowStateFunction(~,name)
            table={...
            'sf_internal_entry_action_','EntryAction';...
            'sf_internal_activity_action_','DuringAction';...
            };
            subType='<unknown>';
            for i=1:size(table,1)
                pattern=table{i,1};
                if strncmp(name,pattern,numel(pattern))
                    subType=table{i,2};
                    break;
                end
            end
        end

        function subType=getFunctionTypeOfStateflowTransitionFunction(~,name)
            table={...
            'sf_internal_transition_action_','TransitionAction';...
            'sf_internal_condition_action_','ConditionAction';...
            'sf_internal_condition_notaction_','Condition';...
            };
            subType='<unknown>';
            for i=1:size(table,1)
                pattern=table{i,1};
                if strncmp(name,pattern,numel(pattern))
                    subType=table{i,2};
                    break;
                end
            end
        end

        function functionType=getFunctionTypeOfMatlabCode(this,functionID)
            if this.isFirstFunctionOfScript(functionID)
                functionType='MainFunction';
            else
                functionType='SubFunction';
            end
        end

        function result=isFirstFunctionOfScript(this,functionID)
            result=false;
            thisFunction=this.irFunctions(functionID);
            thisScriptID=thisFunction.ScriptID;
            thisPosition=thisFunction.TextStart;
            if thisScriptID~=0
                allScriptIDs=[this.irFunctions.ScriptID];
                allPositions=[this.irFunctions.TextStart];
                keep=thisScriptID==allScriptIDs;
                allPositions=allPositions(keep);
                if thisPosition<=min(allPositions)
                    result=true;
                end
            end
        end

    end

end

