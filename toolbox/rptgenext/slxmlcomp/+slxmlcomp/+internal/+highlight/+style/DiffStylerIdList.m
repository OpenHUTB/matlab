classdef DiffStylerIdList < handle




    properties ( Access = private )
        IdList
    end

    methods


        function obj = DiffStylerIdList(  )
            obj.IdList = string.empty;
        end

        function add( obj, stylerId )
            arguments
                obj
                stylerId( 1, 1 )string
            end
            obj.IdList = [ obj.IdList, stylerId ];
        end

        function remove( obj, stylerId )
            arguments
                obj
                stylerId( 1, 1 )string
            end
            obj.IdList = obj.IdList( obj.IdList ~= stylerId );
        end

        function ids = getAll( obj )
            ids = obj.IdList;
        end
    end

    methods ( Static )
        function obj = getInstance(  )

            persistent instance;

            if isempty( instance )
                instance = slxmlcomp.internal.highlight.style.DiffStylerIdList(  );
            end
            obj = instance;
        end
    end
end


