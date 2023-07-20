classdef Var<plccore.common.Object




    properties(Access=protected)
Scope
Name
Type
Description
InitialValue
Required
Visible
ParamIndex
    end

    methods
        function obj=Var(scope,name,type,desc,required,visible,paramIndex)
            assert(type.isa('plccore.type.AbstractType'));
            obj.Kind='Var';
            obj.Scope=scope;
            obj.Name=name;
            obj.Type=type;
            if nargin>3
                obj.Description=desc;
            else
                obj.Description='';
            end

            obj.Required=true;
            if nargin>4
                assert(islogical(required));
                if~required
                    obj.Required=false;
                end
            end

            obj.Visible=true;
            if nargin>6
                assert(islogical(visible));
                if~visible
                    obj.Visible=false;
                end
                obj.ParamIndex=paramIndex;
            end
        end

        function obj=setName(obj,new_name)
            obj.Name=new_name;
        end

        function name=name(obj)
            name=obj.Name;
        end

        function obj=setType(obj,new_type)
            obj.Type=new_type;
        end

        function ret=type(obj)
            ret=obj.Type;
        end

        function ret=toString(obj)
            val='';
            if~isempty(obj.InitialValue)
                val=sprintf(' = %s',obj.InitialValue.toString);
            end
            desc='';
            if~isempty(obj.Description)
                desc=sprintf(' /* %s */',obj.Description);
            end

            ret=sprintf(' %s: %s%s%s',obj.Name,obj.Type.toString,val,...
            desc);
        end

        function ret=description(obj)
            ret=obj.Description;
        end

        function setDescription(obj,desc)
            obj.Description=desc;
        end

        function ret=required(obj)
            ret=obj.Required;
        end

        function setRequired(obj,required)
            assert(islogical(required));
            obj.Required=required;
        end

        function ret=visible(obj)
            ret=obj.Visible;
        end

        function setVisible(obj,visible)
            assert(islogical(visible));
            obj.Visible=visible;
        end

        function ret=hasInitialValue(obj)
            ret=~isempty(obj.InitialValue);
        end

        function ret=initialValue(obj)
            ret=obj.InitialValue;
        end

        function setInitialValue(obj,val)
            obj.InitialValue=val;
        end

        function ret=paramIndex(obj)
            ret=obj.ParamIndex;
            if isempty(ret)
                ret=NaN;
            end
        end

        function setParamIndex(obj,val)
            obj.ParamIndex=val;
        end

        function ret=scope(obj)
            ret=obj.Scope;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitVar(obj,input);
        end
    end

end


