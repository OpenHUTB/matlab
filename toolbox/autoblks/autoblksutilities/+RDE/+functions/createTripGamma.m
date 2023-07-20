function v=createTripGamma(t,params,varargin)














    p=inputParser();
    addParameter(p,'TransitionTime',10);
    parse(p,varargin{:});


    m1=params.UrbanAverageSpeedRange;
    v1Avg=m1(1)+rand()*diff(m1);
    m2=params.RuralAverageSpeedRange;
    v2Avg=m2(1)+rand()*diff(m2);
    m3=params.MotorwayAverageSpeedRange;
    v3Avg=m3(1)+rand()*diff(m3);


    r=rand(1,3);
    r=r./[v1Avg,v2Avg,v3Avg];
    r=r/sum(r);
    r=r*t(end);
    t1=r(1);
    t2=r(1)+r(2);


    v1=RDE.functions.createSpeedGamma(t,'MinSpeed',0,'MaxSpeed',60/3.6,...
    'AverageSpeed',v1Avg,'ShapeParameter',params.ShapeParameter);
    v2=RDE.functions.createSpeedGamma(t,'MinSpeed',0,'MaxSpeed',90/3.6,...
    'AverageSpeed',v2Avg,'ShapeParameter',params.ShapeParameter,...
    'MinSpeedMethod','Remove');
    v3=RDE.functions.createSpeedGamma(t,'MinSpeed',91/3.6,'MaxSpeed',145/3.6,...
    'AverageSpeed',v3Avg,'ShapeParameter',params.ShapeParameter,...
    'MinSpeedMethod','Remove');


    l=p.Results.TransitionTime;
    k1=max(0,min(((t1+l/2)-t)/l,1));
    k2=max(0,min(((t2+l/2)-t)/l,1))-k1;
    k3=ones(size(t))-(k1+k2);
    v=k1.*v1+k2.*v2+k3.*v3;


    v=smoothdata(v,params.SmoothingMethod,params.SmoothingWindowLength);
end