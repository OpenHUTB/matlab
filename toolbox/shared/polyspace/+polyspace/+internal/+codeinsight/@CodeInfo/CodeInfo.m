classdef CodeInfo < handle



    properties
        MissingFunctionDeclaration( 1, : )string
        MissingTypeDefinition( 1, : )string
    end

    properties ( Hidden )
        AST internal.cxxfe.ast.Ast = internal.cxxfe.ast.Ast.empty
    end

    properties ( Hidden, Transient, Access = private )
        CodeInsightInfo internal.cxxfe.ast.codeinsight.CodeInsight = internal.cxxfe.ast.codeinsight.CodeInsight.empty
        functionNameInfoMap( 1, 1 )dictionary
        functionSignatureInfoMap( 1, 1 )dictionary
        variableNameInfoMap( 1, 1 )dictionary
    end

    methods
        function obj = CodeInfo( AST )
            arguments
                AST( 1, 1 )internal.cxxfe.ast.Ast
            end
            obj.AST = AST;
            obj.functionNameInfoMap = dictionary(  );
            obj.functionSignatureInfoMap = dictionary(  );
            obj.variableNameInfoMap = dictionary(  );
        end

        function res = getMainFunction( self )
            res = internal.cxxfe.ast.Function.empty;
            for cIdx = 1:self.AST.Project.Compilations.Size
                cUnit = self.AST.Project.Compilations.at( cIdx );
                if ~isempty( cUnit.MainFunction )
                    res = cUnit.MainFunction;
                    return ;
                end
            end
        end

        function res = getFunctions( self, options )
            arguments
                self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
                options.Signature( 1, 1 )logical = false
                options.EntryPoints( 1, 1 )logical
                options.Defined( 1, 1 )logical
                options.Declared( 1, 1 )logical
                options.CompilerGenerated( 1, 1 )logical = false
                options.SLCCImportCompliant( 1, 1 )logical
                options.IgnoreDeclarationPos( 1, 1 )logical = false
            end
            self.checkObject(  );
            res = string( [  ] );
            if isfield( options, 'EntryPoints' )
                if options.EntryPoints
                    fInfoList = self.CodeInsightInfo.EntryPoints;
                else
                    fInfoList = self.CodeInsightInfo.Functions.toArray;
                    if ~isempty( fInfoList )
                        fInfoList( [ fInfoList.IsCalled ] == true );
                    end
                end
            else
                fInfoList = self.CodeInsightInfo.Functions.toArray;
            end

            if isfield( options, 'Defined' )
                if ~isempty( fInfoList )
                    fInfoList = fInfoList( [ fInfoList.IsDefined ] == options.Defined );
                end
            end
            if isfield( options, 'Declared' )
                if ~isempty( fInfoList )
                    fInfoList = fInfoList( [ fInfoList.IsDeclared ] == options.Declared );
                end
            end
            if isfield( options, 'SLCCImportCompliant' )
                if ~isempty( fInfoList )
                    compliantRes = polyspace.internal.codeinsight.CodeInfo.isSLCCImportCompliant( fInfoList, options.IgnoreDeclarationPos );
                    fInfoList = fInfoList( compliantRes == options.SLCCImportCompliant );
                end
            end
            if ~isempty( fInfoList )
                fList = [ fInfoList.Function ];
                if ~isempty( fList )
                    fList = fList( [ fList.IsCompilerGenerated ] == options.CompilerGenerated );
                end
                if options.Signature
                    res = arrayfun( @( x )( string( x.generateSignature ) ), fList );
                else
                    res = string( { fList.Name } );
                end
            end
        end

        function res = getVariables( self, options )
            arguments
                self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
                options.Signature( 1, 1 )logical = false
                options.IgnoreStaticVariables( 1, 1 )logical = true
                options.Defined( 1, 1 )logical
                options.SLCCImportCompliant( 1, 1 )logical
                options.IgnoreDeclarationPos( 1, 1 )logical = false
            end
            self.checkObject(  );
            res = string( [  ] );
            vInfoList = self.CodeInsightInfo.Variables.toArray;
            if ~isempty( vInfoList ) && options.IgnoreStaticVariables
                vList = [ vInfoList.Variable ];
                vInfoList = vInfoList( [ vList.StorageClass ] ~= internal.cxxfe.ast.StorageClassKind.Static );
            end
            if ~isempty( vInfoList ) && isfield( options, 'Defined' )
                vInfoList = vInfoList( [ vInfoList.IsDefined ] == options.Defined );
            end
            if ~isempty( vInfoList ) && isfield( options, 'SLCCImportCompliant' )
                compliantRes = polyspace.internal.codeinsight.CodeInfo.isSLCCImportCompliant( vInfoList, options.IgnoreDeclarationPos );
                vInfoList = vInfoList( compliantRes == options.SLCCImportCompliant );
            end
            if ~isempty( vInfoList )
                vList = [ vInfoList.Variable ];
                if options.Signature
                    res = arrayfun( @( x )( polyspace.internal.codeinsight.CodeInfo.generateTypeName( x.Type, x.Name ) + ";" ), vList );
                else
                    res = string( { vList.Name } );
                end
            end
        end




        function tInfoList = getTypeInfoForVariableAndFunctions( self, options )
            arguments
                self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
                options.SLCCImportCompliant( 1, 1 )logical
                options.IgnoreDeclarationPos( 1, 1 )logical = false
                options.EntryPoints( 1, 1 )logical
                options.IgnoreMWIncludes( 1, 1 )logical = false
            end
            self.checkObject(  );
            if isfield( options, 'EntryPoints' )
                if options.EntryPoints
                    fInfoList = self.CodeInsightInfo.EntryPoints;
                else
                    fInfoList = self.CodeInsightInfo.Functions.toArray;
                    if ~isempty( fInfoList )
                        fInfoList( [ fInfoList.IsCalled ] == true );
                    end
                end
            else
                fInfoList = self.CodeInsightInfo.Functions.toArray;
            end


            if ~isempty( fInfoList )
                fList = [ fInfoList.Function ];
                if ~isempty( fList )
                    fInfoList = fInfoList( [ fList.IsCompilerGenerated ] == false );
                end
            end

            vInfoList = self.CodeInsightInfo.Variables.toArray;
            if isfield( options, 'SLCCImportCompliant' )
                if ~isempty( vInfoList )
                    compliantRes = polyspace.internal.codeinsight.CodeInfo.isSLCCImportCompliant( vInfoList, options.IgnoreDeclarationPos );
                    vInfoList = vInfoList( compliantRes == options.SLCCImportCompliant );
                end
                if ~isempty( fInfoList )
                    compliantRes = polyspace.internal.codeinsight.CodeInfo.isSLCCImportCompliant( fInfoList, options.IgnoreDeclarationPos );
                    fInfoList = fInfoList( compliantRes == options.SLCCImportCompliant );
                end
            end
            typeToConsider = internal.cxxfe.ast.types.Type.empty;
            if ~isempty( vInfoList )
                vars = [ vInfoList.Variable ];
                typeToConsider = [ vars.Type ];
            end
            for idx = 1:numel( fInfoList )
                paramTypes = fInfoList( idx ).Function.Type.ParamTypes.toArray;
                if ~isempty( paramTypes )
                    typeToConsider = [ typeToConsider, fInfoList( idx ).Function.Type.RetType, paramTypes ];%#ok<AGROW>
                else
                    typeToConsider = [ typeToConsider, fInfoList( idx ).Function.Type.RetType ];%#ok<AGROW>
                end
            end
            typeToConsider = arrayfun( @polyspace.internal.codeinsight.CodeInfo.getUnderlayingTypeToImport, typeToConsider, 'UniformOutput', false );
            typeToConsider = [ typeToConsider{ : } ];
            if ~isempty( typeToConsider ) && options.IgnoreMWIncludes
                isNotDefInMWInc = arrayfun( @( x )~polyspace.internal.codeinsight.CodeInfo.isDefinedInMWInc( x ), typeToConsider );
                typeToConsider = typeToConsider( isNotDefInMWInc );
            end
            if ~isempty( typeToConsider )
                typeToConsiderUUID = unique( { typeToConsider.UUID } );
            else
                typeToConsiderUUID = {  };
            end
            allTypeInfo = self.CodeInsightInfo.Types.toArray;
            if ~isempty( allTypeInfo )
                allTypeInfoType = [ allTypeInfo.Type ];
                allTypeInfoTypeUUID = { allTypeInfoType.UUID };
            else
                allTypeInfoTypeUUID = {  };
            end

            tInfoList = allTypeInfo( ismember( allTypeInfoTypeUUID, typeToConsiderUUID ) );
        end

        function res = getTypes( self, options )
            arguments
                self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
                options.SLCCImportCompliant( 1, 1 )logical
                options.FilterBuiltins( 1, 1 )logical = true
                options.IgnoreMWIncludes( 1, 1 )logical = false
            end
            self.checkObject(  );
            res = string( [  ] );
            tInfoList = self.CodeInsightInfo.Types.toArray;
            if isfield( options, 'SLCCImportCompliant' )
                if ~isempty( tInfoList )
                    compliantRes = polyspace.internal.codeinsight.CodeInfo.isTypeSLCCImportCompliant( tInfoList );
                    tInfoList = tInfoList( compliantRes == options.SLCCImportCompliant );
                end
            end
            if ~isempty( tInfoList )
                tList = [ tInfoList.Type ];

                if ( options.FilterBuiltins )
                    defOrDecl = arrayfun( @( x )~isempty( x.DefPos ) || x.DeclPos.Size > 0, tList );
                    tList = tList( defOrDecl );
                end
                if ~isempty( tList ) && options.IgnoreMWIncludes
                    isNotDefInMWInc = arrayfun( @( x )~polyspace.internal.codeinsight.CodeInfo.isDefinedInMWInc( x ), tList );
                    tList = tList( isNotDefInMWInc );
                end
                if ~isempty( tList )
                    res = string( { tList.Name } );
                else
                    res = string( [  ] );
                end
            end
        end

        function res = getFunctionInfoStruct( self, options )
            arguments
                self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
                options.SLCCImportCompliant( 1, 1 )logical
                options.IgnoreDeclarationPos( 1, 1 )logical = false
                options.CompilerGenerated( 1, 1 )logical = false
            end
            self.checkObject(  );

            fInfoList = self.CodeInsightInfo.Functions.toArray;
            if ~isempty( fInfoList )
                fInfoFcnList = [ fInfoList.Function ];
                fInfoList = fInfoList( [ fInfoFcnList.IsCompilerGenerated ] == options.CompilerGenerated );
            end
            res.EntryPoints = self.CodeInsightInfo.EntryPoints;

            if ~isempty( res.EntryPoints )
                entryPointsFcn = [ res.EntryPoints.Function ];
                isCompilerGeneratedOpt = ( [ entryPointsFcn.IsCompilerGenerated ] == options.CompilerGenerated );
                res.EntryPoints = res.EntryPoints( isCompilerGeneratedOpt );
            end
            if isfield( options, 'SLCCImportCompliant' )
                if ~isempty( fInfoList )
                    IsImportCompliant = polyspace.internal.codeinsight.CodeInfo.isSLCCImportCompliant( fInfoList, options.IgnoreDeclarationPos );
                    res.FunctionInfo = fInfoList( IsImportCompliant == options.SLCCImportCompliant );
                else
                    res.FunctionInfo = fInfoList;
                end
            else
                res.FunctionInfo = fInfoList;
            end
            if ~isempty( res.FunctionInfo )
                res.Function = [ res.FunctionInfo.Function ];
            else
                res.Function = [  ];
            end
        end

        function res = getFunctionInfoByName( self, name )
            arguments
                self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
                name( 1, 1 )string
            end
            self.checkObject(  );

            functionNameInfoMap0 = self.getFunctionNameInfoMap(  );

            if functionNameInfoMap0.isConfigured && functionNameInfoMap0.isKey( name )
                res = functionNameInfoMap0( name );
            else
                res = [  ];
            end
        end

        function res = getFunctionInfoBySignature( self, signature )
            arguments
                self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
                signature( 1, 1 )string
            end
            self.checkObject(  );

            functionSignatureInfoMap0 = self.getFunctionSignatureInfoMap(  );

            if functionSignatureInfoMap0.isConfigured && functionSignatureInfoMap0.isKey( signature )
                res = functionSignatureInfoMap0( signature );
            else
                res = [  ];
            end
        end

        function res = getVariableInfoStruct( self, options )
            arguments
                self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
                options.SLCCImportCompliant( 1, 1 )logical
            end
            self.checkObject(  );

            vInfoList = self.CodeInsightInfo.Variables.toArray;
            res.EntryPoints = self.CodeInsightInfo.EntryPoints;
            if isfield( options, 'SLCCImportCompliant' )
                IsImportCompliant = polyspace.internal.codeinsight.CodeInfo.isSLCCImportCompliant( vInfoList );
                res.VariableInfo = vInfoList( IsImportCompliant == options.SLCCImportCompliant );
            else
                res.VariableInfo = vInfoList;
            end
            if ~isempty( res.VariableInfo )
                res.Variable = [ res.VariableInfo.Variable ];
            end
        end

        function res = getVariableInfoByName( self, name )
            arguments
                self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
                name( 1, 1 )string
            end
            self.checkObject(  );

            variableNameInfoMap0 = self.getVariableNameInfoMap(  );
            if variableNameInfoMap0.isConfigured && variableNameInfoMap0.isKey( name )
                res = variableNameInfoMap0( name );
            else
                res = [  ];
            end
        end

        function res = getTypeInfoStruct( self, options )
            arguments
                self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
                options.SLCCImportCompliant( 1, 1 )logical
                options.FilterBuiltins( 1, 1 )logical = true
                options.IgnoreMWIncludes( 1, 1 )logical = false
                options.IgnoreSystemIncludes( 1, 1 )logical = true
            end
            self.checkObject(  );

            tInfoList = self.CodeInsightInfo.Types.toArray;

            if isfield( options, 'SLCCImportCompliant' )
                if ~isempty( tInfoList )
                    IsImportCompliant = polyspace.internal.codeinsight.CodeInfo.isTypeSLCCImportCompliant( tInfoList );
                    res.TypeInfo = tInfoList( IsImportCompliant == options.SLCCImportCompliant );
                else
                    res.TypeInfo = [  ];
                end
            else
                res.TypeInfo = tInfoList;
            end
            if ~isempty( res.TypeInfo )
                res.Type = [ res.TypeInfo.Type ];
                if options.FilterBuiltins

                    defOrDecl = arrayfun( @( x )~isempty( x.DefPos ) || x.DeclPos.Size > 0, res.Type );
                    res.Type = res.Type( defOrDecl );
                    res.TypeInfo = res.TypeInfo( defOrDecl );
                end
                if ~isempty( res.Type ) && options.IgnoreMWIncludes
                    isNotDefInMWInc = arrayfun( @( x )~polyspace.internal.codeinsight.CodeInfo.isDefinedInMWInc( x ), res.Type );
                    res.Type = res.Type( isNotDefInMWInc );
                    res.TypeInfo = res.TypeInfo( isNotDefInMWInc );
                end
                if ~isempty( res.Type ) && options.IgnoreSystemIncludes
                    isNotDefInSystemInc = arrayfun( @( x )~polyspace.internal.codeinsight.CodeInfo.isDefinedInSystemInc( x ), res.Type );
                    res.Type = res.Type( isNotDefInSystemInc );
                    res.TypeInfo = res.TypeInfo( isNotDefInSystemInc );
                end
                if ~isempty( res.Type )
                    typeToKeep = polyspace.internal.codeinsight.CodeInfo.uniqueTypeIndex( res.Type );
                    res.Type = res.Type( typeToKeep );
                    res.TypeInfo = res.TypeInfo( typeToKeep );
                end
            else
                res.Type = [  ];
            end
        end

        res = getHeaderInterface( self )
        [ originalHeaders, headerGraph ] = getHeaderList( self );
        res = getSLCCGlobalIOData( self );
        [ success, headerContent, sourceContent ] = generateStubs( self, options );
        hasChanged = undefASM( self, fileToModify );
        hasChanged = undefASMInSources( self, sourceFolder );
        hasChanged = undefVariableDefinition( self, fileToModify );
    end

    methods

        function codeInsightObj = get.CodeInsightInfo( self )
            if isempty( self.CodeInsightInfo )
                if isempty( self.AST )
                    error( "No parsing data available" );
                end
                assert( self.AST.Project.Compilations.Size == 1 );
                cUnit = self.AST.Project.Compilations.at( 1 );
                annotations = cUnit.Annotations.toArray;
                for a = annotations
                    if isa( a, 'internal.cxxfe.ast.codeinsight.CodeInsight' )
                        codeInsightObj = a;
                        break ;
                    end
                end
            end
        end
    end

    methods ( Hidden, Access = private )

        function checkObject( self )
            if isempty( self )
                error( "Empty CodeInfo" );
            end
            if isempty( self.AST )
                error( "No parsing data available" );
            end
        end

        function map = getFunctionNameInfoMap( self )
            if ~self.functionNameInfoMap.isConfigured
                funInfoList = self.CodeInsightInfo.Functions.toArray;
                funList = [ funInfoList.Function ];
                funNameList = { funList.Name };
                self.functionNameInfoMap = dictionary( string( funNameList ), funInfoList );
            end
            map = self.functionNameInfoMap;
        end

        function map = getVariableNameInfoMap( self )
            if ~self.variableNameInfoMap.isConfigured && self.CodeInsightInfo.Variables.Size > 0
                varInfoList = self.CodeInsightInfo.Variables.toArray;
                varList = [ varInfoList.Variable ];
                varNameList = { varList.Name };
                self.variableNameInfoMap = dictionary( string( varNameList ), varInfoList );
            end
            map = self.variableNameInfoMap;
        end

        function map = getFunctionSignatureInfoMap( self )
            if ~self.functionSignatureInfoMap.isConfigured
                funInfoList = self.CodeInsightInfo.Functions.toArray;
                funList = [ funInfoList.Function ];
                funSignatureList = arrayfun( @( x )x.generateSignature, funList, 'UniformOutput', false );
                self.functionSignatureInfoMap = dictionary( string( funSignatureList ), funInfoList );
            end
            map = self.functionSignatureInfoMap;
        end
    end

    methods ( Hidden )

        function s = saveobj( obj )
            s.AST = internal.cxxfe.ast.Ast.serializeToUTF16String( obj.AST, internal.cxxfe.ast.io.IoFormat.json );
        end


        function res = hasSLCCCompliantInfo( obj )
            co = obj.CodeInsightInfo;
            res = false;
            if co.Functions.Size > 0
                res = polyspace.internal.codeinsight.CodeInfo.hasSimulinkSLCCImportComplianceAnnotation( co.Functions.at( 1 ) );
            else
                if co.Types.Size > 0
                    res = polyspace.internal.codeinsight.CodeInfo.hasSimulinkSLCCImportComplianceAnnotation( co.Types.at( 1 ) );
                else
                    if co.Variables.Size > 0
                        res = polyspace.internal.codeinsight.CodeInfo.hasSimulinkSLCCImportComplianceAnnotation( co.Variables.at( 1 ) );
                    end
                end
            end
        end
    end

    methods ( Static, Hidden )

        function obj = loadobj( s )
            if isstruct( s )
                ast = internal.cxxfe.ast.Ast.deserializeFromUTF16String( s.AST, internal.cxxfe.ast.io.IoFormat.json );
                obj = polyspace.internal.codeinsight.CodeInfo( ast );
            else
                obj = s;
            end
        end


        function res = getUnderlayingTypeToImport( aType, recurseOnPointer )
            arguments
                aType( 1, 1 )internal.cxxfe.ast.types.Type
                recurseOnPointer( 1, 1 )logical = true
            end

            if polyspace.internal.codeinsight.CodeInfo.isAliasToPointerType( aType )
                aType = internal.cxxfe.ast.types.Type.skipTyperefs( aType );
            end

            if aType.isPointerType
                if recurseOnPointer
                    res = polyspace.internal.codeinsight.CodeInfo.getUnderlayingTypeToImport( aType.Type, false );
                else
                    res = aType.Type;
                end
                return ;
            end
            if aType.isQualifiedType
                res = polyspace.internal.codeinsight.CodeInfo.getUnderlayingTypeToImport( aType.Type );
                return ;
            end
            if aType.isArrayType
                res = polyspace.internal.codeinsight.CodeInfo.getUnderlayingTypeToImport( aType.Type );
                return ;
            end
            res = aType;
        end

        function res = hasSimulinkSLCCImportComplianceAnnotation( obj )
            tmp = internal.cxxfe.ast.codeinsight.SimulinkSLCCImportCompliance.empty;
            annotations = obj.Annotations.toArray;
            for a = annotations
                if isa( a, class( tmp ) )
                    tmp = a;
                    break ;
                end
            end
            res = ~isempty( tmp );
        end



        function res = getSimulinkSLCCImportComplianceAnnotation( obj )
            res = internal.cxxfe.ast.codeinsight.SimulinkSLCCImportCompliance.empty;
            annotations = obj.Annotations.toArray;
            for a = annotations
                if isa( a, class( res ) )
                    res = a;
                    break ;
                end
            end
            if isempty( res )
                m = message( 'cxxfe:codeinsight:ImportCompUnavailable' );
                error( m );
            end
        end



        function res = getSimulinkSLCCTypeImportComplianceAnnotation( obj )
            res = internal.cxxfe.ast.codeinsight.SimulinkSLCCTypeImportCompliance.empty;
            annotations = obj.Annotations.toArray;
            for a = annotations
                if isa( a, class( res ) )
                    res = a;
                    break ;
                end
            end
            if isempty( res )
                m = message( 'cxxfe:codeinsight:ImportCompUnavailable' );
                error( m );
            end
        end



        function res = isSLCCImportCompliant( objList, IgnoreDeclarationPos )
            if isempty( objList )
                res = [  ];
                return ;
            end
            annotationList = arrayfun( @( x )polyspace.internal.codeinsight.CodeInfo.getSimulinkSLCCImportComplianceAnnotation( x ), objList );
            if any( isempty( annotationList ) )
                m = message( 'cxxfe:codeinsight:ImportCompUnavailable' );
                error( m );
            end
            if nargin > 1 && IgnoreDeclarationPos
                res = [ annotationList.isCompliantIgnoreDeclarationPos ];
            else
                res = [ annotationList.isCompliant ];
            end
        end



        function res = isTypeSLCCImportCompliant( objList )
            annotationList = arrayfun( @( x )polyspace.internal.codeinsight.CodeInfo.getSimulinkSLCCTypeImportComplianceAnnotation( x ), objList );
            if isempty( annotationList )
                res = [  ];
            else
                res = [ annotationList.isCompliantAsImportedType ];
            end
        end


        function res = isAliasToPointerType( aType )
            underlayingType = internal.cxxfe.ast.types.Type.skipTyperefs( aType );
            res = underlayingType.isPointerType(  );
        end



        function res = isDereferenceablePointer( aType )
            underlayingType = internal.cxxfe.ast.types.Type.skipTyperefs( aType );
            if ~underlayingType.isPointerType(  )
                res = false;
            else
                res = ~( underlayingType.Type.isQualifiedType(  ) && underlayingType.Type.IsConst );
            end
        end


        function res = isAliasToArrayType( aType )
            underlayingType = internal.cxxfe.ast.types.Type.skipTyperefs( aType );
            res = underlayingType.isArrayType(  );
        end


        function res = isAliasToIncompleteType( aType )
            underlayingType = internal.cxxfe.ast.types.Type.skipTyperefs( aType );
            res = ( underlayingType.isAggregateType(  ) && underlayingType.IsIncomplete );
        end



        function res = isDefinedInMWInc( aType )
            if isempty( aType.DefPos )
                res = false;
                return ;
            end
            res = polyspace.internal.codeinsight.CodeInfo.isMWIncludePath( string( aType.DefPos.File.Path ) );
        end

        function res = isMWIncludePath( aPath )
            arguments
                aPath( 1, 1 )string
            end
            MWInc = string( {  ...
                fullfile( matlabroot, 'extern', 'include' ); ...
                fullfile( matlabroot, 'simulink', 'include' ) ...
                } );
            res = aPath.startsWith( MWInc );
        end


        function res = isDefinedInSystemInc( aType )
            if isempty( aType.DefPos ) || isempty( aType.DefPos.File )
                res = false;
                return ;
            end
            res = aType.DefPos.File.IsIncludedFromSystemIncludeDir;
        end

        function res = uniqueTypeIndex( aTypeList )
            arguments
                aTypeList( 1, : )internal.cxxfe.ast.types.Type
            end

            function aHash = hashType( aType )
                aHash = string( aType.StaticMetaClass.name ) + "$" +  ...
                    aType.Name + "$" +  ...
                    aType.DefPos.Line + "$" +  ...
                    aType.DefPos.Col + "$" +  ...
                    string( aType.DefPos.File.Path );
            end
            hashList = arrayfun( @( x )hashType( x ), aTypeList );
            [ ~, res, ~ ] = unique( hashList, "stable" );
        end

        typename = generateTypeName( type, name );
        sig = generateFunctionSignature( aASTFun, parameterPrefix );
        [ typeIncludes, typeWithNoInclude ] = getTypeIncludes( typelist );
        headerFileList = filterHeadersFromGraph( headerList, includeFileList, headerGraph );
    end

end


