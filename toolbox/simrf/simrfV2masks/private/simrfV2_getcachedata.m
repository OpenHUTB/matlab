function[cacheData,cacheBlock,cacheDataBase,blkNames]=...
    simrfV2_getcachedata(block,levels,createCache)




    if nargin<3

        createCache=true;
        if nargin<2
            levels=0;
        end
    end

    blkNames=cell(levels,1);
    cacheBlock=block;
    if levels>0
        lvlInd=1;


        while lvlInd<=levels&&strcmp(get_param(cacheBlock,'Type'),'block')
            blkNames{levels+1-lvlInd}=get_param(cacheBlock,'Name');
            cacheBlockPrev=cacheBlock;
            cacheBlock=get_param(cacheBlock,'Parent');
            lvlInd=lvlInd+1;
        end




        if~strcmp(get_param(cacheBlock,'Type'),'block')
            blkNames=blkNames(levels+3-lvlInd:levels);
            levels=lvlInd-2;
            cacheBlock=cacheBlockPrev;
        else
            blkNames=blkNames(levels+2-lvlInd:levels);
            levels=lvlInd-1;
        end
    end

    cacheData=get_param(cacheBlock,'UserData');
    if levels==0
        cacheDataBase=struct;
    else
        cacheDataBase=cacheData;



        lvlInd=1;
        while lvlInd<=levels
            if isfield(cacheData,blkNames{lvlInd})
                cacheData=cacheData.(blkNames{lvlInd});
                lvlInd=lvlInd+1;
            else
                cacheData=[];
                lvlInd=levels+1;
            end
        end
    end



    if~isempty(cacheData)&&~isfield(cacheData,'MaxPoles')
        cacheData.MaxPoles=48;
    end


    if createCache&&(isempty(cacheData)||~isfield(cacheData,'Vers'))
        if isfield(cacheData,'NumPorts')
            nports=cacheData.nports;
        else
            nports=2;
        end
        if isfield(cacheData,'FitOpt')
            fitopt=cacheData.FitOpt;
        else
            fitopt=0;
        end
        if isfield(cacheData,'FitTol')
            fittol=cacheData.FitTol;
        else
            fittol=0;
        end
        if isfield(cacheData,'MaxPoles')
            maxpoles=cacheData.MaxPoles;
        else
            maxpoles=48;
        end
        if isfield(cacheData,'FitErrorAchieved')
            fiterror=cacheData.FitErrorAchieved;
        else
            fiterror=[];
        end
        if isfield(cacheData,'RationalModel')
            if isfield(cacheData.RationalModel,'A')
                ratmodA=cacheData.RationalModel.A;
                ratmodAcell=cacheData.RationalModel.ACell;
            else
                ratmodA={};
                ratmodAcell={};
            end
            if isfield(cacheData.RationalModel,'C')
                ratmodC=cacheData.RationalModel.C;
                ratmodCcell=cacheData.RationalModel.CCell;
            else
                ratmodC={};
                ratmodCcell={};
            end
            if isfield(cacheData.RationalModel,'D')
                ratmodD=cacheData.RationalModel.D;
                ratmodDcell=cacheData.RationalModel.DCell;
                ratmodImpedCell=cacheData.RationalModel.Z0Cell;
                Z0=str2num(cacheData.RationalModel.Z0Cell{2});%#ok<ST2NM>
            else
                ratmodD={};
                ratmodDcell={};
                ratmodImpedCell={'Z0';'[50,50]'};
                Z0=50;
            end
        else
            ratmodA={};
            ratmodC={};
            ratmodD={};
            ratmodAcell={};
            ratmodCcell={};
            ratmodDcell={};
            ratmodImpedCell={'Z0';'[50,50]'};
            Z0=50;
        end


        cacheData=[];
        cacheData.Vers=2.0;
        cacheData.NumPorts=nports;
        cacheData.Impedance=Z0;
        cacheData.OrigParamType='s';


        cacheData.filename='';
        cacheData.timestamp=0;
        cacheData.hashcode=0;


        cacheData.Fit=false;
        cacheData.FitOpt=fitopt;
        cacheData.FitTol=fittol;
        cacheData.MaxPoles=maxpoles;
        cacheData.FitErrorAchieved=fiterror;


        cacheData.RationalModel.A=ratmodA;
        cacheData.RationalModel.C=ratmodC;
        cacheData.RationalModel.D=ratmodD;
        cacheData.RationalModel.ACell=ratmodAcell;
        cacheData.RationalModel.CCell=ratmodCcell;
        cacheData.RationalModel.DCell=ratmodDcell;
        cacheData.RationalModel.Z0Cell=ratmodImpedCell;
        simrfV2_setcachedata(cacheBlock,cacheData,cacheDataBase,blkNames);
        set_param(cacheBlock,'UserDataPersistent','on');


        cacheData.NL.IP3=[];
        cacheData.NL.P1dB=[];
        cacheData.NL.Psat=[];
        cacheData.NL.GCS=[];
        cacheData.NL.HasNLfileData=false;
    end

end