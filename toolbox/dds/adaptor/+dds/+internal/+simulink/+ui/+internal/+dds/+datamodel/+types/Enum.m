classdef Enum<dds.internal.simulink.ui.internal.dds.datamodel.types.Type



    properties(Access=private)
    end

    properties(Access=public)
        UserData;
    end

    methods
        function this=Enum(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.types.Type(mdl,tree,node);
            UserData=[];
        end

        function dlgStruct=getDialogSchema(this,~)
            name=this.mNode.Name;


            dlgStruct=Simulink.dd.enumtypeddg(this,this.mSimObject,name);
            dlgStruct=this.addFullAndShortName(dlgStruct);
        end

        function valid=isValidSourceForEnum(this)
            valid=true;
        end

        function userData=getUserData(this)
            userData=this.UserData;
        end

        function setUserData(this,userData)
            this.UserData=userData;
        end
    end


    methods(Static,Access=public)

        function typeObj=create(ddsMdl,~,typeLibNode,name)
            types=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypesList(typeLibNode);
            txn=ddsMdl.beginTransaction;
            typeObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsMdl,types,'dds.datamodel.types.Enum',name);
            typeObj.Base=dds.datamodel.types.Integer(ddsMdl);
            element=dds.datamodel.types.EnumMember(ddsMdl);
            element.Name='Element1';
            element.Index=1;
            element.ValueStr='0';
            typeObj.Members.add(element);
            element=dds.datamodel.types.EnumMember(ddsMdl);
            element.Name='Element2';
            element.Index=2;
            element.ValueStr='1';
            typeObj.Members.add(element);
            typeLibNode.Elements.add(typeObj);
            dds.internal.simulink.ui.internal.dds.datamodel.types.Type.makeNameUnique(ddsMdl,typeObj);
            dds.internal.simulink.getSimObjectFor(ddsMdl,typeObj);
            txn.commit;
        end

    end



    methods(Access=private)


    end
end
