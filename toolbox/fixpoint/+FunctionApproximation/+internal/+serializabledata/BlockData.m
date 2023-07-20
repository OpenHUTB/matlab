classdef BlockData<FunctionApproximation.internal.serializabledata.SerializableData









    properties(Transient,Hidden)
SID
    end

    properties(SetAccess=private,Hidden)
SIDLocal
    end

    properties
FullName
Name
ParentName
ModelName
NumOutputs
    end

    methods
        function this=update(this,blockPath)
            this.SIDLocal=Simulink.ID.getSID(blockPath);
            this.FullName=Simulink.ID.getFullName(this.SIDLocal);
            this.ParentName=Simulink.ID.getFullName(Simulink.ID.getParent(this.SIDLocal));
            this.ModelName=Simulink.ID.getModel(this.SIDLocal);
            blockObject=get_param(blockPath,'Object');
            this.Name=blockObject.Name;
            this.NumOutputs=blockObject.Ports(2);
            this=setInterfaceTypes(this);
        end

        function sid=get.SID(this)
            if~Simulink.ID.isValid(this.SIDLocal)
                try
                    this.SIDLocal=Simulink.ID.getSID(this.FullName);
                catch err
                    rethrow(err);
                end
            end
            sid=this.SIDLocal;
        end
    end

    methods(Abstract,Access=protected)
        this=setInterfaceTypes(this)
    end

    methods(Hidden,Sealed)
        function this=setSIDLocal(this,sid)


            this.SIDLocal=sid;
        end

        function this=setFullName(this,fullName)


            this.FullName=fullName;
        end

        function flag=isequal(this,other)
            flag=isa(other,class(this));
            if flag
                properties={'FullName','Name','ParentName','ModelName','NumOutputs'};
                for iProp=1:numel(properties)
                    prop=properties{iProp};
                    flag=flag&&isequal(this.(prop),other.(prop));
                    if~flag
                        break;
                    end
                end
            end
        end
    end
end


