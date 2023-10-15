classdef ( Sealed, Hidden )UiLayout < simscape.battery.internal.sscinterface.StringItem




    properties ( Constant )
        Type = "UiLayout";
    end

    properties ( Access = private )
        UiGroups = simscape.battery.internal.sscinterface.UiGroup.empty;
    end

    methods
        function obj = UiLayout(  )

        end

        function obj = addUiGroup( obj, title, parameters )

            obj.UiGroups( end  + 1 ) = simscape.battery.internal.sscinterface.UiGroup( title, parameters );
        end

        function mergedUiLayout = merge( uiLayouts )

            arguments
                uiLayouts{ mustBeNonempty, mustBeVector }
            end



            uiGroups = [ uiLayouts.UiGroups ];
            uiGroupsTitles = [ uiGroups.Title ];
            [ ~, uniqueGroupsIdx, GroupsIdx ] = unique( uiGroupsTitles, 'stable' );
            mergedUiGroups = simscape.battery.internal.sscinterface.UiGroup.empty( 0, length( uniqueGroupsIdx ) );
            for uniqueGroup = 1:length( uniqueGroupsIdx )
                mergedUiGroups( uniqueGroup ) = uiGroups( GroupsIdx == uniqueGroup ).merge;
            end


            mergedUiLayout = uiLayouts( 1 );
            mergedUiLayout.UiGroups = mergedUiGroups;
        end
    end

    methods ( Access = protected )

        function children = getChildren( obj )

            children = [  ];
        end

        function str = getOpenerString( obj )

            uiLayoutString = "UILayout = [";
            splitGroups = arrayfun( @( uiGroups )uiGroups.getString, obj.UiGroups );
            splitStr = [ uiLayoutString, splitGroups ];


            stringLengths = splitStr.strlength;
            cumstringLengths = cumsum( stringLengths );
            strLines = floor( cumstringLengths / obj.IdealCharsPerLine );
            newlineExpected = diff( strLines ) ~= 0;

            delimiter = repmat( ",", size( newlineExpected ) );
            delimiter( newlineExpected ) = delimiter( newlineExpected ) + "..." + newline;
            delimiter( 1 ) = "";
            str = join( splitStr, delimiter );
        end

        function str = getTerminalString( ~ )

            str = "];" + newline;
        end
    end
end


