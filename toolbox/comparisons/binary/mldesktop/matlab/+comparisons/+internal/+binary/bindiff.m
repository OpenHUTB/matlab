function htmlOut = bindiff( source1, source2, report_id, detailed, width )

arguments

    source1{ mustBeTextScalar }
    source2{ mustBeTextScalar }
    report_id{ mustBeTextScalar }

    detailed( 1, 1 )logical = false

    width( 1, 1 ){ mustBeInteger, mustBePositive } = 8
end
comparisons.internal.fileutil.mustBeReadable( source1 );
comparisons.internal.fileutil.mustBeReadable( source2 );

htmlOut = i_Generate( source1, source2, detailed, report_id, width );
end


function data = i_ReadFromFile( filename, MAXLEN )


fid = fopen( filename, 'r' );
if fid < 0
    key = 'FileReadError';
    str = i_string( key, filename );
    E = MException( [ 'comparisons:binary:', key ], '%s', str );
    throw( E );
end
data = fread( fid, MAXLEN, 'uint8' );
fclose( fid );
end



function htmloutput = i_Generate( source1, source2, detailed, report_id, width )
[ source1, name1, title1 ] = i_getFileParts( source1 );
[ source2, name2, title2 ] = i_getFileParts( source2 );

identical = i_filesIdentical( source1, source2 );

[ name1, name2 ] = escapeHTML( name1, name2 );
if identical
    statusmsg = i_string( 'Identical', name1, name2 );
else
    statusmsg = i_string( 'Different', name1, name2 );
end

if ~isequal( name1, name2 )
    title = i_commonWebString( 'WindowTitle', title1, title2 );
else
    title = title1;
end

currentline = 1;
htmloutput = cell( 1e5, 1 );

import comparisons.internal.web3.createHeader
writeLine( '%s', createHeader(  ) );
writeLine( '%s', [ '<title>', escapeHTML( title ), '</title>' ] );



jsPath = i_getPathToJSCallbackFcn(  );
writeLine( [ '<script type="text/javascript" src="', jsPath, '"></script>' ] );

import comparisons.internal.web3.createCSS
writeLine( '%s', createCSS(  ) );
writeLine( '%s', i_createFindCSS(  ) );

writeLine( '</head><body class="binarycomparisonreport">' );
writeLine( '%s', [ '<center><p>', char( statusmsg ), '</p></center>' ] );
if ~detailed
    if ~identical && ~isempty( report_id )

        txt = i_string( 'ShowDetails' );
        link = i_getShowDetailLink( txt );
        writeLine( '%s', [ '<center><p>', char( link ), '</p></center>' ] );
    end
elseif ~identical
    N = width;
    MAXREAD = 1e7;
    data1 = i_ReadFromFile( source1, MAXREAD );
    data2 = i_ReadFromFile( source2, MAXREAD );
    [ firstDiff, startAt ] = i_FindFirstDiff( data1, data2 );
    if startAt > 0
        data1 = data1( startAt:end  );
        data2 = data2( startAt:end  );

        MAXLEN = 2000;
        truncated = false;
        if numel( data1 ) > MAXLEN
            data1 = data1( 1:MAXLEN );
            truncated = true;
        end
        if numel( data2 ) > MAXLEN
            data2 = data2( 1:MAXLEN );
            truncated = true;
        end

        [ a1, a2 ] = diffcode( data1, data2 );
        count = 1;
        writeLine( '<p>%s</p>', i_string( 'FirstDiff', firstDiff - 1, startAt - 1 ) );
        if truncated
            writeLine( '<p>%s</p>', i_string( 'ShowingOnly', MAXLEN ) );
        end
        writeLine( '%s', '<pre>' );





        linewidth = width * 4 + 1;
        blankline = repmat( ' ', 1, linewidth );
        lefttitle = blankline;
        lefttitle( 1:numel( title1 ) ) = title1;
        righttitle = blankline;
        righttitle( 1:numel( title2 ) ) = title2;
        writeLine( '%s  -  %s', escapeHTML( lefttitle ), escapeHTML( righttitle ) );
        writeLine( ' ' );

        while count <= numel( a1 )
            writeDiffsLine( count );
            count = count + N;
        end
        writeLine( '%s', '</pre>' );
    else

        writeLine( i_string( 'NoDifferences', MAXREAD ) );
    end
end
writeLine( '%s', '</body></html>' );
htmloutput = sprintf( '%s\n', htmloutput{ 1:currentline - 1 } );

    function writeLine( str, varargin )
        htmloutput{ currentline } = sprintf( str, varargin{ : } );
        currentline = currentline + 1;
    end

    function writeDiffsLine( startIndex )
        leftstring = '';
        rightstring = '';
        lefthex = '';
        righthex = '';

        NO_DIFFERENCE = 0;
        INSERTION = 1;
        DELETION = 2;
        MODIFICATION = 3;
        EMPTY_ENTRY = 99999;
        state = NO_DIFFERENCE;
        for k = 1:N
            ind = startIndex + k - 1;
            if ind > numel( a1 )

                remaining = startIndex + N - numel( a1 ) - 1;
                if state ~= NO_DIFFERENCE
                    endSpanLeft(  );
                    endSpanRight(  );
                end
                for i = 1:remaining
                    appendValues( EMPTY_ENTRY, EMPTY_ENTRY )
                end
                break ;
            end
            if a1( ind ) ~= 0
                if a2( ind ) ~= 0
                    if data1( a1( ind ) ) == data2( a2( ind ) )

                        if state ~= NO_DIFFERENCE
                            endSpanLeft(  );
                            endSpanRight(  );
                        end
                        state = NO_DIFFERENCE;
                    elseif state ~= MODIFICATION

                        if state ~= NO_DIFFERENCE
                            endSpanLeft(  );
                            endSpanRight(  );
                        end
                        startSpanLeft( 'diffnomatch' );
                        startSpanRight( 'diffnomatch' );
                        state = MODIFICATION;
                    end
                    appendValues( data1( a1( ind ) ), data2( a2( ind ) ) );
                else
                    if state ~= DELETION
                        if state ~= NO_DIFFERENCE
                            endSpanLeft(  );
                            endSpanRight(  );
                        end
                        startSpanLeft( 'diffnew left' );
                        startSpanRight( 'diffskip' );
                        state = DELETION;
                    end
                    appendValues( data1( a1( ind ) ), EMPTY_ENTRY );
                end
            else
                if state ~= INSERTION
                    if state ~= NO_DIFFERENCE
                        endSpanLeft(  );
                        endSpanRight(  );
                    end
                    startSpanLeft( 'diffskip' );
                    startSpanRight( 'diffnew right' );
                    state = INSERTION;
                end
                appendValues( EMPTY_ENTRY, data2( a2( ind ) ) );
            end
        end
        if state ~= NO_DIFFERENCE
            endSpanLeft(  );
            endSpanRight(  );
        end
        writeLine( '%s %s  -  %s %s', leftstring, lefthex, rightstring, righthex );

        function str = byteToString( b )
            if b >= 32 && b < 127
                str = code2html( char( b ) );
            elseif b == EMPTY_ENTRY

                str = ' ';
            else
                str = '.';
            end
        end
        function str = byteToHex( b )
            if ( b == EMPTY_ENTRY )
                str = '  ';
            else
                str = dec2hex( b );
                if numel( str ) < 2
                    assert( numel( str ) == 1 );
                    str = [ '0', str ];
                end
            end
        end

        function appendValues( v1, v2 )
            leftstring = [ leftstring, byteToString( v1 ) ];
            rightstring = [ rightstring, byteToString( v2 ) ];
            lefthex = [ lefthex, ' ', byteToHex( v1 ) ];
            righthex = [ righthex, ' ', byteToHex( v2 ) ];
        end

        function endSpanLeft(  )
            leftstring = [ leftstring, '</span>' ];
            lefthex = [ lefthex, '</span>' ];
        end
        function endSpanRight(  )
            rightstring = [ rightstring, '</span>' ];
            righthex = [ righthex, '</span>' ];
        end
        function startSpanLeft( leftclass )
            leftstring = [ leftstring, '<span class="', leftclass, '">' ];
            lefthex = [ lefthex, '<span class="', leftclass, '">' ];
        end
        function startSpanRight( rightclass )
            rightstring = [ rightstring, '<span class="', rightclass, '">' ];
            righthex = [ righthex, '<span class="', rightclass, '">' ];
        end
    end

end


function [ firstDiff, startOffset ] = i_FindFirstDiff( data1, data2 )
for i = 1:min( numel( data1 ), numel( data2 ) )
    if data1( i ) ~= data2( i )
        firstDiff = i;
        startOffset = max( firstDiff - 50, 1 );
        return ;
    end
end
if numel( data1 ) ~= numel( data2 )

    firstDiff = max( [ i, 1 ] );
    startOffset = max( firstDiff - 50, 1 );
else

    firstDiff =  - 1;
    startOffset =  - 1;
end
end


function str = i_string( key, varargin )
str = message( [ 'comparisons:binary:', key ], varargin{ : } ).getString(  );
end

function str = i_commonWebString( key, varargin )
str = message( [ 'comparisons:commonweb:', key ], varargin{ : } ).getString(  );
end

function [ source, fullname, shortname ] = i_getFileParts( source )
source = char( source );
fullname = source;
[ ~, name, ext ] = fileparts( source );
shortname = [ name, ext ];
end

function p = i_getPathToJSCallbackFcn(  )
p = '/toolbox/comparisons/binary/apps/bindiff.js';
end

function link = i_getShowDetailLink( txt )
jsCallback = 'showDetailsCallback()';
link = [  ...
    '<span ',  ...
    'style="color:blue; cursor:pointer; text-decoration:underline " ',  ...
    'onclick="', jsCallback, '"',  ...
    '>%s</span>' ];
link = sprintf( link, txt );
end

function tf = i_filesIdentical( source1, source2 )
tf = i_sameSizeInBytes( source1, source2 ) ...
    && isequal( i_getFileChecksumBytes( source1 ), i_getFileChecksumBytes( source2 ) );
end

function tf = i_sameSizeInBytes( source1, source2 )
info1 = dir( source1 );
info2 = dir( source2 );
tf = isequal( info1.bytes, info2.bytes );
end

function checksumBytes = i_getFileChecksumBytes( fileName )
digester = matlab.internal.crypto.BasicDigester( 'DeprecatedMD5' );
checksumBytes = digester.computeFileDigest( fileName );
end

function findCSS = i_createFindCSS(  )
findCSS = cell( 100, 1 );
currentline = 1;

    function writeLine( str, varargin )
        findCSS{ currentline } = sprintf( str, varargin{ : } );
        currentline = currentline + 1;
    end

import comparisons.internal.findutil.getFindHighlightClassName
import comparisons.internal.findutil.getFindHighlightRGB
highlightClassName = char( getFindHighlightClassName(  ) );
highlightRGB = getFindHighlightRGB(  );
textRGB = num2str( highlightRGB.textColor );
backgroundRGB = num2str( highlightRGB.backgroundColor );
cssLines = {
    [ '.', highlightClassName, ' {\n' ];
    [ '       color: rgb(', textRGB, ');\n' ];
    [ '  background: rgb(', backgroundRGB, ');\n' ];
    ' text-shadow: none;\n';
    '}\n'
    };

writeLine( '<style>\n' );
cellfun( @writeLine, cssLines );
writeLine( '</style>' );

findCSS = sprintf( '%s\n', findCSS{ 1:currentline - 1 } );
end

function varargout = escapeHTML( varargin )
varargout = cellfun( @code2html, varargin, 'UniformOutput', false );
end


