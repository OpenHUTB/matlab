classdef ( Sealed )DeepLearningConfigProducer < coderapp.internal.config.util.CompositeProducer

    methods
        function this = DeepLearningConfigProducer(  )
            this@coderapp.internal.config.util.CompositeProducer( 'coder.DeepLearningConfig',  ...
                'SyncBoundWithValidation', false,  ...
                'ExcludeKeys', { 'gpuEnabled' },  ...
                'Reuse', false );
            this.IgnoreSetterErrors = true;
        end

        function produce( this )
            produce@coderapp.internal.config.util.CompositeProducer( this );
            this.postProductionImport(  );
        end

        function update( this, triggerKeys )
            update@coderapp.internal.config.util.CompositeProducer( this, triggerKeys );
            this.postProductionImport( triggerKeys );
        end
    end

    methods ( Access = protected )
        function cfg = instantiate( this )
            [ enabled, targetLib ] = this.value( 'dlEnabled', 'dlTargetLib' );%#ok<ASGLU>
            if enabled

                try
                    [ ~, cfg ] = evalc( 'coder.DeepLearningConfig(TargetLibrary = targetLib)' );
                catch
                    cfg = coder.DeepLearningConfigBase.empty(  );
                end
            else
                cfg = coder.DeepLearningConfigBase.empty(  );
            end
        end

        function updateScript( this )
            [ enabled, targetLib, gpuEnabled ] = this.value( 'dlEnabled', 'dlTargetLib', 'gpuEnabled' );
            if enabled && ( this.isUserModified( 'dlTargetLib' ) || ~gpuEnabled )



                this.ScriptHelper.setInstantiator( 'coder.DeepLearningConfig', { targetLib } );
            elseif ~enabled && gpuEnabled
                this.ScriptHelper.setInstantiator( 'coder.DeepLearningConfigBase.empty', {  } );
            else
                this.ScriptHelper.setInstantiator( '' );
            end
        end
    end

    methods ( Access = protected )
        function imported = postImport( this, dlConfig, imported )
            if ~isempty( imported )
                [ ~, excluded ] = this.filterKeys( dlConfig, fieldnames( imported ) );
                imported = rmfield( imported, excluded );
                if ~isempty( dlConfig )
                    compatibles = enumeration( 'coderapp.internal.dl.DeepLearningTargetLibrary' );
                    [ enabled, targetLib ] = this.value( 'dlEnabled', 'dlTargetLib' );
                    if any( strcmp( dlConfig.TargetLibrary, { compatibles.Value } ) )
                        if ~enabled
                            imported.dlEnabled = true;
                        end
                        if ~strcmp( targetLib, dlConfig.TargetLibrary )
                            imported.dlTargetLib = dlConfig.TargetLibrary;
                        end
                    elseif enabled
                        imported.dlEnabled = false;
                    end
                end
            else
                imported = struct(  ...
                    'dlEnabled', false,  ...
                    'dlTargetLib', coderapp.internal.dl.DeepLearningTargetLibrary.None.Value );
            end
        end

        function production = updateProperties( this, production, keys, resetScript )
            arguments
                this
                production
                keys = this.FilteredKeys
                resetScript = true
            end
            production = updateProperties@coderapp.internal.config.util.CompositeProducer( this,  ...
                production, this.filterKeys( production, keys ), resetScript );
        end
    end

    methods ( Access = private )
        function postProductionImport( this, triggerKeys )
            arguments
                this
                triggerKeys = {  }
            end
            if any( ismember( triggerKeys, { 'dlTargetLib', 'dlEnabled' } ) ) && ~isempty( this.Production ) && ~this.Importing
                this.requestImport( this.Production, false, false );
            end
        end

        function [ included, excluded ] = filterKeys( this, dlConfig, keys )


            filter = strcmp( keys, 'dlTargetLib' );
            if ~isempty( dlConfig )
                owners = this.metadata( keys, 'targetLib' );
                active = dlConfig.TargetLibrary;
                for i = 1:numel( owners )
                    filter( i ) = filter( i ) || any( strcmp( active, owners{ i } ) );
                end
            end
            included = keys( filter );
            excluded = keys( ~filter );
        end
    end
end



