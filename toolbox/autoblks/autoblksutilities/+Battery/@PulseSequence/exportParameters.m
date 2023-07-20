function Tables=exportParameters(psObj,varargin)








































%#ok<*AGROW>




    p=inputParser;
    p.addParameter('SOC',0:.1:1,@(x)validateattributes(x,{'numeric'},{'vector','<=',1,'>=',0}));
    p.addParameter('Current',[],@(x)validateattributes(x,{'numeric'},{'vector','finite','nonnan'}));
    p.addParameter('Temperature',[],@(x)validateattributes(x,{'numeric'},{'vector','finite','nonnan'}));
    p.parse(varargin{:});


    SOC_BP=sort(p.Results.SOC);
    C_BP=sort(p.Results.Current);
    T_BP=sort(p.Results.Temperature);



    parObj=[psObj.Parameters];
    metaObj=[psObj.MetaData];
    NumRC=parObj(1).NumRC;
    NumTC=parObj(1).NumTimeConst;


    SOCAll=[];
    CurrAll=[];
    TempAll=[];
    EmAll=[];
    R0All=[];
    RxAll=zeros(NumRC,0);
    TxAll=zeros(NumRC,0,NumTC);


    for pIdx=1:numel(parObj)

        ThisSOC=parObj(pIdx).SOC;
        ThisTemp=repmat(metaObj(pIdx).TestTemperature,size(ThisSOC));
        ThisCurr=repmat(abs(metaObj(pIdx).TestCurrent),size(ThisSOC));
        if strcmp({metaObj(pIdx).TestType},'pulsedischarge')
            ThisCurr=-ThisCurr;
        end

        SOCAll=[SOCAll,ThisSOC];
        CurrAll=[CurrAll,ThisCurr];
        TempAll=[TempAll,round(ThisTemp)];
        EmAll=[EmAll,parObj(pIdx).Em];
        R0All=[R0All,parObj(pIdx).R0];
        RxAll=[RxAll,parObj(pIdx).Rx];

        TxAll=[TxAll,parObj(pIdx).Tx];

    end




    if numel(T_BP)>1



        [SOCq,Tq,Cq]=meshgrid(SOC_BP,T_BP,C_BP);


        Points=[TempAll;SOCAll;CurrAll]';
        Values=EmAll';
        s=scatteredInterpolant(Points,Values,'linear','nearest');
        Em=s(Tq,SOCq,Cq);


        Points=[TempAll;SOCAll;CurrAll]';
        Values=R0All';
        s=scatteredInterpolant(Points,Values,'linear','nearest');
        R0=s(Tq,SOCq,Cq);

        for xIdx=1:NumRC


            Points=[SOCAll;CurrAll]';
            Values=RxAll(xIdx,:)';
            s=scatteredInterpolant(Points,Values,'linear','nearest');
            Rx(:,:,:,xIdx)=s(Tq,SOCq,Cq);


            if NumTC==1
                Points=[TempAll;SOCAll;CurrAll]';
                Values=TxAll(xIdx,:)';
            else
                Points=[TempAll,TempAll;SOCAll,SOCAll;zeros(size(CurrAll)),CurrAll]';
                Values=TxAll(xIdx,:,:)';
            end
            s=scatteredInterpolant(Points,Values,'linear','nearest');

            Tx(:,:,:,xIdx)=s(Tq,SOCq,Cq);

        end

    elseif numel(C_BP>1)



        [SOCq,Cq]=meshgrid(SOC_BP,C_BP);


        Points=[SOCAll;CurrAll]';
        Values=EmAll';
        s=scatteredInterpolant(Points,Values,'linear','nearest');
        Em=s(SOCq,Cq);


        Points=[SOCAll;CurrAll]';
        Values=R0All';
        s=scatteredInterpolant(Points,Values,'linear','nearest');
        R0=s(SOCq,Cq);

        for xIdx=1:NumRC


            Points=[SOCAll;CurrAll]';
            Values=RxAll(xIdx,:)';
            s=scatteredInterpolant(Points,Values,'linear','nearest');
            Rx(:,:,xIdx)=s(SOCq,Cq);


            if NumTC==1
                Points=[SOCAll;CurrAll]';
                Values=TxAll(xIdx,:)';
            else
                Points=[SOCAll,SOCAll;zeros(size(CurrAll)),CurrAll]';
                Values=TxAll(xIdx,:,:)';
            end
            s=scatteredInterpolant(Points,Values,'linear','nearest');

            Tx(:,:,xIdx)=s(SOCq,Cq);

        end

    else



        SOCq=SOC_BP;


        Em=interp1(SOCAll',EmAll',SOCq,'linear','extrap');


        R0=interp1(SOCAll',R0All',SOCq,'linear','extrap');

        for xIdx=1:NumRC


            Rx(xIdx,:)=interp1(SOCAll',RxAll(xIdx,:)',SOCq,'linear','extrap');


            if NumTC==1
                Tx(xIdx,:)=interp1(SOCAll',TxAll(xIdx,:)',SOCq,'linear','extrap');
            else
                Tx(xIdx,:,1)=interp1(SOCAll',TxAll(xIdx,:,1)',SOCq,'linear','extrap');
                Tx(xIdx,:,2)=interp1(SOCAll',TxAll(xIdx,:,2)',SOCq,'linear','extrap');
            end

        end

    end





    Tables.Em=Em;
    Tables.R0=R0;
    Tables.Rx=Rx;
    Tables.Tx=Tx;
    Tables.SOC_LUT=SOC_BP;
    Tables.Current_LUT=C_BP;
    Tables.Temperature_LUT=T_BP;

