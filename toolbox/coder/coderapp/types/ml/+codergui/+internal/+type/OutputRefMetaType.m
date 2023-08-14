classdef(Sealed)OutputRefMetaType<codergui.internal.type.MetaType




    properties(SetAccess=immutable)
        Id char='metatype.outputType'
        CustomAttributes codergui.internal.type.AttributeDef=[...
        codergui.internal.type.AttributeDefs.FunctionName,...
        codergui.internal.type.AttributeDefs.OutputIndex...
        ]
    end

    methods(Access={?codergui.internal.type.MetaType,?codergui.internal.type.TypeMakerNode})
        function coderType=toCoderType(this,node,~)
            [funcName,outputIndex]=node.multiGet(this.CustomAttributes);
            coderType=coder.OutputType(funcName,outputIndex);
        end

        function fromCoderType(this,node,coderType)
            node.multiSet(this.CustomAttributes,{coderType.FunctionName,coderType.OutputIndex});
        end

        function applyClass(~,node,~)
            if~isempty(node.Parent)
                error(message('Coder:common:UnsupportedOutputTypeInAggregate'));
            end
            node.set('size','IsEnabled',false);
            node.set('size','IsVisible',false);
        end

        function cleanupNode(~,node)
            node.set('size','IsEnabled',true);
            node.set('size','IsVisible',true);
        end

        function size=validateSize(~,size,~)
            if size.NumElements~=0
                error('Output type references do not need sizes');
            end
        end

        function code=toCode(~,node,varName,~)
            [func,index]=node.multiGet({'functionName','outputIndex'},'value','deal');
            if index~=1
                code=sprintf('%s = coder.OutputType(''%s'', %d);',varName,func,index);
            else
                code=sprintf('%s = coder.OutputType(''%s'');',varName,func);
            end
        end

        function mf0=toMF0(this,node,model,~)
            mf0=coderapp.internal.codertype.OutputType(model);

            [funcName,outputIndex]=node.multiGet(this.CustomAttributes);
            mf0.FunctionName=funcName;
            mf0.OutputIndex=outputIndex;
        end

        function class=fromMF0(this,node,mf0)
            class='coder.OutputType';
            node.multiSet(this.CustomAttributes,{mf0.FunctionName,mf0.OutputIndex});
        end
    end
end
