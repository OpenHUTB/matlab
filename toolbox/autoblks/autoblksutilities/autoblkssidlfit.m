function [ netParams_double, muU, muY, sigU, sigY ] = autoblkssidlfit( EngInputs, EngOutputs, options )

Ts = options.Ts;

Throttle = EngInputs( :, 2 );
Wastegate = EngInputs( :, 3 );
Speed = EngInputs( :, 1 );
IntCamPhs = EngInputs( :, 6 );
ExhCamPhs = EngInputs( :, 7 );
SpkDelta = EngInputs( :, 9 );
Lambda = EngInputs( :, 10 );

MAP = EngOutputs( :, 2 );
Airflow = EngOutputs( :, 6 );
Torque = EngOutputs( :, 1 );
ThrottleInPrs = EngOutputs( :, 12 );
ExhTemp = EngOutputs( :, 4 );

U = [ MAP, Wastegate, Speed, IntCamPhs, ExhCamPhs, SpkDelta, Lambda ];
X = [ Airflow, Torque, ThrottleInPrs, ExhTemp ];


if size( EngOutputs, 2 ) == 14
    w = repmat( EngOutputs( :, 14 ), 1, size( X, 2 ) );
else
    w = ones( size( Speed, 1 ), size( X, 2 ) );
end


windowSize = round( 0.1 / Ts );
U = smoothdata( U, 1, "gaussian", windowSize );
X = smoothdata( X, 1, "gaussian", windowSize );


downsamplemult = options.downsamplemult;
U = U( 1:downsamplemult:end , : );
X = X( 1:downsamplemult:end , : );
w = w( 1:downsamplemult:end , : );
Ts = Ts * downsamplemult;
options.Ts = Ts;
options.timesteps = ( 0:options.predictTimesteps ) * Ts;

nrows = round( size( U, 1 ) / 2 );
U = U( 1:nrows, : );
X = X( 1:nrows, : );
w = w( 1:nrows, : );


options.w = w;








Y = X;


muU = mean( U );
sigU = std( U );

muY = mean( Y );
sigY = std( Y );

Uscaled = ( U - muU ) ./ sigU;
Yscaled = ( Y - muY ) ./ sigY;


Uscaled = Uscaled';
Yscaled = Yscaled';


if options.addDithering
    Uscaled = Uscaled .* ( 1 + options.noiseLevel * randn( size( Uscaled ) ) );
    Yscaled = Yscaled .* ( 1 + options.noiseLevel * randn( size( Yscaled ) ) );
end


nu = size( Uscaled, 1 );
ny = size( Yscaled, 1 );
nx = ny;


if options.useAugmentation
    ny = nx + nx;
else
    ny = nx;
end


inputSize = nu + ny;
outputSize = ny;
hiddenSize = options.hiddenSize;

neuralODEParameters = initNetwork_fcn( inputSize, hiddenSize, outputSize );


options.numObservations = size( Yscaled, 2 );

if ~isfield( options, 'numIterationsPerEpoch' )
    options.numIterationsPerEpoch = floor( options.numObservations ./ options.miniBatchSize );
end

options.numTrainingTimesteps = size( Yscaled, 2 ) - 1;

tic
neuralODEParameters = trainNeuralODE_fcn( neuralODEParameters, Uscaled, Yscaled, options );
neuralODETrainingTime = toc


netParams_double = extractNetworkParam_fcn( neuralODEParameters, options );

end


function [ neuralODEParameters, trainFig ] = trainNeuralODE_fcn( neuralODEParameters, U, Y, options )










trainFig = figure;
clf
lossLine = animatedline( 'Color', 'k', 'Marker', 'o', 'MarkerSize', 3 );
ylim( [ 0, inf ] )
xlabel( "Iteration" )
ylabel( "Loss" )
grid on
set( gca, 'YScale', 'log' );

stopbutton = uicontrol( 'Style', 'togglebutton', 'String', 'Stop', 'Value', 0, 'Position', [ 5, 5, 70, 20 ] );

averageGrad = [  ];
averageSqGrad = [  ];
start = tic;


switch options.dlode45GradientMode
    case "direct"
        mdlGrd_fcn = @modelGradients;
    case "adjoint"
        mdlGrd = @modelGradients;
        mdlGrd_fcn = dlaccelerate( mdlGrd );


        clearCache( mdlGrd_fcn );
end


switch options.splineInterpolant
    case "pchip"
        UallInterp = pchip( options.Ts * ( 0:size( U, 2 ) - 1 ), U );
    case "cubic"
        UallInterp = spline( options.Ts * ( 0:size( U, 2 ) - 1 ), U );
end


useAugmentation = options.useAugmentation;
augmentationSize = options.augmentationSize;
perturb_tspan = options.perturb_tspan;
Ts = options.Ts;
odeSolver = options.odeSolver;
maxStep = options.maxStep;
relTol = options.relTol;
absTol = options.absTol;
dlode45GradientMode = options.dlode45GradientMode;
numIterationsPerEpoch = options.numIterationsPerEpoch;
initialLearnRate = options.initialLearnRate;
learnRateDecay = options.learnRateDecay;
miniBatchSize = options.miniBatchSize;
predictTimesteps = options.predictTimesteps;
threshLoss = options.LossThreshold;
gradDecay = options.gradDecay;
sqGradDecay = options.sqGradDecay;
momentum = options.momentum;
optimizer = options.optimizer;
lossFcn = options.lossFcn;
numEpochs = options.numEpochs;
actFun = options.actFun;
timeLimit = options.timeLimit;
displayFrequency = options.displayFrequency;

loss_w = options.w;


vel = [  ];

iter = 0;

for epoch = 1:options.numEpochs

    for iteration = 1:numIterationsPerEpoch
        iter = iter + 1;


        learnRate = initialLearnRate / ( 1 + learnRateDecay * iter );





        [ dlx0, weights, minibatch_time_location, targets, numTimesPerObs ] = createMiniBatch(  ...
            Y, predictTimesteps, miniBatchSize, Ts, perturb_tspan, loss_w );

        [ gradients, loss ] = dlfeval(  ...
            @( ts, x, p, T )mdlGrd_fcn( ts, x, p, T, weights, numTimesPerObs, minibatch_time_location, UallInterp,  ...
            dlode45GradientMode, actFun, odeSolver, lossFcn, useAugmentation, augmentationSize,  ...
            maxStep, relTol, absTol ),  ...
            Ts, dlx0, neuralODEParameters, targets );

        currentLoss = double( extractdata( loss ) );
        if currentLoss < threshLoss
            break
        end
        switch optimizer
            case "adam"

                [ neuralODEParameters, averageGrad, averageSqGrad ] = adamupdate(  ...
                    neuralODEParameters, gradients,  ...
                    averageGrad, averageSqGrad, iter,  ...
                    learnRate, gradDecay, sqGradDecay );
            case "sgdm"

                [ neuralODEParameters, vel ] = sgdmupdate(  ...
                    neuralODEParameters, gradients,  ...
                    vel, learnRate, momentum );
            case "rmsprop"
                [ neuralODEParameters, averageSqGrad ] = rmspropupdate(  ...
                    neuralODEParameters, gradients,  ...
                    averageSqGrad, learnRate );
        end

        if mod( iter, displayFrequency ) == 0
            D = duration( 0, 0, toc( start ), 'Format', 'hh:mm' );
            addpoints( lossLine, iter, currentLoss );
            title( "Epoch: " + epoch + "/" + numEpochs + ", Iter: " + mod( iter, numIterationsPerEpoch ) + "/" + numIterationsPerEpoch + ", Loss: " + gather( currentLoss ) + ", Time: " + string( D ) )
            drawnow
        end


        stoptraining = get( stopbutton, 'Value' );

        if stoptraining || toc( start ) > timeLimit
            return ;
        end

    end

end

end



function [ X0, weights, minibatch_time_location, targets, numTimesPerObs ] =  ...
    createMiniBatch( X, numTimesPerObs, miniBatchSize, Ts, perturb_tspan, loss_w )





numTimesPerObs = numTimesPerObs + randi( [  - perturb_tspan, perturb_tspan ], 1 );


dataLength = size( X, 2 );
s = randperm( dataLength - numTimesPerObs, miniBatchSize );


minibatch_time_location = ( s - 1 ) * Ts;


X0 = dlarray( X( :, s ) );


weights = loss_w( s );


targets = zeros( [ size( X0, 1 ), miniBatchSize ] );


for k = 1:miniBatchSize
    targets( :, k ) = X( :, s( k ) + numTimesPerObs );
end

end

function [ gradients, loss ] = modelGradients( Ts, dlX0, neuralOdeParameters, targets, weights,  ...
    predictTimesteps, minibatch_time_location, UallInterp, dlode45GradientMode, actFun,  ...
    odeSolver, lossFcn,  ...
    useAugmentation, augmentationSize, maxStep, relTol, absTol )







tspan = ( 1:predictTimesteps ) * Ts - Ts;


[ dlX, dlU ] = ODESolve( tspan, dlX0, neuralOdeParameters, minibatch_time_location,  ...
    UallInterp, actFun, odeSolver, dlode45GradientMode,  ...
    useAugmentation, augmentationSize,  ...
    Ts, predictTimesteps, maxStep, relTol, absTol );





switch lossFcn
    case "l1loss"
        loss = l1loss( dlX, targets,  ...
            'NormalizationFactor', 'all-elements',  ...
            'DataFormat', 'CB' );
    case "l2loss"
        loss = l2loss( dlX, targets,  ...
            'NormalizationFactor', 'all-elements',  ...
            'DataFormat', 'CB' );
    case "huber"
        loss = huber( dlX, targets,  ...
            'NormalizationFactor', 'all-elements',  ...
            'DataFormat', 'CB',  ...
            'TransitionPoint', 0.2 );
    case "msle"

        loss = sum( ( log( abs( dlX + 1 ) ./ abs( targets + 1 ) ) ) .^ 2, 'all' ) ./ size( dlX, 2 );
    case "custom"

        loss = iComputeLoss( dlU, dlX, targets, weights );
end



gradients = dlgradient( loss, neuralOdeParameters );

end

function [ X, U ] = ODESolve( tspan, X0, neuralOdeParameters, minibatch_time_location,  ...
    UallInterp, actFun, odeSolver, dlode45GradientMode,  ...
    useAugmentation, augmentationSize,  ...
    Ts, predictTimesteps, maxStep, relTol, absTol )



maxStepSize = Ts * predictTimesteps / maxStep;

if useAugmentation
    nx = size( X0, 1 );

    X0 = cat( 1, X0, zeros( [ augmentationSize * nx, size( X0, 2 ) ], "like", X0 ) );
end


t = linspace( tspan( 1 ), tspan( end  ), maxStep );




if isdlarray( t )
    t = extractdata( t );
end


U = ppval( UallInterp, minibatch_time_location + t( end  ) );


switch odeSolver
    case "dlode45"
        X = dlode45( @( t, x, p )odeModel_fcn( t, x, p, minibatch_time_location, UallInterp, actFun ),  ...
            [ tspan( 1 ), tspan( end  ) ], X0, neuralOdeParameters,  ...
            DataFormat = 'CB',  ...
            MaxStepSize = maxStepSize,  ...
            RelativeTolerance = relTol,  ...
            AbsoluteTolerance = absTol,  ...
            GradientMode = dlode45GradientMode );

    case "dleuler"

        h = diff( t );

        x = X0;

        fcn = @( t, x )odeModel_fcn( t, x, neuralOdeParameters, minibatch_time_location, UallInterp, actFun );
        for n = 1:numel( h )

            x = x + h( n ) * fcn( t( n ), x );
        end

        X = single( x );

    case "dlheun"

        h = diff( t );

        x = X0;

        fcn = @( t, x )odeModel_fcn( t, x, neuralOdeParameters, minibatch_time_location, UallInterp, actFun );
        for n = 1:numel( h )

            y = fcn( t( n ), x );
            xhat = x + h( n ) * y;

            x = x + 0.5 * h( n ) * ( y + fcn( t( n ) + h( n ), xhat ) );
        end

        X = single( x );

    case "dlRK2"

        h = diff( t );

        x = X0;

        fcn = @( t, x )odeModel_fcn( t, x, neuralOdeParameters, minibatch_time_location, UallInterp, actFun );
        for n = 1:numel( h )

            k1 = fcn( t( n ), x );
            k2 = fcn( t( n ) + h( n ), x + k1 );

            x = x + ( 1 / 2 ) * ( k1 + k2 ) * h( n );
        end

        X = single( x );

    case "dlRK4"

        h = diff( t );

        x = X0;

        fcn = @( t, x )odeModel_fcn( t, x, neuralOdeParameters, minibatch_time_location, UallInterp, actFun );
        for n = 1:numel( h )

            k1 = fcn( t( n ), x );
            k2 = fcn( t( n ) + 0.5 * h( n ), x + 0.5 * h( n ) * k1 );
            k3 = fcn( t( n ) + 0.5 * h( n ), x + 0.5 * h( n ) * k2 );
            k4 = fcn( t( n ) + h( n ), x + k3 * h( n ) );

            x = x + ( 1 / 6 ) * ( k1 + 2 * k2 + 2 * k3 + k4 ) * h( n );
        end

        X = single( x );

    case "dlRK45"

        h = diff( t );

        x = X0;

        fcn = @( t, x )odeModel_fcn( t, x, neuralOdeParameters, minibatch_time_location, UallInterp, actFun );
        for n = 1:numel( h )
            [ x, ~ ] = RK45( fcn, x, t( n ), h( n ) );
        end

        X = single( x );

    case "dlRKF45"

        h = diff( t );

        fcn = @( t, x )odeModel_fcn( t, x, neuralOdeParameters, minibatch_time_location, UallInterp, actFun );

        x = RKF45( fcn, tspan( 1 ), tspan( end  ), X0, mean( h ), absTol, relTol );

        X = single( x );
end

if useAugmentation

    X( nx + 1:end , : ) = [  ];
end

end


function y = RKF45( f, a, b, ya, h, atol, rtol )















c30 = 3 / 8;
c31 = 3 / 32;
c32 = 9 / 32;
c40 = 12 / 13;
c41 = 1932 / 2197;
c42 =  - 7200 / 2197;
c43 = 7296 / 2197;
c51 = 439 / 216;
c52 =  - 8;
c53 = 3680 / 513;
c54 =  - 845 / 4104;
c61 =  - 8 / 27;
c62 = 2;
c63 =  - 3544 / 2565;
c64 = 1859 / 4104;
c65 =  - 11 / 40;
cz1 = 16 / 135;
cz3 = 6656 / 12825;
cz4 = 28561 / 56430;
cz5 =  - 9 / 50;
cz6 = 2 / 55;
ce1 = 1 / 360;
ce3 =  - 128 / 4275;
ce4 =  - 2197 / 75240;
ce5 = 1 / 50;
ce6 = 2 / 55;

alpha = 0.8;
k = 0;

i = 1;
t = a;

y = ya;
wi = ya;

lastit = 0;
while lastit == 0

    if t + 1.1 * h > b
        h = b - t;
        lastit = 1;
    end


    s1 = f( t, wi );
    s2 = f( t + 0.25 * h, wi + 0.25 * h * s1 );
    s3 = f( t + c30 * h, wi + c31 * h * s1 + c32 * h * s2 );
    s4 = f( t + c40 * h, wi + c41 * h * s1 + c42 * h * s2 + c43 * h * s3 );
    s5 = f( t + h, wi + c51 * h * s1 + c52 * h * s2 + c53 * h * s3 + c54 * h * s4 );
    s6 = f( t + 0.5 * h, wi + c61 * h * s1 + c62 * h * s2 + c63 * h * s3 + c64 * h * s4 + c65 * h * s5 );
    z = wi + h * ( cz1 * s1 + cz3 * s3 + cz4 * s4 + cz5 * s5 + cz6 * s6 );
    e = h * sqrt( sum( ( ce1 * s1 + ce3 * s3 + ce4 * s4 + ce5 * s5 + ce6 * s6 ) .^ 2, 'all' ) );


    T = rtol * sqrt( sum( wi .^ 2, 'all' ) ) + atol;
    if e <= T
        t = t + h;
        h = alpha * h * ( T / e ) ^ 0.2;
        i = i + 1;
        wi = z;
        y = z;
        k = 0;
    elseif k == 0
        h = alpha * h * ( T / e ) ^ 0.2;
        k = k + 1;
        lastit = 0;
    else
        h = h / 2;
        lastit = 0;
    end

end
end

function [ y, out ] = RK45( func, y, x0, h )















a2 = 0.25;
a3 = 0.375;
a4 = 12 / 13;
a6 = 0.5;
b21 = 0.25;
b31 = 3 / 32;
b32 = 9 / 32;
b41 = 1932 / 2197;
b42 =  - 7200 / 2197;
b43 = 7296 / 2197;
b51 = 439 / 216;
b52 =  - 8;
b53 = 3680 / 513;
b54 =  - 845 / 4104;
b61 =  - 8 / 27;
b62 = 2;
b63 =  - 3544 / 2565;
b64 = 1859 / 4104;
b65 =  - 11 / 40;
c1 = 25 / 216;
c3 = 1408 / 2565;
c4 = 2197 / 4104;
c5 =  - 0.20;
d1 = 1 / 360;
d3 =  - 128 / 4275;
d4 =  - 2197 / 75240;
d5 = 0.02;
d6 = 2 / 55;
h2 = a2 * h;h3 = a3 * h;h4 = a4 * h;h6 = a6 * h;
k1 = func( x0, y );
k2 = func( x0 + h2, y + h * b21 * k1 );
k3 = func( x0 + h3, y + h * ( b31 * k1 + b32 * k2 ) );
k4 = func( x0 + h4, y + h * ( b41 * k1 + b42 * k2 + b43 * k3 ) );
k5 = func( x0 + h, y + h * ( b51 * k1 + b52 * k2 + b53 * k3 + b54 * k4 ) );
k6 = func( x0 + h6, y + h * ( b61 * k1 + b62 * k2 + b63 * k3 + b64 * k4 + b65 * k5 ) );
y = y + h * ( c1 * k1 + c3 * k3 + c4 * k4 + c5 * k5 );
out = d1 * k1 + d3 * k3 + d4 * k4 + d5 * k5 + d6 * k6;
end



function y = odeModel_fcn( t, x, params, delta_ts, UallInterp, actFun )








if isdlarray( t )
    t = extractdata( t );
end


u = ppval( UallInterp, t + delta_ts );


y = [ x;u ];


actfun = cell( 1, length( params.fcLayer ) );
for k = 1:length( actfun )
    switch actFun{ k }
        case "gelu"
            actfun{ k } = @gelu;
        case "tanh"
            actfun{ k } = @tanh;
        case "radbas"
            actfun{ k } = @radbas;
    end
end


y = actfun{ 1 }( params.inputLayer.Weights * y + params.inputLayer.Bias );


for k = 1:length( params.fcLayer )
    y = actfun{ k }( params.fcLayer( k ).Weights * y + params.fcLayer( k ).Bias );
end


y = params.outputLayer.Weights * y + params.outputLayer.Bias;
end

function y = gelu( x )




y = ( x / 2 ) .* ( 1 + tanh( sqrt( 2 / pi ) * ( x + 0.044715 * x .^ 3 ) ) );
end

function y = radbas( x )

y = exp(  - x .^ 2 );
end


function netParams = initNetwork_fcn( inputSize, hiddenSize, outputSize )















hiddenSize = [ hiddenSize( 1 ), hiddenSize ];


sz = [ hiddenSize( 1 ), inputSize ];
netParams.inputLayer = struct( "Weights", initializeGlorot( sz, sz( 1 ), sz( 2 ) ),  ...
    "Bias", initializeZeros( [ sz( 1 ), 1 ] ) );


for k = 1:length( hiddenSize ) - 1
    sz = [ hiddenSize( k + 1 ), hiddenSize( k ) ];
    netParams.fcLayer( k ) = struct( "Weights", initializeGlorot( sz, sz( 1 ), sz( 2 ) ),  ...
        "Bias", initializeZeros( [ sz( 1 ), 1 ] ) );
end



sz = [ outputSize, hiddenSize( end  ) ];
netParams.outputLayer = struct( "Weights", initializeGlorot( sz, sz( 1 ), sz( 2 ) ),  ...
    "Bias", initializeZeros( [ sz( 1 ), 1 ] ) );

end


function parameter = initializeZeros( sz, className )

arguments
    sz
    className = 'single'
end

parameter = zeros( sz, className );
parameter = dlarray( parameter );

end


function weights = initializeGlorot( sz, numOut, numIn, className )

arguments
    sz
    numOut
    numIn
    className = 'single'
end

Z = 2 * rand( sz, className ) - 1;
bound = sqrt( 6 / ( numIn + numOut ) );

weights = bound * Z;
weights = dlarray( weights );

end

function netParams = extractNetworkParam_fcn( net, options )


netParams = struct(  );


netParams.inputLayer = struct( "Weights", double( extractdata( net.inputLayer.Weights ) ),  ...
    "Bias", double( extractdata( net.inputLayer.Bias ) ) );


netParams.fcLayerSize = length( net.fcLayer );
for k = 1:length( net.fcLayer )
    netParams.( "fcLayer" + k + "Weights" ) = double( extractdata( net.fcLayer( k ).Weights ) );
    netParams.( "fcLayer" + k + "Bias" ) = double( extractdata( net.fcLayer( k ).Bias ) );
end


netParams.outputLayer = struct( "Weights", double( extractdata( net.outputLayer.Weights ) ),  ...
    "Bias", double( extractdata( net.outputLayer.Bias ) ) );


for k = 1:length( options.actFun )
    netParams.( "actFun_" + k ) = options.actFun{ k };
end

end


function loss = iComputeLoss( dlU, dlX, targets, w )

useCustomLoss = true;

if useCustomLoss

    loss = sum( ( w .* ( dlX - targets ) ) .^ 2, 'all' );
else

    loss = sum( ( dlX - targets ) .^ 2, 'all' );
end


loss = real( loss ) ./ size( dlX, 2 );
end


