classdef ParamType<handle



    methods(Static)
        function obj=create(node)%#ok<STOUT>
            typeName=node.getAttribute('type');
            if isempty(typeName)
                type='ConfigSetEnumParam';
            else
                switch typeName
                case 'enum'
                    type='ConfigSetEnumParam';
                case 'minmax'
                    type='ConfigSetMinMaxParam';
                otherwise
                    type=typeName;
                end
            end

            eval(['obj = configset.internal.constraint.',type,'(node);']);
            assert(isa(obj,'configset.internal.data.ParamType'));
        end
    end

    methods(Abstract)
        out=isValid(obj,val)
        out=getTypeName(obj)
        out=getAvailableValues(obj)
    end

end
