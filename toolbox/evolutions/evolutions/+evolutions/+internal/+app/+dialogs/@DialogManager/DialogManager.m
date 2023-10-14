classdef DialogManager < evolutions.internal.ui.tools.DialogManagerInterface

    properties ( Hidden )
        TestMode( 1, 1 )logical = false
    end

    properties
        AppView
        Dialog
    end

    properties ( Dependent, SetAccess = protected )
        ParentAppFigure
    end

    methods
        function obj = DialogManager
        end

        function setFigureHandle( obj, appView )
            obj.AppView = appView;
        end

        function fig = get.ParentAppFigure( obj )
            if ~isempty( obj.AppView )
                fig = getToolGroup( obj.AppView );
            else
                fig = [  ];
            end
        end
    end

    methods
        output = getUIAlert( h, message, title, varargin );
        output = getUIConfirm( h, message, varargin );
        output = getFileDependencies( h, project );
        output = addFiles( h, project );
        output = getEvolutionName( h );
        output = getEvolutionTreeName( h );
        output = getLayoutName( h );
        output = generateReport( h, currentTree );
        output = getOrganizeLayout( h, layoutFilesPath );
    end

    methods ( Access = protected )
        function position = getParentPosition( obj )
            if ~isempty( obj.AppView )
                position = getAppPosition( obj.AppView );
            else

                position = get( 0, 'screensize' );
            end
        end

        function dialog = createCustomDialog( obj, type, userData )
            arguments
                obj evolutions.internal.app.dialogs.DialogManager
                type char
                userData = [  ];
            end
            dialog = evolutions.internal.app.dialogs.customdialogs ...
                .CustomDialogFactory.getCustomDialog( type, userData );
            dialog.setDialogPosition( obj.getParentPosition );

            dialog.TestMode = obj.TestMode;
        end
    end
end

