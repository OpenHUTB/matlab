classdef SimulinkObjectProperties < slreportgen.report.ObjectPropertiesBase











































































    properties






























        Object{ slreportgen.report.validators.mustBeSimulinkObject( Object ) } = [  ];






        ShowPromptNames{ mlreportgen.report.validators.mustBeLogical } = true;

    end

    properties ( Access = protected )


        HierNumberedTitleTemplateName = "SimulinkObjPropHierNumberedTitle";
        NumberedTitleTemplateName = "SimulinkObjPropNumberedTitle"
        ParaStyleName = "SimulinkObjectPropertiesScript";
    end


    methods

        function simulinkObjectProperties = SimulinkObjectProperties( varargin )
            if nargin == 1
                varargin = [ { "Object" }, varargin ];
            end
            simulinkObjectProperties =  ...
                simulinkObjectProperties@slreportgen.report.ObjectPropertiesBase( varargin{ : } );

            if ~mlreportgen.report.ReporterBase.isPropertySet( "PropertyTable", varargin )
                defaultTable = mlreportgen.report.BaseTable;
                defaultTable.TableStyleName = "SimulinkObjectPropertiesContent";
                defaultTable.TableWidth = '100%';
                simulinkObjectProperties.PropertyTable = defaultTable;
            end

            if ( isempty( simulinkObjectProperties.TemplateName ) )
                simulinkObjectProperties.TemplateName = 'SimulinkObjectProperties';
            end

        end

        function impl = getImpl( simulinkObjectProperties, rpt )
            arguments
                simulinkObjectProperties( 1, 1 )
                rpt( 1, 1 ){ validateReport( simulinkObjectProperties, rpt ) }
            end

            if isempty( simulinkObjectProperties.Object )
                error( message( "slreportgen:report:error:noSimulinkObjectSourceSpecified" ) );
            else

                if isempty( simulinkObjectProperties.LinkTarget ) && ~isempty( simulinkObjectProperties.Object )
                    makeLinkTarget = false;







                    objH = slreportgen.utils.getSlSfHandle( simulinkObjectProperties.Object );
                    obj = slreportgen.utils.getSlSfObject( objH );

                    parentPath = slreportgen.utils.getParent( obj );

                    if ~isempty( parentPath )
                        parentPath = strrep( parentPath, newline, ' ' );
                        parentDiagram = getContext( rpt, parentPath );
                        if ~isempty( parentDiagram )
                            if slreportgen.utils.isMaskedSystem( simulinkObjectProperties.Object )
                                if strcmp( parentDiagram.MaskedSystemLinkPolicy, "default" )
                                    makeLinkTarget = isValidTarget( simulinkObjectProperties );
                                elseif strcmp( parentDiagram.MaskedSystemLinkPolicy, "block" )
                                    makeLinkTarget = true;
                                end
                            else
                                makeLinkTarget = isValidTarget( simulinkObjectProperties );
                            end
                        end
                    end

                    if makeLinkTarget
                        simulinkObjectProperties.LinkTarget = slreportgen.utils.getObjectID( simulinkObjectProperties.Object );
                    end

                end
                impl = getImpl@slreportgen.report.ObjectPropertiesBase( simulinkObjectProperties, rpt );
            end
        end
    end

    methods ( Access = protected )

        function content = getTableContent( simulinkObjectProperties, rpt )
            if ischar( simulinkObjectProperties.Object ) || isstring( simulinkObjectProperties.Object )
                handle = get_param( simulinkObjectProperties.Object, "Handle" );
            else
                handle = simulinkObjectProperties.Object;
            end

            compileModel( rpt, handle );

            try

                objType = slreportgen.utils.getObjectType( handle );
                if strcmp( objType, 'TruthTable' ) || strcmp( objType, 'MATLABFunction' ) || strcmp( objType, 'StateTransitionTableBlock' )
                    objType = 'Block';
                end

                dialogParam = getReportedProperties( simulinkObjectProperties, handle, objType );

            catch
                content = [  ];
                return ;
            end


            nParams = numel( dialogParam );
            content = cell( nParams, 2 );
            emptyVals = false( nParams, 1 );
            for i = 1:nParams

                propName = dialogParam{ i };
                returnRawValue = false;
                [ propVal, propName, emptyVals( i ) ] = getObjectProperty( simulinkObjectProperties, handle,  ...
                    objType, propName, returnRawValue );


                if simulinkObjectProperties.ShowPromptNames
                    dialogPropName = '';
                    try
                        dParam = get_param( handle, 'dialogparameters' );
                        if isfield( dParam, propName )
                            dialogPropName = dParam.( char( propName ) ).( 'Prompt' );
                            dialogPropName = strrep( dialogPropName, ':', '' );
                        end
                    catch

                    end

                    if ~isempty( dialogPropName )
                        propName = dialogPropName;
                    end
                end

                content{ i, 1 } = propName;
                content{ i, 2 } = propVal;
            end


            if ~simulinkObjectProperties.ShowEmptyValues && nParams > 0
                content = content( ~emptyVals, : );
            end
        end

        function titleContent = getTableTitleString( simulinkObjectProperties )
            objH = slreportgen.utils.getSlSfHandle( simulinkObjectProperties.Object );
            obj = slreportgen.utils.getSlSfObject( objH );
            switch ( obj.Type )
                case 'annotation'
                    objPath = strrep( obj.Path, newline, ' ' );
                    titleContent = string( objPath ) + "/" + mlreportgen.utils.getFirstLine( obj.Name ) + " Properties";
                case 'port'
                    objParent = strrep( obj.Parent, newline, ' ' );
                    titleContent = string( objParent ) + " " + mlreportgen.utils.capitalizeFirstChar( obj.PortType ) + ":" + obj.PortNumber + " Properties";
                case { 'block', 'block_diagram' }
                    objPath = strrep( obj.Path, newline, ' ' );
                    objName = strrep( obj.Name, newline, ' ' );
                    titleContent = string( objPath ) + "/" + string( objName ) + " Properties";
                case 'line'
                    parentPath = get_param( obj.Handle, 'Parent' );
                    parentPath = strrep( parentPath, newline, ' ' );
                    srcPortHandle = get_param( obj.Handle, 'SrcPortHandle' );
                    portNum = get_param( srcPortHandle, 'PortNumber' );
                    parentName = strrep( get_param( get_param( srcPortHandle, 'Parent' ), 'Name' ),  ...
                        newline, ' ' );
                    objectName = sprintf( '%s<%i>', parentName, portNum );
                    titleContent = string( parentPath ) + "/" + objectName + " Line Properties";
                otherwise
                    titleContent = "Simulink Object Properties";
            end
        end

    end

    methods ( Access = { ?slreportgen.report.SimulinkObjectProperties, ?slreportgen.finder.DiagramElementResult } )
        function props = getReportedProperties( simulinkObjectProperties, handle, objType )
            if isempty( simulinkObjectProperties.Properties )

                props = "Type";
                if strcmp( objType, 'Block' )
                    props = [ props, "Block Type" ];
                end
                dialogParams = slreportgen.utils.getSimulinkObjectParameters( handle, objType );
                dialogParams = updateModelReferenceBlkParameters( objType, dialogParams );
                props = [ props, string( dialogParams( : ) )' ];
            else

                props = simulinkObjectProperties.Properties;
            end
        end

        function [ val, propName, isEmptyVal ] = getObjectProperty( simulinkObjectProperties, handle, objType, propName, returnRawVal )
            if strcmpi( propName, "type" )
                val = objType;
            elseif ( strcmp( objType, 'ModelReference' ) &&  ...
                    ( strcmp( propName, 'ParameterArgumentValues' ) ) )
                val = getInstanceSpecificParameters( handle, propName );
            else

                normPropName = strrep( propName, " ", "" );

                val = objectPropertyValue( simulinkObjectProperties, handle, normPropName );
                objType = get_param( handle, 'type' );

                if strcmp( objType, 'line' ) && ( strcmp( normPropName, 'SrcPortHandle' ) ||  ...
                        strcmp( normPropName, 'SrcBlockHandle' ) ||  ...
                        strcmp( normPropName, 'DstPortHandle' ) ||  ...
                        strcmp( normPropName, 'DstBlockHandle' ) )
                    [ propName, val ] = getLinePropValue( simulinkObjectProperties, propName, val );
                end
            end

            isEmptyVal = isEmptyPropValue( simulinkObjectProperties, val );


            if ~returnRawVal && ( ~isEmptyVal || simulinkObjectProperties.ShowEmptyValues )
                val = formatPropertyValue( val );
            end

            if iscell( val ) && isempty( val{ 1 } ) || isempty( val )
                val = '';
            end
        end
    end

    methods ( Access = protected, Hidden )

        result = openImpl( reporter, impl, varargin )
    end


    methods ( Static )
        function path = getClassFolder(  )

            [ path ] = fileparts( mfilename( 'fullpath' ) );
        end

        function template = createTemplate( templatePath, type )








            path = slreportgen.report.SimulinkObjectProperties.getClassFolder(  );
            template = mlreportgen.report.ReportForm.createFormTemplate(  ...
                templatePath, type, path );
        end

        function classfile = customizeReporter( toClasspath )













            classfile = mlreportgen.report.ReportForm.customizeClass( toClasspath,  ...
                "slreportgen.report.SimulinkObjectProperties" );
        end

    end

    methods ( Access = protected )



        function isTarget = isValidTarget( simulinkObjectProperties )
            isTarget = false;
            objType = slreportgen.utils.getObjectType( simulinkObjectProperties.Object );
            if strcmp( objType, 'Block' ) ||  ...
                    strcmp( objType, 'TruthTable' ) ||  ...
                    strcmp( objType, 'MATLABFunction' ) ||  ...
                    strcmp( objType, 'StateTransitionTableBlock' )
                isTarget = true;
            end
        end
    end

    methods ( Access = private )
        function bValue = objectPropertyValue( simulinkObjectProperties, handle, blockParameter )
            try
                switch ( string( blockParameter ) )
                    case "Script"
                        bValue = locScript( simulinkObjectProperties, handle );
                    case "Chart"
                        bValue = locChart( simulinkObjectProperties, handle );
                    case { "UpdateMethod(TT)", "SampleTime(TT)" }
                        bValue = locTruthTableParams( simulinkObjectProperties, handle, char( blockParameter ) );
                    otherwise
                        bValue = mlreportgen.utils.safeGet( handle, char( blockParameter ), "get_param" );
                        if iscell( bValue ) &&  ...
                                length( bValue ) == 1 &&  ...
                                ischar( bValue{ 1 } ) &&  ...
                                strcmp( 'N/A', bValue{ 1 } )
                            bValue = mlreportgen.utils.safeGet( handle, char( blockParameter ), "get" );
                        end
                end
            catch
                bValue = 'N/A';
            end
        end

        function [ propertyName, propertyValue ] = getLinePropValue( ~, propName, propValue )
            switch propName
                case 'SrcPortHandle'
                    propertyName = 'SrcPortNumber';
                    propertyValue = get_param( propValue{ 1 }, 'PortNumber' );
                case 'SrcBlockHandle'
                    propertyName = 'SrcBlockPath';
                    propertyValue = getfullname( propValue{ 1 } );
                case 'DstPortHandle'
                    propertyName = 'DstPortNumber';
                    propertyValue = get_param( propValue{ 1 }, 'PortNumber' );
                case 'DstBlockHandle'
                    propertyName = 'DstBlockPath';
                    propertyValue = getfullname( propValue{ 1 } );
                otherwise
                    propertyName = '';
                    propertyValue = '';
            end
        end

        function pValue = locScript( simulinkObjectProperties, objList )

            if ischar( objList )
                objList = { objList };
            else
                objList = { getfullname( objList ) };

            end

            nObj = length( objList );
            pValue = [  ];
            for i = nObj: - 1:1
                emlFcn = slreportgen.utils.block2chart( objList{ i } );
                script = emlFcn.Script;
                if iscell( script )
                    script = script{ 1 };
                end
                para = mlreportgen.dom.Paragraph( script );
                para.StyleName = simulinkObjectProperties.ParaStyleName;
                para.WhiteSpace = "preserve";

                if isempty( pValue )
                    pValue = para;
                else
                    pValue( end  + 1 ) = para;%#ok<AGROW>
                end

            end

        end

        function pValue = locChart( ~, objList )
            if ischar( objList )
                objList = { objList };
            else
                objList = { getfullname( objList ) };
            end
            nObj = length( objList );
            for i = nObj: - 1:1
                sfChart = slreportgen.utils.block2chart( objList{ i } );
                pValue{ i, 1 } = sfChart.Name;

            end

        end

        function pValue = locTruthTableParams( ~, objList, propName )

            if ischar( objList )
                objList = { objList };

            else
                objList = { getfullname( objList ) };
            end
            nObj = length( objList );

            for i = nObj: - 1:1
                ttObj = slreportgen.utils.block2chart( char( objList{ i } ) );

                switch propName
                    case "UpdateMethod(TT)"
                        pValue{ i, 1 } = ttObj.ChartUpdate;
                    case "SampleTime(TT)"
                        sampleTime = ttObj.SampleTime;
                        if isempty( sampleTime )
                            sampleTime = "-1";
                        end
                        pValue{ i, 1 } = sampleTime;
                end

            end

        end
    end
end

function para = formatPropertyValue( propVal )

blockDialogValueType = class( propVal );
switch blockDialogValueType
    case 'cell'

        value = char( mlreportgen.utils.toString( propVal ) );



        if ( ~isempty( value ) )
            if strcmp( value( 1 ), '{' ) && strcmp( value( end  ), '}' )
                value( 1 ) = '';
                value( end  ) = '';
                value = strtrim( value );
            end
        end
        para = mlreportgen.dom.Paragraph( string( value ) );
        para.WhiteSpace = "preserve";

    case 'mlreportgen.dom.Paragraph'
        para = propVal;
    case 'mlreportgen.dom.FormalTable'
        para = propVal;
    otherwise
        para = string( propVal );
end
end



function dialogParameters = updateModelReferenceBlkParameters( objType, dialogParameters )
if strcmp( objType, 'ModelReference' )
    idx = strcmp( dialogParameters, 'ParameterArgumentValuesAsString' );
    dialogParameters( idx ) = [  ];
    idx = strcmp( dialogParameters, 'InstanceParameters' );
    dialogParameters( idx ) = [  ];
end
end



function blockDialogValue = getInstanceSpecificParameters( handle, ~ )


bValue = mlreportgen.utils.safeGet( handle, "InstanceParameters", "get_param" );
blockDialogValue = [  ];
if ~isempty( bValue{ 1 } )
    formalTable = mlreportgen.dom.FormalTable(  );




    formalTable.Width = '100%';
    formalTable.RowSep = 'Solid';
    formalTable.ColSep = 'Solid';
    formalTable.RowSepWidth = '1px';
    formalTable.ColSepWidth = '1px';
    formalTable.StyleName = "SimulinkObjectPropertiesModelRefBlkInstanceTableStyle";

    instanceSpecificParameterValues = bValue{ 1 };


    tableRow = mlreportgen.dom.TableRow(  );
    tableEntry = mlreportgen.dom.TableHeaderEntry(  );
    para = mlreportgen.dom.Paragraph(  );
    para.WhiteSpace = "preserve";
    append( para, mlreportgen.dom.LineBreak(  ) );
    append( para, "Path" );
    append( tableEntry, para );
    append( tableRow, tableEntry );
    tableEntry = mlreportgen.dom.TableHeaderEntry(  );


    tableEntry.Style = [ tableEntry.Style, { mlreportgen.dom.Width( '35%' ) } ];
    para = mlreportgen.dom.Paragraph(  );
    para.WhiteSpace = 'preserve';
    append( para, "Model" );
    append( para, mlreportgen.dom.LineBreak(  ) );
    append( para, "Parameter" );
    append( tableEntry, para );
    append( tableRow, tableEntry );
    tableEntry = mlreportgen.dom.TableHeaderEntry(  );
    tableEntry.Style = [ tableEntry.Style, { mlreportgen.dom.Width( '20%' ) } ];
    para = mlreportgen.dom.Paragraph(  );
    para.WhiteSpace = "preserve";
    append( para, mlreportgen.dom.LineBreak(  ) );
    append( para, "Value" );
    append( tableEntry, para );
    append( tableRow, tableEntry );
    append( formalTable.Header, tableRow );


    for i = 1:length( instanceSpecificParameterValues )
        tableRow = mlreportgen.dom.TableRow(  );
        para = mlreportgen.dom.Paragraph(  );
        lenOfFullPath = instanceSpecificParameterValues( i ).Path.getLength;
        if ( lenOfFullPath > 0 )
            para = mlreportgen.dom.Paragraph(  );
            para.WhiteSpace = 'preserve';

            lengthOfBlockPaths = instanceSpecificParameterValues( i ).Path.getLength;
            for ind = 1:lengthOfBlockPaths - 1
                append( para, mlreportgen.utils.normalizeString( instanceSpecificParameterValues( i ).Path.getBlock( ind ) ) );
                append( para, mlreportgen.dom.LineBreak(  ) );
            end
            append( para, mlreportgen.utils.normalizeString( instanceSpecificParameterValues( i ).Path.getBlock( lengthOfBlockPaths ) ) );
        else
            append( para, " " );
        end
        tableEntry = mlreportgen.dom.TableEntry(  );
        append( tableEntry, para );
        append( tableRow, tableEntry );

        tableEntry = mlreportgen.dom.TableEntry(  );
        append( tableEntry, instanceSpecificParameterValues( i ).Name );
        append( tableRow, tableEntry );

        tableEntry = mlreportgen.dom.TableEntry(  );
        append( tableEntry, instanceSpecificParameterValues( i ).Value );
        append( tableRow, tableEntry );

        append( formalTable.Body, tableRow );
    end
    blockDialogValue = formalTable;
end
end

