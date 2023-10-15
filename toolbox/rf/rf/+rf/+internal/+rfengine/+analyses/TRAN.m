classdef TRAN < handle




    properties
        Circuit
        History
        Evaluator
        TransientEvaluator

        Residue
        Jacobian
        L
        U
        P

        Counter

        AllowedDeltaError
        AllowedResidueError

        Flambda
        Lambda = 0

        Tstep = [  ]
        Tstop = [  ]
        Tstart = 0
        Tmax = [  ]
        Events = [  ]
        T = [  ]
        X = [  ]
        Order = [  ]
        Method = 'ndf2'
        NewtonFailures
        LTEFailures
        NewtonIters

        Parameters
    end

    methods
        function self = TRAN( ckt, varargin )
            self.Circuit = ckt;
            self.Circuit.TRAN = self;

            self.Tstep = rf.internal.rfengine.Circuit.spice2double( varargin{ 1 } );
            self.Tstop = rf.internal.rfengine.Circuit.spice2double( varargin{ 2 } );
            if nargin > 3
                self.Tstart =  ...
                    rf.internal.rfengine.Circuit.spice2double( varargin{ 3 } );
            end
            if nargin > 4
                self.Tmax =  ...
                    rf.internal.rfengine.Circuit.spice2double( varargin{ 4 } );
            else
                self.Tmax = ( self.Tstop - self.Tstart ) / 10;
            end
        end

        function [ result, success ] = Execute( self, params )
            self.Parameters = params;
            beta = self.Parameters.OpConductanceToGround;

            if isa( self.Circuit, 'rf.internal.rfengine.Circuit' )

                computeGlobalConnectivity( self.Circuit, beta )
                self.Evaluator =  ...
                    rf.internal.rfengine.analyses.circuitEvaluator( self.Circuit, self );
                self.TransientEvaluator =  ...
                    rf.internal.rfengine.analyses.TRANEvaluator( self.Circuit, self );
            end

            fprintf( self, 'Transient analysis begins...\n' );


            events = [ self.Tstart, self.Tstop ];
            if ~isempty( self.Circuit.Vpwl )
                for k = 1:size( self.Circuit.Vpwl.Nodes, 2 )
                    events = [ events, self.Circuit.Vpwl.Structure( k ).time ];%#ok<AGROW>
                end
            end
            if ~isempty( self.Circuit.Ipwl )
                for k = 1:size( self.Circuit.Ipwl.Nodes, 2 )
                    events = [ events, self.Circuit.Ipwl.Structure( k ).time ];%#ok<AGROW>
                end
            end
            self.Events = unique( events );


            if ~isempty( self.Circuit.Vic )
                self.Circuit.Vic.Enabled = false;
            end
            if ~isempty( self.Circuit.Iic )
                self.Circuit.Iic.Enabled = false;
            end

            if isempty( self.Circuit.OP )
                self.Circuit.OP = rf.internal.rfengine.analyses.OP( self.Circuit );
                [ ~, success ] = Execute( self.Circuit.OP, params );%#ok<ASGLU>
            end


            initialGuess = [  ...
                self.Circuit.OP.I(  );
                self.Circuit.OP.V(  ) ];
            success = trans( self, initialGuess, self.Parameters.RelTol, self.Parameters.AbsTol, 10, beta );
            result = [  ];
            if success
                fprintf( self,  ...
                    'Transient analysis converged (Newton iterations: %d)\n\n',  ...
                    self.NewtonIters );
            else
                error( 'Transient analysis did not converge' );
            end
        end

        function xout = Interpolate( self, x, tout )
            arguments
                self
                x( :, : ){ mustBeNumeric, mustBeReal }
                tout( 1, : ){ mustBeNumeric, mustBeReal }
            end
            xout = zeros( size( x, 1 ), length( tout ) );

            idx = 1 + sum( self.T( : ) < tout );
            for k = 1:length( tout )
                if tout( k ) < self.T( 1 ) || tout( k ) > self.T( end  )
                    xout( :, k ) = NaN;
                elseif self.Order( idx( k ) ) == 0
                    xout( :, k ) = x( :, idx( k ) );
                else
                    t0 = self.T( idx( k ) );
                    t1 = self.T( idx( k ) - 1 );
                    x0 = x( :, idx( k ) );
                    x1 = x( :, idx( k ) - 1 );

                    if self.Order( idx( k ) ) == 1
                        a0 = ( tout( k ) - t0 ) / ( t1 - t0 );
                        a1 = ( tout( k ) - t1 ) / ( t0 - t1 );
                        xout( :, k ) = a0 * x0 + a1 * x1;
                    else
                        t2 = self.T( idx( k ) - 2 );
                        x2 = x( :, idx( k ) - 2 );

                        a0 = ( ( tout( k ) - t1 ) * ( tout( k ) - t2 ) ) / ( ( t0 - t1 ) * ( t0 - t2 ) );
                        a1 = ( ( tout( k ) - t0 ) * ( tout( k ) - t2 ) ) / ( ( t1 - t0 ) * ( t1 - t2 ) );
                        a2 = ( ( tout( k ) - t0 ) * ( tout( k ) - t1 ) ) / ( ( t2 - t0 ) * ( t2 - t1 ) );
                        xout( :, k ) = a0 * x0 + a1 * x1 + a2 * x2;
                    end
                end
            end
        end

        function out = V( self, nodeName, tout )
            out = self.X( self.Circuit.NumBranches + 1:end , : );
            if nargin > 1
                validateattributes( nodeName, { 'char', 'string' },  ...
                    { 'nonempty', 'scalartext' }, '', 'nodeName' )
                i = self.Circuit.NodeMap( nodeName ) - 1;
                out = out( i, : );
                if nargin > 2
                    out = self.Interpolate( out, tout );
                end
            end
        end

        function out = I( self, branchName, tout )
            out = self.X( 1:self.Circuit.NumBranches, : );
            if nargin > 1
                validateattributes( branchName, { 'char', 'string' },  ...
                    { 'nonempty', 'scalartext' }, '', 'branchName' )
                i = strcmpi( self.Circuit.VariableNames, branchName );
                out = out( i, : );
                if nargin > 2
                    out = self.Interpolate( out, tout );
                end
            end
        end

        function evaluate( self, x, time, h, method, prevT, prevFiv, prevQiv, beta )

            timeDomainEvaluate( self.TransientEvaluator, x, time, h, method, prevT, prevFiv, prevQiv, beta )

            freq = 0;
            freqDomainEvaluate( self.Evaluator, x, freq, true )


            self.Residue = [ self.Evaluator.Fiv - self.Lambda * self.Evaluator.Uiv;
                self.Evaluator.Fk ];



            self.AllowedResidueError =  ...
                abs( self.Residue ) * self.Parameters.RelTol +  ...
                self.Parameters.AbsTol;

            self.Jacobian = self.Evaluator.G + real( self.Evaluator.G_freq );
            [ self.L, self.U, self.P ] = lu( self.Jacobian );


        end

        function [ delta, success ] = solve( self, residue )

            lastwarn( '' );
            w1 = warning( 'off', 'MATLAB:singularMatrix' );
            w2 = warning( 'off', 'MATLAB:illConditionedMatrix' );
            w3 = warning( 'off', 'MATLAB:nearlySingularMatrix' );

            delta = full( self.U\( self.L\( self.P * residue ) ) );
            success = true;

            if ~isempty( lastwarn )

                if any( ~isfinite( delta ) ) ||  ...
                        norm( self.Jacobian * delta - residue ) ...
                        > 1e-3 * norm( residue )
                    success = false;
                    fprintf( self, lastwarn );
                end
            end


            warning( w1 )
            warning( w2 )
            warning( w3 )
        end

        function [ x, is_limited ] = update( ~, x, delta )




            vLimit = Inf;
            is_limited = any( abs( delta ) > vLimit );
            delta( delta > vLimit ) = vLimit;
            delta( delta <  - vLimit ) =  - vLimit;

            x = x - delta;
        end

        function converged = checkDelta( self, x, dx )
            converged =  ...
                all( abs( dx ) ...
                < self.Parameters.RelTol * abs( x ) + self.Parameters.AbsTol );
        end

        function converged = checkResidue( self )
            converged = all( abs( self.Residue ) < self.AllowedResidueError );
        end

        function [ x, iter, converged, Fiv, Qiv, JL, JU ] =  ...
                transientNewton( self, x0, reltol, abstol, maxiter, prevT, prevFiv, prevQiv, time, h, method, beta )
            converged = false;
            deltaConverged = false;
            x = x0;

            B = self.Circuit.NumBranches;
            IAbstol = abstol * ones( B, 1 );
            VAbstol = abstol * ones( size( x( B + 1:end  ) ) );
            absJkTimesIAbstol = abs( self.Circuit.Jk ) * IAbstol;

            for iter = 1:maxiter
                evaluate( self, x, time, h, method, prevT, prevFiv, prevQiv, beta );

                if any( ~isfinite( self.TransientEvaluator.Ftrans ) )
                    converged = false;
                    break
                end

                absJkTimesAbsXi = abs( self.Circuit.Jk ) * abs( x( 1:B ) );
                diagJi = diag( self.Evaluator.Ji );
                idx = find( diagJi );
                Fi = self.TransientEvaluator.Ftrans( 1:B );
                functionConverged =  ...
                    isempty( find( abs( self.Circuit.Jk( :, idx ) * ( Fi( idx ) ./ diagJi( idx ) ) ) >  ...
                    max( absJkTimesAbsXi * reltol, absJkTimesIAbstol ), 1 ) );

                if iter > 1 && functionConverged && deltaConverged
                    converged = true;
                    break
                end

                [ JL, JU ] = lu( self.TransientEvaluator.Jtrans );
                delta = JU\( JL\self.TransientEvaluator.Ftrans );

                if any( ~isfinite( delta ) )
                    converged = false;
                    break
                end

                dxi = delta( 1:B );
                dxv = delta( B + 1:end  );
                xv = x( B + 1:end  );
                deltaConverged = isempty( find( abs( dxv ) > max( reltol * abs( xv ), VAbstol ), 1 ) );

                if iter > 1 && functionConverged && deltaConverged
                    converged = true;
                    break
                end

                [ x, limited ] = update( self, x, delta );
                if limited
                    deltaConverged = false;
                end

                fprintf( self, '%-2d\t%.6e\t%.6e\t%.6e\t%d\t\t%d\t\t%d\n',  ...
                    iter, norm( self.TransientEvaluator.Ftrans, inf ), norm( dxi, inf ), norm( dxv, inf ),  ...
                    limited, functionConverged, deltaConverged );
            end
            Fiv = self.Evaluator.Fiv - self.Evaluator.Uiv;
            Qiv = self.Evaluator.Qiv;
            if iter > 1 && iter < maxiter
                fprintf( self, '%-2d\t%.6e\t%.6e\t%.6e\t%d\t\t%d\t\t%d\n',  ...
                    iter, norm( self.TransientEvaluator.Ftrans, inf ), norm( dxi, inf ), norm( dxv, inf ),  ...
                    limited, functionConverged, deltaConverged );
            end
        end

        function converged = trans( self, x0, reltol, abstol, maxiter, beta )
            methodOrder = 2;
            if ~isempty( self.Circuit.OPTIONS.Method )
                switch lower( self.Circuit.OPTIONS.Method )
                    case 'trap'
                        method = @trapezoidal;
                    case 'ndf2'
                        method = @ndf2;
                    case { 'bdf2', 'gear' }
                        method = @bdf2;
                    case { 'bdf1', 'be' }
                        method = @backwardEuler;
                        methodOrder = 1;
                end
            else
                method = @ndf2;
            end
            self.Method = method;

            fprintf( self, 'Tstop=%e\n', self.Tstop( end  ) );
            fprintf( self,  ...
                '\tNORM(F,INF)\t\tNORM(DXV,INF)\tNORM(DXI,INF)\tLIMITED\tRESIDUE\tDELTA\n' );
            t = self.Tstart;
            evaluate( self, x0, t, [  ], @noMethod, [  ], [  ], [  ], beta );
            prevQiv = self.Evaluator.Qiv;
            prevFiv = self.Evaluator.Fiv - self.Evaluator.Uiv;
            h = self.Tstep;
            hMax = 10 * self.Tmax;
            h = min( h, hMax );

            time = t;
            x = x0;
            self.Order = 0;
            N = self.Circuit.NumNodes;
            B = self.Circuit.NumBranches;
            historyLength = 3;

            newtonFactor = 0.1;
            newtonReltol = newtonFactor * reltol;
            newtonAbstol = newtonFactor * abstol;
            newtonIters = 0;
            newtonFailures = 0;

            errAllowed = max( abstol, reltol * abs( x0 ) );
            LTEfac = 7;
            lteFailures = 0;
            converged = true;
            nsteps = 0;

            for stopTime = self.Events( 2:end  )
                firstFailure = true;
                Qiv = self.Evaluator.Qiv;
                while true
                    if 1.1 * ( h + h ) >= stopTime - t
                        h = ( stopTime - t ) / 2;
                        t1 = t + h;
                        t2 = stopTime;
                    else
                        t1 = t + h;
                        t2 = t1 + h;
                    end

                    fprintf( self, 'step=%d t=%e h=%e\n', nsteps + 1, t, h );
                    [ x1, iter, converged, Fiv1, Qiv1 ] =  ...
                        transientNewton( self, x( :, end  ), newtonReltol, newtonAbstol,  ...
                        maxiter, [  ], [  ], Qiv, t1, h, @backwardEuler, beta );
                    newtons = 1;
                    newtonIters = newtonIters + iter;

                    if converged
                        fprintf( self, 'step=%d t=%e h=%e\n', nsteps + 2, t1, h );
                        [ x2, iter, converged, Fiv2, Qiv2 ] =  ...
                            transientNewton( self, x1, newtonReltol, newtonAbstol,  ...
                            maxiter, [  ], [  ], Qiv1, t2, h, @backwardEuler, beta );
                        newtons = newtons + 1;
                        newtonIters = newtonIters + iter;
                    end

                    if converged
                        fprintf( self, 'using h=%e at t=%e to estimate error\n', 2 * h, t );
                        [ x3, iter, converged ] =  ...
                            transientNewton( self, x2, newtonReltol, newtonAbstol,  ...
                            maxiter, [  ], [  ], Qiv, t2, 2 * h, @backwardEuler, beta );
                        newtons = newtons + 1;
                        newtonIters = newtonIters + iter;
                    end

                    if ~converged
                        fprintf( self, 'transientNewton failed\n' );
                        newtonFailures = newtonFailures + newtons;
                        h = h * 0.3;
                        if h < 16 * eps * max( abs( t ), abs( t + hMax ) )
                            warning( 'h < hmin failure at t=%e\n', t )
                            break
                        end
                    else
                        err = 0.5 * abs( x3 - x2 );
                        [ maxRatio, idxMaxRatio ] =  ...
                            max( err( B + 1:end  ) ./ ( LTEfac * errAllowed( B + 1:end  ) ) );
                        if maxRatio > 1
                            fprintf( self, 'LTE failed maxRatio %e index %d\n',  ...
                                maxRatio, idxMaxRatio + B );
                            lteFailures = lteFailures + 3;
                            reductionFactor =  ...
                                max( 0.01, 0.7 / maxRatio ^ ( 1 / 2 ) );
                            if firstFailure
                                firstFailure = false;
                            else
                                reductionFactor = min( reductionFactor, 0.5 );
                            end
                            h = reductionFactor * h;
                            if h < 16 * eps * max( abs( t ), abs( t + hMax ) )
                                warning( 'h < hmin failure at t=%e\n', t )
                                break
                            end
                        else
                            fprintf( self, '\n' );
                            break
                        end
                    end
                    fprintf( self, '\n' );
                end

                if converged
                    time( end  + ( 1:2 ) ) = [ t1, t2 ];
                    x( :, end  + ( 1:2 ) ) = [ x1, x2 ];
                    self.Order( end  + ( 1:2 ) ) = ones( 1, 2 );
                    nsteps = nsteps + 2;
                    prevQiv( :, end  + ( 1:2 ) ) = [ Qiv1, Qiv2 ];
                    prevFiv( :, end  + ( 1:2 ) ) = [ Fiv1, Fiv2 ];
                    prevQiv( :, 1:( size( prevQiv, 2 ) - historyLength ) ) = [  ];
                    prevFiv( :, 1:( size( prevFiv, 2 ) - historyLength ) ) = [  ];
                else
                    break
                end

                errAllowed = max( errAllowed,  ...
                    reltol * max( abs( [ x( :, end  - 1 ), x( :, end  ) ] ), [  ], 2 ) );
                t = time( end  );
                if t == stopTime
                    continue
                end
                if methodOrder == 2
                    h = 2 * h;
                end

                inverseOrderPlus1 = 1 / ( methodOrder + 1 );
                while t < stopTime
                    firstFailure = true;
                    while true
                        if 1.1 * h > stopTime - t
                            h = stopTime - t;
                            tnew = stopTime;
                        else
                            tnew = t + h;
                        end
                        fprintf( self, 'step=%d t=%e h=%e\n', nsteps + 1, t, h );


                        h1 = tnew - time( end  - 1 );
                        h2 = tnew - time( end  - 2 );
                        if methodOrder == 2
                            a = ( h2 * h1 ) / ( ( t - time( end  - 2 ) ) * ( t - time( end  - 1 ) ) );
                            a1 = ( h2 * h ) / ( ( time( end  - 1 ) - time( end  - 2 ) ) * ( time( end  - 1 ) - t ) );
                            a2 = ( h1 * h ) / ( ( time( end  - 2 ) - time( end  - 1 ) ) * ( time( end  - 2 ) - t ) );
                            xPredicted = a * x( :, end  ) + a1 * x( :, end  - 1 ) + a2 * x( :, end  - 2 );
                        else
                            a = h1 / ( t - time( end  - 1 ) );
                            a1 = h / ( time( end  - 1 ) - t );
                            xPredicted = a * x( :, end  ) + a1 * x( :, end  - 1 );
                        end

                        [ xnew, iter, converged, Fiv, Qiv, JL, JU ] =  ...
                            transientNewton( self, xPredicted, newtonReltol, newtonAbstol,  ...
                            maxiter, time( end  - 2:end  ), prevFiv, prevQiv, tnew, h, method, beta );
                        newtonIters = newtonIters + iter;

                        if ~converged
                            fprintf( self, 'transientNewton failed\n' );
                            newtonFailures = newtonFailures + 1;
                            h = h * 0.3;
                            if h < 16 * eps * max( abs( t ), abs( t + hMax ) )
                                warning( 'h < hmin failure at t=%e\n', t )
                                break
                            end
                        else
                            if methodOrder == 2
                                cnew = Qiv / ( h * h1 * h2 );
                                c = prevQiv( :, end  ) /  ...
                                    (  - h * ( t - time( end  - 2 ) ) * ( t - time( end  - 1 ) ) );
                                c1 = prevQiv( :, end  - 1 ) /  ...
                                    (  - h1 * ( time( end  - 1 ) - t ) * ( time( end  - 1 ) - time( end  - 2 ) ) );
                                c2 = prevQiv( :, end  - 2 ) /  ...
                                    (  - h2 * ( time( end  - 2 ) - t ) * ( time( end  - 2 ) - time( end  - 1 ) ) );
                                Qttt = 6 * ( cnew + c + c1 + c2 );
                                if isequal( method, @trapezoidal )

                                    Qerr = [ (  - h ^ 2 / 6 ) * Qttt;sparse( N - 1, 1 ) ];
                                elseif isequal( method, @bdf2 )

                                    Qerr = [ (  - h * h1 / 6 ) * Qttt;sparse( N - 1, 1 ) ];
                                else

                                    Qerr = [ (  - h * h1 / 12 ) * Qttt;sparse( N - 1, 1 ) ];
                                end
                            else
                                cnew = Qiv / ( h * h1 );
                                c = prevQiv( :, end  ) / (  - h * ( t - time( end  - 1 ) ) );
                                c1 = prevQiv( :, end  - 1 ) / (  - h1 * ( time( end  - 1 ) - t ) );
                                Qtt = 2 * ( cnew + c + c1 );

                                Qerr = [ (  - h / 2 ) * Qtt;sparse( N - 1, 1 ) ];
                            end
                            err = full( abs( JU\( JL\Qerr ) ) );
                            [ maxRatio, idxMaxRatio ] =  ...
                                max( err( B + 1:end  ) ./ ( LTEfac * errAllowed( B + 1:end  ) ) );
                            if maxRatio > 1
                                fprintf( self,  ...
                                    'LTE failed, maxRatio=%e index=%d\n',  ...
                                    maxRatio, idxMaxRatio + B );
                                lteFailures = lteFailures + 1;
                                reductionFactor =  ...
                                    max( 0.1, 0.7 / maxRatio ^ inverseOrderPlus1 );
                                if firstFailure
                                    firstFailure = false;
                                else
                                    reductionFactor =  ...
                                        min( reductionFactor, 0.5 );
                                end
                                h = reductionFactor * h;
                                if h < 16 * eps * max( abs( t ), abs( t + hMax ) )
                                    warning( 'h < hmin failure at t=%e\n', t )
                                    break
                                end
                            else
                                break
                            end
                        end
                    end

                    if converged
                        time( end  + 1 ) = tnew;%#ok<AGROW>
                        x( :, end  + 1 ) = xnew;%#ok<AGROW>
                        self.Order( end  + 1 ) = methodOrder;
                        nsteps = nsteps + 1;
                        prevQiv( :, end  + 1 ) = Qiv;%#ok<AGROW>
                        prevFiv( :, end  + 1 ) = Fiv;%#ok<AGROW>
                        prevQiv( :, 1 ) = [  ];
                        prevFiv( :, 1 ) = [  ];
                        inverseGrowthFactor = maxRatio ^ inverseOrderPlus1;
                        ratio = hMax / h;
                        if 0.7 < inverseGrowthFactor * ratio
                            ratio = 0.7 / inverseGrowthFactor;
                        end
                        ratio = min( 2, max( 0.2, ratio ) );
                        if abs( ratio - 1 ) > 0.2
                            h = ratio * h;
                        end
                        h = min( h, hMax );
                    else
                        break
                    end

                    errAllowed = max( errAllowed, reltol * abs( x( :, end  ) ) );
                    t = time( end  );
                    fprintf( self, '\n' );
                end

                if ~converged
                    break
                end

                if methodOrder == 2
                    h = 0.5 * ( time( end  ) - time( end  - 1 ) );
                end
            end

            fprintf( self, 'converged=%d steps=%d newtonFailures=%d lteFailures=%d newtonIters=%d avgNewtons=%.1f\n',  ...
                converged, nsteps, newtonFailures, lteFailures, newtonIters,  ...
                newtonIters / ( nsteps + newtonFailures + lteFailures ) );

            self.X = x;
            self.T = time;
            self.NewtonFailures = newtonFailures;
            self.LTEFailures = lteFailures;
            self.NewtonIters = newtonIters;
        end

        function fprintf( self, varargin )
            if self.Parameters.OpVerbose
                fprintf( varargin{ : } );
            end
        end
    end
end

