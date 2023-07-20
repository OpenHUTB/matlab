


classdef TruthTable<slci.stateflow.StateflowFunction


    properties(Access=private)
        fLanguage='';
        fTruthTableAST=[];
        fNeedConstraints=true;
    end

    methods


        function out=getLanguage(aObj)
            out=aObj.fLanguage;
        end


        function out=findDefaultTransitions(aObj)
            out={};
            truthTableUDDObj=aObj.getUDDObject();
            transitions=truthTableUDDObj.find('-isa','Stateflow.Transition');
            for i=1:numel(transitions)
                if isempty(transitions(i).Source)
                    out{end+1}=transitions(i);%#ok
                end
            end
        end


        function BuildTransitionLists(aObj)
            transitionObjs=aObj.findDefaultTransitions();
            for idx=1:numel(transitionObjs)
                id=transitionObjs{idx}.Id;
                transition=aObj.ParentChart.getTransitionFromId(id);
                assert(~isempty(transition));
                aObj.AddDefaultTransition(transition);
            end
        end


        function out=getTruthTableAST(aObj)
            out=aObj.fTruthTableAST;
        end



        function createAST(aObj)
            if strcmpi(aObj.fLanguage,'MATLAB')
                mtreeNode=aObj.getRootFunctionNode();


                if strcmpi(mtreeNode.kind,'FUNCTION')




                    [isAstNeeded,ast]=slci.matlab.astTranslator.createMatlabAst(...
                    mtreeNode,aObj);
                    assert(isAstNeeded);
                    assert(~isempty(ast));
                    assert(isa(ast,'slci.ast.SFAstMatlabFunctionDef'));
                    aObj.fTruthTableAST=ast;
                end
            end
        end

        function aObj=TruthTable(aTruthTableUDDObj,aParent,addConstraints)
            aObj=aObj@slci.stateflow.StateflowFunction(aTruthTableUDDObj,aParent,addConstraints);
            aObj.fClassName=DAStudio.message('Slci:compatibility:ClassNameTruthTable');
            aObj.fClassNames=DAStudio.message('Slci:compatibility:ClassNameTruthTables');

            aObj.fLanguage=aTruthTableUDDObj.Language;
            assert(~isempty(aObj.fLanguage));

            children=aTruthTableUDDObj.find('-isa','Stateflow.Data');


            aObj.setData(children,'Input');
            aObj.setData(children,'Output');
            aObj.setData(children,'Temporary');
            aObj.setData(children,'Local');
            aObj.setData(children,'Constant');


            aObj.setInplacePairName(children);
        end


        function out=needConstraints(aObj)
            out=aObj.fNeedConstraints;
        end

    end

    methods(Access=private)

        function out=getRootFunctionNode(aObj)
            ttUDDObj=aObj.getUDDObject();

            ttMgr=Stateflow.TruthTable.TruthTableManager(ttUDDObj.Id);

            codeGen=ttMgr.TruthTableContentGenerator;




            strCell=strsplit(codeGen.MATLABCode,newline)';
            strCell=aObj.processMATLABConditionStatements(ttMgr,strCell);
            strCell=aObj.inlineActions(strCell,ttMgr,codeGen);


            script=strjoin(string(strCell),newline);
            section=mtree(script);
            fcns=mtfind(list(section.root),'Kind','FUNCTION');
            assert(~isempty(fcns));
            out=fcns.select(1);
        end

        function str=processCond(aObj,str,cVar)
            if(contains(str,sprintf('%s = ',cVar)))
                str=strrep(str,'logical','');
            end
        end


        function strCell=processMATLABConditionStatements(aObj,ttMgr,strCell)
            numCondVars=size(ttMgr.ConditionTable,1)-1;

            MATLABLocalVariables=aObj.getConditionVariables(ttMgr,numCondVars);

            for i=1:numel(MATLABLocalVariables)
                strCell=cellfun(@(x)(aObj.processCond(x,MATLABLocalVariables{i})),...
                strCell,'UniformOutput',false);
            end
        end


        function out=getDefaultConditionVariables(aObj,count)
            out=cell(1,count);
            for i=1:count
                out{i}=['aVarTruthTableCondition','_',num2str(i)];
            end
        end



        function out=getDefaultActionLabels(aObj,count)
            out=cell(1,count);
            for i=1:count
                out{i}=['aFcnTruthTableAction','_',num2str(i)];
            end
        end




        function defaultCondVars=getConditionVariables(aObj,ttMgr,numCondVars)

            defaultCondVars=aObj.getDefaultConditionVariables(numCondVars);
            condLblMap=ttMgr.ConditionLabelToRowIndexMap;
            customCondLbls=condLblMap.keys;
            customCondRowIdx=condLblMap.values;
            for i=1:numel(customCondRowIdx)
                defaultCondVars{customCondRowIdx{i}}=customCondLbls{i};
            end
        end




        function defaultActionLbls=getUserActionLabels(aObj,ttMgr,defaultActionLbls)
            actionLblMap=ttMgr.ActionLabelToRowIndexMap;
            customActionLbls=actionLblMap.keys;
            customActionRowIdx=actionLblMap.values;
            for i=1:numel(customActionRowIdx)
                defaultActionLbls{customActionRowIdx{i}}=customActionLbls{i};
            end
        end



        function strCell=inlineActions(aObj,strCell,ttMgr,codeGen)

            numActions=size(ttMgr.ActionTable,1);

            dActionLabs=aObj.getDefaultActionLabels(numActions);

            dActionLabs=aObj.getUserActionLabels(ttMgr,dActionLabs);

            for i=1:numel(dActionLabs)
                actCall=dActionLabs{i};
                callLineNum=find(contains(strCell,sprintf('%s();',actCall)));

                [~,actCode]=ttMgr.divideLabelAndCode(codeGen.ActionTable{i,2});

                for j=1:numel(callLineNum)
                    strCell{callLineNum(j)}=actCode;
                end
            end
        end
    end
end
