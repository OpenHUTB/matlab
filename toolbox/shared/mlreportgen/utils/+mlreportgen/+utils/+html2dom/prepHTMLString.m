function preppedStr = prepHTMLString( htmlStr, options )

arguments
    htmlStr string;
    options.Tidy logical = true;
    options.EncodeHTMLEntity logical = true;
end

if ( strlength( htmlStr ) > 0 )
    content = htmlStr;

    if options.EncodeHTMLEntity
        content = encodeHTMLEntityString( content );
    end

    if options.Tidy
        content = mlreportgen.utils.tidy( content, "OutputType", "html" );
    end


    tempfile = compose( "%s.html", tempname );
    fid = fopen( tempfile, "w", "n", "utf-8" );
    scopeDelete = onCleanup( @(  )delete( tempfile ) );
    fprintf( fid, "%s", content );
    fclose( fid );

    preppedStr = mlreportgen.utils.html2dom.prepHTMLFile( tempfile,  ...
        "Tidy", false,  ...
        "EncodeHTMLEntity", false );
else
    preppedStr = string.empty(  );
end
end


