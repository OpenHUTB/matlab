






classdef(Hidden=true)CodeDescriptorUtils
    methods(Static)





        function res=computeFunctionKey(fcn)

            if~isempty(fcn.FunctionOwner)&&~isempty(fcn.FunctionOwner.Type)


                res=fcn.FunctionOwner.Type.Identifier;
                isCxx=true;
            else
                res="";

                isCxx=false;
            end
            res=fcn.Prototype.Name+"|"+res+"|"+coder.internal.CodeDescriptorUtils.computePrototypeKey(fcn.Prototype,isCxx);
        end

        function res=computePrototypeKey(proto,isCxx)
            if isempty(proto.Return)
                retTyStr="void";
            else
                retTyStr=coder.internal.CodeDescriptorUtils.computeTypeKey(proto.Return.Type,isCxx);
            end
            args(1:proto.Arguments.Size())="";
            for ii=1:proto.Arguments.Size()
                args(ii)=coder.internal.CodeDescriptorUtils.computeTypeKey(proto.Arguments(ii).Type,isCxx,true);
            end
            res="function("+retTyStr+",{"+strjoin(args,",")+"})";
        end






        function res=computeTypeKey(ty,isCxx,isArgTy)
            if nargin<3
                isArgTy=false;
            end

            if~isempty(ty.Identifier)
                res=ty.Identifier;
            elseif isa(ty,'coder.descriptor.types.Void')

                res="void";
            elseif isa(ty,'coder.descriptor.types.Single')||...
                isa(ty,'coder.descriptor.types.Double')||...
                isa(ty,'coder.descriptor.types.Half')

                res="float"+ty.WordLength;
            elseif isa(ty,'coder.descriptor.types.Char')

                if ty.Signed
                    res="s";
                else
                    res="u";
                end
                res=res+"int"+ty.WordLength;
            elseif isa(ty,'coder.descriptor.types.Enum')

                if ty.Signed
                    res="s";
                else
                    res="u";
                end
                res=res+"enum"+ty.WordLength;
            elseif isa(ty,'coder.descriptor.types.Numeric')

                if ty.Signedness
                    res="s";
                else
                    res="u";
                end
                res=res+"int"+ty.WordLength;
            elseif isa(ty,'coder.descriptor.types.Pointer')

                res="ptr("+coder.internal.CodeDescriptorUtils.computeTypeKey(ty.BaseType,isCxx)+")";
            elseif isa(ty,'coder.descriptor.types.Reference')

                res="ref("+coder.internal.CodeDescriptorUtils.computeTypeKey(ty.BaseType,isCxx,isArgTy)+")";
            elseif isa(ty,'coder.descriptor.types.Matrix')
                res=coder.internal.CodeDescriptorUtils.computeTypeKey(ty.BaseType,isCxx);
                if isArgTy&&...
                    (isempty(ty.BaseType.Identifier)||~ty.ReadOnly||~isCxx)

                    res="ptr("+res+")";
                else


                    dim=1;
                    for ii=1:ty.Dimensions.Size()
                        dim=dim*ty.Dimensions(ii);
                    end
                    if isArgTy&&ty.ReadOnly

                        res="const("+res+")";
                    end
                    res="array("+res+","+dim+")";
                end
            elseif isa(ty,'coder.descriptor.types.Function')

                res=coder.internal.CodeDescriptorUtils.computePrototypeKey(ty.Prototype);
            elseif isa(ty,'coder.descriptor.types.Aggregate')

                if isa(ty,'coder.descriptor.types.Class')
                    res="class";
                elseif isa(ty,'coder.descriptor.types.Struct')
                    res="struct";
                elseif isa(ty,'coder.descriptor.types.Union')
                    res="union";
                else
                    assert(false);
                end
            else
                res="unknown";
            end



            if~isArgTy
                if ty.Volatile
                    res="volatile("+res+")";
                end
                if ty.ReadOnly
                    res="const("+res+")";
                end
            end
        end
    end
end
