classdef(Sealed)EnumMetaType<codergui.internal.type.MetaType




    properties(SetAccess=immutable)
        Id char='metatype.enum'
        CustomAttributes codergui.internal.type.AttributeDef=codergui.internal.type.AttributeDef.empty()
    end

    methods(Access={?codergui.internal.type.MetaType,?codergui.internal.type.TypeMakerNode})
        function coderType=toCoderType(~,node,~)
            [sz,varDims]=node.Size.toNewTypeArgs();
            coderType=coder.newtype(node.Class,sz,varDims);
        end

        function fromCoderType(~,node,coderType)
            node.Size=codergui.internal.type.Size(coderType.SizeVector,coderType.VariableDims);
        end

        function address=validateAddress(this,address,node)
            address=this.validateNameAddress(address,node,'invalidEnumMemberName','duplicateEnumMemberName');
        end

        function code=toCode(~,node,varName,~)
            [sz,varDims]=node.Size.toNewTypeArgs(true);
            code=sprintf('%s = coder.newtype(''%s'', %s, %s);',...
            varName,node.Class,sz,varDims);
        end

        function enumType=toMF0(~,node,model,~)
            enumType=coderapp.internal.codertype.EnumType(model);
            enumType.Size=node.Size.toMfzDims();
            enumType.ClassName=node.Class;
        end

        function class=fromMF0(~,node,mf0)
            class=mf0.ClassName;
            node.Size=codergui.internal.type.Size(mf0.Size);
        end
    end

    methods
        function compatible=isCompatibleClass(~,className)
            metaClass=meta.class.fromName(className);
            compatible=~isempty(metaClass)&&metaClass.Enumeration&&any(ismember(...
            {metaClass.SuperclassList.Name},{'int8','uint8','int16','uint16','int32','Simulink.IntEnumType'}));
        end
    end
end
