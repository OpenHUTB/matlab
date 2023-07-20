classdef ElementKindEnum



    enumeration
        Component,
        Port,
Connector
    end

    methods(Static)
        function e=make(elemKindStr)
            if strcmpi(elemKindStr,'Component')
                e=systemcomposer.query.internal.ElementKindEnum.Component;
            elseif strcmpi(elemKindStr,'Port')
                e=systemcomposer.query.internal.ElementKindEnum.Port;
            elseif strcmpi(elemKindStr,'Connector')
                e=systemcomposer.query.internal.ElementKindEnum.Connector;
            else
                error('Unsupported element kind');
            end
        end
    end
end

