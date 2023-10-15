classdef ( Sealed, Hidden )Comment < simscape.battery.internal.sscinterface.StringItem




    properties ( Constant )
        Type = "Comment";
    end

    properties ( Access = private )
        CommentString
    end

    methods
        function obj = Comment( commentString )


            arguments
                commentString string{ mustBeTextScalar, mustBeNonzeroLengthText }
            end

            obj.CommentString = commentString;
        end
    end

    methods ( Access = protected )

        function children = getChildren( ~ )

            children = [  ];
        end

        function str = getOpenerString( obj )

            str = obj.getFormattedString(  );
        end

        function str = getTerminalString( ~ )

            str = newline;
        end
    end

    methods ( Access = private )
        function formattedString = getFormattedString( obj )

            if ~contains( obj.CommentString, newline )
                [ splitComment, commentMatch ] = obj.CommentString.split( " " );
                wordLengths = splitComment.strlength(  );
                cumWordLengths = cumsum( wordLengths );
                remWhiteSpaceIdx = uint64( cumWordLengths / obj.IdealCharsPerLine );
                newlineExpected = diff( remWhiteSpaceIdx ) ~= 0;


                commentMatch( newlineExpected ) = newline;
                indentedString = join( splitComment, commentMatch );
            else


                indentedString = obj.CommentString;
            end


            precommentedString = "% " + indentedString;
            formattedString = precommentedString.replace( newline, newline + "% " );
        end
    end
end

