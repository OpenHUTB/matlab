function parseData(p,args)
















































    d=[];
    isIntensity=false;

    Nargs=numel(args);
    if Nargs==1








        t=args{1};
        if~isempty(t)

            if isvectornd(t)
                t=t(:);
            end
























            ang=angle(t).*180./pi;
            mag=abs(t);









            [~,N]=size(t);
            for i=1:N
                u.ang_orig=ang(:,i);
                u.ang=ang(:,i);
                u.mag=mag(:,i);
                u.freq=[];
                u.data=t(:,i);
                if i==1
                    d=u;
                else
                    d(end+1,1)=u;%#ok<AGROW>
                end
            end

        end

    else






        N=numel(args);
        if rem(N,2)~=0
            error(message('rflib:smithplot:InputInPairs'));

        end
        for i=1:2:N
            freq=args{i};
            if~isreal(freq)||~isvectornd(freq)
                error(message('rflib:smithplot:RealInput','frequency'));

            end
            freq=freq(:);

            data=args{i+1};
            if~isnumeric(data)||~ismatrix(data)
                error(message('rflib:smithplot:RealInput','data'));

            end
            if isvectornd(data)
                data=data(:);
            end

            ang=angle(data).*180./pi;
            mag=abs(data);

            [~,N]=size(data);
            for j=1:N
                u.ang_orig=ang(:,j);
                u.ang=ang(:,j);
                u.mag=mag(:,j);
                u.freq=freq;
                u.data=data(:,j);
                if j==1&&numel(d)<1
                    d=u;
                else
                    d(end+1,1)=u;%#ok<AGROW>
                end
            end

            Nfreq=size(freq,1);
            Nmag=size(mag,1);

            if Nfreq~=Nmag&&Nfreq~=Nmag+1
                error(message('rflib:smithplot:DataSameSize'));

            end
        end
    end






    d=assessUniformAngleSpacing(d);









    if~isIntensity&&strcmpi(p.NextPlot,'add')

        p.pData_Raw=[p.pData_Raw;d];
    else

        p.pData_Raw=d;
    end



    if isempty(d)
        p.pCurrentDataSetIndex=[];
    else
        p.pCurrentDataSetIndex=1;
    end

    p.DataCacheDirty=true;
