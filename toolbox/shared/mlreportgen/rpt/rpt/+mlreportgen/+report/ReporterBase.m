classdef ( Abstract, Hidden )ReporterBase < mlreportgen.report.ReportForm & matlab.mixin.Copyable















    properties




















        TemplateSrc{ mustBeValidTemplateSrc( TemplateSrc ) } = [  ];






        TemplateName{ mustBeString( TemplateName ) } = [  ];











        LinkTarget{ mlreportgen.report.validators.mustBeLinkTarget( LinkTarget ) } = [  ];
    end

    properties ( SetAccess = protected, Hidden, NonCopyable )

        Impl = [  ];


        TargetReport = [  ];
    end

    properties ( Access = protected )




        CopyPtr = [  ];
    end

    methods
        function reporter = ReporterBase( varargin )
            setInformalArg( reporter, varargin{ : } );
        end

        function impl = getImpl( reporter, rpt )






            arguments
                reporter( 1, 1 )




                rpt( 1, 1 ){ validateReport( reporter, rpt ) }
            end

            if isempty( reporter.Impl )
                impl = getDocumentPart( reporter, rpt );
                reporter.TargetReport = rpt;
            else


                if reporter.TargetReport == rpt
                    impl = reporter.Impl;
                else
                    error( message( "mlreportgen:report:error:reporterAddedToReport",  ...
                        rpt.OutputPath, reporter.TargetReport.OutputPath ) );
                end
            end
        end

    end

    methods ( Hidden )
        function templatePath = getDefaultTemplatePath( reporter, rpt )
            templatePath = [  ];

            if ismethod( reporter, 'getClassFolder' )
                reporterPath = reporter.getClassFolder(  );
                templatePath =  ...
                    mlreportgen.report.ReportForm.getFormTemplatePath(  ...
                    reporterPath, rpt.Type );
            end
        end
    end

    methods ( Access = { ?mlreportgen.report.ReporterBase, ?mlreportgen.report.ReportBase }, Hidden )
        validateReport( ~, report )
    end

    methods ( Access = protected, Hidden )

        ctr = getImplCtr( ~ )

        function result = openImpl( reporter, impl, varargin )
            if isempty( varargin )
                result = open( impl );
            else
                key = varargin{ 1 };
                result = open( impl, key, reporter );
            end
        end

        function dp = getDocumentPart( reporter, rpt )
            dp = [  ];
            cacheTemplateSrc = false;

            [ templatePath, templateSrc ] = resolveTemplateSrc( reporter, rpt );


            if ~isempty( templatePath ) && isempty( templateSrc )
                templatePath = char( templatePath );

                if rpt.TemplateSrcCache.isKey( templatePath )
                    templateSrc = rpt.TemplateSrcCache( templatePath );
                    templatePath = [  ];
                else

                    cacheTemplateSrc = true;
                end
            end

            if isempty( templatePath ) && isempty( templateSrc )
                templatePath = getDefaultTemplatePath( reporter, rpt );
                reporter.TemplateSrc = templatePath;
            end

            if isempty( templatePath )
                if ~isempty( reporter.TemplateName )





                    ctr = getImplCtr( reporter );




                    if isempty( templateSrc )
                        templateSrc = rpt;
                    end

                    dp = ctr( templateSrc, reporter.TemplateName );
                    reporter.TemplateSrc = templateSrc;
                else
                    if ~isempty( templateSrc )
                        dp = mlreportgen.report.internal.DocumentPart( templateSrc.Type, templateSrc.TemplatePath );
                        reporter.TemplateSrc = templateSrc;
                    end
                end
            else
                type = rpt.Type;

                type = char( type );
                ctr = getImplCtr( reporter );
                if isempty( reporter.TemplateName )
                    dp = ctr( type, templatePath );
                else
                    dp = ctr( type, templatePath, reporter.TemplateName );
                end
                reporter.TemplateSrc = templatePath;
            end
            if ~isempty( dp )
                if isempty( rpt.Document )
                    open( rpt );
                end
                dp.Language = rpt.Document.Language;
                reporter.Impl = dp;
                updateImplTemplateName( reporter );
                if openImpl( reporter, dp )

                    if cacheTemplateSrc && isa( dp, 'mlreportgen.dom.Form' )
                        rpt.TemplateSrcCache( dp.TemplatePath ) = dp;
                    end



                    if ~isempty( reporter.LinkTarget )
                        if isa( reporter.LinkTarget, 'mlreportgen.dom.LinkTarget' )
                            domLinkTarget = reporter.LinkTarget;
                        else
                            domLinkTarget = mlreportgen.dom.LinkTarget( reporter.LinkTarget );
                        end

                        mlreportgen.report.internal.LockedForm.add(  ...
                            dp, rpt, domLinkTarget );
                    end

                    fillForm( reporter, dp, rpt );

                end
            end
        end

        function [ templatePath, templateSrc ] = resolveTemplateSrc( reporter, rpt )


            if ischar( reporter.TemplateSrc ) || isstring( reporter.TemplateSrc )

                templatePath = reporter.TemplateSrc;
                templateSrc = [  ];
            else

                if isa( reporter.TemplateSrc, 'mlreportgen.report.ReporterBase' )
                    if isempty( reporter.TemplateSrc.Impl )

                        [ templatePath, templateSrc ] =  ...
                            resolveTemplateSrc( reporter.TemplateSrc, rpt );
                    else

                        templatePath = [  ];
                        templateSrc = reporter.TemplateSrc.Impl;
                    end
                elseif isa( reporter.TemplateSrc, 'mlreportgen.report.ReportBase' )
                    templatePath = [  ];
                    if isempty( reporter.TemplateSrc.Document )
                        open( reporter.TemplateSrc );
                    end
                    templateSrc = reporter.TemplateSrc.Document;
                else

                    if isempty( reporter.TemplateSrc )
                        templatePath = getDefaultTemplatePath( reporter, rpt );
                        templateSrc = [  ];
                    else
                        templatePath = [  ];
                        templateSrc = reporter.TemplateSrc;
                    end
                end
            end
        end

        function processHole( reporter, form, rpt )

            if strcmp( form.CurrentHoleId( 1 ), '#' )
                if ~isa( form, 'mlreportgen.dom.PageHdrFtr' )
                    fillHeadersFooters( reporter, form, rpt );
                end
            else
                fillHole( reporter, form, rpt );
            end
        end

        function updateImplTemplateName( reporter )%#ok<MANU>
        end

        function chapterNumbered = isChapterNumberHierarchical( ~, rpt )



            chapterNumbered = [  ];
            sect1 = getContext( rpt, 'Section1' );
            if ~isempty( sect1 )


                chapterNumbered = sect1.Numbered;
            end



            if isempty( chapterNumbered )
                sectNumbered = getContext( rpt, 'OutlineLevelNumbered' );





                if isempty( sectNumbered )







                    level = getContext( rpt, 'OutlineLevel' );
                    if isempty( sect1 ) && isempty( level )
                        chapterNumbered = false;
                    else

                        chapterNumbered = true;
                    end
                else



                    chapterNumbered = sectNumbered( 1 );
                end
            end

        end







        function cpObj = copyElement( rptr )
            cpObj = copyElement@matlab.mixin.Copyable( rptr );


            rptr.CopyPtr = cpObj;
            cleanupVar = onCleanup( @(  )set( [ rptr, cpObj ], "CopyPtr", [  ] ) );



            props = properties( rptr );
            nProps = length( props );
            for i = 1:nProps
                prop = props{ i };
                copiedVal = getCopiedVal( rptr, cpObj, rptr.( prop ) );
                if ~isempty( copiedVal )
                    cpObj.( prop ) = copiedVal;
                end
            end
        end

    end

    methods ( Access = private, Sealed = true )




        function copiedVal = getCopiedVal( rptr, cpObj, propVal )


            copiedVal = [  ];
            if iscell( propVal )

                nElems = numel( propVal );
                copiedVal = propVal;
                for k = 1:nElems
                    newVal = getCopiedVal( rptr, cpObj, propVal{ k } );
                    if ~isempty( newVal )
                        copiedVal{ k } = newVal;
                    end
                end
            elseif isa( propVal, "mlreportgen.report.ReporterBase" )

                nElems = numel( propVal );
                copiedVal = propVal;
                for k = 1:nElems
                    elem = propVal( k );




                    if isempty( elem.CopyPtr )
                        copiedVal( k ) = copy( elem );
                    else
                        copiedVal( k ) = elem.CopyPtr;
                    end
                end
            elseif isa( propVal, "mlreportgen.dom.Object" )

                nElems = numel( propVal );
                copiedVal = propVal;
                for k = 1:nElems
                    copiedVal( k ) = clone( propVal( k ) );
                end
            elseif isa( propVal, "mlreportgen.report.Layout" )

                layout = copy( propVal );
                layout.Owner = cpObj;
                copiedVal = layout;
            end
        end
    end

    methods ( Static )

        function translation = getTranslation( translations, locale )







            if isempty( locale )
                locale = get( 0, 'Language' );
            end

            translation = findTranslation( translations, locale );

            if isempty( translation )

                translation = findTranslation( translations, 'en' );
            end
        end

        function translations = parseTranslation( classFolder, filename )





















            fileToParse = fullfile( classFolder, 'resources', 'translations', filename );

            xmlparser = matlab.io.xml.dom.Parser(  );
            xmldoc = parseFile( xmlparser, fileToParse );

            translations = containers.Map;

            localeElements = xmldoc.getElementsByTagName( 'locale' );
            translationLength = localeElements.getLength(  );

            for i = 0:translationLength - 1
                localeElement = localeElements.item( i );
                translationStruct = struct( 'Locale', char( localeElement.getAttribute( 'id' ) ) );
                childField = localeElement.getFirstChild(  );
                while ~isempty( childField )

                    if childField.getNodeType == 1 && "tr" == string( childField.getTagName )
                        translationStruct.( char( childField.getAttribute( 'id' ) ) ) = string( childField.getTextContent );
                    end
                    childField = childField.getNextSibling(  );
                end
                translations( translationStruct.Locale ) = translationStruct;
            end

        end

    end

    methods ( Static, Hidden )


        function idx = getPropertySetIdx( propertyName, list )
            idx = [  ];
            for ind = 1:2:length( list )
                if strcmp( list{ ind }, propertyName )
                    idx = ind;
                    break ;
                end
            end
        end

        function isSet = isPropertySet( propertyName, list )
            isSet = false;
            for ind = 1:2:length( list )
                if strcmp( list{ ind }, propertyName )
                    isSet = true;
                    break ;
                end
            end
        end

        function isInline = isInlineContent( content, varargin )
            isInline = false;

            mustBeSingleValue = ~isempty( varargin ) && varargin{ 1 };
            if mustBeSingleValue
                if ischar( content )
                    isInline = numel( string( content ) ) == 1;
                else
                    if numel( content ) == 1
                        isInline = isstring( content ) ||  ...
                            ( isa( content, 'mlreportgen.dom.Element' ) &&  ...
                            isInlineCompatible( content ) );
                    end
                end
            else
                if isvector( content )
                    if iscell( content )
                        len = length( content );
                        for i = 1:len
                            isInline = mlreportgen.report.ReporterBase.isInlineContent( content{ i }, false );
                            if ~isInline
                                return
                            end
                        end
                    else
                        if ischar( content )
                            str = string( content );
                            if numel( str ) > 1
                                for item = content
                                    isInline = mlreportgen.report.ReporterBase.isInlineContent( item, false );
                                    if ~isInline
                                        return
                                    end
                                end
                            else
                                isInline = true;
                            end
                        else
                            if numel( content ) > 1
                                len = numel( content );
                                for i = 1:len
                                    isInline = mlreportgen.report.ReporterBase.isInlineContent( content( i ), false );
                                    if ~isInline
                                        return
                                    end
                                end
                            else
                                isInline = isstring( content ) ||  ...
                                    ( isa( content, 'mlreportgen.dom.Element' ) &&  ...
                                    isInlineCompatible( content ) );
                            end
                        end

                    end
                end
            end
        end
    end
end


function translation = findTranslation( translations, locale )

translation = [  ];

if isstring( locale )
    locale = char( locale );
end

if isKey( translations, locale )
    translation = translations( locale );
else
    if length( locale ) > 2
        locale = locale( 1:2 );
        if isKey( translations, locale )
            translation = translations( locale );
        end
    end
end
end


function E = createValidatorException( errorID, varargin )
messageObject = message( errorID, varargin{ 1:end  } );
E = MException( errorID, messageObject.getString );
end

function mustBeString( varargin )
mlreportgen.report.validators.mustBeString( varargin{ : } );
end

function mustBeValidTemplateSrc( value )
if ~( ( isnumeric( value ) && isempty( value ) ) ||  ...
        ( ischar( value ) && ~isempty( value ) ) ||  ...
        ( isstring( value ) && numel( value ) == 1 && "" ~= value ) ||  ...
        ( isa( value, 'mlreportgen.report.ReportBase' ) ) ||  ...
        ( isa( value, 'mlreportgen.report.ReporterBase' ) ) ||  ...
        ( isa( value, 'mlreportgen.dom.Form' ) ) )
    throw( createValidatorException( 'mlreportgen:report:validators:mustBeValidTemplateSrc' ) );
end
end

