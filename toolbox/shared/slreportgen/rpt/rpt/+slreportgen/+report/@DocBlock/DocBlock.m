classdef DocBlock < slreportgen.report.Reporter













































































































    properties




        Object{ mustBeDocBlockObject( Object ) } = [  ];












        ImportTextInline{ mlreportgen.report.validators.mustBeLogical } = false;











        TextSep{ mustBeMember( TextSep,  ...
            { 'Ignore', 'LineFeed', 'BlankLine' } ) } = "Ignore";









        ConvertHTML{ mlreportgen.report.validators.mustBeLogical } = true;









        EmbedFile{ mlreportgen.report.validators.mustBeLogical } = false;












        ParagraphFormatter{ mlreportgen.report.validators.mustBeInstanceOf(  ...
            'mlreportgen.dom.Paragraph', ParagraphFormatter ) } = [  ];













        TextFormatter{ mlreportgen.report.validators.mustBeInstanceOf(  ...
            'mlreportgen.dom.Text', TextFormatter ) } = [  ];
    end

    properties ( Access = private, Hidden )

        DocBlockObj = [  ];
    end

    methods
        function this = DocBlock( varargin )

            if nargin == 1
                varObj = varargin{ 1 };
                varargin = { "Object", varObj };
            end

            this = this@slreportgen.report.Reporter( varargin{ : } );


            p = inputParser;




            p.KeepUnmatched = true;




            addParameter( p, "TemplateName", "DocBlock" );
            addParameter( p, "TextSep", "Ignore" );

            paragraph = mlreportgen.dom.Paragraph;
            paragraph.WhiteSpace = "preserve";

            paragraph.StyleName = "DocBlockTextTypePara";
            addParameter( p, "ParagraphFormatter", paragraph );

            text = mlreportgen.dom.Text;
            text.WhiteSpace = "preserve";
            addParameter( p, "TextFormatter", text );


            parse( p, varargin{ : } );


            results = p.Results;
            this.TemplateName = results.TemplateName;
            this.TextSep = results.TextSep;
            this.ParagraphFormatter = results.ParagraphFormatter;
            this.TextFormatter = results.TextFormatter;

        end

        function set.Object( this, value )
            if ischar( value )
                this.Object = string( value );
            else
                this.Object = value;
            end
        end

        function set.ParagraphFormatter( this, value )


            mustBeNonempty( value );



            this.ParagraphFormatter = value;
        end

        function set.TextFormatter( this, value )


            mustBeNonempty( value );



            this.TextFormatter = value;
        end

        function impl = getImpl( this, rpt )
            arguments
                this( 1, 1 )
                rpt( 1, 1 ){ validateReport( this, rpt ) }
            end

            if isempty( this.Object )

                error( message( "slreportgen:report:error:noSourceObjectSpecified", class( this ) ) );
            else
                this.DocBlockObj = slreportgen.utils.getSlSfHandle( this.Object );


                if isempty( this.LinkTarget )

                    parent = get_param( this.DocBlockObj, "Parent" );
                    hs = slreportgen.utils.HierarchyService;
                    dhid = hs.getDiagramHID( parent );
                    parentPath = hs.getPath( dhid );

                    if ~isempty( parentPath )
                        parentDiagram = getContext( rpt, parentPath );
                        if ~isempty( parentDiagram ) && ( parentDiagram.HyperLinkDiagram )
                            this.LinkTarget = slreportgen.utils.getObjectID( this.Object );
                        end
                    end
                end


                modelH = slreportgen.utils.getModelHandle( this.Object );
                compileModel( rpt, modelH );
                impl = getImpl@slreportgen.report.Reporter( this, rpt );
            end
        end

        function docBlockFile = getDocBlockFile( this, rpt )
            arguments
                this( 1, 1 )
                rpt( 1, 1 ){ validateReport( this, rpt ) }
            end

            if isempty( this.Object )

                error( message( "slreportgen:report:error:noSourceObjectSpecified", class( this ) ) );
            else
                docBlockFile = [  ];
                docBlockObj = slreportgen.utils.getSlSfHandle( this.Object );
                contentType = get_param( docBlockObj, "DocumentType" );

                extn = [  ];
                if strcmp( contentType, "RTF" ) || strcmp( contentType, "HTML" )
                    extn = lower( contentType );
                elseif strcmp( contentType, "Text" )
                    extn = "txt";
                end

                if ~isempty( extn )
                    docBlockFile = generateDocBlockFileName( docBlockObj, rpt, extn );
                    docblock( "blk2file", docBlockObj, docBlockFile );
                end
            end

        end
    end


    methods ( Access = { ?mlreportgen.report.ReportForm, ?slreportgen.report.DocBlock } )
        function content = getContent( this, rpt )


            contentType = get_param( this.DocBlockObj, 'DocumentType' );
            switch ( contentType )
                case "RTF"
                    content = getRTFDocBlockContent( this, rpt );
                case "HTML"
                    content = getHTMLDocBlockContent( this, rpt );
                case "Text"
                    content = getTextDocBlockContent( this, rpt );
            end
        end
    end

    methods ( Access = protected, Hidden )

        result = openImpl( reporter, impl, varargin )
    end

    methods ( Access = private )

        function docBlockContent = getRTFDocBlockContent( this, rpt )


            docBlockFile = getDocBlockFile( this, rpt );
            switch ( lower( rpt.Type ) )
                case { "html", "pdf" }
                    blockFullName = getBlockFullName( this.DocBlockObj );
                    if ( this.EmbedFile )





                        docBlockContent = mlreportgen.dom.EmbeddedObject( docBlockFile, blockFullName );

                    else





                        docBlockContent = mlreportgen.dom.ExternalLink( docBlockFile, blockFullName );

                    end
                    docBlockContent.StyleName = "DocBlockExternalLink";

                case ( "html-file" )




                    blockFullName = getBlockFullName( this.DocBlockObj );
                    docBlockContent = mlreportgen.dom.ExternalLink( docBlockFile, blockFullName );
                    docBlockContent.StyleName = "DocBlockExternalLink";

                case "docx"


                    docBlockContent = mlreportgen.dom.DOCXSubDoc( docBlockFile );
            end
        end

        function docBlockContent = getHTMLDocBlockContent( this, rpt )


            docBlockFile = getDocBlockFile( this, rpt );






            switch ( lower( rpt.Type ) )
                case { "html", "html-file" }
                    docBlockContent = mlreportgen.dom.RawText( fileread( docBlockFile ) );
                case { "docx", "pdf" }
                    if ( this.ConvertHTML )
                        prepHTMLFile = mlreportgen.utils.html2dom.prepHTMLFile( docBlockFile, docBlockFile, "Tidy", false );
                        docBlockContent = mlreportgen.dom.HTMLFile( prepHTMLFile );

                    else
                        blockFullName = getBlockFullName( this.DocBlockObj );
                        if ( strcmpi( rpt.Type, "pdf" ) && this.EmbedFile )





                            docBlockContent = mlreportgen.dom.EmbeddedObject( docBlockFile, blockFullName );
                        else






                            docBlockContent = mlreportgen.dom.ExternalLink( docBlockFile, blockFullName );
                        end
                        docBlockContent.StyleName = "DocBlockExternalLink";
                    end
            end
        end


        function docBlockContent = getTextDocBlockContent( this, ~ )
            docBlockContent = [  ];

            textContent = mlreportgen.utils.safeGet( this.DocBlockObj, "userdata", "get_param" );

            if ~isempty( textContent{ 1 } )

                textContent = splitlines( textContent{ 1 }.content );


                if ( this.ImportTextInline )
                    docBlockContent = addContentAsInline( this, textContent );
                else

                    switch lower( this.TextSep )
                        case "ignore"


                            docBlockContent = addContentAsPara( this, textContent );
                        case "linefeed"


                            docBlockContent = addContentAsParasSepByLineFeed( this, textContent );
                        case "blankline"


                            docBlockContent = addContentAsParasSepByBlankLine( this, textContent );
                    end
                end
            end
        end




        function inlineTextContent = addContentAsInline( this, textContent )
            inlineTextContent = clone( this.TextFormatter );
            str = "";
            len = numel( textContent );


            for ind = 1:len - 1
                str = strcat( str, textContent{ ind } );


                str = str + newline;
            end

            str = strcat( str, textContent{ len } );
            inlineTextContent.Content = inlineTextContent.Content + str;

        end




        function paraContent = addContentAsPara( this, textContent )
            paraContent = clone( this.ParagraphFormatter );
            str = "";
            len = numel( textContent );
            for ind = 1:len - 1
                str = strcat( str, textContent{ ind } );


                str = str + newline;
            end

            str = strcat( str, textContent{ len } );
            append( paraContent, str );

        end



        function paraContent = addContentAsParasSepByLineFeed( this, textContent )
            len = numel( textContent );
            paraContent = cell( 1, len );
            for index = 1:len
                paraContent{ index } = clone( this.ParagraphFormatter );
                append( paraContent{ index }, textContent{ index } );
            end

        end





        function paraContent = addContentAsParasSepByBlankLine( this, textContent )
            len = numel( textContent );
            paraContent = cell( 1, len );

            index_1 = 1;

            index_2 = 1;
            while ( index_1 <= len )
                str = "";
                paraContent{ index_2 } = clone( this.ParagraphFormatter );
                while ( index_1 <= len && ~isempty( textContent{ index_1 } ) )
                    str = strcat( str, textContent{ index_1 }, " " );
                    index_1 = index_1 + 1;
                end

                append( paraContent{ index_2 }, deblank( str ) );
                index_2 = index_2 + 1;
                index_1 = index_1 + 1;
            end


            paraContent = paraContent( ~cellfun( 'isempty', paraContent ) );
        end

    end

    methods ( Static )
        function path = getClassFolder(  )


            [ path ] = fileparts( mfilename( 'fullpath' ) );
        end

        function template = createTemplate( templatePath, type )








            path = slreportgen.report.DocBlock.getClassFolder(  );
            template = mlreportgen.report.ReportForm.createFormTemplate(  ...
                templatePath, type, path );
        end

        function classFile = customizeReporter( toClasspath )









            classFile = mlreportgen.report.ReportForm.customizeClass(  ...
                toClasspath, "slreportgen.report.DocBlock" );
        end

    end

end


function mustBeDocBlockObject( object )
if ~isempty( object ) && ~slreportgen.utils.isDocBlock( object )
    error( message( "slreportgen:report:error:invalidSourceObject" ) );
end
end




function filePath = generateDocBlockFileName( obj, rpt, type )


newFolderPath = getSupportingFolder( rpt );

sid = Simulink.ID.getSID( obj );

newStr = strrep( sid, ":", "_" );

fileName = sprintf( 'DocBlock-%s.%s',  ...
    newStr, type );
filePath = fullfile( newFolderPath, fileName );

end



function blockFullName = getBlockFullName( object )
obj = slreportgen.utils.getSlSfObject( object );
blockPath = mlreportgen.utils.normalizeString( obj.Path );
blockName = mlreportgen.utils.normalizeString( obj.Name );
blockFullName = slreportgen.utils.pathJoin( blockPath, blockName );
end
