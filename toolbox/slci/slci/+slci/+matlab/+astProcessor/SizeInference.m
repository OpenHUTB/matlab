



classdef SizeInference<handle

    properties(Access=private)


        fMtreeInference=[];

    end


    methods(Access=public)



        function obj=SizeInference(mtreeToInference)
            assert(isa(mtreeToInference,'containers.Map'),...
            'Invalid input argument');
            obj.fMtreeInference=mtreeToInference;
        end


        function astTable=apply(obj,astTable)

            assert(isa(astTable,'containers.Map'),...
            'Invalid input argument');


            fids=keys(astTable);
            for k=1:numel(fids)
                fid=fids{k};
                ast=astTable(fid);
                if isKey(obj.fMtreeInference,fid)
                    funcInference=obj.fMtreeInference(fid);
                    ast=obj.inferSize(ast,funcInference);
                    astTable(fid)=ast;
                end
            end





        end


        function ast=inferSize(obj,ast,mtreeInference)

            assert(isa(ast,'slci.ast.SFAst'),...
            'Invalid input argument');

            fMtreeNode=ast.getMtree();
            assert(~isempty(fMtreeNode),...
            'Mtree node is unset for Matlab Ast');
            if mtreeInference.hasSize(fMtreeNode)
                size=mtreeInference.getSize(fMtreeNode);


                if~isempty(size)
                    ast.setDataDim(double(size));
                end
            end

            children=ast.getChildren();
            for k=1:numel(children)
                child=children{k};
                obj.inferSize(child,mtreeInference);
            end
        end

    end

end
