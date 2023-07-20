function plot_data_sectors(p)






















    set(p.hDataLineGlow,'Visible','off');



    set(p.hDataLine,...
    'HandleVisibility','off');


    ht=p.hDataPatch;
    hm=p.hDataLine;
    Nht=numel(ht);
    bogus1=~ishghandle(ht);
    bogus2=~ishghandle(hm);
    if Nht>0&&(Nht~=numel(hm)||any(bogus1)||any(bogus2))

        delete(ht(~bogus1));
        ht=[];
        delete(hm(~bogus2));
        hm=[];
        Nht=0;
    end


    if Nht==0&&getNumDatasets(p)>1
        str='Can plot only one data set for Style = ''sector''.';
        warning('polari:TooManyDataSetsForSectorPlot',str);
        showBannerMessage(p,str);
    end
    pdata=getDataset(p);

    r=pdata.mag;
    theta=pdata.ang_orig;
    Nr=numel(r);
    Nth=numel(theta);

    if Nth==0||Nr==0
        ht=p.hDataPatch;
        hm=p.hDataLine;
        if isempty(ht)||~ishghandle(ht)
            ht.Visible='off';
            hm.Visible='off';
        end
        return
    end
    if(Nth~=Nr)&&(Nth~=Nr+1)
        error('Number of angles must be the same as or one more than number of magnitudes when using ''sectors'' display style.');
    end
    if Nr==1&&Nth<2
        error('Must specify 2 angles if a single magnitude is specified.');
    end

    if Nth>45
        str='Too many data points for ''sector'' plot style.';
        warning('polari:TooManyDataPointsForSectorPlot',str);
        showBannerMessage(p,str);
    end

    centeredMarkers=Nth==Nr+1;

    if Nth~=Nr&&p.ConnectEndpoints





        theta(end+1)=theta(1);



        theta=unwrap(theta*pi/180)*180/pi;

        r(end+1)=r(1);
        Nr=Nr+1;
        Nth=Nth+1;
    end



    if Nth==Nr
        if p.ConnectEndpoints





            theta(end+1)=theta(1);
        else




            dt=theta(end)-theta(1);
            if dt<-180
                dt=theta(1)+theta(end)+360;
            elseif dt>180
                dt=theta(1)+theta(end)-360;
            else
                dt=theta(1)+theta(end);
            end
            theta(end+1)=dt/2;
        end


        theta=unwrap(theta*pi/180)*180/pi;


    end


    th=getNormalizedAngle(p,theta(:));
    r=getNormalizedMag(p,r);
    if strcmpi(p.AngleDirection,'cw')
        th=flip(th);
        r=flip(r);
    end




    fc=p.SectorsColor;
    if ischar(fc)||(isstring(fc)&&isscalar(fc))

        faceColor=fc;
        if strcmpi(fc,'none')
            faceAlpha=0;
        else
            faceAlpha=p.SectorsAlpha;
        end
        cdata=[];
    else

        faceColor='flat';
        faceAlpha=p.SectorsAlpha;
        Ncolors=size(fc,1);
        if Ncolors>Nr

            fc=fc(1:Nr,:);
        elseif Ncolors>1&&Ncolors~=Nr

            int_reps=floor(Nr/Ncolors);
            fc2=fc;
            fc=zeros(Nr,3);
            fc(1:int_reps*Ncolors,:)=repmat(fc2,int_reps,1);
            rem_rows=Nr-int_reps*Ncolors;
            fc(int_reps*Ncolors+1:end,:)=fc2(1:rem_rows,:);
        end
        cdata=reshape(fc,1,size(fc,1),3);
    end


    Nd=numel(pdata);




    if Nht~=Nd


        Zmin=0.1;
        Zmax=0.2;
        del=Zmax-Zmin;
        Zplane=Zmin+del*(0:Nd-1)'/Nd;

        datasetIndex=1;

        ht=patch(...
        'Parent',p.hAxes,...
        'Tag',sprintf('PolarData%d',p.pAxesIndex),...
        'EdgeAlpha',1,...
        'XData',[],...
        'YData',[],...
        'ZData',[]);
        p.hDataPatch=ht;
        set(ht,'uicontextmenu',p.UIContextMenu_Data);
        setappdata(ht,'polariDatasetIndex',datasetIndex);
        setappdata(ht,'polariZPlane',Zplane(datasetIndex));

        hm=line(...
        'Parent',p.hAxes,...
        'HandleVisibility','off',...
        'Tag',sprintf('PolarMarker%d',p.pAxesIndex),...
        'LineStyle','none',...
        'XData',[],...
        'YData',[],...
        'ZData',[]);
        p.hDataLine=hm;
        set(hm,'uicontextmenu',p.UIContextMenu_Data);
        setappdata(hm,'polariDatasetIndex',datasetIndex);
        setappdata(hm,'polariZPlane',Zplane(datasetIndex));
    else


        Zplane=zeros(Nd,1);
        for i=1:Nd
            Zplane(i)=getappdata(ht(i),'polariZPlane');
        end
    end




    [verts,faces]=internal.polariCommon.sectorsPatchRounded(r,th,Zplane);


    set(ht,...
    'Faces',faces,...
    'Vertices',verts,...
    'FaceColor',faceColor,...
    'FaceAlpha',faceAlpha,...
    'EdgeColor',p.EdgeColor,...
    'CData',cdata,...
    'Marker','none',...
    'LineStyle',p.LineStyle,...
    'LineWidth',p.LineWidth,...
    'Visible','on');


    if strcmpi(p.Marker,'none')
        hm.Visible='off';
    else
        [xd,yd,zd]=sectors_marker_points(r,th,centeredMarkers);
        set(hm,...
        'XData',xd,...
        'YData',yd,...
        'ZData',zd,...
        'Visible','on',...
        'LineStyle','none',...
        'Marker',p.Marker,...
        'MarkerSize',p.MarkerSize);
    end



