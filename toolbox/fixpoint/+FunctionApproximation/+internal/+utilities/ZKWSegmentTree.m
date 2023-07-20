classdef ZKWSegmentTree<handle




    properties
ArrayLength
Tree
TreeHeight
TreeSize
LastLayerBeginingIndex

    end

    methods
        function this=ZKWSegmentTree(array)
            this.ArrayLength=numel(array);
            this.TreeHeight=ceil(log2(this.ArrayLength+2))+1;
            this.TreeSize=bitshift(1,this.TreeHeight)-1;
            this.Tree=-Inf(this.TreeSize,1);
            this.LastLayerBeginingIndex=bitshift(1,this.TreeHeight-1);


            this.Tree(this.LastLayerBeginingIndex+1:this.LastLayerBeginingIndex+this.ArrayLength)=array;


            for jj=this.LastLayerBeginingIndex-1:-1:1
                leftChildValue=bitshift(jj,1);
                rightChildValue=bitor(leftChildValue,1);


                this.Tree(jj)=max(this.Tree(leftChildValue),this.Tree(rightChildValue));

            end
        end

        function intervalMax=query(this,s,t)




            s=max(1,s);
            t=min(this.ArrayLength,t);

            intervalMax=-Inf;


            leftIndex=s+this.LastLayerBeginingIndex-1;
            rightIndex=t+this.LastLayerBeginingIndex+1;

            for layerHeight=this.TreeHeight:-1:1
                if rightIndex-leftIndex==1
                    break
                end
                if~(bitand(leftIndex,1))
                    intervalMax=max(intervalMax,this.Tree(bitxor(leftIndex,1)));
                end
                if bitand(rightIndex,1)
                    intervalMax=max(intervalMax,this.Tree(bitxor(rightIndex,1)));
                end


                leftIndex=bitshift(leftIndex,-1);
                rightIndex=bitshift(rightIndex,-1);
            end

        end
    end
end