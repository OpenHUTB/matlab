


classdef VhdlEntityInfo<eda.internal.hdlparser.HdlDesignUnitInfo





    properties(Access=private)
        GenericDeclr='';
    end

    methods

        function obj=VhdlEntityInfo()
            obj=obj@eda.internal.hdlparser.HdlDesignUnitInfo;
            obj.GenericDeclr='';
        end

        function clear(obj)
            clear@HdlDesignUnitInfo(obj);
            obj.GenericDeclr='';
        end
        function addPort(obj,name,type,direction,bitwidth,isdescending)
            newPort=struct('Name',name,...
            'Type',type,...
            'Direction',direction,...
            'Bitwidth',bitwidth,...
            'Isdescending',isdescending);
            obj.Ports=[obj.Ports,newPort];
        end

        function setPortDataType(obj,indx,type)
            obj.Ports(indx).Type=type;
        end
        function type=getPortDataType(obj,indx)
            type=obj.Ports(indx).Type;
        end

        function setGenericDeclr(obj,str)
            obj.GenericDeclr=str;
        end
        function str=getGenericDeclr(obj)
            str=obj.GenericDeclr;
        end
    end
end

