classdef CodeCovDataGroup < matlab.mixin.Copyable











    properties ( Hidden = true )
        Data
        FilteredInstances
        Impl
    end

    methods ( Access = public )



        function this = CodeCovDataGroup(  )
            this.Data = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
            this.Impl = internal.codecov.CodeCovDataGroup(  );
            this.FilteredInstances = {  };
        end




        function obj = clone( this )
            obj = copy( this );
        end




        function add( this, codeCovData, aName )
            arguments
                this
                codeCovData( 1, 1 )codeinstrum.internal.codecov.CodeCovData
                aName( 1, : )char = ''
            end

            if ~isempty( this )
                if nargin < 3
                    aName = codeCovData.Name;
                end

                assert( ~isempty( aName ) );
                this.Data( aName ) = codeCovData;
                this.Impl.add( codeCovData.CodeCovDataImpl, aName );
            end
        end




        function names = allNames( this )
            names = this.Data.keys(  );
        end





        function varargout = get( this, varargin )
            oneOut = false;
            nout = nargout;
            if numel( varargin ) ~= nout
                oneOut = true;
            end
            if nout == 0
                nout = 1;
            end

            varargout = cell( nout, 1 );

            for ii = 1:length( varargin )
                arg = varargin{ ii };

                validateattributes( arg,  ...
                    { 'char' }, { 'row' }, 'codeinstrum.internal.codecov.CodeCovDataGroup.get', '', ii );

                cvd = [  ];
                if this.Data.isKey( arg )
                    cvd = this.Data( arg );
                end
                if oneOut
                    varargout{ 1 } = [ varargout{ 1 };cvd ];
                else
                    varargout{ ii } = cvd;
                end
            end
        end




        function display( this )%#ok<DISPLAY>

            varName = inputname( 1 );
            if isempty( varName )
                varName = 'ans';
            end

            clsName = class( this );

            if numel( this ) == 1
                fprintf( 1, '\n%s = ... %s', varName, clsName );
                allNames = this.allNames(  );
                if numel( allNames ) < 1
                    fprintf( 1, ' (empty)\n\n' );
                else
                    fprintf( 1, '\n\n     keys: %s\n\n', strjoin( allNames, ', ' ) );
                end
            else
                dim = size( this );
                dimStr = '';
                sep = '';
                for ii = 1:numel( dim )
                    dimStr = sprintf( '%s%s%d', dimStr, sep, dim( ii ) );
                    sep = 'x';
                end
                fprintf( 1, '\n%s = \n\n   [%s] %s\n\n', varName, dimStr, clsName );
            end
        end




        function unify( this )
            this.Impl.unify(  );
        end



        function startTime = getStartTime( this )
            this.Impl.unify(  );
            startTime = this.Impl.StartTime;
        end



        function endTime = getEndTime( this )
            this.Impl.unify(  );
            endTime = this.Impl.EndTime;
        end




        function res = getNumTests( this )
            this.unify(  );
            res = this.Impl.CodeCovDataGroupCore.tests.Size(  );
        end




        function res = isActive( this, metricKind )
            res = this.Impl.isActive( metricKind );
        end




        function res = getNumInstances( this )
            res = this.Impl.getNumInstances(  );
        end




        function res = getNumResults( this )
            res = this.Impl.getNumResults(  );
        end





        function instancesInfos = getInstanceSIDs( this )
            instancesInfos = this.Impl.getInstanceSIDs(  );
        end





        function res = getInstanceResults( this, instIdx )
            if ischar( instIdx )
                nameRslt = instIdx;
                instInfo = this.getInstanceSIDs(  );
                instIdx = find( strcmp( instInfo, instIdx ), 1 );
                if isempty( instIdx )
                    error( message( 'MATLAB:InputParser:failedWithError', 'instIdx', nameRslt ) );
                end
            end
            res = this.Impl.getInstanceResults( instIdx );
        end




        function res = getAggregatedResults( this )
            res = this.Impl.getAggregatedResults(  );
        end




        function cvds = getAll( this, unified )
            arguments
                this
                unified = false
            end
            if ~unified
                cvds = this.Data.values(  );
                cvds = [ cvds{ : } ];
            else

                this.Impl.unify(  );
                filesPath = this.Impl.getFilesPath(  );


                cvds = codeinstrum.internal.codecov.CodeCovData.empty( 0, numel( filesPath ) );
                jj = 1;
                for ii = 1:numel( filesPath )
                    ids = this.Impl.getUniqueIds( filesPath{ ii } );
                    for k = 1:numel( ids )
                        cvds( jj ) = this.getUnified( ids{ k } );
                        jj = jj + 1;
                    end
                end
            end
        end





        function setProfilingSections( this, executionTime )
            arguments
                this
                executionTime( 1, 1 )coder.profile.datamodel.ExecutionTime
            end
            this.Impl.setProfilingSections( executionTime );
        end




        function state = hasData( this )
            state = ~isempty( this ) && ~isempty( this.Data );
        end




        function state = hasResults( this )
            if hasData( this )
                cvds = getAll( this );
                state = false;
                for ii = 1:numel( cvds )
                    state = hasResults( cvds( ii ) );
                    if state
                        return
                    end
                end
            else
                state = false;
            end
        end




        function resetFilters( this )
            this.Impl.resetFilters(  );
        end





        function annotateAllFiles( this, isFilter, rationale, instIdx )
            if nargin < 4
                instIdx = 1;
            end

            if nargin < 3
                rationale = '';
            end
            if nargin < 2
                isFilter = true;
            else
                isFilter = logical( isFilter );
            end

            kind = internal.codecov.FilterKind.GLOBAL;
            cvds = this.getAll(  );
            for ii = 1:numel( cvds )
                this.insertAnnotation( instIdx, cvds( ii ).CodeTr.Root, kind, isFilter, rationale );
            end
            this.Impl.resetUnify(  );
        end





        function annotateFile( this, isFilter, rationale, fileName, instIdx )
            if nargin < 5
                instIdx = 1;
            end
            kind = internal.codecov.FilterKind.FILE;
            sourceLocations = this.findSourceLoc( fileName, '', false );
            for ii = 1:numel( sourceLocations )
                for jj = 1:numel( sourceLocations( ii ).objs )
                    this.insertAnnotation( instIdx, sourceLocations( ii ).objs( jj ), kind, isFilter, rationale );
                end
            end
            this.Impl.resetUnify(  );
        end





        function annotateFunction( this, isFilter, rationale, fileName, funName, instIdx )
            if nargin < 6
                instIdx = 1;
            end
            kind = internal.codecov.FilterKind.FUNCTION;
            sourceLocations = this.findSourceLoc( fileName, funName, false );
            for ii = 1:numel( sourceLocations )
                for jj = 1:numel( sourceLocations( ii ).objs )
                    this.insertAnnotation( instIdx, sourceLocations( ii ).objs( jj ), kind, isFilter, rationale );
                end
            end
            this.Impl.resetUnify(  );
        end





        function annotateExpression( this, isFilter, rationale, fileName, funName, expr, exprIdx, cvMetricType, instIdx )
            if nargin < 9
                instIdx = 1;
            end
            sourceLocations = this.findSourceLoc( fileName, funName, false );


            groupSids = this.getInstanceSIDs(  );
            if ~ischar( instIdx )
                instName = groupSids( instIdx );
            else
                instName = instIdx;
            end
            for ii = 1:numel( sourceLocations )
                instInfo = sourceLocations( ii ).cvd.getInstanceSIDs(  );
                subInstIdx = find( strcmp( instInfo, instName ), 1 );
                if isempty( subInstIdx )
                    error( message( 'MATLAB:InputParser:failedWithError', 'instIdx', instIdx ) );
                end
                sourceLocations( ii ).cvd.annotateExpression( isFilter, rationale, fileName, funName, expr, exprIdx, cvMetricType, subInstIdx );
            end
            this.Impl.resetUnify(  );
        end




        function res = plus( lhs, rhs )
            arguments
                lhs( 1, 1 )codeinstrum.internal.codecov.CodeCovDataGroup
                rhs( 1, 1 )codeinstrum.internal.codecov.CodeCovDataGroup
            end
            res = codeinstrum.internal.codecov.CodeCovDataGroup.performOp( lhs, rhs, '+' );
        end




        function res = minus( lhs, rhs )
            arguments
                lhs( 1, 1 )codeinstrum.internal.codecov.CodeCovDataGroup
                rhs( 1, 1 )codeinstrum.internal.codecov.CodeCovDataGroup
            end
            res = codeinstrum.internal.codecov.CodeCovDataGroup.performOp( lhs, rhs, '-' );
        end




        function res = times( lhs, rhs )
            arguments
                lhs( 1, 1 )codeinstrum.internal.codecov.CodeCovDataGroup
                rhs( 1, 1 )codeinstrum.internal.codecov.CodeCovDataGroup
            end
            res = codeinstrum.internal.codecov.CodeCovDataGroup.performOp( lhs, rhs, '*' );
        end




        function res = mtimes( lhs, rhs )
            arguments
                lhs( 1, 1 )codeinstrum.internal.codecov.CodeCovDataGroup
                rhs( 1, 1 )codeinstrum.internal.codecov.CodeCovDataGroup
            end
            res = times( lhs, rhs );
        end




        function setDescription( this, value )
            names = this.allNames(  );
            for ii = 1:numel( names )
                resObj = this.Data( names{ ii } );
                resObj.Description = value;
            end
        end




        function setTestRunInfo( this, value )
            names = this.allNames(  );
            for ii = 1:numel( names )
                resObj = this.Data( names{ ii } );
                resObj.setTestRunInfo( value );
            end
        end




        function setAggregatedTestInfo( this, value )
            names = this.allNames(  );
            for ii = 1:numel( names )
                resObj = this.Data( names{ ii } );
                resObj.setAggregatedTestInfo( value );
            end
        end




        function res = toStruct( this )
            res = struct(  );
            res.codeCovDataGroupObj = this.Impl;
        end




        function removeUncoveredFunctionsData( this )
            cvds = this.getAll(  );
            for ii = 1:numel( cvds )
                cvds( ii ).removeUncoveredFunctionsData(  );
            end
        end
    end

    methods ( Access = protected )



        function resObj = copyElement( this )
            resObj = copyElement@matlab.mixin.Copyable( this );
            resObj.Data = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
            resObj.Impl = internal.codecov.CodeCovDataGroup(  );
            names = allNames( this );
            cvds = getAll( this );
            for ii = 1:numel( cvds )
                add( resObj, copyElement( cvds( ii ) ), names{ ii } );
            end
        end




        function insertAnnotation( this, instIdx, obj, kind, isFilter, rationale )
            if ischar( instIdx )
                instInfo = this.getInstanceSIDs(  );
                instIdx = find( strcmp( instInfo, instIdx ), 1 );
                if isempty( instIdx )
                    error( message( 'MATLAB:InputParser:failedWithError', 'instIdx', instIdx ) );
                end
            end


            if isempty( rationale )
                rationale = '';
            end

            numInstances = this.getNumInstances(  );

            if instIdx <  - 1
                instIdx = 1:numInstances;
            end

            if isFilter
                filterMode = internal.codecov.FilterMode.EXCLUDED;
            else
                filterMode = internal.codecov.FilterMode.JUSTIFIED;
            end

            for ii = instIdx( : )'
                this.Impl.addFilter( ii,  ...
                    kind,  ...
                    internal.codecov.FilterSource.USER,  ...
                    filterMode, rationale, obj );
            end
        end




        function performOpExtraOp( this, lhs, rhs )%#ok

        end
    end

    methods ( Access = public, Hidden = true )




        function out = findSourceLoc( this, fileName, fcnName, unify )
            arguments
                this
                fileName( 1, : )char = ''
                fcnName( 1, : )char = ''
                unify = false
            end
            out = struct.empty(  );
            covDatas = this.getAll( unify );
            for ii = 1:numel( covDatas )
                subObjs = covDatas( ii ).findSourceLoc( fileName, fcnName );
                if numel( subObjs ) > 0
                    out( end  + 1 ).cvd = covDatas( ii );
                    out( end  ).objs = subObjs;
                end
            end
        end
    end

    methods ( Access = private )




        function cvdunify = getUnified( this, id, instIdx )
            if nargin == 2
                instIdx = 0;
            elseif ischar( instIdx )
                instInfo = this.getInstanceSIDs(  );
                instIdx = find( strcmp( instInfo, instIdx ), 1 );
            end
            cvdIntern = this.Impl.getCodeCovData( id, instIdx );
            cvdunify = codeinstrum.internal.codecov.CodeCovData.loadobjFromImpl( cvdIntern );
        end
    end

    methods ( Static = true, Hidden = true )




        function obj = loadobjFromImpl( implObj, className )
            arguments
                implObj( 1, 1 )internal.codecov.CodeCovDataGroup
                className( 1, : )char = 'codeinstrum.internal.codecov.CodeCovDataGroup'
            end
            obj = feval( className );
            obj.Impl = implObj;
            for ii = 1:obj.Impl.CodeCovDataGroupCore.codeCovDataSrc.Size(  )
                codeCovDataIntern = obj.Impl.CodeCovDataGroupCore.codeCovDataSrc( ii );
                codeCovData = codeinstrum.internal.codecov.CodeCovData.loadobjFromImpl( codeCovDataIntern );
                obj.add( codeCovData );
            end
        end
    end

    methods ( Static )



        function obj = loadobj( this, obj )
            obj = this;
            this.Impl = internal.codecov.CodeCovDataGroup(  );
            allNames = obj.allNames(  );
            for ii = 1:numel( allNames )
                obj.Impl.add( obj.Data( allNames{ ii } ).CodeCovDataImpl, allNames{ ii } );
            end
        end




        function res = fromPsProfFile( psprofPath )
            impl = internal.codecov.CodeCovDataGroup.fromPsProfFile( psprofPath );
            res = internal.codecov.CodeCovDataGroup.empty(  );
            if ~isempty( impl )
                res = codeinstrum.internal.codecov.CodeCovDataGroup.loadobjFromImpl( impl );
            end
        end




        function res = performOp( lhs, rhs, opStr, expectedRsltType )
            narginchk( 3, 4 );
            if nargin < 4
                expectedRsltType = '';
            end
            validatestring( opStr, { '+', '-', '*' }, 'codeinstrum.internal.codecov.CodeCovDataGroup.performOp', 'opStr', 3 );

            isLhsCodeCovDataGroup = isa( lhs, 'codeinstrum.internal.codecov.CodeCovDataGroup' );
            isRhsCodeCovDataGroup = isa( rhs, 'codeinstrum.internal.codecov.CodeCovDataGroup' );

            if isLhsCodeCovDataGroup && ~isempty( lhs ) && hasData( lhs )
                lan = lhs.allNames(  );
            else
                lan = {  };
            end
            if isRhsCodeCovDataGroup && ~isempty( rhs ) && hasData( rhs )
                ran = rhs.allNames(  );
            else
                ran = {  };
            end
            ian = intersect( lan, ran );

            if isempty( expectedRsltType )
                resClsName = 'codeinstrum.internal.codecov.CodeCovDataGroup';
            else
                resClsName = expectedRsltType;
            end
            if isLhsCodeCovDataGroup
                resClsName = class( lhs );
            elseif isRhsCodeCovDataGroup
                resClsName = class( rhs );
            end
            res = eval( resClsName );


            res.performOpExtraOp( lhs, rhs );

            for idx = 1:length( ian )
                p = lhs.get( ian{ idx } );
                q = rhs.get( ian{ idx } );

                r = p;


                if isempty( p ) || ~hasResults( p )
                    if opStr ~= '*'
                        r = q;
                    end
                elseif isempty( q ) || ~hasResults( q )
                    if opStr == '*'
                        r = feval( [ class( r ), '.empty()' ] );
                    end
                else


                    r = eval( [ class( r ), '.performOp(p, q, opStr)' ] );
                end

                res.add( r, ian{ idx } );
            end

            if opStr ~= '*'
                [ ~, ilan, iran ] = setxor( lan, ran );
                for idx = 1:numel( ilan )
                    key = lan{ ilan( idx ) };
                    res.add( lhs.get( key ), key );
                end

                for idx = 1:numel( iran )
                    key = ran{ iran( idx ) };
                    res.add( rhs.get( key ), key );
                end
            end
        end
    end
end

