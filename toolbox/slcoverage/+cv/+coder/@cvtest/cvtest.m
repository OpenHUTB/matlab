classdef cvtest < cv.internal.cvtest

    properties ( GetAccess = public, SetAccess = protected, Hidden )
        id( 1, 1 ){ mustBeNumeric } = 0
    end

    properties
        label( 1, : )char = ''
        setupCmd( 1, : )char = ''
        settings struct = struct( 'decision', true, 'condition', false, 'mcdc', false, 'relationalop', false )
        options struct = struct( 'covBoundaryRelTol', 1e-2, 'covBoundaryAbsTol', 1e-5, 'mcdcMode', SlCov.McdcMode.Masking )
        filter( 1, : )char = ''
    end

    properties ( Hidden = true, SetAccess = private )
        dbVersion( 1, : )char = SlCov.CoverageAPI.getDbVersion(  )
    end

    properties ( GetAccess = public, SetAccess = ?cv.coder.cvdata, Hidden )
        isLocked( 1, 1 )logical = false
    end

    methods



        function this = cvtest( varargin )
            narginchk( 0, 2 );

            if nargin > 0
                if isa( varargin{ 1 }, 'cv.coder.cvtest' )
                    narginchk( 1, 1 );
                    this = varargin{ 1 };
                    return
                else
                    narginchk( 1, 2 );
                    this.label = varargin{ 1 };
                    if nargin > 1
                        this.setupCmd = varargin{ 2 };
                    end
                end
            end
        end




        function res = valid( ~ )
            res = true;
        end




        function set.settings( this, value )
            arguments
                this( 1, 1 )cv.coder.cvtest
                value( 1, 1 )struct{ mustBeNonempty }
            end

            this.assertReadOnly(  );

            fNames = fieldnames( value );
            idx = find( ~ismember( fNames, { 'decision', 'condition', 'mcdc', 'relationalop' } ), 1 );
            if ~isempty( idx )
                error( message( 'Slvnv:simcoverage:cvtest:InvalidMetricName', fNames{ idx } ) );
            end
            for ii = 1:numel( fNames )
                val = value.( fNames{ ii } );
                if numel( val ) ~= 1
                    error( message( 'Slvnv:simcoverage:cvtest:InvalidMetricValue', fNames{ ii } ) );
                end
                if ~isa( val, 'logical' ) && ( val ~= 1 && val ~= 0 )
                    error( message( 'Slvnv:simcoverage:cvtest:InvalidMetricValue', fNames{ ii } ) );
                end
                value.( fNames{ ii } ) = logical( val );
            end
            this.settings = value;
        end




        function set.options( this, value )
            arguments
                this( 1, 1 )cv.coder.cvtest
                value( 1, 1 )struct{ mustBeNonempty }
            end

            this.assertReadOnly(  );

            fNames = fieldnames( value );
            idx = find( ~ismember( fNames, { 'covBoundaryRelTol', 'covBoundaryAbsTol', 'mcdcMode' } ), 1 );
            if ~isempty( idx )
                error( message( 'Slvnv:simcoverage:cvtest:InvalidOptionName', fNames{ idx } ) );
            end
            for ii = 1:numel( fNames )
                val = value.( fNames{ ii } );
                if numel( val ) ~= 1
                    error( message( 'Slvnv:simcoverage:cvtest:InvalidOptionValue', fNames{ ii } ) );
                end
                if fNames{ ii } == "mcdcMode"
                    if ~isa( val, 'SlCov.McdcMode' )
                        error( message( 'Slvnv:simcoverage:cvtest:InvalidOptionValue', fNames{ ii } ) );
                    end
                else
                    if ~isa( val, 'double' ) && ~isa( val, 'single' )
                        error( message( 'Slvnv:simcoverage:cvtest:InvalidOptionValue', fNames{ ii } ) );
                    end
                    value.( fNames{ ii } ) = double( val );
                end
            end
            this.options = value;
        end




        function set.label( this, value )
            this.assertReadOnly(  );
            this.label = value;
        end




        function set.setupCmd( this, value )
            this.assertReadOnly(  );
            this.setupCmd = value;
        end




        function set.filter( this, value )
            this.assertReadOnly(  );
            this.filter = value;
        end

        display( this )
    end

    methods ( Hidden )



        function copyTo( this, cvt )
            mCls = metaclass( this );
            for ii = 1:numel( mCls.PropertyList )
                prop = mCls.PropertyList( ii );


                ...
                    ...
                    ...
                    ...
                    ...
                    ...
                    cvt.( prop.Name ) = this.( prop.Name );
            end
        end




        function outObj = clone( this, varargin )
            if nargin == 2 && isa( varargin{ 1 }, 'cv.coder.cvtest' )
                outObj = varargin{ 1 };
            else
                outObj = cv.coder.cvtest(  );
            end
            this.copyTo( outObj );
        end
    end

    methods ( Access = protected )
        function assertReadOnly( this )
            if this.isLocked
                error( message( 'Slvnv:simcoverage:cvtest:ReadOnlyObject' ) );
            end
        end
    end
end


