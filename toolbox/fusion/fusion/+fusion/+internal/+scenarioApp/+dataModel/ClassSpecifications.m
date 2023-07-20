classdef ClassSpecifications<handle

    properties(SetAccess=protected,Hidden)
Map
    end

    properties(Access=protected)
Name
    end

    methods(Abstract,Static)
        getNewSpecification(varargin)
    end

    methods

        function clear(this)
            map=this.Map;
            ids=keys(map);
            for indx=1:numel(ids)
                remove(map,ids{indx});
            end
        end

        function spec=getSpecification(this,id)
            map=this.Map;
            if isKey(map,id)
                spec=map(id);
            else
                spec=this.getNewSpecification('name','Undefined Class');
            end
            spec.id=id;
        end

        function ids=getAllIds(this)
            ids=keys(this.Map);
            ids=[ids{:}];
        end

        function setSpecification(this,id,spec)
            map=this.Map;
            map(id)=spec;
        end

        function changeID(this,oldID,newID)
            map=this.Map;
            if isKey(map,oldID)
                spec=map(oldID);
                remove(map,oldID);
                map(newID)=spec;%#ok<*NASGU>
            end
        end

        function setProperty(this,id,name,value)
            spec=getSpecification(this,id);
            spec.(name)=value;
            setSpecification(this,id,spec);
        end

        function value=getProperty(this,id,name)
            spec=getSpecification(this,id);
            value=spec.(name);
        end

        function saveAsPreference(this)
            setpref('TrackingScenarioDesigner',this.Name,this.Map);
        end
    end

    methods(Hidden)
        function data=getSaveData(this)
            data=this.Map;
        end

        function processOpenData(this,data)
            ids=keys(data);


            for indx=1:numel(ids)
                data(ids{indx})=this.getNewSpecification(data(ids{indx}));
            end
            this.Map=data;
        end
    end

end