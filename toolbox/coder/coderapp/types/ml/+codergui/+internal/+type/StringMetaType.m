classdef(Sealed)StringMetaType<codergui.internal.type.MetaType



    properties(SetAccess=immutable)
        Id char='metatype.string'
        CustomAttributes codergui.internal.type.AttributeDef=[...
        codergui.internal.type.AttributeDefs.StringSize,...
        codergui.internal.type.AttributeDefs.VarSize,...
        codergui.internal.type.AttributeDefs.Unbounded...
        ]
    end

    methods(Access={?codergui.internal.type.MetaType,?codergui.internal.type.TypeMakerNode})
        function coderType=toCoderType(this,node,~)
            [sz,varDims]=node.Size.toNewTypeArgs();
            coderType=coder.newtype('string',sz,varDims);
            [contentLength,varSize]=this.handleUnbounded(node);
            coderType.Properties.Value=coder.newtype('char',[1,contentLength],[0,varSize]);
        end

        function fromCoderType(this,node,coderType)
            node.Size=codergui.internal.type.Size(coderType.SizeVector,coderType.VariableDims);
            valueType=coderType.Properties.Value;
            length=valueType.SizeVector(2);
            this.applyNonDefaultAttributes(node,this.CustomAttributes,...
            {length,valueType.VariableDims(2),isinf(length)});
        end

        function applyClass(~,node,~)
            node.SizeAttribute.IsEnabled=false;
        end

        function validateNode(~,node)
            customs=node.CustomAttributes;
            stringLengthAttr=customs(1);
            varSizeAttr=customs(2);
            unboundedAttr=customs(3);

            isUnbounded=unboundedAttr.Value;
            stringLength=stringLengthAttr.Value;

            if isUnbounded
                stringLength=Inf;
            elseif stringLength==Inf
                stringLength=0;
            end
            node.set(stringLengthAttr,stringLength);

            stringLengthAttr.IsEnabled=~isUnbounded;
            varSizeAttr.IsEnabled=~isUnbounded&&stringLength~=0;
        end

        function[contentLength,varSize]=handleUnbounded(this,node)
            [contentLength,varSize,unbounded]=node.multiGet(this.CustomAttributes);
            if contentLength==0
                varSize=false;
            end
            if unbounded
                contentLength=Inf;
                varSize=true;
            end
        end

        function code=toCode(this,node,varName,~)
            [sz,varDims]=node.Size.toNewTypeArgs(true);
            [contentLength,varSize]=this.handleUnbounded(node);
            code=sprintf([...
'%s = coder.newtype(''string'', %s, %s);\n'...
            ,'%s.StringLength = %d;\n'...
            ,'%s.VariableStringLength = %s;'],...
            varName,sz,varDims,...
            varName,contentLength,...
            varName,string(varSize));
        end

        function stringType=toMF0(this,node,model,~)
            stringType=coderapp.internal.codertype.StringType(model);
            stringType.Size=node.Size.toMfzDims();

            [contentLength,varSize]=this.handleUnbounded(node);
            stringType.ContentLength=toMfzDims(codergui.internal.type.Size(contentLength,varSize));
        end

        function class=fromMF0(this,node,mf0)
            class='string';
            node.Size=codergui.internal.type.Size(mf0.Size);

            contentSize=codergui.internal.type.Size(mf0.ContentLength);
            stringSize=contentSize.Dimensions.length;
            varSize=contentSize.Dimensions.variableSized;
            this.applyNonDefaultAttributes(node,this.CustomAttributes,...
            {stringSize,varSize,isinf(stringSize)});
        end
    end
end
