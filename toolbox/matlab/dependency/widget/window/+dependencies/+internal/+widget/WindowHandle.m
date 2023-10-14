classdef WindowHandle < handle & matlab.mixin.Heterogeneous

    properties ( SetAccess = immutable )
        ID double;
        Window dependencies.internal.widget.Window;
    end

    methods
        function this = WindowHandle( baseURL, options )
            arguments

                baseURL;


                options.Title = missing;


                options.InitialSize = i_getDefaultInitialSize(  );


                options.MinimumSize = [ 400, 160 ];


                options.Tag = missing;
            end

            window = dependencies.internal.widget.Window(  ...
                baseURL, options.Title,  ...
                options.InitialSize,  ...
                options.MinimumSize,  ...
                options.Tag );

            this.ID = getNextUniqueID(  );
            this.Window = window;
        end

        function launch( this )
            this.Window.show(  );
        end

        function delete( this )
            this.Window.delete(  );
        end
    end
end

function initialSize = i_getDefaultInitialSize(  )
ss = get( 0, 'ScreenSize' );
initialWidth = ss( 3 ) / 2;
initialHeight = ss( 4 ) / 2;
initialSize = [ initialWidth, initialHeight ];
end

