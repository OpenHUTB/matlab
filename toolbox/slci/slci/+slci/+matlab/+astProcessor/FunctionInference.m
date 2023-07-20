



classdef FunctionInference<handle

    properties(Access=private)


        fMtreeInference=[];

    end


    methods(Access=public)



        function obj=FunctionInference(mtreeToInference)
            assert(isa(mtreeToInference,'containers.Map'),...
            'Invalid input argument');
            obj.fMtreeInference=mtreeToInference;
        end

        function astTable=apply(obj,astTable)


            fids=keys(astTable);
            for k=1:numel(fids)
                fid=fids{k};
                ast=astTable(fid);
                assert(isa(ast,'slci.ast.SFAstMatlabFunctionDef'));
                ast.setFunctionID(fid);
            end


            astTable=obj.computeCallSite(astTable);

        end


        function astTable=computeCallSite(obj,astTable)

            assert(isa(astTable,'containers.Map'),...
            'Invalid input argument');



            fids=keys(astTable);
            for k=1:numel(fids)
                fid=fids{k};
                ast=astTable(fid);
                chart=ast.getRootAstOwner();
                assert(isa(chart,'slci.matlab.EMChart'));
                if isKey(obj.fMtreeInference,fid)
                    funcInference=obj.fMtreeInference(fid);
                    ast=obj.inferCallSite(ast,funcInference,chart);
                    astTable(fid)=ast;
                end
            end


            fcnNameToDef=containers.Map;
            fids=keys(astTable);
            defs=values(astTable);
            names=cellfun(@getName,defs,'UniformOutput',false);
            unames=unique(names);
            for k=1:numel(unames)
                name=unames{k};
                matches=strcmp(names,name);
                fcnNameToDef(name)=defs(matches);
            end

            for k=1:numel(fids)
                fid=fids{k};
                ast=astTable(fid);
                astTable(fid)=obj.deriveCallSite(ast,fcnNameToDef);
            end

        end

    end

    methods(Access=private)


        function ast=inferCallSite(obj,ast,mtreeInference,chart)

            assert(isa(ast,'slci.ast.SFAst'),...
            'Invalid input argument');

            if isa(ast,'slci.ast.SFAstMatlabFunctionCall')
                [flag,fid]=obj.getFID(ast,mtreeInference);
                if~flag

                    parentNode=ast.getParent();
                    if isa(parentNode,'slci.ast.SFAstEqualAssignment')
                        [flag,fid]=obj.getFID(parentNode,mtreeInference);
                    end
                end

                if flag
                    assert(~isempty(fid));

                    if chart.hasFunction(fid)
                        ast.setFunctionID(fid);
                    end
                end

            end

            children=ast.getChildren();
            for k=1:numel(children)
                child=children{k};
                obj.inferCallSite(child,mtreeInference,chart);
            end
        end


        function[flag,fid]=getFID(~,ast,mtreeInference)

            flag=false;
            fid=[];

            fMtreeNode=ast.getMtree();
            assert(~isempty(fMtreeNode),'Mtree node is unset for Matlab Ast');
            if mtreeInference.hasCalledFunctionID(fMtreeNode)
                fid=mtreeInference.getCalledFunctionID(fMtreeNode);
                assert(~isempty(fid)||fid~=-1);
                flag=true;
            end
        end


        function ast=deriveCallSite(obj,ast,fcnNameToDef)

            assert(isa(ast,'slci.ast.SFAst'),...
            'Invalid input argument');


            if isa(ast,'slci.ast.SFAstMatlabFunctionCall')...
                &&(ast.getFunctionID()==-1)
                [flag,def]=obj.getMatch(ast,fcnNameToDef);
                if flag
                    assert(isa(def,...
                    'slci.ast.SFAstMatlabFunctionDef'));
                    assert(def.getFunctionID()~=-1);
                    ast.setFunctionID(def.getFunctionID());
                end
            end

            children=ast.getChildren();
            for k=1:numel(children)
                child=children{k};
                obj.deriveCallSite(child,fcnNameToDef);
            end
        end


        function[flag,def]=getMatch(~,fcall,fcnNameToDef)
            flag=false;
            def=[];
            assert(isa(fcall,'slci.ast.SFAstMatlabFunctionCall'));
            if isKey(fcnNameToDef,fcall.getName())
                [flag,def]=slci.matlab.astProcessor.FunctionInference.getFunctionMatch(...
                fcall,fcnNameToDef);
            end
        end

    end

    methods(Access=public,Static=true)


        function[flag,def]=getFunctionMatch(fcall,fcnNameToDef)

            flag=false;%#ok
            assert(isa(fcall,'slci.ast.SFAstMatlabFunctionCall'));
            fname=fcall.getName();
            specializations=fcnNameToDef(fname);
            indxs=cellfun(@(x)slci.matlab.astProcessor.FunctionInference.isInScope(fcall,x),...
            specializations);
            specializations=specializations(indxs);

            if numel(specializations)==1
                def=specializations{1};
                flag=true;
            else



                subfcnindxs=cellfun(@(x)IsSubFunction(x),specializations);
                subfcns=specializations(subfcnindxs);
                [flag,def]=slci.matlab.astProcessor.FunctionInference.getSignatureMatch(fcall,...
                subfcns);

                if~flag
                    standalonefcns=specializations(~subfcnindxs);
                    [flag,def]=slci.matlab.astProcessor.FunctionInference.getSignatureMatch(fcall,...
                    standalonefcns);
                end

            end

        end


        function[flag,def]=getSignatureMatch(fcall,specializations)

            flag=false;
            def=[];


            for k=1:numel(specializations)
                defInputs=specializations{k}.getInputs();
                actualInputs=fcall.getInputs();
                if slci.matlab.astProcessor.FunctionInference.isInputMatch(...
                    actualInputs,defInputs)
                    def=specializations{k};
                    flag=true;
                    return;
                end
            end

        end


        function flag=isInputMatch(inputArgs,defInputs)

            flag=true;

            if numel(inputArgs)~=numel(defInputs)

                flag=false;
                return;
            else
                for k=1:numel(inputArgs)
                    arg=inputArgs{k};
                    assert(k<=numel(defInputs));
                    if~isempty(arg.getDataType)&&...
                        strcmp(arg.getDataType(),defInputs{k}.getDataType())&&...
                        ~isequal(arg.getDataDim(),-1)&&...
                        isequal(arg.getDataDim(),defInputs{k}.getDataDim())

                    else

                        flag=false;
                        return;
                    end
                end
            end
        end




        function flag=isInScope(callNode,def)

            caller=callNode.getRootAst();
            assert(isa(caller,'slci.ast.SFAstMatlabFunctionDef'));
            flag=false;
            if~def.IsSubFunction()||...
                slci.matlab.astProcessor.MatlabFunctionUtils.isSameScript(callNode,def)
                flag=true;
            end
        end

    end


end
