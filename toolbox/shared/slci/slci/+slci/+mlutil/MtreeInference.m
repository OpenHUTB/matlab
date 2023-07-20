



classdef MtreeInference<handle

    properties
        fRootNode=[];
        fMtreeAttributes=[];
    end

    methods


        function obj=MtreeInference(mt,inferenceData)
            obj.fMtreeAttributes=slci.mlutil.MtreeAttributes(mt);
            obj.fRootNode=mt;
            obj.appendInference(obj.fRootNode,inferenceData);
        end


        function hasType=hasType(obj,node)
            hasType=~isempty(obj.fMtreeAttributes(node).Type);
        end


        function type=getType(obj,node)
            assert(obj.hasType(node));
            type=obj.fMtreeAttributes(node).Type;
        end


        function hasSize=hasSize(obj,node)
            hasSize=~isempty(obj.fMtreeAttributes(node).Size);
        end


        function size=getSize(obj,node)
            assert(obj.hasSize(node));
            size=obj.fMtreeAttributes(node).Size;
        end


        function isComplex=isComplex(obj,node)
            isComplex=obj.fMtreeAttributes(node).Complex;
        end


        function calledFunctionId=getCalledFunctionID(obj,node)
            assert(obj.hasCalledFunctionID(node));
            calledFunctionId=obj.fMtreeAttributes(node).CalledFunctionID;
        end


        function hasCalledFunction=hasCalledFunctionID(obj,node)
            hasCalledFunction=~isempty(...
            obj.fMtreeAttributes(node).CalledFunctionID);
        end


        function print(obj)

            obj.printNode(obj.fRootNode);
        end


        function printNode(obj,mNode)
            disp(' === Node === ');
            disp([' Kind: ',mNode.kind]);
            disp(['Start position: ',sprintf('%ld',obj.getStartPos(mNode))]);
            disp(['End position: ',sprintf('%ld',obj.getEndPos(mNode))]);
            [L,C]=pos2lc(mNode,position(mNode));
            disp([' Position line:col: ',sprintf('%ld',L),':',sprintf('%ld',C)]);
            disp([' Type: ',obj.fMtreeAttributes(mNode).Type]);
            disp([' Size: ',num2str(obj.fMtreeAttributes(mNode).Size)]);
            disp(' ============ ');
            [~,children]=slci.mlutil.getMtreeChildren(mNode);
            for k=1:numel(children)
                obj.printNode(children{k});
            end
        end

    end

    methods(Access=private)


        function appendInference(obj,mNode,functionInference)

            [childFound,children]=slci.mlutil.getMtreeChildren(mNode);
            if~childFound
                warning('child not found as node type is not supported');
            end

            for k=1:numel(children)
                obj.appendInference(children{k},functionInference);
            end


            startPos=obj.getStartPos(mNode);
            endPos=obj.getEndPos(mNode);

            obj.fMtreeAttributes(mNode).Type=...
            obj.readType(startPos,endPos,functionInference);

            obj.fMtreeAttributes(mNode).Size=...
            obj.readSize(startPos,endPos,functionInference);

            obj.fMtreeAttributes(mNode).Complex=...
            obj.readComplex(startPos,endPos,functionInference);

            obj.fMtreeAttributes(mNode).CalledFunctionID=...
            obj.readCalledFunctionID(startPos,endPos,functionInference);
        end


        function startPos=getStartPos(~,mNode)
            startPos=lefttreepos(mNode);
        end


        function endPos=getEndPos(~,mNode)
            endPos=righttreepos(mNode);
        end


        function type=readType(~,startPos,endPos,functionInference)


            type=[];

            if functionInference.hasType(startPos,endPos)
                types=functionInference.getType(startPos,endPos);
                if numel(types)==1
                    type=types{1};

                end
            end
        end


        function size=readSize(~,startPos,endPos,functionInference)


            size=[];

            if functionInference.hasSize(startPos,endPos)
                sizes=functionInference.getSize(startPos,endPos);
                if(numel(sizes)==1)
                    size=sizes{1};
                end
            end
        end


        function complex=readComplex(~,startPos,endPos,functionInference)


            complex=false;

            if functionInference.hasComplex(startPos,endPos)
                complexity=functionInference.getComplex(startPos,endPos);
                if(numel(complexity)==1)
                    complex=complexity{1};
                end
            end
        end


        function calledFunctionID=readCalledFunctionID(...
            ~,startPos,endPos,functionInference)


            calledFunctionID=[];

            if functionInference.hasCalledFunctionID(startPos,endPos)
                calledFunctionIDs=functionInference.getCalledFunctionID(...
                startPos,endPos);
                if numel(calledFunctionIDs)==1
                    calledFunctionID=calledFunctionIDs{1};
                end
            end
        end

    end

end
