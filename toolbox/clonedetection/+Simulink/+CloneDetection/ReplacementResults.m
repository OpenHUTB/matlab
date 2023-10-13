classdef ReplacementResults

    properties ( SetAccess = 'private', GetAccess = 'public' )
        ReplacedClones
        ExcludedClones
    end

    properties ( SetAccess = 'private', GetAccess = 'public', Hidden = true )
        ClonesId
    end

    methods
        function obj = ReplacementResults( results )
            arguments
                results = [  ]
            end

            obj.ReplacedClones = struct( [  ] );
            obj.ExcludedClones = struct( [  ] );
            obj.ClonesId = '';
            try
                if ~isempty( results )
                    if ~isfield( results, 'ReplacedClones' ) ||  ...
                            ~isfield( results, 'ExcludedClones' ) ||  ...
                            ~isfield( results, 'ClonesId' )
                        DAStudio.error( 'sl_pir_cpp:creator:InvalidCloneResultsObject' );
                    end

                    obj.ReplacedClones = results.ReplacedClones;
                    obj.ExcludedClones = results.ExcludedClones;
                    obj.ClonesId = results.ClonesId;
                end
            catch exception
                exception.throwAsCaller(  );
                return ;
            end
        end
    end
end

