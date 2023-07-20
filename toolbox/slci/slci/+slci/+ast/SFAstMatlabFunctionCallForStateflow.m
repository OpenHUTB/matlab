



classdef SFAstMatlabFunctionCallForStateflow<slci.ast.SFAstUserFunction

    methods


        function aObj=SFAstMatlabFunctionCallForStateflow(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAstUserFunction(aAstObj,aParent);
        end

        function setName(aObj,aAstObj)
            assert(isa(aAstObj,'mtree'));
            if strcmpi(aAstObj.kind,'ID')
                aObj.fName=aAstObj.string;
            else
                assert(any(strcmpi(aAstObj.kind,{'CALL','LP','SUBSCR'})));
                assert(strcmpi(aAstObj.Left.kind,'ID'),...
                'Invalid function node');
                aObj.fName=aAstObj.Left.string;
            end
        end

        function setSfId(aObj,aAstObj,aParent)
            assert(isa(aAstObj,'mtree'));
            chart=aParent.ParentChart;
            if isKey(chart.getSFFuncNamesMap,aObj.fName)
                funcNamesMap=chart.getSFFuncNamesMap;
                sid=funcNamesMap(aObj.fName);
                if isKey(chart.getGraphicalFunctionsMap,sid)
                    functionsMap=chart.getGraphicalFunctionsMap;
                    aObj.fSfId=functionsMap(sid).getSfId;
                elseif isKey(chart.getSLFuncSfIdMap,sid)
                    funcSfIdMap=chart.getSLFuncSfIdMap;
                    aObj.fSfId=funcSfIdMap(sid);
                elseif isKey(chart.getTruthTablesMap,sid)
                    truthTablesMap=chart.getTruthTablesMap;
                    aObj.fSfId=truthTablesMap(sid).getSfId;
                else
                    assert(false,'This line should never be reached.');
                end
            end
        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(aObj,inputObj)

            assert(isa(inputObj,'mtree'));


            if strcmpi(inputObj.kind,'ID')

            else
                assert(any(strcmpi(inputObj.kind,{'CALL','LP','SUBSCR'})));
                if~isempty(inputObj.Right)
                    mtreeNodes=slci.mlutil.getListNodes(inputObj.Right);
                    aObj.fChildren=cell(1,numel(mtreeNodes));
                    for k=1:numel(mtreeNodes)
                        [isAstNeeded,astObj]=slci.matlab.astTranslator.createAst(...
                        mtreeNodes{k},aObj);
                        assert(isAstNeeded&&~isempty(astObj));
                        aObj.fChildren{1,k}=astObj;
                    end
                end
            end
        end


        function addMatlabFunctionConstraints(aObj)%#ok<MANU>


        end
    end

end