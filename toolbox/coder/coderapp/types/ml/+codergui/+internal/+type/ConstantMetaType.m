classdef ConstantMetaType<codergui.internal.type.MetaType


    properties(SetAccess=immutable)
        Id char='metatype.constant'
        CustomAttributes codergui.internal.type.AttributeDef=[...
        codergui.internal.type.AttributeDefs.Value
        ]
    end

    methods
        function this=ConstantMetaType()
            this.SupportsChecksum=false;
        end

        function supported=isSupported(~)
            supported=false;
        end
    end

    methods(Access={?codergui.internal.type.MetaType,?codergui.internal.type.TypeMakerNode})
        function coderType=toCoderType(~,node,~)
            [value,expr]=node.multiGet({'value','valueExpression'});
            if~isempty(expr)
                value=evalin('base',expr);
            end
            coderType=coder.Constant(value);
        end

        function fromCoderType(~,node,coderType)
            node.set('value',coderType.Value);
            node.internalSetClass(class(coderType.Value));
        end

        function applyToNode(~,node)
            node.attr('class').IsEnabled=false;
            node.attr('size').IsEnabled=false;
            node.attr('address').IsEnabled=false;
        end

        function cleanupNode(~,node)
            node.attr('class').IsEnabled=true;
            node.attr('size').IsEnabled=true;
            node.attr('address').IsEnabled=true;
        end

        function code=toCode(~,node,varName,~)
            expr=node.get('valueExpression');
            if~isempty(expr)
                code=sprintf('%s = coder.Constant(%s);',varName,expr);
            else
                code=sprintf('error("%s")',message('coderApp:typeMaker:unsupportedConstant',varName));
            end
        end

        function constantType=toMF0(~,node,model,~)
            [value,expr]=node.multiGet({'value','valueExpression'});
            if~isempty(expr)
                value=evalin('base',expr);
            end

            constantType=coderapp.internal.codertype.Constant(model);
            constantType.ClassName=node.Class;
            constantType.Value=coderapp.internal.codertype.Value(model);

            if isempty(value)
                error('Unexpected coder.Constant value constructor');
            end

            if~isempty(expr)
                constantType.Value.ValueConstructor=expr;
            end

            constantType.Value.Value=value;
            constantType.Size=node.Size.toMfzDims();
        end

        function cls=fromMF0(~,node,mf0)
            cls='coder.Constant';
            if~isempty(mf0.Value.Value)


                try
                    value=evalin('base',mf0.Value.Value);
                catch
                    value=mf0.Value.Value;
                end
                node.set('value',value);
                node.internalSetClass(class(value));
            else
                node.internalSetClass('');
            end

            if~isempty(mf0.Value.ValueConstructor)
                valueCon=mf0.Value.ValueConstructor;
                node.set('valueExpression',valueCon);
            end
        end
    end
end
