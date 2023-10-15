classdef Result < handle

    properties ( SetAccess = 'private', GetAccess = 'public' )
        TopModel
        BusHierarchies
    end

    properties ( SetAccess = 'private', GetAccess = 'private', Hidden = true )
        RawResults
    end

    methods ( Access = public )
        function obj = Result( results, identificationResultsMcos )
            arguments
                results = [  ]
                identificationResultsMcos = [  ]
            end
            obj.TopModel = [  ];
            obj.BusHierarchies = {  };
            if ~isempty( results )
                if isfield( results, 'TopModel' )
                    obj.TopModel = results.TopModel;
                end

                if isfield( results, 'BusHierarchies' )
                    obj.BusHierarchies = results.BusHierarchies;
                end
            end

            obj.RawResults = identificationResultsMcos;
        end
    end

    methods ( Access = public, Hidden = true )
        function candidatesData = getRawResults( obj )
            candidatesData = obj.RawResults;
        end
    end
end


