function[accessTable,inView]=accessIntervals(time,lla,GS_latlon,varargin)











































    if~builtin('license','checkout','Aerospace_Blockset')||...
        ~builtin('license','checkout','Aerospace_Toolbox')
        error(message('spacecraft:cubesat:licenseFailAero'));
    end

    narginchk(3,4);
    [varargin{:}]=convertStringsToChars(varargin{:});
    p=inputParser;

    addRequired(p,'time',@(x)validateattributes(x,{'datetime'},{'column'},'generateAccessTable',...
    'time'));
    addRequired(p,'lla',@(x)validateattributes(x,{'numeric'},{'ncols',3},'generateAccessTable',...
    'Geodetic Lat, Lon, Alt (deg, deg, m)'));
    addRequired(p,'GS_latlon',@(x)validateattributes(x,{'numeric'},{'numel',2},'generateAccessTable',...
    'Ground station latitude'));
    addOptional(p,'method','spherical',@(x)validateattributes(x,{'char','string'},...
    {},'generateAccessTable','Method'));
    parse(p,time,lla,GS_latlon,varargin{:});
    time=p.Results.time;
    lla=p.Results.lla;
    GS_lat=p.Results.GS_latlon(1);
    GS_lon=p.Results.GS_latlon(2);
    size_lla=size(lla,1);
    if contains(p.Results.method,'sphe')
        r_e=sqrt(sum(lla2ecef([lla(:,1),lla(:,2),zeros(size_lla,1)],'WGS84').^2,2));

        lambda_all=acosd(r_e./(r_e+lla(:,3)));

        los_dist=distance(lla(:,1),lla(:,2),GS_lat,GS_lon);

        inView=lambda_all-los_dist>0;
    elseif contains(p.Results.method,'topo')
        r_e=sqrt(sum(lla2ecef([GS_lat,GS_lon,0],'WGS84').^2));
        topo_data=load('topo.mat');
        los_vis=los2(topo_data.topo,topo_data.topolegend,...
        lla(:,1),lla(:,2),repmat(GS_lat,[size_lla,1]),repmat(GS_lon,size_lla,1),...
        lla(:,3),zeros(size_lla,1),"MSL","AGL",r_e);
        inView=los_vis'>0;
    else
        error(message('spacecraft:cubesat:losMethodFail'));
    end

    passes=lla(inView,:);
    los_dist=sqrt(sum((lla2ecef(passes)-lla2ecef([GS_lat,GS_lon,0])).^2,2));
    pass_times=time(inView,:);
    if~isempty(passes)
        passes_size=size(passes,1);

        pass_idx=zeros(1,passes_size);

        for i=2:passes_size

            pass_idx(i)=(pass_times(i)-pass_times(i-1)>seconds(100));
        end
        startIdx=[1,find(pass_idx==1)];
        windowStartTime=pass_times(startIdx,:);
        stopIdx=[find(pass_idx==1)-1,passes_size];
        windowStopTime=pass_times(stopIdx);
        duration=windowStopTime-windowStartTime;

        accessTable=table(windowStartTime,windowStopTime,...
        duration,arrayfun(@(start,stop)passes(start:stop,1),...
        startIdx,stopIdx,'UniformOutput',false)',...
        arrayfun(@(start,stop)passes(start:stop,2),...
        startIdx,stopIdx,'UniformOutput',false)',...
        arrayfun(@(start,stop)passes(start:stop,3),...
        startIdx,stopIdx,'UniformOutput',false)',...
        arrayfun(@(start,stop)los_dist(start:stop),...
        startIdx,stopIdx,'UniformOutput',false)',...
        arrayfun(@(start,stop)min(los_dist(start:stop)),startIdx,stopIdx)');

    else
        accessTable=table([],[],[],[],[],[],[],[]);
    end
    accessTable.Properties.VariableNames={'start','stop','duration',...
    'lat','lon','alt','losDist','closestApproach'};
    accessTable.Properties.VariableUnits={'','','',...
    'deg','deg','m','m','m'};
end
