classdef EquivalencyCheckResults < handle

    properties ( SetAccess = 'private', GetAccess = 'public' )
        List
    end

    properties ( SetAccess = 'private', GetAccess = 'public', Hidden = true )
        ClonesId
    end

    methods
        function this = EquivalencyCheckResults( replacementResults )
            arguments
                replacementResults = [  ]
            end
            this.ClonesId = replacementResults.ClonesId;
            this.List = {  };
        end

        function this = addEquivalencyCheckResults( this, result )
            if ~isempty( result )
                if ~isfield( result, 'IsEquivalencyCheckPassed' ) ||  ...
                        ~isfield( result, 'OriginalModel' ) ||  ...
                        ~isfield( result, 'UpdatedModel' )
                    DAStudio.error( 'sl_pir_cpp:creator:InvalidEquivalencyCheckData' );
                else
                    appendIndexForList = length( this.List ) + 1;
                    this.List( appendIndexForList ).IsEquivalencyCheckPassed =  ...
                        result.IsEquivalencyCheckPassed;
                    this.List( appendIndexForList ).OriginalModel =  ...
                        result.OriginalModel;
                    this.List( appendIndexForList ).UpdatedModel =  ...
                        result.UpdatedModel;
                end
            end
        end
    end
end


