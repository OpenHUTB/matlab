classdef ( Sealed )DefaultCoderConfigProvider < coderapp.internal.config.AbstractProducer

    properties ( SetAccess = immutable )
        Mode
    end

    methods
        function this = DefaultCoderConfigProvider( mode )
            arguments
                mode{ mustBeMember( mode, { 'dynamic', 'mex', 'embedded' } ) } = 'dynamic'
            end
            this.Mode = mode;
        end

        function produce( this )
            [ buildType, useEmbeddedCoder, targetLang, gpuEnabled, hardwareName ] = this.value(  ...
                'buildType', 'useEmbeddedCoder', 'targetLang', 'gpuEnabled', 'hardwareName' );

            switch this.Mode
                case 'mex'
                    buildType = 'MEX';
                    hardwareName = '';
                    code = ~this.value( 'x_isFiaccel' );
                case 'embedded'
                    useEmbeddedCoder = true;
                    code = true;
                    if buildType == "MEX"
                        buildType = 'LIB';
                    end
                case 'dynamic'
                    if buildType == "MEX"
                        code = ~this.value( 'x_isFiaccel' );
                    else
                        code = true;
                    end
            end

            if gpuEnabled
                cfg = coder.gpuConfig( buildType, 'ecoder', useEmbeddedCoder, 'code', code );
            else
                cfg = coder.config( buildType, 'ecoder', useEmbeddedCoder, 'code', code );
                if code
                    cfg.TargetLang = targetLang;
                end
            end
            if coderapp.internal.hw.HardwareConfigController.isHardwareName( hardwareName )
                cfg.Hardware = emlcprivate( 'projectCoderHardware', hardwareName );
            end
            if ~isequal( cfg, this.Production )
                this.Production = cfg;
            end
        end

        function update( this, triggerKeys )
            if isempty( this.Production ) || this.Mode == "dynamic" || ~isempty( setdiff( triggerKeys, 'buildType' ) )
                this.produce(  );
            end
        end
    end

end




