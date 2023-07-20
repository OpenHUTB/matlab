classdef ListValueType<codergui.internal.ui.ValueType




    properties(SetAccess=immutable)
        Id char='List'
        BaseValueType codergui.internal.ui.ValueType=codergui.internal.ui.ValueTypes.empty()
        ElementType codergui.internal.ui.ValueType=codergui.internal.ui.ValueTypes.empty()
        DefaultValue={}
    end

    methods
        function this=ListValueType(elementType)
            this=this@codergui.internal.ui.ValueType(true);
            this.ElementType=elementType;
        end

        function value=validateValue(this,value)
            if~iscell(value)||(~isempty(value)&&~isvector(value))
                codergui.internal.util.throwInternal('ListValueType values must be cell vectors');
            end
            for i=1:numel(value)
                value{i}=this.ElementType.validateValue(value{i});
            end
            value=reshape(value,1,[]);
        end

        function value=fromDecodedJson(this,decoded)
            value=cell(1,numel(decoded));
            for i=1:numel(decoded)
                value{i}=this.ElementType.fromDecodedJson(decoded{i});
            end
        end

        function encodable=toJsonEncodable(this,value)
            encodable=cell(1,numel(value));
            for i=1:numel(value)
                encodable{i}=this.ElementType.fromDecodedJson(value{i});
            end
        end
    end
end
