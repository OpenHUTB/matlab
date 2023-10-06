classdef(Abstract)GenericRegistry<handle


    methods(Access=protected)
        function result=register(this,type)
            class=metaclass(this);
            names={class.MethodList.Name};
            applicable=~cellfun('isempty',regexp(names,['^register.*',type,'$']));

            result=this.findprop(type).DefaultValue;
            for n=find(applicable)
                registered=this.(names{n});
                result=[result;registered(:)];%#ok<AGROW>
            end
        end
    end

end
