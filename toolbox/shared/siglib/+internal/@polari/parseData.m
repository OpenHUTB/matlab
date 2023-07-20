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
            if isreal(t)


                [M,N]=size(t);
                ang=(0:M-1)'*(360/M);
                for i=1:N
                    u.ang_orig=ang;
                    u.ang=ang;
                    u.mag=t(:,i);

                    if i==1
                        d=u;
                    else
                        d(end+1,1)=u;%#ok<AGROW>
                    end
                end
            else







                ang=angle(t).*180./pi;
                mag=abs(t);









                [~,N]=size(t);
                for i=1:N
                    u.ang_orig=ang(:,i);
                    u.ang=ang(:,i);
                    u.mag=mag(:,i);
                    if i==1
                        d=u;
                    else
                        d(end+1,1)=u;%#ok<AGROW>
                    end
                end
            end
        end














































    else






        N=numel(args);
        if rem(N,2)~=0
            error(message('siglib:polarpattern:InputInPairs'));

        end
        for i=1:2:N
            ang=args{i};
            if~isreal(ang)||~isvectornd(ang)
                error(message('siglib:polarpattern:RealInput','angles'));

            end
            ang=ang(:);

            mag=args{i+1};
            if~isreal(ang)||~ismatrix(ang)
                error(message('siglib:polarpattern:RealInput','magnitudes'));

            end
            if isvectornd(mag)
                mag=mag(:);
            end

            Nang=size(ang,1);
            Nmag=size(mag,1);
            if Nang~=Nmag&&Nang~=Nmag+1
                error(message('siglib:polarpattern:DataSameSize'));

            end


            if Nang>0&&Nmag>0
                u.ang_orig=ang;

                if Nang==Nmag+1








                    u.ang=(ang(1:end-1,i)+ang(2:end,i))*0.5;
                else
                    u.ang=ang;
                end



                [~,Nm]=size(mag);
                for j=1:Nm


                    u.mag=mag(:,j);
                    if isempty(d)
                        d=u;
                    else
                        d(end+1,1)=u;%#ok<AGROW>
                    end
                end
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
