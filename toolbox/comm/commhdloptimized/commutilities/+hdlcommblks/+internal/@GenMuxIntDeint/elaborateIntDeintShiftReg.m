function elaborateIntDeintShiftReg(this,hN,hC,intdelay)






    ip_sig=hN.PirInputSignals(1);
    op_sig=hN.PirOutputSignals(1);


    num_branches=length(intdelay);




    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo=getSysObjInfo(this,sysObjHandle);
    else
        blockInfo=getBlockInfo(this,hC);
    end

    ic=blockInfo.ic;


    if isscalar(ic)
        ic=repmat(ic,length(intdelay),1);
    end


    op_hT=op_sig(1).Type.BaseType;
    if~op_hT.isDoubleType
        ic_fi_signed=op_hT.Signed;
        ic_fi_wl=op_hT.WordLength;
        ic_fi_fl=-1*op_hT.FractionLength;
        ic=fi(ic,ic_fi_signed,ic_fi_wl,ic_fi_fl,...
        'RoundingMethod','Nearest','OverflowAction','Saturate');
    end


    resetnone=false;
    rtype=this.getImplParams('ResetType');
    if~isempty(rtype)
        resetnone=strncmpi(rtype,'none',4);
    end



    ctr_wl=ceil(log2(num_branches));
    ctr_hT=hN.getType('FixedPoint','Signed',0,'WordLength',ctr_wl,...
    'FractionLength',0);
    branch_ctr=hN.addSignal2('Type',ctr_hT,'Name','branch_val');


    ctr_comp=pirelab.getCounterLimitedComp(hN,branch_ctr,num_branches-1,...
    ip_sig.SimulinkRate,'branch',0);
    ctr_comp.addComment('Counter for calculation of the commutator branch');



    enb_hT=hN.getType('Boolean');
    enb_sigs(num_branches)=branch_ctr;


    hT=ip_sig.Type;
    branch_op_sigs(num_branches)=branch_ctr;

    for ii=1:num_branches

        branch_str=num2str(ii-1);
        branch_op_sigs(ii)=hN.addSignal2('Type',hT,...
        'Name',['op_branch_',branch_str]);

        if intdelay(ii)~=0

            enb_sigs(ii)=hN.addSignal2('Type',enb_hT,...
            'Name',['is_branch_',num2str(ii-1)]);
            enb_comp=pirelab.getCompareToValueComp(hN,branch_ctr,...
            enb_sigs(ii),'==',ii-1);
            enb_comp.addComment(['Enable for branch ',num2str(ii-1)]);




            icomp=pirelab.getIntDelayEnabledComp(hN,ip_sig,...
            branch_op_sigs(ii),enb_sigs(ii),intdelay(ii),['branch_',branch_str],...
            ic(ii),resetnone);



        else
            icomp=pirelab.getWireComp(hN,ip_sig,branch_op_sigs(ii));
        end
        icomp.addComment(['Branch ',branch_str,': Delay = '...
        ,num2str(intdelay(ii))]);
    end



    inputmode=1;
    zeroBasedIndex=1;

    compname='choose_output';

    rndMode='floor';
    satMode='wrap';
    mps_comp=pirelab.getMultiPortSwitchComp(hN,...
    [branch_ctr,branch_op_sigs],op_sig,inputmode,zeroBasedIndex,...
    rndMode,satMode,compname);
    mps_comp.addComment(['Pick the appropriate output based on the '...
    ,'branch count']);


