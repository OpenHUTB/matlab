classdef ( Sealed )FiMetaType < codergui.internal.type.MetaType

    properties ( Constant, Access = private )
        NT_CATEGORY = message( 'coderApp:metaTypes:categoryNumericType' )
        FIMATH_CATEGORY = message( 'coderApp:metaTypes:categoryFimath' )
        NT_ATTR_STRUCT = createNtAttrDefs(  )
        FM_ATTR_STRUCT = createFimathAttrDefs(  )

        NumericTypeProperties cell = codergui.internal.type.FiMetaType.NT_ATTR_STRUCT.props
        NumericTypeAttributes codergui.internal.type.AttributeDef = codergui.internal.type.FiMetaType.NT_ATTR_STRUCT.attrs
        FimathProperties cell = codergui.internal.type.FiMetaType.FM_ATTR_STRUCT.props
        FimathAttributes codergui.internal.type.AttributeDef = codergui.internal.type.FiMetaType.FM_ATTR_STRUCT.attrs
        SpecifyAttribute codergui.internal.type.AttributeDef = codergui.internal.type.AttributeDef(  ...
            'fi_specifyFimath', codergui.internal.ui.ValueTypes.Boolean,  ...
            'Name', message( 'coderApp:metaTypes:attrSpecifyFimath' ),  ...
            'Description', message( 'coderApp:metaTypes:attrSpecifyFimathDesc' ),  ...
            'Value', false )
    end

    properties ( SetAccess = immutable )
        Id char = 'metatype.fi'
        CustomAttributes
    end

    methods
        function this = FiMetaType(  )
            this.CustomAttributes = [
                this.SpecifyAttribute,  ...
                this.NumericTypeAttributes,  ...
                this.FimathAttributes,  ...
                codergui.internal.type.AttributeDefs.Complex ...
                ];
        end

        function supported = isSupported( ~ )
            supported = ~isempty( which( 'fimath' ) ) && license( 'test', 'Fixed_Point_Toolbox' );
        end
    end

    methods ( Access = { ?codergui.internal.type.MetaType, ?codergui.internal.type.TypeMakerNode } )
        function applyToNode( this, node )
            this.initAttrsFromFimath( node, globalfimath(  ) );
            this.updateAttrVisibility( node );
        end

        function coderType = toCoderType( this, node, ~ )
            [ sz, varDims ] = node.Size.toNewTypeArgs(  );
            nt = this.toNumericType( node );

            extraArgs = {  };
            [ complex, specify ] = node.multiGet( [  ...
                codergui.internal.type.AttributeDefs.Complex, this.SpecifyAttribute ],  ...
                'value', 'deal' );
            if complex
                extraArgs( end  + 1:end  + 2 ) = { 'complex', true };
            end
            if specify
                extraArgs( end  + 1:end  + 2 ) = { 'fimath', this.toFimath( node ) };
            end

            coderType = coder.newtype( 'embedded.fi', nt, sz, varDims, extraArgs{ : } );
        end

        function fromCoderType( this, node, coderType )
            node.Size = codergui.internal.type.Size( coderType.SizeVector, coderType.VariableDims );
            this.initAttrsFromNumericType( node, coderType.NumericType );

            if coderType.Complex
                node.set( codergui.internal.type.AttributeDefs.Complex, true );
            end

            node.set( this.SpecifyAttribute, ~isempty( coderType.Fimath ) );
            if ~isempty( coderType.Fimath )
                this.initAttrsFromFimath( node, coderType.Fimath );
            else
                this.initAttrsFromFimath( node, globalfimath(  ) );
            end
        end

        function code = toCode( this, node, varName, ~ )
            [ sz, varDims ] = node.Size.toNewTypeArgs( true );
            nt = this.toNumericType( node );
            fm = this.toFimath( node );

            extraArgs = {  };
            [ complex, specify ] = node.multiGet( [  ...
                codergui.internal.type.AttributeDefs.Complex, this.SpecifyAttribute ],  ...
                'value', 'deal' );
            if specify
                extraArgs( end  + 1:end  + 2 ) = { '''fimath''', formatFiToString( fm.tostring(  ) ) };
            end
            if complex
                extraArgs( end  + 1:end  + 2 ) = { '''complex''', 'true' };
            end

            code = sprintf( '%s = coder.newtype(''embedded.fi'', %s, %s, %s%s);\n',  ...
                varName, formatFiToString( nt.tostring(  ) ), sz, varDims, strjoin( strcat( { ', ' }, extraArgs ), '' ) );
        end

        function mf0 = toMF0( this, node, model, ~ )
            mf0 = coderapp.internal.codertype.FiType( model );
            mf0.NumericType = coderapp.internal.codertype.NumericType( model );
            mf0.Size = node.Size.toMfzDims(  );

            [ complex, specify ] = node.multiGet( [  ...
                codergui.internal.type.AttributeDefs.Complex, this.SpecifyAttribute ],  ...
                'value', 'deal' );
            if complex
                mf0.Complex = true;
            end

            if specify
                fm = this.toFimath( node );
                mf0.FiMath = coderapp.internal.codertype.FiMath( model );



                flds = fieldnames( fm );
                for i = 1:numel( flds )
                    mf0.FiMath.( flds{ i } ) = fm.( flds{ i } );
                end
            end

            nt = this.toNumericType( node );
            flds = fieldnames( nt );
            for i = 1:numel( flds )
                mf0.NumericType.( flds{ i } ) = nt.( flds{ i } );
            end
        end

        function class = fromMF0( this, node, mf0 )
            function pv = getProps( obj )
                pv = {  };
                props = properties( obj );
                for i = 1:numel( props )
                    pv{ end  + 1 } = props{ i };%#ok<AGROW>
                    pv{ end  + 1 } = obj.( pv{ end  } );%#ok<AGROW>
                end
            end

            class = 'embedded.fi';
            node.Size = codergui.internal.type.Size( mf0.Size );
            ntProps = getProps( mf0.NumericType );
            this.initAttrsFromNumericType( node, numerictype( ntProps{ : } ) );

            if mf0.Complex
                node.set( codergui.internal.type.AttributeDefs.Complex, true );
            end

            node.set( this.SpecifyAttribute, ~isempty( mf0.FiMath ) );
            if ~isempty( mf0.FiMath )
                fmProps = getProps( mf0.FiMath );
                this.initAttrsFromFimath( node, fimath( fmProps{ : } ) );
            else
                this.initAttrsFromFimath( node, globalfimath(  ) );
            end
        end

        function validateNode( this, node )
            this.updateAttrVisibility( node );
        end
    end

    methods ( Access = private )
        function initAttrsFromFimath( this, node, fm )
            this.applyObjectValuesToAttrs( node, this.FimathAttributes, this.FimathProperties, fm );
        end

        function initAttrsFromNumericType( this, node, fm )
            this.applyObjectValuesToAttrs( node, this.NumericTypeAttributes,  ...
                this.NumericTypeProperties, fm );
        end

        function fm = toFimath( this, node )
            fm = this.applyAttrsToObject( node, this.FimathAttributes, this.FimathProperties, fimath(  ) );
        end

        function nt = toNumericType( this, node )
            nt = this.applyAttrsToObject( node, this.NumericTypeAttributes,  ...
                this.NumericTypeProperties, numerictype(  ) );
        end

        function updateAttrVisibility( this, node )
            this.updateNtAttrVisibility( node );
            this.updateFimathAttrVisibility( node );
        end

        function updateNtAttrVisibility( ~, node )



            dtMode = node.get( 'fi_dataTypeMode' );
            showSignedness = true;
            showWordLen = true;
            showFracLen = false;
            showSlope = false;
            showBias = false;

            switch dtMode
                case { 'Single', 'Double', 'Boolean' }
                    showSignedness = false;
                    showWordLen = false;
                case { 'Fixed-point: binary point scaling', 'Scaled double: binary point scaling' }
                    showFracLen = true;
                case { 'Fixed-point: slope and bias scaling', 'Scaled double: slope and bias scaling' }
                    showSlope = true;
                    showBias = true;
            end

            showDto = dtMode ~= "Boolean" && node.get( 'fi_dataTypeOverride' ) ~= "Inherit";
            applyAttrVisibility( node.attr(  ...
                { 'fi_signedness', 'fi_wordLength', 'fi_fractionLength', 'fi_slope', 'fi_bias', 'fi_dataTypeOverride' } ),  ...
                [ showSignedness, showWordLen, showFracLen, showSlope, showBias, showDto ] );
        end

        function updateFimathAttrVisibility( this, node )


            [ specify, productMode, sumMode ] = node.multiGet(  ...
                { this.SpecifyAttribute.Key, 'fi_productMode', 'fi_sumMode' }, 'value', 'deal' );

            showables = this.FimathAttributes( 1:end  - 2 );
            applyAttrVisibility( node.attr( showables ),  ...
                repmat( specify, size( showables ) ) );
            if ~specify
                return
            end

            showMaxProdWl = false;
            showProdWl = false;
            showProdSlope = false;
            showProdSlopeAdjust = false;
            showProdBias = false;
            showProdFl = false;

            switch productMode
                case 'FullPrecision'
                    showMaxProdWl = true;
                case { 'KeepLSB', 'KeepMSB' }
                    showProdWl = true;
                case 'SpecifyPrecision'
                    showProdWl = true;
                    [ prodBias, prodSlopeAdust ] = node.multiGet(  ...
                        { 'fi_productBias', 'fi_productSlopeAdjustmentFactor',  }, 'value', 'deal' );
                    if prodSlopeAdust ~= 1 || prodBias ~= 0
                        showProdSlopeAdjust = true;
                        showProdBias = true;
                    else
                        showProdFl = true;
                    end
            end

            prodAttrs = node.attr( { 'fi_maxProductWordLength', 'fi_productWordLength', 'fi_productSlope',  ...
                'fi_productSlopeAdjustmentFactor', 'fi_productBias', 'fi_productFractionLength' } );
            prodVisible = [ showMaxProdWl, showProdWl, showProdSlope, showProdSlopeAdjust,  ...
                showProdBias, showProdFl ];
            applyAttrVisibility( prodAttrs, prodVisible );

            showMaxSumWl = false;
            showSumWl = false;
            showSumSlope = false;
            showSumSlopeAdjust = false;
            showSumBias = false;
            showSumFl = false;
            showCastBeforeSum = true;
            switch sumMode
                case 'FullPrecision'
                    showMaxSumWl = true;
                    showCastBeforeSum = false;
                case { 'KeepLSB', 'KeepMSB' }
                    showSumWl = true;
                case 'SpecifyPrecision'
                    showSumWl = true;
                    [ sumBias, sumSlopeAdjust ] = node.multiGet(  ...
                        { 'fi_sumBias', 'fi_sumSlopeAdjustmentFactor',  }, 'value', 'deal' );
                    if sumSlopeAdjust ~= 1 || sumBias ~= 0
                        showSumSlopeAdjust = true;
                        showSumBias = true;
                    else
                        showSumFl = true;
                    end
            end

            sumAttrs = node.attr( { 'fi_maxSumWordLength', 'fi_sumWordLength', 'fi_sumSlope',  ...
                'fi_productSlopeAdjustmentFactor', 'fi_sumBias', 'fi_sumFractionLength',  ...
                'fi_castBeforeSum' } );
            sumVisible = [ showMaxSumWl, showSumWl, showSumSlope, showSumSlopeAdjust,  ...
                showSumBias, showSumFl, showCastBeforeSum ];
            applyAttrVisibility( sumAttrs, sumVisible );
        end
    end

    methods ( Static, Access = private )
        function applyObjectValuesToAttrs( node, attrDefs, props, object )
            attrVals = cell( 1, numel( props ) );
            for i = 1:numel( props )
                attrVals{ i } = object.( props{ i } );
            end
            node.multiSet( attrDefs, attrVals );
        end

        function object = applyAttrsToObject( node, attrDefs, props, object )
            values = node.multiGet( attrDefs, 'value' );
            visible = node.multiGet( attrDefs, 'IsVisible' );

            for i = 1:numel( props )
                try
                    if visible{ i }
                        object.( props{ i } ) = values{ i };
                    end
                catch me %#ok<NASGU>


                end
            end
        end
    end

    methods ( Static, Hidden )
        function applyNumericTypeProperties( node, nt )
            arguments
                node( 1, 1 )codergui.internal.type.TypeMakerNode
                nt( 1, 1 ){ mustBeA( nt, 'embedded.numerictype' ) }
            end

            invokeMultiSet( node, nt, codergui.internal.type.FiMetaType.NT_ATTR_STRUCT );
        end

        function applyFimathProperties( node, fm )
            arguments
                node( 1, 1 )codergui.internal.type.TypeMakerNode
                fm( 1, 1 )embedded.fimath
            end

            invokeMultiSet( node, fm, codergui.internal.type.FiMetaType.FM_ATTR_STRUCT );
        end
    end
end


function result = createNtAttrDefs(  )
import codergui.internal.type.AttributeDef;
import codergui.internal.ui.ValueTypes;


ntCategory = codergui.internal.type.FiMetaType.NT_CATEGORY;
maxValue = double( intmax( 'uint16' ) );
ntAttrs = {
    AttributeDef( 'fi_signedness', ValueTypes.Text,  ...
    'Name', message( 'coderApp:metaTypes:attrSignedness' ),  ...
    'Description', message( 'coderApp:metaTypes:attrSignednessDesc' ),  ...
    'Category', ntCategory,  ...
    'Value', 'Signed',  ...
    'AllowedValues', { 'Signed', 'Unsigned' } ), 'Signedness'
    AttributeDef( 'fi_wordLength', ValueTypes.PositiveInteger,  ...
    'Name', message( 'coderApp:metaTypes:attrWordLength' ),  ...
    'Description', message( 'coderApp:metaTypes:attrWordLengthDesc' ),  ...
    'Category', ntCategory,  ...
    'Value', 16,  ...
    'Min', 1,  ...
    'Max', maxValue ), 'WordLength'
    AttributeDef( 'fi_fractionLength', ValueTypes.Integer,  ...
    'Name', message( 'coderApp:metaTypes:attrFractionLength' ),  ...
    'Description', message( 'coderApp:metaTypes:attrFractionLengthDesc' ),  ...
    'Category', ntCategory,  ...
    'Value', 15,  ...
    'Min',  - maxValue,  ...
    'Max', maxValue ), 'FractionLength'
    AttributeDef( 'fi_dataTypeMode', ValueTypes.Text,  ...
    'Name', message( 'coderApp:metaTypes:attrDataTypeMode' ),  ...
    'Description', message( 'coderApp:metaTypes:attrDataTypeModeDesc' ),  ...
    'Category', ntCategory,  ...
    'Value', 'Fixed-point: binary point scaling',  ...
    'AllowedValues', {
    'Single'
    'Double'
    'Fixed-point: unspecified scaling'
    'Fixed-point: binary point scaling'
    'Fixed-point: slope and bias scaling'
    'Scaled double: unspecified scaling'
    'Scaled double: binary point scaling'
    'Scaled double: slope and bias scaling'
    } ), 'DataTypeMode'
    AttributeDef( 'fi_slope', ValueTypes.Number,  ...
    'Name', message( 'coderApp:metaTypes:attrSlope' ),  ...
    'Description', message( 'coderApp:metaTypes:attrSlopeDesc' ),  ...
    'Category', ntCategory,  ...
    'Value', 1,  ...
    'Min', 0,  ...
    'IncludeMin', false,  ...
    'IncludeMax', false ), 'Slope'
    AttributeDef( 'fi_bias', ValueTypes.Number,  ...
    'Name', message( 'coderApp:metaTypes:attrBias' ),  ...
    'Description', message( 'coderApp:metaTypes:attrBiasDesc' ),  ...
    'Category', ntCategory,  ...
    'Value', 0 ), 'Bias'
    AttributeDef( 'fi_dataTypeOverride', ValueTypes.Text,  ...
    'Name', message( 'coderApp:metaTypes:attrDataTypeOverride' ),  ...
    'Description', message( 'coderApp:metaTypes:attrDataTypeOverrideDesc' ),  ...
    'Category', ntCategory,  ...
    'Value', 'Inherit',  ...
    'AllowedValues', { 'Inherit', 'Off' } ), 'DataTypeOverride'
    };
result.props = ntAttrs( :, 2 );
result.attrs = [ ntAttrs{ :, 1 } ];
end


function result = createFimathAttrDefs(  )
import codergui.internal.type.AttributeDef;
import codergui.internal.ui.ValueTypes;
maxValue = double( intmax( 'uint16' ) );


fmCategory = codergui.internal.type.FiMetaType.FIMATH_CATEGORY;
fmAttrs = AttributeDef( 'fi_roundingMethod', ValueTypes.Text,  ...
    'Name', message( 'coderApp:metaTypes:attrRoundingMethod' ),  ...
    'Description', message( 'coderApp:metaTypes:attrRoundingMethodDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', 'Nearest',  ...
    'AllowedValues', { 'Ceiling', 'Convergent', 'Floor', 'Nearest', 'Round', 'Zero' } );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_overflowAction', ValueTypes.Text,  ...
    'Name', message( 'coderApp:metaTypes:attrOverflowAction' ),  ...
    'Description', message( 'coderApp:metaTypes:attrOverflowActionDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', 'Saturate',  ...
    'AllowedValues', { 'Saturate', 'Wrap' } );
precisionOpts = { 'FullPrecision', 'KeepLSB', 'KeepMSB', 'SpecifyPrecision' };
fmAttrs( end  + 1 ) = AttributeDef( 'fi_productMode', ValueTypes.Text,  ...
    'Name', message( 'coderApp:metaTypes:attrProductMode' ),  ...
    'Description', message( 'coderApp:metaTypes:attrProductModeDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', 'FullPrecision',  ...
    'AllowedValues', precisionOpts );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_maxProductWordLength', ValueTypes.PositiveInteger,  ...
    'Name', message( 'coderApp:metaTypes:attrMaxProductWordLength' ),  ...
    'Description', message( 'coderApp:metaTypes:attrMaxProductWordLengthDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', 1,  ...
    'Min', 1,  ...
    'Max', maxValue );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_productWordLength', ValueTypes.PositiveInteger,  ...
    'Name', message( 'coderApp:metaTypes:attrProductWordLength' ),  ...
    'Description', message( 'coderApp:metaTypes:attrProductWordLengthDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', 32,  ...
    'Min', 1,  ...
    'Max', maxValue );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_productFractionLength', ValueTypes.Integer,  ...
    'Name', message( 'coderApp:metaTypes:attrProductFractionLength' ),  ...
    'Description', message( 'coderApp:metaTypes:attrProductFractionLengthDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', 32,  ...
    'Max', maxValue );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_productFixedExponent', ValueTypes.Number,  ...
    'Name', message( 'coderApp:metaTypes:attrProductFixedExponent' ),  ...
    'Description', message( 'coderApp:metaTypes:attrProductFixedExponentDesc' ),  ...
    'Category', fmCategory,  ...
    'Value',  - 30 );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_productSlope', ValueTypes.Number,  ...
    'Name', message( 'coderApp:metaTypes:attrProductSlope' ),  ...
    'Description', message( 'coderApp:metaTypes:attrProductSlopeDesc' ),  ...
    'Category', fmCategory );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_productSlopeAdjustmentFactor', ValueTypes.Number,  ...
    'Name', message( 'coderApp:metaTypes:attrProductSlopeAdjustmentFactor' ),  ...
    'Description', message( 'coderApp:metaTypes:attrProductSlopeAdjustmentFactorDesc' ),  ...
    'Category', fmCategory );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_productBias', ValueTypes.Number,  ...
    'Name', message( 'coderApp:metaTypes:attrProductBias' ),  ...
    'Description', message( 'coderApp:metaTypes:attrProductBiasDesc' ),  ...
    'Category', fmCategory );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_sumMode', ValueTypes.Text,  ...
    'Name', message( 'coderApp:metaTypes:attrSumMode' ),  ...
    'Description', message( 'coderApp:metaTypes:attrSumModeDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', 'FullPrecision',  ...
    'AllowedValues', precisionOpts );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_maxSumWordLength', ValueTypes.PositiveInteger,  ...
    'Name', message( 'coderApp:metaTypes:attrSumModeWordLength' ),  ...
    'Description', message( 'coderApp:metaTypes:attrSumModeWordLengthDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', 1,  ...
    'Min', 1,  ...
    'Max', maxValue );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_sumWordLength', ValueTypes.PositiveInteger,  ...
    'Name', message( 'coderApp:metaTypes:attrSumWordLength' ),  ...
    'Description', message( 'coderApp:metaTypes:attrSumWordLengthDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', 32,  ...
    'Min', 1,  ...
    'Max', maxValue );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_sumFractionLength', ValueTypes.Integer,  ...
    'Name', message( 'coderApp:metaTypes:attrSumFractionLength' ),  ...
    'Description', message( 'coderApp:metaTypes:attrSumFractionLengthDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', 32,  ...
    'Max', maxValue );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_sumFixedExponent', ValueTypes.Number,  ...
    'Name', message( 'coderApp:metaTypes:attrSumFixedExponent' ),  ...
    'Description', message( 'coderApp:metaTypes:attrSumFixedExponentDesc' ),  ...
    'Category', fmCategory,  ...
    'Value',  - 30 );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_sumSlope', ValueTypes.Number,  ...
    'Name', message( 'coderApp:metaTypes:attrSumSlope' ),  ...
    'Description', message( 'coderApp:metaTypes:attrSumSlopeDesc' ),  ...
    'Category', fmCategory );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_sumSlopeAdjustmentFactor', ValueTypes.Number,  ...
    'Name', message( 'coderApp:metaTypes:attrSumSlopeAdjustmentFactor' ),  ...
    'Description', message( 'coderApp:metaTypes:attrSumSlopeAdjustmentFactorDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', 1,  ...
    'Min', 1,  ...
    'Max', 2,  ...
    'Step', 0.1,  ...
    'IncludeMax', false );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_sumBias', ValueTypes.Number,  ...
    'Name', message( 'coderApp:metaTypes:attrSumBias' ),  ...
    'Description', message( 'coderApp:metaTypes:attrSumBiasDesc' ),  ...
    'Category', fmCategory );
fmAttrs( end  + 1 ) = AttributeDef( 'fi_castBeforeSum', ValueTypes.Boolean,  ...
    'Name', message( 'coderApp:metaTypes:attrCastBeforeSum' ),  ...
    'Description', message( 'coderApp:metaTypes:attrCastBeforeSumDesc' ),  ...
    'Category', fmCategory,  ...
    'Value', true );

result.props = regexprep( { fmAttrs.Key }, 'fi_([a-zA-Z])', '${upper($1)}' );
result.attrs = fmAttrs;
end


function code = formatFiToString( code )
lines = strsplit( code, newline(  ) );
if numel( lines ) == 1
    return ;
end
lines = strtrim( lines );
code = strjoin( [ lines( 1 ), strcat( { sprintf( '\t' ) }, lines( 2:end  ) ) ], newline(  ) );
end


function applyAttrVisibility( attrs, visible )
currentVisible = [ attrs.IsVisible ];
for i = find( currentVisible ~= visible )
    attrs( i ).IsVisible = visible( i );
end
end


function invokeMultiSet( node, extObj, attrDescs )
values = cell( 1, numel( attrDescs.attrs ) );
for i = 1:numel( attrDescs.attrs )
    values{ i } = extObj.( attrDescs.props{ i } );
end
node.multiSet( attrDescs.attrs, values );
end


