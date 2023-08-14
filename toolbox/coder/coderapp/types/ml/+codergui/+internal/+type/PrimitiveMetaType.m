classdef PrimitiveMetaType<codergui.internal.type.MetaType




    properties(SetAccess=immutable)
        Id char='metatype.primitive'
        CustomAttributes codergui.internal.type.AttributeDef=[...
        codergui.internal.type.AttributeDefs.Sparse,...
        codergui.internal.type.AttributeDefs.Complex,...
        codergui.internal.type.AttributeDefs.Gpu...
        ]
    end

    methods(Access={?codergui.internal.type.MetaType,?codergui.internal.type.TypeMakerNode})
        function coderType=toCoderType(this,node,~)
            [sz,varDims]=node.Size.toNewTypeArgs();
            pairs=reshape([{this.CustomAttributes.Key};node.multiGet(this.CustomAttributes)],1,[]);
            coderType=coder.newtype(node.Class,sz,varDims,pairs{:});
        end

        function fromCoderType(this,node,coderType)
            node.multiSet('size',[],{codergui.internal.type.Size(coderType.SizeVector,coderType.VariableDims)},true);
            this.applyNonDefaultAttributes(node,this.CustomAttributes,{coderType.Sparse,coderType.Complex,coderType.Gpu});
        end

        function applyClass(this,node,typeClass)
            customs=node.CustomAttributes;
            sparseAttr=customs(1);
            complexAttr=customs(2);
            gpuAttr=customs(3);

            if typeClass~="double"&&typeClass~="logical"
                sparseAttr.Value=false;
                sparseAttr.IsEnabled=false;
            elseif~sparseAttr.IsEnabled
                sparseAttr.IsEnabled=true;
            end

            if typeClass=="char"||typeClass=="half"
                gpuAttr.Value=false;
                gpuAttr.IsEnabled=false;
            elseif~gpuAttr.IsEnabled
                gpuAttr.IsEnabled=true;
            end

            if typeClass=="char"||typeClass=="logical"
                complexAttr.Value=false;
                complexAttr.IsEnabled=false;
            elseif~complexAttr.IsEnabled
                complexAttr.IsEnabled=true;
            end

            this.validateSize(node.Size,node);
        end

        function size=validateSize(this,size,node)
            customs=node.CustomAttributes;
            sparseAttr=customs(1);
            gpuAttr=customs(3);
            if(~isempty(size)&&isequal(size,codergui.internal.type.Size.scalar()))||...
                (~isempty(node.Parent)&&~node.Parent.MetaType.IsLeaf)
                gpuAttr.Value=false;
                gpuAttr.IsEnabled=false;
            elseif~gpuAttr.IsEnabled
                gpuAttr.IsEnabled=true;
            end

            if sparseAttr.Value
                dims=size.Dimensions;
                boundedVarSized=([dims.length]~=Inf)&[dims.variableSized];
                if any(boundedVarSized)
                    [dims(boundedVarSized).length]=deal(Inf);
                    node.Size=this.annotate(codergui.internal.type.Size(dims),...
                    message('coderApp:typeMaker:sparseTypeIsUnboundedIfVarsized'));
                end
            end
        end

        function validateNode(this,node)
            this.validateSize(node.Size,node);
        end

        function code=toCode(~,node,varName,~)
            [complex,sparse,gpu]=node.multiGet({'complex','sparse','gpu'},'value','deal');
            extraArgs={};
            if complex
                extraArgs(end+1:end+2)={'''complex''','true'};
            end
            if sparse
                extraArgs(end+1:end+2)={'''sparse''','true'};
            end
            if gpu
                extraArgs(end+1:end+2)={'''gpu''','true'};
            end

            [sz,varDims]=node.Size.toNewTypeArgs(true);
            code=sprintf('%s = coder.newtype(''%s'', %s, %s%s);',...
            varName,node.Class,sz,varDims,strjoin(strcat({', '},extraArgs),''));
        end

        function primitiveType=toMF0(this,node,model,~)
            pairs=reshape([{this.CustomAttributes.Key};node.multiGet(this.CustomAttributes)],1,[]);
            primitiveType=coderapp.internal.codertype.PrimitiveType(model);
            primitiveType.ClassName=node.Class;
            primitiveType.Size=node.Size.toMfzDims();

            for i=1:2:numel(pairs)
                key=pairs{i};


                key(1)=upper(key(1));
                primitiveType.(key)=pairs{i+1};
            end
        end

        function class=fromMF0(this,node,mf0)
            class=mf0.ClassName;
            node.multiSet('size',[],{codergui.internal.type.Size(mf0.Size)},true);
            this.applyNonDefaultAttributes(node,this.CustomAttributes,{mf0.Sparse,mf0.Complex,mf0.Gpu});
        end
    end
end
