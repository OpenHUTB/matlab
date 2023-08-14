classdef Info




    properties(GetAccess=public,SetAccess=immutable)

        CalleeFcnInfo(1,:)


        KernelSize(1,2)uint32


        ImageSize(1,2)uint32



        KernelArgIdxs(1,:)uint32



        StreamedArgIdxs(1,:)uint32



        StreamedArgIdxsInternal(1,:)uint32



        NonStreamedArgIdxs(1,:)uint32







        BoundaryMethod(1,:)char



        BoundaryConst(1,1)int32
    end

    properties(GetAccess=public,SetAccess=public)


        GraphStreamedIdxs(1,:)uint32
    end

    methods(Access=public)

        function this=Info(node,fcnTypeInfoOrVarDescs,fcnInfoRegistry,useAggregate)

            sizeArg=node.Right.Next;
            [isSizeConst,sizeConstVal]=this.getConstVal(sizeArg,2,fcnTypeInfoOrVarDescs,useAggregate);
            assert(isSizeConst&&numel(sizeConstVal)==2,...
            'Non constant size, or size of wrong dimension');
            this.KernelSize=uint32(sizeConstVal);



            this.BoundaryMethod='Constant';



            this.BoundaryConst=0;



            currentIdxCount=uint32(3);
            currArg=sizeArg.Next;
            hasFirstImageSize=false;
            while~isempty(currArg)
                if strcmp(currArg.kind,'CHARVECTOR')
                    if strcmp(currArg.tree2str,'''NonSampleInput''')

                        this.NonStreamedArgIdxs(end+1)=currentIdxCount+uint32(1);
                        this.KernelArgIdxs(end+1)=currentIdxCount+uint32(1);
                    elseif strcmp(currArg.tree2str,'''BoundaryConstant''')

                        boundaryValArg=currArg.Next;
                        [isBoundaryConst,boundaryConstVal]=this.getConstVal(boundaryValArg,currentIdxCount+1,fcnTypeInfoOrVarDescs,useAggregate);
                        assert(isBoundaryConst&&numel(boundaryConstVal)==1,...
                        'Non constant size, or size of wrong dimension');
                        this.BoundaryConst=int32(boundaryConstVal);
                    end
                else



                    foundStreamedInput=false;
                    if currentIdxCount==3
                        foundStreamedInput=true;
                    else
                        if~strcmp(currArg.previous.kind,'CHARVECTOR')
                            foundStreamedInput=true;
                        end
                    end

                    if foundStreamedInput
                        imageDesc=this.getVarDesc(currArg,currentIdxCount,fcnTypeInfoOrVarDescs,useAggregate);
                        this.StreamedArgIdxs(end+1)=currentIdxCount;
                        this.KernelArgIdxs(end+1)=currentIdxCount;
                        this.StreamedArgIdxsInternal(end+1)=numel(this.StreamedArgIdxs)+numel(this.NonStreamedArgIdxs);



                        this.GraphStreamedIdxs(end+1)=numel(this.StreamedArgIdxs)+numel(this.NonStreamedArgIdxs);
                        if~hasFirstImageSize


                            this.ImageSize=imageDesc.type.Dimensions;
                            hasFirstImageSize=true;
                        end
                    end
                end

                currentIdxCount=currentIdxCount+uint32(1);
                currArg=currArg.Next;
            end

            this.CalleeFcnInfo=internal.mtree.utils.npufun.getCalledFcnTypeInfo(...
            node,fcnTypeInfoOrVarDescs,fcnInfoRegistry,this,useAggregate);
        end

    end

    methods(Access=private)

        function varDesc=getVarDesc(~,node,index,fcnTypeInfoOrVarDescs,useAggregate)
            if isa(fcnTypeInfoOrVarDescs,'internal.mtree.FunctionTypeInfo')
                fcnTypeInfo=fcnTypeInfoOrVarDescs;

                if useAggregate
                    varDesc=internal.mtree.getVarDesc(node,fcnTypeInfo,'treeAttributesAggregate');
                else
                    varDesc=internal.mtree.getVarDesc(node,fcnTypeInfo);
                end
            else
                varDesc=fcnTypeInfoOrVarDescs{index};
            end
        end

        function[isConst,constVal]=getConstVal(this,node,index,fcnTypeInfoOrVarDescs,useAggregate)
            varDesc=this.getVarDesc(node,index,fcnTypeInfoOrVarDescs,useAggregate);
            if varDesc.isConst
                isConst=true;
                if useAggregate
                    constVal=varDesc.constVal{1};
                else
                    constVal=varDesc.constVal;
                end
            else
                isConst=false;
                constVal=[];
            end
        end
    end
end


