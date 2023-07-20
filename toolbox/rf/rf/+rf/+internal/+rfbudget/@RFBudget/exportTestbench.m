function out=exportTestbench(obj)




    v=ver;
    installedProducts={v(:).Name};
    haveSimulink=builtin('license','test','SIMULINK')&&...
    any(strcmp('Simulink',installedProducts));
    haveRFBlockset=builtin('license','test','RF_Blockset')&&...
    any(strcmp('RF Blockset',installedProducts));
    haveDST=builtin('license','test','Signal_Blocks')&&...
    any(strcmp('DSP System Toolbox',installedProducts));
    if~haveSimulink||~haveRFBlockset||~haveDST
        error(message('rf:rfbudget:NeedRFBLKSandDST'))
    end
    ant=zeros(1,length(obj.Elements));
    PA=zeros(1,length(obj.Elements));
    for i=1:length(obj.Elements)
        ant(i)=isa(obj.Elements(i),'rfantenna');
        PA(i)=isa(obj.Elements(i),'powerAmplifier');
    end
    if any(ant)
        error(message('rf:rfbudget:TestbenchExport'))
    end
    if any(PA)
        error(message('rf:shared:TestBenchExport'))
    end



    InputFreq=obj.InputFrequency(1);
    OutputFreqs=obj.OutputFrequency(1,:);
    OutputPowerVec=obj.OutputPower(1,:);
    TransducerGainVec=obj.TransducerGain(1,:);
    OIP3Vec=obj.OIP3(1,:);
    IIP3Vec=obj.IIP3(1,:);
    NFVec=obj.NF(1,:);
    SNRVec=obj.SNR(1,:);


    [Fin,FinScale,FinUnits]=engunits(InputFreq);
    if(Fin==0)
        Fin15Dig=0;
    else
        Fin_exp=floor(log10(abs(Fin)));
        Fin_mantisa=Fin*10^(-Fin_exp);
        Fin15Dig=round(Fin_mantisa,15)*10^(Fin_exp);
        if(~isempty(FinUnits))
            FinStr=[sprintf('%.15g',Fin15Dig),'e',num2str(-log10(FinScale))];
        else
            FinStr=sprintf('%.15g',round(Fin_mantisa,15));
            if(Fin_exp~=0)
                FinStr=[FinStr,'e',num2str(Fin_exp)];
            end
        end
    end


    [Fout,FoutScale,FoutUnits]=engunits(abs(OutputFreqs(end)));
    if(Fout==0)
        Fout15Dig=0;
    else
        Fout_exp=floor(log10(abs(Fout)));
        Fout_mantisa=Fout*10^(-Fout_exp);
        Fout15Dig=round(Fout_mantisa,15)*10^(Fout_exp);
        if(~isempty(FoutUnits))
            FoutStr=[sprintf('%.15g',Fout15Dig),'e'...
            ,num2str(-log10(FoutScale))];
        else
            FoutStr=sprintf('%.15g',round(Fout_mantisa,15));
            if(Fout_exp~=0)
                FoutStr=[FoutStr,'e',num2str(Fout_exp)];
            end
        end
    end

    [BW,BWScale,BMUnits]=engunits(obj.SignalBandwidth);
    BW_exp=floor(log10(abs(BW)));
    BW_mantisa=BW*10^(-BW_exp);
    BW15Dig=round(BW_mantisa,15)*10^(BW_exp);
    if(~isempty(BMUnits))
        BWStr=[sprintf('%.15g',BW15Dig),'e',num2str(-log10(BWScale))];
    else
        BWStr=sprintf('%.15g',round(BW_mantisa,15));
        if(BW_exp~=0)
            BWStr=[BWStr,'e',num2str(BW_exp)];
        end
    end





    if(((Fout>0)&&(Fout15Dig*(1/FoutScale)<=BW15Dig*(1/BWScale)))||...
        ((Fin>0)&&(Fin15Dig*(1/FinScale)<=BW15Dig*(1/BWScale))))
        error(message('rf:rfbudget:BadTestbenchInOutFreq'))
    end


    elementsInputFreq=[InputFreq,OutputFreqs(1:end-1)];
    for elementInd=1:length(obj.Elements)
        if((isa(obj.Elements(elementInd),'modulator')&&...
            ((elementsInputFreq(elementInd)==0)||...
            (OutputFreqs(elementInd)==0)))&&...
            (obj.Elements(elementInd).LO-obj.SignalBandwidth)<=0)



            error(message('rf:rfbudget:BadTestbenchInOutFreq'))
        end
    end

    h=new_system('','model');
    sys=get(h,'Name');
    bdclose(h)

    srcTestbench='simrfTestbenchRFtoRF';
    srcTestbenchBlk='Testbench RF to RF';
    if(Fin==0)
        FinStr=BWStr;
        srcTestbench='simrfTestbenchIQtoRF';
        srcTestbenchBlk='Testbench IQ to RF';
    end
    if(Fout==0)
        FoutStr=BWStr;
        if(Fin==0)
            srcTestbench='simrfTestbenchIQtoIQ';
            srcTestbenchBlk='Testbench IQ to IQ';
        else
            srcTestbench='simrfTestbenchRFtoIQ';
            srcTestbenchBlk='Testbench RF to IQ';
        end
    end


    src='rfTestbenches_lib';
    load_system(src)










    new_system(sys,'Model',[src,'/',srcTestbench])


    h=find_system(sys,'regexp','on','FindAll','on','text','\w*RF Budget\w*');
    str=get(h,'Text');
    idx=strfind(str,'-----');
    if(Fin~=0)
        str=[...
        str(1:idx(1)-1),...
        sprintf('%.4g',TransducerGainVec(end)),str(idx(1)+5:idx(2)-1),...
        sprintf('%.4g',NFVec(end)),str(idx(2)+5:idx(3)-1),...
        sprintf('%.4g',OIP3Vec(end)),str(idx(3)+5:idx(4)-1),...
        sprintf('%.4g',IIP3Vec(end)),str(idx(4)+5:end)];
    else
        NFloor=OutputPowerVec(end)-SNRVec(end)-...
        10*log10(obj.SignalBandwidth);
        str=[...
        str(1:idx(1)-1),...
        sprintf('%.4g',TransducerGainVec(end)),str(idx(1)+5:idx(2)-1),...
        sprintf('%.4g',NFloor),str(idx(2)+5:idx(3)-1),...
        sprintf('%.4g',NFVec(end)),str(idx(3)+5:idx(4)-1),...
        sprintf('%.4g',OIP3Vec(end)),str(idx(4)+5:idx(5)-1),...
        sprintf('%.4g',IIP3Vec(end)),str(idx(5)+5:end)];
    end
    set(h,'Text',str)


    numOfIQMods=sum(arrayfun(@(x)isa(x,'modulator'),...
    obj.Elements([(Fin==0),(OutputFreqs(1:end-1)==0)])));
    numOfIQDemods=sum(arrayfun(@(x)isa(x,'modulator'),...
    obj.Elements(OutputFreqs==0)));

    h=find_system(sys,'regexp','on','FindAll','on','text','\w*altered\w*');
    if(((Fin~=0)&&(Fout~=0))&&...
        ((numOfIQMods==0)&&(numOfIQDemods==0)))

        delete(h)
    else
        str=get(h,'Text');
        idx=strfind(str,'-----');
        str=[str(1:idx(1)-1),sprintf('%.4g',BW),str(idx(1)+5:end)];
        str=strrep(str,'Hz',[BMUnits,'Hz']);
        set(h,'Text',str)
    end


    DUT=[sys,'/DUT_Subsystem'];
    set_param(DUT,'LinkStatus','none')
    h=exportRFBlockset(obj,DUT,obj.SignalBandwidth);%#ok<NASGU>


    TB=[get_param(sys,'Name'),'/',srcTestbenchBlk];
    set_param(TB,'ZoomFactor','FitSystem')
    T_amp_dBm_val=obj.AvailableInputPower;

    T_amp_dBm_scD=floor(abs(T_amp_dBm_val)/5)*5;
    if(T_amp_dBm_scD<5)
        T_amp_dBm_scD=5;
    elseif(T_amp_dBm_scD>100)
        T_amp_dBm_scD=100;
    end
    T_amp_dBm_scL=(floor(T_amp_dBm_val/T_amp_dBm_scD)-2)*T_amp_dBm_scD;
    T_amp_dBm_scU=(floor(T_amp_dBm_val/T_amp_dBm_scD)+3)*T_amp_dBm_scD;


    set_param(TB,'T_amp_dBm_scL',sprintf('%.15g',T_amp_dBm_scL),'T_amp_dBm_scU',sprintf('%.15g',T_amp_dBm_scU));





    set_param(TB,'T_amp_dBm',sprintf('%.15g',T_amp_dBm_val),'T_amp_dBmV',sprintf('%.15g',T_amp_dBm_val+...
    round(30+10*log10(50))));
    set_param(TB,'Fin',FinStr,'Fout',FoutStr,'Base_bw',BWStr);


    set_param(sys,'StopTime','inf')
    set_param(sys,'SolverType','Fixed-step')
    set_param(sys,'Solver','FixedStepDiscrete')
    set_param(sys,'SolverMode','SingleTasking')
    set_param(sys,'InheritedTsInSrcMsg','none')
    set_param(sys,'ZoomFactor','FitSystem')

    if nargout>0
        out=sys;
    else
        open_system(sys)
    end

