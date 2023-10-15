classdef CacheManager < handle





























    properties ( SetAccess = private )

        CacheFolder string;
    end

    properties ( Access = private )


        IsOpen logical = false;


        IsEnabled logical = true;


        ModelCaches struct
    end

    properties ( Constant, Access = private )
        INIT_FROM_ENV_VARNAME string = "WEBVIEW_CACHE";
    end

    methods ( Static )
        function out = instance(  )



            persistent INSTANCE
            if isempty( INSTANCE )
                INSTANCE = slreportgen.webview.internal.CacheManager(  );
            end
            out = INSTANCE;
        end
    end

    methods
        function prevState = open( this )





            prevState = this.IsOpen;
            this.IsOpen = true;
            this.CacheFolder = Simulink.fileGenControl( "getConfig" ).CacheFolder;
        end

        function close( this )



            if this.IsOpen
                modelNames = fieldnames( this.ModelCaches );
                for i = 1:numel( modelNames )
                    modelCache = this.ModelCaches.( modelNames{ i } );
                    try
                        if ~isempty( modelCache )
                            modelCache.close(  );
                        end
                    catch ME
                        warning( ME.message );
                    end
                    delete( modelCache );
                end
                this.ModelCaches = struct(  );
                this.IsOpen = false;
            end
        end

        function tf = isOpen( this )



            tf = this.IsOpen;
        end

        function previousValue = enable( this, value )







            arguments
                this
                value logical = true;
            end
            previousValue = this.IsEnabled;
            this.IsEnabled = value;
        end

        function tf = isEnabled( this )



            tf = this.IsEnabled;
        end

        function out = caches( this )



            out = [  ];
            if this.isEnabled(  )
                modelNames = fieldnames( this.ModelCaches );
                nCaches = numel( modelNames );
                out = slreportgen.webview.internal.Cache.empty( nCaches );
                opened = true( 1, nCaches );
                for i = 1:numel( modelNames )
                    out( i ) = this.ModelCaches.( modelNames{ i } );
                    opened( i ) = out( i ).isOpen(  );
                end
                out( ~opened ) = [  ];
            end
        end

        function cache = get( this, modelName )



            arguments
                this
                modelName string
            end
            assert( this.IsOpen )
            if this.isEnabled(  ) && ~isempty( modelName ) && ~isNewModel( modelName ) && ~strcmp( modelName, "simulink" )
                if ~isfield( this.ModelCaches, modelName )
                    modelBaseFolder = this.CacheFolder ...
                        + filesep(  ) + "slprj" + filesep(  ) + "slwebview" + filesep(  ) + modelName;
                    cache = slreportgen.webview.internal.Cache( modelName, modelBaseFolder );
                    cache.open(  );
                    if cache.isModelOpenAndDirty(  )
                        cache.close(  );
                        cache = [  ];
                    else
                        if ~cache.isValid(  )
                            cache.clear(  );
                        end
                    end
                    this.ModelCaches.( modelName ) = cache;
                end
                cache = this.ModelCaches.( modelName );
            else
                cache = [  ];
            end
        end
    end

    methods ( Access = private )
        function this = CacheManager(  )
            this.ModelCaches = struct(  );
            env = getenv( this.INIT_FROM_ENV_VARNAME );
            this.IsEnabled = isempty( env ) || ( strcmpi( env, "on" ) || strcmpi( env, "1" ) );
        end
    end
end

function tf = isNewModel( modelName )
tf = slreportgen.utils.isModelLoaded( modelName ) &&  ...
    isempty( get_param( modelName, "FileName" ) );
end
