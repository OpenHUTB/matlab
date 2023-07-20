classdef MATLABFunctionSymbolData<handle













    properties(Access=private)

        RootFunctionId=[];


        FIdList=[];


        FIdToFcnDet=[];


        FIdToSymbol=[];


        FIdToOperations=[];


        FIdToFcnCallSites=[];
    end

    properties(Constant)

        NodeKindToDispName=...
        slreportgen.utils.MATLABFunctionSymbolData.populateNodeKindToDispName();


        ExcludeNodeList=...
        slreportgen.utils.MATLABFunctionSymbolData.populateExcludeNodeList();
    end

    methods(Static)


        function displayMap=populateNodeKindToDispName()
            displayMap=containers.Map;


            displayMap('TRANS')='''';
            displayMap('DOTTRANS')='.''';
            displayMap('NOT')='~';
            displayMap('UMINUS')='UNARY -';
            displayMap('UPLUS')='UNARY +';
            displayMap('PARENS')='()';


            displayMap('PLUS')='+';
            displayMap('MINUS')='-';
            displayMap('MUL')='*';
            displayMap('DIV')='/';
            displayMap('LDIV')='\';
            displayMap('EXP')='^';
            displayMap('DOTMUL')='.*';
            displayMap('DOTDIV')='./';
            displayMap('DOTLDIV')='.\';
            displayMap('DOTEXP')='.^';


            displayMap('AND')='&';
            displayMap('OR')='|';
            displayMap('ANDAND')='&&';
            displayMap('OROR')='||';


            displayMap('LT')='<';
            displayMap('GT')='>';
            displayMap('LE')='<=';
            displayMap('GE')='>=';
            displayMap('EQ')='==';
            displayMap('NE')='~=';


            displayMap('ANON')='ANON';
            displayMap('ANONID')='ANONID';
            displayMap('AT')='AT';
            displayMap('ATBASE')='@';
            displayMap('ATTR')='ATTR';
            displayMap('ATTRIBUTES')='ATTRIBUTES';
            displayMap('BANG')='!';
            displayMap('BLKCOM')='BLKCOM';
            displayMap('BREAK')='BREAK';
            displayMap('CALL')='CALL';
            displayMap('CASE')='CASE';
            displayMap('CELL')='{}';
            displayMap('CELLMARK')='CELLMARK';
            displayMap('CLASSDEF')='CLASSDEF';
            displayMap('COLON')=':';
            displayMap('COMMENT')='COMMENT';
            displayMap('CONTINUE')='CONTINUE';
            displayMap('DCALL')='DCALL';
            displayMap('DOT')='.';
            displayMap('DOTLP')='.( )';
            displayMap('DOUBLE')='DOUBLE';
            displayMap('ELSE')='ELSE';
            displayMap('ELSEIF')='ELSEIF';
            displayMap('ENUMERATION')='ENUMERATION';
            displayMap('EQUALS')='=';
            displayMap('ERR')='ERR';
            displayMap('ETC')='ETC';
            displayMap('EVENTS')='EVENTS';
            displayMap('EXPR')='EXPR';
            displayMap('FIELD')='FIELD';
            displayMap('FOR')='FOR';
            displayMap('FUNCTION')='FUNCTION';
            displayMap('GLOBAL')='GLOBAL';
            displayMap('ID')='ID';
            displayMap('IF')='IF';
            displayMap('IFHEAD')='IFHEAD';
            displayMap('INT')='INT';
            displayMap('LB')='[ ]';
            displayMap('LC')='{ }';
            displayMap('METHODS')='METHODS';
            displayMap('OTHERWISE')='OTHERWISE';
            displayMap('PARFOR')='PARFOR';
            displayMap('PERSISTENT')='PERSISTENT';
            displayMap('PRINT')='PRINT';
            displayMap('PROPERTIES')='PROPERTIES';
            displayMap('PROTO')='PROTO';
            displayMap('QUEST')='?';
            displayMap('RETURN')='RETURN';
            displayMap('ROW')='ROW';
            displayMap('SPMD')='SPMD';
            displayMap('CHARVECTOR')='CHARVECTOR';
            displayMap('SUBSCR')='()';
            displayMap('SWITCH')='SWITCH';
            displayMap('TRY')='TRY';
            displayMap('WHILE')='WHILE';
        end



        function excludeList=populateExcludeNodeList()
            excludeList=containers.Map;

            excludeList('INT')=1;
            excludeList('DOUBLE')=1;
            excludeList('CHARVECTOR')=1;
            excludeList('AND')=1;
            excludeList('OR')=1;
            excludeList('ANDAND')=1;
            excludeList('OROR')=1;
            excludeList('LT')=1;
            excludeList('GT')=1;
            excludeList('LE')=1;
            excludeList('GE')=1;
            excludeList('EQ')=1;
            excludeList('NE')=1;
        end
    end

    methods


        function obj=MATLABFunctionSymbolData(emUDDObject)

            assert(isa(emUDDObject,'Stateflow.EMChart'),...
            'Invalid Input Argument');


            obj.FIdToFcnDet=containers.Map('KeyType','int32',...
            'ValueType','Any');
            obj.FIdToSymbol=containers.Map('KeyType','int32',...
            'ValueType','Any');
            obj.FIdToOperations=containers.Map('KeyType','int32',...
            'ValueType','Any');
            obj.FIdToFcnCallSites=containers.Map('KeyType','int32',...
            'ValueType','Any');

            [fIdToMtreeInfer,scrInfoObj]=obj.getInferenceData(emUDDObject);
            obj.populateMaps(fIdToMtreeInfer,scrInfoObj,emUDDObject);
        end


        function rootId=getRootFunctionID(aObj)
            rootId=aObj.RootFunctionId;
        end


        function fIds=getFIdList(aObj)
            fIds=aObj.FIdList;
        end


        function flag=hasFcnDetails(aObj,fid)
            flag=isKey(aObj.FIdToFcnDet,fid);
        end


        function functionDetails=getFcnDetails(aObj,fid)
            assert(aObj.hasFcnDetails(fid),...
            ['Invalid Function ID',num2str(fid)]);
            functionDetails=aObj.FIdToFcnDet(fid);
        end


        function flag=hasSymbolTableDetails(aObj,fid)
            flag=isKey(aObj.FIdToSymbol,fid);
        end


        function symbolTableData=getSymbolTableDetails(aObj,fid)
            assert(aObj.hasSymbolTableDetails(fid),...
            ['Invalid Function ID',num2str(fid)]);
            symbolTableData=aObj.FIdToSymbol(fid);
        end


        function flag=hasOperTableDetails(aObj,fid)
            flag=isKey(aObj.FIdToOperations,fid);
        end


        function operationsTableData=getOperTableDetails(aObj,fid)
            assert(aObj.hasOperTableDetails(fid),...
            ['Invalid Function ID',num2str(fid)]);
            operationsTableData=aObj.FIdToOperations(fid);
        end


        function flag=hasFcnCallSiteDetails(aObj,fid)
            flag=isKey(aObj.FIdToFcnCallSites,fid);
        end


        function fcnCallSiteTableData=getFcnCallSiteDetails(aObj,fid)
            assert(aObj.hasFcnCallSiteDetails(fid),...
            ['Invalid Function ID',num2str(fid)]);
            fcnCallSiteTableData=aObj.FIdToFcnCallSites(fid);
        end

    end

    methods(Access=private)


        function[fIdToMtreeInfer,scrInfoObj]=getInferenceData(aObj,emUDDObject)
            mlData=slci.mlutil.MLData(emUDDObject);
            aObj.RootFunctionId=mlData.getRootFunctionID();
            aObj.FIdList=mlData.getFunctions();
            scrInfoObj=mlData.getScripts();

            mlInference=slci.mlutil.MLInference(mlData);
            fIdToMtreeInfer=mlInference.getInference();
        end


        function populateMaps(aObj,fIdToMtreeInfer,scrInfoObj,emUDDObject)
            for i=1:numel(aObj.FIdList)
                fcnId=aObj.FIdList(i);
                functionDetails=...
                aObj.getFunctionDetails(fcnId,scrInfoObj,emUDDObject);
                aObj.FIdToFcnDet(fcnId)=functionDetails;

                aObj.FIdToSymbol(fcnId)=...
                struct('name',{},'dataType',{},'size',{},...
                'position',{});
                aObj.FIdToOperations(fcnId)=...
                struct('name',{},'dataType',{},'size',{},...
                'position',{});
                aObj.FIdToFcnCallSites(fcnId)=...
                struct('name',{},'dataType',{},'size',{},...
                'functionId',{},'position',{});

                assert(fIdToMtreeInfer.isKey(fcnId));
                mtreeInference=fIdToMtreeInfer(fcnId);
                aObj.filterData(fcnId,mtreeInference.fRootNode,mtreeInference);
            end
        end


        function functionDetails=getFunctionDetails(aObj,fcnId,scrInfoObj,emUDDObject)
            functionDetails=...
            struct('fcnName','','scrPath','','isUserVisible','');
            functionDetails.fcnName=scrInfoObj.getFunctionName(fcnId);
            functionDetails.isUserVisible=scrInfoObj.isUserVisible(fcnId);
            if aObj.isMainScript(fcnId,scrInfoObj)
                functionDetails.scrPath=emUDDObject.Path;
            else
                functionDetails.scrPath=scrInfoObj.getScriptPath(fcnId);
            end
        end


        function bool=isMainScript(aObj,fcnId,scrInfoObj)
            bool=(scrInfoObj.getScriptID(fcnId)==...
            scrInfoObj.getScriptID(aObj.RootFunctionId));
        end


        function filterData(aObj,fId,rootNode,mtreeInference)
            [childFound,children]=slci.mlutil.getMtreeChildren(rootNode);
            if~childFound
                warning('child not found as node type is not supported');
            end

            for k=1:numel(children)
                aObj.filterData(fId,children{k},mtreeInference);
            end

            if aObj.isFunctionCall(rootNode,mtreeInference)
                aObj.appendFunctionCallSiteTableData(fId,rootNode,mtreeInference);
            elseif mtreeInference.hasType(rootNode)&&~aObj.isCallNode(rootNode)
                if strcmp(rootNode.kind,'ID')

                    if~(aObj.isFunctionCall(rootNode.Parent,mtreeInference)...
                        &&rootNode.Parent.Left==rootNode)
                        aObj.appendSymbolTableData(fId,rootNode,mtreeInference);
                    end
                elseif aObj.isSizeManipulating(rootNode)
                    aObj.appendOperationsTableData(fId,rootNode,mtreeInference);
                elseif aObj.isHeterogeneous(rootNode,mtreeInference)&&...
                    ~slreportgen.utils.MATLABFunctionSymbolData.ExcludeNodeList.isKey(rootNode.kind)
                    aObj.appendOperationsTableData(fId,rootNode,mtreeInference);
                end
            end
        end


        function bool=isCallNode(~,rootNode)
            bool=strcmp(rootNode.kind,'CALL')||...
            strcmp(rootNode.kind,'DCALL');
        end


        function bool=isFunctionCall(aObj,rootNode,mtreeInference)
            bool=aObj.isCallNode(rootNode)&&...
            mtreeInference.hasCalledFunctionID(rootNode);
        end


        function bool=isSizeManipulating(~,rootNode)
            bool=(strcmp(rootNode.kind,'COLON')||...
            strcmp(rootNode.kind,'ROW')||...
            strcmp(rootNode.kind,'LB')||...
            strcmp(rootNode.kind,'LC')||...
            strcmp(rootNode.kind,'SUBSCR')||...
            strcmp(rootNode.kind,'CELL'));
        end


        function heterogeneous=isHeterogeneous(~,rootNode,mtreeInference)
            heterogeneous=false;
            type={};
            [childFound,child]=slci.mlutil.getMtreeChildren(rootNode);
            if~childFound
                warning('child not found as node type is not supported');
            end

            if numel(child)>1
                for i=1:numel(child)
                    if mtreeInference.hasType(child{i})
                        type=[type,{mtreeInference.getType(child{i})}];%#ok<AGROW>
                    else
                        heterogeneous=true;
                        return
                    end
                end

                if~all(strcmp(type,type{1})==1)
                    heterogeneous=true;
                end
            end

        end


        function appendFunctionCallSiteTableData(obj,fId,rootNode,mtreeInference)
            assert(strcmp(rootNode.Left.kind,'ID'));
            commData=obj.getCommonData(rootNode,mtreeInference);
            s=obj.FIdToFcnCallSites(fId);
            idx=numel(s)+1;
            s(idx).name=rootNode.Left.string;
            s(idx).size=commData.size;
            s(idx).dataType=commData.dataType;
            s(idx).position=commData.position;
            s(idx).functionId=mtreeInference.getCalledFunctionID(rootNode);

            obj.FIdToFcnCallSites(fId)=s;
        end


        function appendSymbolTableData(obj,fId,rootNode,mtreeInference)
            commData=obj.getCommonData(rootNode,mtreeInference);
            s=obj.FIdToSymbol(fId);
            idx=numel(s)+1;
            s(idx).name=rootNode.string;
            s(idx).size=commData.size;
            s(idx).dataType=commData.dataType;
            s(idx).position=commData.position;

            obj.FIdToSymbol(fId)=s;
        end


        function appendOperationsTableData(obj,fId,rootNode,mtreeInference)
            commData=obj.getCommonData(rootNode,mtreeInference);
            s=obj.FIdToOperations(fId);
            idx=numel(s)+1;
            if slreportgen.utils.MATLABFunctionSymbolData.NodeKindToDispName.isKey...
                (rootNode.kind)
                s(idx).name=...
                slreportgen.utils.MATLABFunctionSymbolData.NodeKindToDispName...
                (rootNode.kind);
            else
                s(idx).name=tree2str(rootNode);
            end
            s(idx).size=commData.size;
            s(idx).dataType=commData.dataType;
            s(idx).position=commData.position;

            obj.FIdToOperations(fId)=s;
        end


        function commData=getCommonData(~,rootNode,mtreeInference)
            commData=struct('size','','dataType','','position','');
            if mtreeInference.hasSize(rootNode)
                commData.size=mtreeInference.getSize(rootNode);
            end

            if mtreeInference.hasType(rootNode)
                commData.dataType=mtreeInference.getType(rootNode);
            end

            position=lefttreepos(rootNode);
            [L,C]=pos2lc(rootNode,position);
            commData.position=strcat(num2str(L),':',num2str(C));
        end

    end
end

