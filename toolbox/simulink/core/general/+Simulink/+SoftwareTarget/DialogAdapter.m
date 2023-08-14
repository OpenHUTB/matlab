classdef DialogAdapter<handle





    properties
        Prop=[];
        Object=[];
        Type='edit';
    end
    properties(Dependent)
        Value;
        Name;
        Prompt;
    end
    methods
        function h=DialogAdapter(object,prop,type)
            h.Object=object;
            h.Prop=prop;
            h.Type=type;
        end
        function v=get.Name(h)
            v=h.Prop.Name;
        end
        function set.Name(h,v)
            h.Prop.Name=v;
        end
        function v=get.Prompt(h)
            v=h.Prop.Prompt;
        end
        function set.Prompt(h,v)
            h.Prop.Prompt=v;
        end
        function v=get.Value(h)
            switch h.Type
            case{'edit','combobox'}
                v=h.Object.getProperty(h.Name);
            case 'checkbox'
                if strcmpi(h.Object.getProperty(h.Name),'on')
                    v=true;
                else
                    v=false;
                end
            otherwise
                assert(false,'unhandled case in DialogAdapter');
            end
        end
        function set.Value(h,v)
            switch h.Type
            case{'edit','combobox'}
                h.Object.setProperty(h.Name,v);
            case 'checkbox'
                if v
                    h.Object.setProperty(h.Name,'on');
                else
                    h.Object.setProperty(h.Name,'off');
                end
            otherwise
                assert(false,'unhandled case in DialogAdapter');
            end
        end
        function varType=getPropDataType(h,varName)
            if strcmp(varName,'Value')
                switch h.Type
                case{'edit','combobox'}
                    varType='string';
                case 'checkbox'
                    varType='bool';
                otherwise
                    varType='mxArray';
                end
            else
                varType='mxArray';
            end
        end
    end
end
