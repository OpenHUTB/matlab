



classdef MLMtree<handle

    properties(Access=private)

        fFuncIDToMtree=[];
    end


    methods(Access=public)




        function obj=MLMtree(aScriptInfo,fids)

            assert(isa(aScriptInfo,'slci.mlutil.ScriptInfo'),...
            'Invalid Input Argument');


            obj.fFuncIDToMtree=containers.Map('KeyType','int32',...
            'ValueType','Any');


            assert((nargin==1)||(nargin==2));
            if nargin==1
                fids=aScriptInfo.getFunctions();
            end
            obj.populate(aScriptInfo,fids);
        end


        function mtreeNodes=getMtree(aObj)
            mtreeNodes=aObj.fFuncIDToMtree;
        end

    end

    methods(Access=private)


        function populate(aObj,aScriptInfo,fids)


            scriptIDToFuncNodes=containers.Map('KeyType','int32',...
            'ValueType','Any');


            for k=1:numel(fids)

                fid=fids(k);


                scriptID=aScriptInfo.getScriptID(fid);
                scriptText=aScriptInfo.getScriptText(fid);
                if isKey(scriptIDToFuncNodes,scriptID)
                    funcNodes=scriptIDToFuncNodes(scriptID);
                else
                    funcNodes=aObj.readFuncNodesForScript(scriptText);
                    scriptIDToFuncNodes(scriptID)=funcNodes;
                end


                if~isempty(funcNodes)
                    assert(aScriptInfo.hasFunctionName(fid));
                    desiredFuncName=aScriptInfo.getFunctionName(fid);
                    if isempty(desiredFuncName)

                        mtreeNode=funcNodes{1};
                        aObj.fFuncIDToMtree(fid)=mtreeNode;
                    else
                        matches=cellfun(...
                        @(x)strcmpi(string(Fname(x)),desiredFuncName),funcNodes);
                        matchedIdx=find(matches==1);
                        if numel(matchedIdx)>0


                            assert(numel(matchedIdx)==1);
                            mtreeNode=funcNodes{matchedIdx};
                            aObj.fFuncIDToMtree(fid)=mtreeNode;
                        end
                    end
                end
            end
        end


        function funcNodes=readFuncNodesForScript(~,scriptText)

            funcNodes={};

            if~isempty(scriptText)
                mt=mtree(scriptText,'-comments');
                if strcmp(mt.root.kind,'ERR')
                    DAStudio.error('Slci:slci:mtreeParseError',scriptText);
                end
                fcns=mtfind(list(mt.root),'Kind','FUNCTION');
                if~isempty(fcns)
                    indices=fcns.indices;
                    numFcns=numel(indices);
                    funcNodes=cell(1,numFcns);
                    for i=1:numFcns
                        index=indices(i);
                        fNode=fcns.select(index);
                        assert(strcmpi(fNode.kind,'FUNCTION'));
                        funcNodes{i}=fNode;
                    end
                end
            end

        end

    end


end
