classdef CandidateElement<handle

    properties
ExtElementID

        StereotypesExtIDs=[];
        StereotypePropVals=[]
    end

    methods(Static)
        function varargout=idMap(idFun,varargin)
            persistent idMap
            if isempty(idMap)
                idMap=containers.Map;
            end
            if idFun=="add"
                elID=varargin{1};
                elem=varargin{2};

                if~isKey(idMap,elID)
                    idMap(elID)=elem;
                else

                    cVal=idMap(elID);
                    cVal=[cVal,elem];
                    idMap(elID)=cVal;
                end

                varargout={};
            elseif idFun=="lookup"
                elem=[];
                elID=varargin{1};

                if isKey(idMap,elID)
                    elem=idMap(elID);
                end

                varargout={elem};
            elseif idFun=="reset"
                idMap=containers.Map;
                varargout={};
            elseif idFun=="getElems"
                cls=varargin{1};
                elems=idMap.values;
                elems=elems(cellfun(@(x)isa(x,cls),elems));
                varargout={elems};
            elseif idFun=="getAll"
                varargout={idMap};
            else
                error("Unknown option to idMap");
            end
        end

    end

    methods
        function this=CandidateElement(extElemID)
            this.ExtElementID=extElemID;
            systemcomposer.xmi.CandidateElement.idMap(...
            "add",extElemID,this);
        end

        function addStereotype(this,st)
            this.StereotypesExtIDs=[this.StereotypesExtIDs,st];
        end

        function addStereotypePropVal(this,stype,prop,propType,val)
            pVal.Stereotype=stype;
            pVal.PropertyName=prop;
            pVal.Type=propType;
            pVal.Value=val;
            this.StereotypePropVals=[this.StereotypePropVals,pVal];
        end
    end
end
