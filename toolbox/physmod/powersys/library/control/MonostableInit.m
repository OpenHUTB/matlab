function[WantBlockChoice,Ts,sps,EdgeDetect]=MonostableInit(block,EdgeDetect,t_mono,ic,Ts)




    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init

        Erreur.identifier='SpecializedPowerSystems:MonostableBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if~(t_mono>=Ts)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The Pulse duration must be be >= One sample time.',BK);
            psberror(Erreur);
        end

        if~all(ic==0|ic==1)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The previous input must be defined as either 0 or 1.',BK);
            psberror(Erreur);
        end
    end



    if(min(t_mono)~=max(t_mono))
        sps.str=sprintf('multiple');
    else
        sps.str=sprintf('%g %c',t_mono(1),'s');
    end

    if EdgeDetect==3
        x1=10;
        x2=30;
        sps.X1=[15,25,25,35]-14;
        sps.Y1=[65,65,95,95];
        sps.X2=[15,25,35]-14;
        sps.Y2=[75,85,75];
        sps.X3=[15,25,25,35]+14;
        sps.Y3=[65+x2,65+x2,95-x2,95-x2];
        sps.X4=[15,25,35]+14;
        sps.Y4=[75+x1,85-x1,75+x1];
    else
        x1=(EdgeDetect-1)*10;
        x2=(EdgeDetect-1)*30;
        sps.X1=[15,25,25,35]+0;
        sps.Y1=[65+x2,65+x2,95-x2,95-x2];
        sps.X2=[15,25,35]+0;
        sps.Y2=[75+x1,85-x1,75+x1];
        sps.X3=[];
        sps.X4=[];
        sps.Y3=[];
        sps.Y4=[];
    end