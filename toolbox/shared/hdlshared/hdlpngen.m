function[hdlbody,pnout_idx,hdlconstants,hdlsignals,hdltypedefs]=hdlpngen(pngen,mask_idx,rst_idx)










































    mask_port=0;
    rst_port=0;
    if(nargin>1)&&~isempty(mask_idx),
        mask_port=1;
    end

    if(nargin>2)&&~isempty(rst_idx),
        rst_port=1;
    end

    hdlbody=[];
    hdlconstants=[];
    hdlsignals=[];
    hdltypedefs=[];
    booleanhdl=hdlblockdatatype('boolean');

    polytmp=pngen.GenPoly;
    polytmp(find(polytmp==1))=0;%#ok<FNDSB>
    if~isempty(find(polytmp~=0)),%#ok<EFIND>

        gp=zeros(1,pngen.GenPoly(1)+1);
        gp(pngen.GenPoly(1)+1-pngen.GenPoly)=1;
        pngen.GenPoly=gp;
    end


    pn_length=numel(pngen.GenPoly)-1;
    if numel(pngen.InitialStates)~=pn_length,
        pngen.InitialStates=repmat(pngen.InitialStates,1,pn_length);
    end

    pn_length=length(pngen.InitialStates);
    flipped_poly=fliplr(pngen.GenPoly);
    xoridx=find(flipped_poly==1)-1;
    xoridx(end)=[];

    comment_str=hdlgetparameter('comment_char');


    [pnreg_vtype,pnreg_sltype]=hdlgettypesfromsizes(pn_length,0,0);
    [pn_valshift_vtype,pn_valshift_sltype]=hdlgettypesfromsizes(pn_length-1,-1,0);
    [pnout_vtype,pnout_sltype]=hdlgettypesfromsizes(pngen.NumBitsOut,0,0);

    [~,pnreg_idx]=hdlnewsignal('pn_reg','block',-1,0,1,pnreg_vtype,pnreg_sltype);
    [~,pnout_idx]=hdlnewsignal('pn_out','block',-1,0,1,pnout_vtype,pnout_sltype);
    hdlregsignal(pnreg_idx);

    if strcmpi(hdlcodegenmode,'filtercoder')
        if hdlgetparameter('isvhdl')
            hdltypedefs=[hdltypedefs,...
            '  TYPE vector_pn_newval_unsignedtype IS ARRAY (NATURAL range <>) OF ',...
            pnreg_vtype,'; -- ',pnreg_sltype,'\n'];
            hdltypedefs=[hdltypedefs,...
            '  TYPE vector_pnvalue_shifted_unsignedtype IS ARRAY (NATURAL range <>) OF ',...
            pn_valshift_vtype,'; -- ',pn_valshift_sltype,'\n'];

            pnreg_vtype=['vector_pn_newval_unsignedtype(0 TO ',num2str(pngen.NumBitsOut+1-1),')'];
            pn_valshift_vtype=['vector_pnvalue_shifted_unsignedtype(0 TO ',num2str(pngen.NumBitsOut-1),')'];
            booleanhdl=['std_logic_vector(0 TO ',num2str(pngen.NumBitsOut-1),')'];
        else

        end

    end

    [~,pnxorout_idx]=hdlnewsignal('pn_xorout','block',-1,0,pngen.NumBitsOut,booleanhdl,'boolean');
    [~,pn_newval_idx]=hdlnewsignal('pn_newvalue','block',-1,0,pngen.NumBitsOut+1,pnreg_vtype,pnreg_sltype);
    [~,pn_valshift_idx]=hdlnewsignal('pn_value_shifted','block',-1,0,pngen.NumBitsOut,pn_valshift_vtype,pn_valshift_sltype);

    hdlsignals=[hdlsignals,...
    makehdlsignaldecl(pnreg_idx),...
    makehdlsignaldecl(pnout_idx),...
    makehdlsignaldecl(pnxorout_idx),...
    makehdlsignaldecl(pn_newval_idx),...
    makehdlsignaldecl(pn_valshift_idx)];


    expand_pnxorout=hdlexpandvectorsignal(pnxorout_idx);
    expand_pn_newval=hdlexpandvectorsignal(pn_newval_idx);
    expand_pn_valshift=hdlexpandvectorsignal(pn_valshift_idx);


    if mask_port==1,

        expand_mask=hdlexpandvectorsignal(mask_idx);
        [maskbr_vtype,maskbr_sltype]=hdlgettypesfromsizes(length(expand_mask),0,0);
        [~,maskbr_idx]=hdlnewsignal('pn_mask','block',-1,0,1,maskbr_vtype,maskbr_sltype);
        hdlbody=[hdlbody,hdlsliceconcat(mask_idx,{(0:length(expand_mask)-1)},maskbr_idx)];
        [~,maskout_idx]=hdlnewsignal('mask_out','block',-1,0,pngen.NumBitsOut,maskbr_vtype,maskbr_sltype);
        expand_maskout=hdlexpandvectorsignal(maskout_idx);
        hdlsignals=[hdlsignals,...
        makehdlsignaldecl(maskbr_idx),...
        makehdlsignaldecl(maskout_idx)];
    else
        if~isfield(pngen,'Mask'),
            pngen.Mask=[zeros(1,(pn_length-1)),1];
        end
        mask_indices=find(fliplr(pngen.Mask)==1)-1;

    end


    init=num2str(pngen.InitialStates);
    init(find(init==' '))=[];%#ok<FNDSB> %get rid of the space
    init_val=bin2dec(init);

    if rst_port==1,
        C_regiv=hdlconstantvalue(init_val,pn_length,0,0,'bin');
        [~,C_regiv_idx]=hdlnewsignal('C_PNGEN_REG_INIT_VAL','block',-1,0,1,hdlsignalvtype(pnreg_idx),hdlsignalsltype(pnreg_idx));
        hdlconstants=[hdlconstants,makehdlconstantdecl(C_regiv_idx,C_regiv)];
        hdlbody=[hdlbody,hdlmux([C_regiv_idx,pnreg_idx],expand_pn_newval(1),rst_idx,{'='},1,'when-else'),'\n'];
    else
        hdlbody=[hdlbody,hdlsignalassignment(pnreg_idx,expand_pn_newval(1))];
    end




    gConnOld=hdlconnectivity.genConnectivity(0);
    if gConnOld,
        hConnDir=hdlconnectivity.getConnectivityDirector;


        hConnDir.addDriverReceiverPair(expand_pn_newval(1),expand_pn_newval(pngen.NumBitsOut+1),'realonly',true);

        hConnDir.addDriverReceiverPair(expand_pn_newval(1),pnout_idx,'realonly',true);
        if mask_port~=0,
            hConnDir.addDriverReceiverPair(maskbr_idx,pnout_idx,'realonly',true);
        end
    end



    for ii=1:pngen.NumBitsOut,

        if pngen.NumBitsOut>1,
            hdlbody=[hdlbody,comment_str,'**stage ',num2str(ii),'\n'];
        end
        oldval=expand_pn_newval(ii);
        oldval_shifted=expand_pn_valshift(ii);
        xorout=expand_pnxorout(ii);
        newval=expand_pn_newval(ii+1);

        hdlbody=[hdlbody,hdlxorreduction(oldval,xoridx,xorout)];
        hdlbody=[hdlbody,hdldatatypeassignment(oldval,oldval_shifted,'floor',false)];
        hdlbody=[hdlbody,hdlsliceconcat([xorout,oldval_shifted],{[],[]},newval)];
        if mask_port==0,

            if isscalar(mask_indices),
                hdlbody=[hdlbody,hdlassignstatement(hdlgetbit(oldval,mask_indices),hdlgetbit(pnout_idx,pngen.NumBitsOut-ii))];
            else
                [dumbody,dumlhs,maskrhs]=hdlxorreduction(oldval,mask_indices);
                hdlbody=[hdlbody,hdlassignstatement(maskrhs,hdlgetbit(pnout_idx,pngen.NumBitsOut-ii))];
            end
        else
            hdlbody=[hdlbody,hdlbitop([maskbr_idx,oldval],expand_maskout(ii),'AND')];
            [dumbody,dumlhs,maskrhs]=hdlxorreduction(expand_maskout(ii),0:pn_length-1);
            hdlbody=[hdlbody,hdlassignstatement(maskrhs,hdlgetbit(pnout_idx,pngen.NumBitsOut-ii))];

        end
    end




    hdlconnectivity.genConnectivity(gConnOld);



    hdlbody=[hdlbody,hdlunitdelay(expand_pn_newval(pngen.NumBitsOut+1),pnreg_idx,...
    ['PN_generation_',hdluniqueprocessname],init_val)];



    function[hdlbody,lhs,rhs]=hdlxorreduction(in,idx,out)







        if hdlgetparameter('isverilog'),
            xorop='^';
        else
            xorop='XOR';
        end



        rhs=hdlgetbit(in,idx(1));

        for ii=2:length(idx),
            rhs=[rhs,' ',xorop,' ',hdlgetbit(in,idx(ii))];
        end

        hdlbody=[];
        lhs=[];

        if nargin>2,



            outname=hdlsignalname(out);
            [assign_prefix,assign_op]=hdlassignforoutput(out);

            lhs=outname;
            hdlbody=['  ',assign_prefix,lhs,' ',assign_op,' '];



            hdlbody=[hdlbody,rhs,';\n\n'];
        end













        function string=hdlgetbit(signal,index)

















            s_sltype=hdlsignalsltype(signal);
            [sWL,~,sSIGN]=hdlwordsize(s_sltype);%#ok<NASGU>
            if sWL==1,
                string=hdlsignalname(signal);
            else
                name=hdlsignalname(signal);
                arrayderef=hdlgetparameter('array_deref');
                string=[name,arrayderef(1),num2str(index(1)),arrayderef(2)];
            end



            function stringcomplete=hdlassignstatement(stringin,stringout,outsig)


















                if nargin<3,
                    aprefix=hdlgetparameter('assign_prefix');
                    aop=hdlgetparameter('assign_op');

                    if hdlgetparameter('isverilog')&&hdlsequentialcontext,
                        aprefix='';
                        aop='<=';
                    end
                else
                    [aprefix,aop]=hdlassignforoutput(outsig);
                end

                stringcomplete=['  ',aprefix,stringout,' ',aop,' ',stringin,';\n\n'];
