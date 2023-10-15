classdef WebBrowserSchema < handle

    properties ( SetAccess = immutable )
        URL
    end

    properties
        MinimumSize( 1, 2 )double = [ 300, 300 ]
    end

    methods
        function obj = WebBrowserSchema( url )
            arguments
                url( 1, 1 )string
            end

            obj.URL = url;
        end
    end

    methods
        function dlgSchema = getDialogSchema( obj )
            borderThickness = 2;
            totalBorderThickess = borderThickness * 2;
            dlgItem = struct( 'Type', 'webbrowser',  ...
                'WebKit', false,  ...
                'DisableContextMenu', true,  ...
                'MinimumSize', obj.MinimumSize - totalBorderThickess,  ...
                'Url', obj.URL );

            dlgSchema = struct( 'DialogTitle', '',  ...
                'Items', { { dlgItem } },  ...
                'StandaloneButtonSet', { { '' } },  ...
                'EmbeddedButtonSet', { { '' } } );
        end
    end
end


