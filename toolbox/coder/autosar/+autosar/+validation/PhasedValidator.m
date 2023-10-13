classdef PhasedValidator < handle

    properties ( Access = protected )
        AutosarUtilsValidator autosar.validation.AutosarUtils;
    end

    methods ( Access = public )

        function this = PhasedValidator( namedargs )
            arguments
                namedargs.ModelHandle = [  ];
            end

            if ~isempty( namedargs.ModelHandle )
                this.AutosarUtilsValidator = autosar.validation.AutosarUtils( namedargs.ModelHandle );
            end
        end

        function verify( this, varargin )

            this.verifyPhase( 'Initial', varargin{ : } );
            this.verifyPhase( 'PostProp', varargin{ : } );
            this.verifyPhase( 'Final', varargin{ : } );
        end


        function verifyPhase( this, validationPhase, varargin )

            switch validationPhase
                case 'Initial'
                    this.verifyInitial( varargin{ : } );
                case 'PostProp'
                    this.verifyPostProp( varargin{ : } );
                case 'Final'
                    this.verifyFinal( varargin{ : } );
                otherwise
                    assert( false, 'Did not recognize phase %s', validationPhase );
            end

        end

    end

    methods ( Access = protected )

        function verifyInitial( ~, varargin )

        end

        function verifyPostProp( ~, varargin )

        end

        function verifyFinal( ~, varargin )

        end

    end

end

