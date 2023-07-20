classdef OptimizationSpecification<handle&matlab.mixin.Heterogeneous







    properties(SetAccess=protected)
Element
    end

    properties(SetAccess=protected,Transient=true)
UniqueID
Group
    end

    properties(Dependent)
ID
    end

    methods
        function this=OptimizationSpecification(element)

            this.UniqueID=[];
            this.Element=element;
        end

        function id=get.ID(this)
            id=this.toString();
            if~isempty(this.UniqueID)

                id=string(this.UniqueID.UniqueKey);
            end
        end

        function setGroup(this,group)


            this.Group=group;
        end
    end

    methods(Abstract)
        str=getDataTypeStr(this);
        str=toString(this);
        setUniqueID(this,varargin);
    end
end

