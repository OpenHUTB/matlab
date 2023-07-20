




classdef MLInference<handle

    properties(Access=private)

        fMtreeInference=[];
    end

    methods




        function obj=MLInference(mlData,fids)

            assert(isa(mlData,'slci.mlutil.MLData'),...
            'Invalid Input Argument');
            obj.fMtreeInference=containers.Map('KeyType','int32',...
            'ValueType','Any');
            assert((nargin==1)||(nargin==2));
            if~mlData.isEmpty()
                if nargin==1
                    fids=mlData.getFunctions();
                end
                obj.build(mlData,fids);
            end

        end


        function mtreeInference=getInference(obj)
            mtreeInference=obj.fMtreeInference;
        end

    end

    methods(Access=private)

        function build(obj,mlData,fids)


            posToInference=mlData.getInference();


            scripts=mlData.getScripts();


            mlMtree=slci.mlutil.MLMtree(scripts,fids);
            mtreeNodes=mlMtree.getMtree();


            for k=1:numel(fids)
                fid=fids(k);


                assert(isKey(posToInference,fid));
                funcInference=posToInference(fid);

                if isKey(mtreeNodes,fid)
                    funcMtree=mtreeNodes(fid);

                    funcMtreeInference=slci.mlutil.MtreeInference(...
                    funcMtree,...
                    funcInference);
                    obj.fMtreeInference(fid)=funcMtreeInference;
                else





                end
            end

        end

    end




end
