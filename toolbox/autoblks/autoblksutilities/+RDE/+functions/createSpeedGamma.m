function v=createSpeedGamma(t,varargin)





















    p=inputParser();
    addParameter(p,'MaxSpeed',60/3.6);
    addParameter(p,'AverageSpeed',30/3.6);
    addParameter(p,'MinSpeed',0);
    addParameter(p,'TimeStep',20);
    addParameter(p,'ShapeParameter',1);
    addParameter(p,'MinSpeedMethod','Saturate');
    addParameter(p,'Plot',false);
    addParameter(p,'InterpMethod','linear');
    parse(p,varargin{:});
    params=p.Results;


    N=5*length(t);
    tNew=(1:N)';
    n=floor(N/params.TimeStep);

    tc=linspace(1,N,n);

    pd=makedist('Gamma',...
    'a',params.ShapeParameter,'b',1/params.ShapeParameter);
    yc=pd.random(size(tc));

    yc=params.MaxSpeed-yc*(params.MaxSpeed-params.AverageSpeed);

    v=interp1(tc,yc,tNew,params.InterpMethod);


    switch params.MinSpeedMethod
    case 'Saturate'

        v=max(v,params.MinSpeed);
        v(numel(t)+1:end)=[];
    case 'Remove'

        v(v<=params.MinSpeed)=[];
        v(numel(t)+1:end)=[];
    end


    if params.Plot
figure
        subplot(1,2,1)
        plot(t,v*3.6);
        hold on
        yline(mean(v)*3.6,'--');
        hold off
        subplot(1,2,2)
        histogram(v*3.6,'NumBins',50);
    end
end