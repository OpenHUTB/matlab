function plotCompressorMap(varargin)





    if isstruct(varargin{1})
        h=varargin{1};
    else
        h.hBlock=varargin{1};
        h.hFigure=[];
        h.hReload=[];
        h.hbp1=[];
        h.hbp2=[];
        h.hEditText=[];
        h.p_diff_plot=simscape.Value(1,'MPa');
    end

    if ischar(h.hBlock)||isstring(h.hBlock)
        h.hBlock=getSimulinkBlockHandle(h.hBlock);
    end


    if~is_simulink_handle(h.hBlock)||...
        (string(get_param(h.hBlock,"ComponentPath"))~="fluids.gas.turbomachinery.compressor"&&...
        string(get_param(h.hBlock,"ComponentPath"))~="fluids.two_phase_fluid.fluid_machines.compressor")


        if~isempty(h.hFigure)&&isgraphics(h.hFigure,"figure")&&...
            string(h.hFigure.Tag)=="Compressor (G) or Compressor (2P) - Plot Compressor Map"
            blockPath=getappdata(h.hFigure,"blockPath");
            h.hBlock=getSimulinkBlockHandle(blockPath);


            if~is_simulink_handle(h.hBlock)||...
                (string(get_param(h.hBlock,"ComponentPath"))~="fluids.gas.turbomachinery.compressor"&&...
                string(get_param(h.hBlock,"ComponentPath"))~="fluids.two_phase_fluid.fluid_machines.compressor")
                error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
            end
        else
            error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
        end
    end


    blockParams=foundation.internal.mask.getEvaluatedBlockParameters(h.hBlock);


    for j=1:height(blockParams)
        param_name=blockParams.Properties.RowNames{j};
        paramValue=blockParams{param_name,'Value'}{1};
        blockStruct.(param_name)=simscapeParameter(blockParams,param_name);
        blockStruct.([param_name,'_prompt'])=blockParams.Prompt{param_name};
    end


    checkParameters(blockStruct);


    createFigure(h);


    plotProperties(blockStruct);

end


function param=simscapeParameter(tableData,paramName)
    paramValue=tableData{paramName,'Value'}{1};
    paramUnit=tableData{paramName,'Unit'}{1};
    param=simscape.Value(paramValue,paramUnit);
end

function checkParameters(blockStruct)

    analytical=value(blockStruct.parameterization,'1');


    omega_TLU_str="Corrected speed vector";
    beta_TLU_str="Beta index vector";
    pr_TLU_str="Pressure ratio table";
    mdot_TLU_str="Corrected mass flow rate table";
    eta_TLU_str="Isentropic efficiency table";
    p_reference_str="Reference pressure for corrected flow";
    T_reference_str="Reference temperature for corrected flow";
    mechanical_efficiency_str="Mechanical efficiency";
    area_A_str="Inlet area at port A";
    area_B_str="Inlet area at port B";

    assert(value(blockStruct.p_reference,'MPa')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',p_reference_str))
    assert(value(blockStruct.T_reference,'K')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',T_reference_str))
    assert(value(blockStruct.mechanical_efficiency,'1')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',mechanical_efficiency_str))
    assert(value(blockStruct.area_A,'m^2')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',area_A_str))
    assert(value(blockStruct.area_B,'m^2')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',area_B_str))

    if logical(analytical==2)


        assert(length(blockStruct.omega_TLU)>=2,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',omega_TLU_str,"2"))
        assert(length(blockStruct.beta_TLU)>=2,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',beta_TLU_str,"2"))
        assert(all(size(blockStruct.mdot_TLU)==[length(blockStruct.omega_TLU),length(blockStruct.beta_TLU)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',mdot_TLU_str,omega_TLU_str,beta_TLU_str))
        assert(all(size(blockStruct.eta_TLU)==[length(blockStruct.omega_TLU),length(blockStruct.beta_TLU)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',eta_TLU_str,omega_TLU_str,beta_TLU_str))
        assert(all(size(blockStruct.pr_TLU)==[length(blockStruct.omega_TLU),length(blockStruct.beta_TLU)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',pr_TLU_str,omega_TLU_str,beta_TLU_str))


        assert(all(diff(value(blockStruct.beta_TLU,'1'))>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',beta_TLU_str))
        assert(all(diff(value(blockStruct.omega_TLU,'rpm'))>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',omega_TLU_str))


        beta_TLU_first=blockStruct.beta_TLU(1);
        beta_TLU_first_prompt=['first element of ',convertStringsToChars(beta_TLU_str)];
        beta_TLU_last=blockStruct.beta_TLU(end);
        beta_TLU_last_prompt=['last element of ',convertStringsToChars(beta_TLU_str)];
        assert(value(beta_TLU_first,'1')==0,...
        message('physmod:simscape:compiler:patterns:checks:EqualZero',beta_TLU_first_prompt))
        assert(value(beta_TLU_last,'1')==1,...
        message('physmod:simscape:compiler:patterns:checks:Equal',beta_TLU_last_prompt,'1'))
        assert(value(blockStruct.area_B,'m^2')>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',area_B_str))
        assert(all(value(blockStruct.omega_TLU,'rpm')>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',omega_TLU_str))
        assert(all(all(value(blockStruct.pr_TLU,'1')>0)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',pr_TLU_str))
        assert(all(all(value(blockStruct.mdot_TLU,'kg/s')>0)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',mdot_TLU_str))
        assert(all(all(value(blockStruct.eta_TLU,'1')>0)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',eta_TLU_str))
        assert(all(all(value(blockStruct.eta_TLU,'1')<=1)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqual',eta_TLU_str,'1'))


        assert(all(all(diff(value(blockStruct.mdot_TLU,'kg/s'),1,1)>0)),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingColumns',mdot_TLU_str))
        assert(all(all(diff(value(blockStruct.pr_TLU,'1'),1,1)>0)),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingColumns',pr_TLU_str))

    end
end

function createFigure(h)

    if isempty(h.hFigure)
        h.hFigure=figure("Tag","Compressor (G) or Compressor (2P) - Plot Compressor Map");


        h.hReload=uicontrol('Style','pushbutton','String','Reload Data','FontWeight','bold',...
        'Units','normalized','Position',[0.005,0.95,0.15,0.05],...
        'backgroundColor',[1,1,1],...
        'Callback',{@pushbuttonCallback,h});


        h.hFigure.Name=get_param(h.hBlock,"Name");


        h.hEditText.Callback{2}=h;
        h.hReload.Callback{2}=h;
    else
        if~isgraphics(h.hFigure,'figure')
            h.hFigure=figure('Name',get_param(h.hBlock,'Name'));
        end
    end

    hAxes=gca;
    cla(hAxes);


    setappdata(h.hFigure,"blockPath",getfullname(h.hBlock));
end

function plotProperties(blockStruct)

    analytical=value(blockStruct.parameterization,'1');
    conAnalEff=value(blockStruct.efficiencyType,'1');

    if logical(analytical==2)

        beta_TLU_plot=value(blockStruct.beta_TLU,'1');
        omega_unit=string(unit(blockStruct.omega_TLU));
        omega_TLU_plot=value(blockStruct.omega_TLU,omega_unit);
        mdot_unit=string(unit(blockStruct.mdot_TLU));
        mdot_TLU_plot=value(blockStruct.mdot_TLU,mdot_unit);
        eta_TLU_plot=value(blockStruct.eta_TLU,'1');
        pr_TLU_plot=value(blockStruct.pr_TLU,'1');


        LineColors=get(gca,'ColorOrder');
        [C,h]=contour(mdot_TLU_plot,pr_TLU_plot,eta_TLU_plot,0.65:0.025:0.90,'Color',LineColors(3,:),'LineWidth',0.5);
        clabel(C,h,'LabelSpacing',350);
        h.DisplayName='Isentropic Efficiency';
        hold on;


        h=plot(mdot_TLU_plot(:,1),pr_TLU_plot(:,1),'Color',LineColors(7,:),'LineWidth',1);
        h.DisplayName='Choke Line';
        h=plot(mdot_TLU_plot(:,size(mdot_TLU_plot,2)),pr_TLU_plot(:,size(pr_TLU_plot,2)),'Color',LineColors(2,:),'LineWidth',1);
        h.DisplayName='Surge Line';


        lim=axis;
        for i=1:size(mdot_TLU_plot,1)
            h=plot(mdot_TLU_plot(i,:),pr_TLU_plot(i,:),'Color',LineColors(1,:),'LineWidth',1);
            h.Annotation.LegendInformation.IconDisplayStyle='off';
            hold on;
            text(mdot_TLU_plot(i,end)-0.01*lim(2),pr_TLU_plot(i,end)+0.02*lim(4),num2str(omega_TLU_plot(i)),...
            'HorizontalAlignment','right');
        end
        h.DisplayName="Constant Speed Lines ("+omega_unit+")";
        h.Annotation.LegendInformation.IconDisplayStyle='on';
        legend('show','Location','best');
        xlabel("Corrected Mass Flow Rate ("+mdot_unit+")");
        grid on;
        lim=axis;
        xspan=lim(2)-lim(1);
        yspan=lim(4)-lim(3);
        scalemargin=0.1;
        axis([lim(1)-scalemargin*xspan,lim(2)+scalemargin*xspan,lim(3)-scalemargin*yspan,lim(4)+scalemargin*yspan]);
        hold off;
    else
        LineColors=get(gca,'ColorOrder');
        a=value(blockStruct.a,'1');
        b=value(blockStruct.b,'1');
        k=value(blockStruct.k,'1');
        Nd_unit=string(unit(blockStruct.NDes));
        Nd=value(blockStruct.NDes,Nd_unit);
        Pd=value(blockStruct.piDes,'1');
        Mdes_unit=string(unit(blockStruct.mdotDes));
        Mdes=value(blockStruct.mdotDes,Mdes_unit);
        mdotMaxEff=value(blockStruct.mdotMaxEff,Mdes_unit);

        MOp=mdotMaxEff/Mdes;

        N=linspace(0.5*Nd,1.1*Nd,7);
        M=linspace(0,2,300);

        Ntil=N./Nd;
        MtilS=Ntil.^b;
        PtilS=Ntil.^(a*b);

        mvect=linspace(0,1.6*Mdes,29);
        prvect=linspace(1,1.5*Pd,29);

        mvecttil=mvect./Mdes;
        prvecttil=(prvect-1)/(Pd-1);

        if logical(conAnalEff==2)


            etanot=value(blockStruct.etaMax,'1');
            piMaxEff=value(blockStruct.piMaxEff,'1');
            c=value(blockStruct.c,'1');
            d=value(blockStruct.d,'1');
            C=value(blockStruct.cCap,'1');
            D=value(blockStruct.dCap,'1');


            if MOp==1
                dela=0;
            else
                dela=log((piMaxEff-1)/(Pd-1))/log(MOp)-a;
            end

            mtilnot=MOp;
            ptilnot=mtilnot.^(a+dela);

            etamap=etanot.*(1-C.*abs((prvecttil'./(mvecttil.^(a+dela-1)))-mvecttil).^c-D.*abs(mvecttil./mtilnot-1).^d);

            testm=etamap>0;

            testnan(1:length(prvecttil),1:length(mvecttil))=NaN;

            for i=1:length(prvecttil)
                testnan(testm(:,i),i)=etamap(testm(:,i),i);
            end

            LineColors=get(gca,'ColorOrder');
            [C,h]=contour(mvect,prvect,testnan,0.6:0.05:0.9,'Color',LineColors(3,:),'LineWidth',0.5);
            clabel(C,h,'LabelSpacing',350);
            h.DisplayName='Isentropic Efficiency';
            hold on;

        end

        h=plot(MtilS.*Mdes,PtilS.*(Pd-1)+1,'k','LineWidth',1);
        h.DisplayName='Spine of Constant Speed Lines';

        hold on;

        for i=1:length(N)
            mmax=Ntil(i).^b-k*(exp((-Ntil(i).^(a*b))./(2*Ntil(i)*k))-1);

            pr_pi=1+(Pd-1).*(Ntil(i).^(a*b)+2*Ntil(i).*k.*log(1-(M(M<mmax)-Ntil(i).^b)./k));
            pr_pi=[pr_pi,1];
            lastvect=M(M<mmax);

            h=plot([M(M<mmax),lastvect(end)].*Mdes,pr_pi,'Color',LineColors(1,:),'LineWidth',1);
            h.Annotation.LegendInformation.IconDisplayStyle='off';
            hold on;
            lim=axis;
            text(0,pr_pi(i)+0.02*lim(4),num2str(N(i)),'HorizontalAlignment','left')
        end
        h.DisplayName="Constant Speed Lines ("+Nd_unit+")";
        h.Annotation.LegendInformation.IconDisplayStyle='on';

        axis([0,1.3*Mdes,1,1.5*Pd]);
        xlabel("Corrected Mass Flow Rate ("+Mdes_unit+")");
        legend('show','Location','best');
        grid on;
        hold off;

    end
    ylabel('Pressure Ratio');
    title('Compressor Map');
end

function pushbuttonCallback(~,~,h)
    fluids.internal.mask.plotCompressorMap(h);
end
