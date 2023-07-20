function[hdlbody,hdlsignals]=hdlsumofelements(in,out,rounding,saturation,style,fullprecisiontree)















    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if nargin<3
        rounding='floor';
        saturation=0;
    end

    if nargin<5
        style='linear';
    end

    if nargin<6
        fullprecisiontree=1;
    end

    if emitMode
        dims=0;
    else
        dims=pirelab.getVectorTypeInfo(in(1),1);
    end










    if length(in)==1
        invectsize=max(hdlsignalvector(in));
        if all(invectsize==0)
            invect=in;
        else
            invect=hdlexpandvectorsignal(in);
        end
    else
        invect=in;
    end

    hdlbody='';
    hdlsignals='';

    outsltype=hdlsignalsltype(out);
    outvtype=hdlsignalvtype(out);
    outcmplx=hdlsignaliscomplex(out);
    outrate=hdlsignalrate(out);

    switch style
    case 'linear'
        last_sum=invect(1);
        count=1;
        if length(invect)==1
            hdlbody=[hdlbody,hdldatatypeassignment(invect,out,rounding,saturation)];
        else
            for n=invect(2:end-1)
                [sumname,sumout]=hdlnewsignal(['sum_',num2str(count)],...
                '',-1,outcmplx,dims,outvtype,outsltype,outrate);
                hdlsignals=[hdlsignals,makehdlsignaldecl(sumout)];
                [tempbody,tempsignals]=hdladd(last_sum,n,sumout,rounding,saturation);
                hdlbody=[hdlbody,tempbody];
                hdlsignals=[hdlsignals,tempsignals];
                count=count+1;
                last_sum=sumout;
            end
            [tempbody,tempsignals]=hdladd(last_sum,invect(end),out,rounding,saturation);
            hdlbody=[hdlbody,tempbody];
            hdlsignals=[hdlsignals,tempsignals];
        end

    case{'tree','pipelined'}

        if strcmp(style,'pipelined')
            pipe=true;
        else
            pipe=false;
        end

        oldsums=invect;
        for level=1:ceil(log2(length(invect)))
            count=1;
            newsums=[];
            newpipe=[];
            for n=2:2:length(oldsums)
                tmp1=hdlsignalsizes(oldsums(n-1));
                sz1=tmp1(1);
                bp1=tmp1(2);
                si1=tmp1(3);
                tmp2=hdlsignalsizes(oldsums(n));
                sz2=tmp2(1);
                bp2=tmp2(2);
                si2=tmp2(3);
                if fullprecisiontree
                    if bp1>bp2
                        sz2=sz2+(bp1-bp2);
                    elseif bp1<bp2
                        sz1=sz1+(bp2-bp1);
                    end
                    bp=max(bp1,bp2);
                    if sz1~=0&&sz2~=0
                        sz=1+max(sz1,sz2);
                    else
                        sz=0;
                    end
                    si=(si1~=0||si2~=0);

                    [sumvtype,sumsltype]=hdlgettypesfromsizes(sz,bp,si);
                else
                    sumvtype=outvtype;
                    sumsltype=outsltype;
                end
                [sumname,sumout]=hdlnewsignal(['sum',num2str(level),'_',num2str(count)],...
                '',-1,outcmplx,dims,sumvtype,sumsltype,outrate);
                newsums=[newsums,sumout];
                hdlsignals=[hdlsignals,makehdlsignaldecl(sumout)];
                [tempbody,tempsignals]=hdladd(oldsums(n-1),oldsums(n),sumout,rounding,saturation);
                hdlbody=[hdlbody,tempbody];
                hdlsignals=[hdlsignals,tempsignals];
                if pipe
                    [pipename,pipeout]=hdlnewsignal(['sumpipe',num2str(level),'_',num2str(count)],...
                    '',-1,outcmplx,dims,sumvtype,sumsltype,outrate);
                    newpipe=[newpipe,pipeout];
                    hdlregsignal(pipeout);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(pipeout)];
                end
                count=count+1;
            end
            if mod(length(oldsums),2)==1
                tmp=hdlsignalsizes(oldsums(end));
                [sumvtype,sumsltype]=hdlgettypesfromsizes(tmp(1),tmp(2),tmp(3));
                newsums=[newsums,oldsums(end)];
                if pipe
                    [pipename,pipeout]=hdlnewsignal(['sumpipe',num2str(level),'_',num2str(count)],...
                    '',-1,outcmplx,dims,sumvtype,sumsltype,outrate);
                    newpipe=[newpipe,pipeout];
                    hdlregsignal(pipeout);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(pipeout)];
                end
            end
            if pipe
                if emitMode
                    [tempbody,tempsignals]=hdlunitdelay(newsums,newpipe,...
                    hdluniqueprocessname,zeros(1,length(newsums)));
                    hdlbody=[hdlbody,tempbody];
                    hdlsignals=[hdlsignals,tempsignals];
                    oldsums=newpipe;
                else
                    for n=1:1:length(newsums)
                        hBufferC=newsums(n).getDrivers.insertBufferOnSrc;
                        hBufferC.setOutputPipeline(1);
                    end
                    oldsums=newsums;
                end
            else
                oldsums=newsums;
            end

        end
        hdlbody=[hdlbody,hdldatatypeassignment(oldsums(1),out,rounding,saturation)];
    case 'cascade'
        config.invectsize=invectsize;
        config.cmplx=outcmplx;
        config.sltype=outsltype;
        config.vtype=outvtype;
        config.decomposition=1;
        config.rounding=rounding;
        config.saturation=saturation;
        modestring='sum';
        name='bla';
        [hdlbody,hdlsignals]=implement_cascade(invect,out,modestring,name,config);
    otherwise
        error(message('HDLShared:directemit:soeunknownstyle',style));

    end

    function[body,signals]=implement_cascade(invect,out,modestring,name,config)

        body='';
        signals='';


        decompose_vector=decompose(config.invectsize,config.decomposition);


        tmpout=[];
        for cloop=2:length(decompose_vector)
            [idxname,tmpout(cloop)]=hdlnewsignal([modestring,'out_',num2str(decompose_vector(cloop))],'block',-1,0,0,config.vtype,config.sltype);
            signals=[signals,makehdlsignaldecl(tmpout(cloop))];
        end
        tmpout(1)=out;

        first_element=1;
        for cloop=1:length(decompose_vector)
            invect_1=[];
            if cloop==length(decompose_vector)
                last_element=(decompose_vector(cloop)+first_element-1);
                for i=first_element:last_element
                    invect_1=[invect_1,invect(cloop+i-1)];
                end
            else
                last_element=(decompose_vector(cloop)+first_element-2);
                for i=first_element:last_element
                    invect_1=[invect_1,invect(cloop+i-1)];
                end
                invect_1=[invect_1,tmpout(cloop+1)];
            end
            if config.decomposition==0
                sufix='';
            else
                sufix=['_',num2str(decompose_vector(cloop))];
            end
            body=[body,'--********************* ',sufix,' Input ',modestring,' implementation ********************','\n'];


            if config.decomposition==0
                Hierarchy='top';
                [tmpbody,tmpsignals]=local_sumofelements_1multi(invect_1,tmpout(cloop),modestring,name,Hierarchy,config,sufix);
            else
                if cloop==1
                    Hierarchy='top';
                else
                    Hierarchy='blk';
                end
                [tmpbody,tmpsignals]=local_sumofelements_1multi(invect_1,tmpout(cloop),modestring,name,Hierarchy,config,sufix);
            end
            body=[body,tmpbody];
            signals=[signals,tmpsignals];
            first_element=first_element+decompose_vector(cloop)-2;
        end




        function[body,signals]=local_sumofelements_1multi(invect,out,modestring,name,Hierarchy,config,sufix)

            invectsize=config.invectsize;
            cmplx=config.cmplx;
            sltype=config.sltype;
            vtype=config.vtype;
            rounding=config.rounding;
            saturation=config.saturation;


            bdt=hdlgetparameter('base_data_type');

            comment=['\n','  ',hdlgetparameter('comment_char'),' ',modestring,'_block',sufix,': '];
            body='';
            signals='';





            max_cnt=length(invect)-2;
            cnt_sz=ceil(log2(length(invect)));


            [cntvtype,cntsltype]=hdlgettypesfromsizes(cnt_sz,0,0);





            if length(invect)==2
                signals=[signals,comment,'Signal/Constant Declaration ','\n'];
                [idxname,nxt_value]=hdlnewsignal(['next',modestring,sufix],'block',-1,0,0,vtype,sltype);
                signals=[signals,makehdlsignaldecl(nxt_value)];

                body=[body,comment,'Determine the ',modestring,' between the two inputs','\n'];
                oldcbs=hdlgetparameter('cast_before_sum');
                [tmpbody,tmpsignals]=hdladd(invect(1),invect(2),nxt_value,rounding,saturation);
                body=[body,tmpbody];
                signals=[signals,tmpsignals];
                hdlsetparameter('cast_before_sum',oldcbs);
                body=[body,hdlunitdelay(nxt_value,out,['update_value',sufix],0)];
            else



                signals=[signals,comment,'Constant Declaration ','\n'];
                [idxname,std_0]=hdlnewsignal(['std_0',sufix],'block',-1,0,0,bdt,'boolean');
                signals=[signals,makehdlconstantdecl(std_0,hdlconstantvalue(0,1,0,0))];
                [idxname,std_1]=hdlnewsignal(['std_1',sufix],'block',-1,0,0,bdt,'boolean');
                signals=[signals,makehdlconstantdecl(std_1,hdlconstantvalue(1,1,0,0))];

                [incsz,incbp,incsi]=hdlgetsizesfromtype(cntsltype);
                [idxname,end_cnt]=hdlnewsignal(['end_cnt',sufix],'block',-1,0,0,cntvtype,cntsltype);
                signals=[signals,makehdlconstantdecl(end_cnt,hdlconstantvalue(max_cnt,incsz,incbp,incsi))];




                signals=[signals,comment,'Counter Signal Declaration','\n'];
                [idxname,cnt_enb]=hdlnewsignal(['cnt_enb',sufix],'block',-1,0,0,bdt,'boolean');
                signals=[signals,makehdlsignaldecl(cnt_enb)];
                [idxname,cntenb_tmp]=hdlnewsignal(['cntenb_tmp',sufix],'block',-1,0,0,bdt,'boolean');
                signals=[signals,makehdlsignaldecl(cntenb_tmp)];
                [idxname,not_cnt_enb]=hdlnewsignal(['not_cnt_enb',sufix],'block',-1,0,0,bdt,'boolean');
                signals=[signals,makehdlsignaldecl(not_cnt_enb)];
                [idxname,cnt]=hdlnewsignal(['cnt',sufix],'block',-1,0,0,cntvtype,cntsltype);
                signals=[signals,makehdlsignaldecl(cnt)];
                [idxname,cnt_dec2]=hdlnewsignal(['cnt_dec2',sufix],'block',-1,0,0,cntvtype,cntsltype);
                signals=[signals,makehdlsignaldecl(cnt_dec2)];


                signals=[signals,comment,' ',modestring,' related signal Declaration','\n'];
                [idxname,pre_value]=hdlnewsignal(['pre_',modestring,sufix],'block',-1,0,0,vtype,sltype);
                signals=[signals,makehdlsignaldecl(pre_value)];
                [idxname,cur_value]=hdlnewsignal(['cur_value',sufix],'block',-1,0,0,vtype,sltype);
                signals=[signals,makehdlsignaldecl(cur_value)];
                [idxname,nxt_value]=hdlnewsignal(['next',modestring,sufix],'block',-1,0,0,vtype,sltype);
                signals=[signals,makehdlsignaldecl(nxt_value)];


                if Hierarchy=='top'
                    signals=[signals,comment,'Status (rdy) related Signal Declaration','\n'];


                    [idxname,rdy_cond]=hdlnewsignal(['rdy_cond',sufix],'block',-1,0,0,bdt,'boolean');
                    signals=[signals,makehdlsignaldecl(rdy_cond)];
                    [idxname,nxt_rdy]=hdlnewsignal(['nxt_rdy',sufix],'block',-1,0,0,bdt,'boolean');
                    signals=[signals,makehdlsignaldecl(nxt_rdy)];
                    [idxname,rdy_tmp]=hdlnewsignal(['rdy_tmp',sufix],'block',-1,0,0,bdt,'boolean');
                    signals=[signals,makehdlsignaldecl(rdy_tmp)];
                    [inxname,rdy_reg]=hdlnewsignal(['rdy_reg',sufix],'block',-1,0,0,bdt,'boolean');
                    signals=[signals,makehdlsignaldecl(rdy_reg)];
                    [inxname,rdy]=hdlnewsignal(['rdy',sufix],'block',-1,0,0,bdt,'boolean');
                    signals=[signals,makehdlsignaldecl(rdy)];
                end

                signals=[signals,comment,' The following signals should be moved to entity as input or output','\n'];
                [idxname,In1_vld]=hdlnewsignal(['In1_vld',sufix],'block',-1,0,0,bdt,'boolean');
                signals=[signals,makehdlsignaldecl(In1_vld)];


                [idxname,outvld_tmp]=hdlnewsignal(['outvld_tmp',sufix],'block',-1,0,0,bdt,'boolean');
                signals=[signals,makehdlsignaldecl(outvld_tmp)];
                if Hierarchy=='top'
                    [idxname,out_vld]=hdlnewsignal(['out_vld',sufix],'block',-1,0,0,bdt,'boolean');
                    signals=[signals,makehdlsignaldecl(out_vld)];

                end


                signals=[signals,comment,'Misc Signal Declaration','\n'];
                [idxname,unsigned_1]=hdlnewsignal(['unsigned_1',sufix],'block',-1,0,0,cntvtype,cntsltype);
                signals=[signals,makehdlconstantdecl(unsigned_1,hdlconstantvalue(1,incsz,incbp,incsi))];
                [idxname,invld_and_not_cntenb]=hdlnewsignal(['invld_and_not_cntenb',sufix],'block',-1,0,0,bdt,'boolean');
                signals=[signals,makehdlsignaldecl(invld_and_not_cntenb)];
                [idxname,not_in1vld]=hdlnewsignal(['not_in1vld',sufix],'block',-1,0,0,bdt,'boolean');
                signals=[signals,makehdlsignaldecl(not_in1vld)];
                [idxname,invld_or_cntenb]=hdlnewsignal(['invld_or_cntenb',sufix],'block',-1,0,0,bdt,'boolean');
                signals=[signals,makehdlsignaldecl(invld_or_cntenb)];

                [idxname,cnt_clkenb]=hdlnewsignal(['cnt_clkenb',sufix],'block',-1,0,0,bdt,'boolean');
                signals=[signals,makehdlsignaldecl(cnt_clkenb)];







                body=[body,hdlbitop(cnt_enb,not_cnt_enb,'NOT')];
                body=[body,hdlbitop([In1_vld,not_cnt_enb],invld_and_not_cntenb,'AND')];
                cc=hdlgetcurrentclockenable;

                body=[body,comment,'Input vector expansion (Demux)','\n'];
                body=[body,hdlmux([invect(1:end-2),invect(end)],cur_value,cnt,{'=='},[],'when-else',[],0:max_cnt-1)];


                body=[body,comment,'Choosing between new input data or saved value ','\n'];
                body=[body,hdlmux([invect(end-1),out],pre_value,invld_and_not_cntenb,{'='},1,'when-else')];


                body=[body,comment,'Counter','\n'];

                body=[body,hdlbitop([In1_vld,cnt_enb],invld_or_cntenb,'OR')];
                body=[body,hdlbitop([cc,invld_or_cntenb],cnt_clkenb,'AND')];


                old_clken=hdlgetcurrentclockenable;
                hdladdclockenablesignal(cnt_clkenb);
                hdlsetcurrentclockenable(cnt_clkenb);
                [tmpbody,tmpsignalidx]=hdlcounter(cnt,max_cnt+1,['counter',sufix],1,0,-1);
                body=[body,tmpbody];
                for n=1:length(tmpsignalidx)
                    signals=[signals,makehdlsignaldecl(tmpsignalidx(n))];
                end

                body=[body,comment,'Counter enable','\n'];
                body=[body,hdlrelop(cnt,end_cnt,cntenb_tmp,'<')];
                body=[body,hdlunitdelay(cntenb_tmp,cnt_enb,['counter_enb',sufix],0)];


                body=[body,comment,'Determine the ',modestring,' between the current and previous value','\n'];
                oldcbs=hdlgetparameter('cast_before_sum');
                hdlsetparameter('cast_before_sum',0);
                [tmpbody,tmpsignals]=hdladd(cur_value,pre_value,nxt_value,rounding,saturation);
                body=[body,tmpbody];
                signals=[signals,tmpsignals];
                hdlsetparameter('cast_before_sum',oldcbs);

                body=[body,hdlunitdelay(nxt_value,out,['update_value',sufix],0)];

                hdlsetcurrentclockenable(old_clken);


                oldcbs=hdlgetparameter('cast_before_sum');
                hdlsetparameter('cast_before_sum',0);
                [tmpbody,tmpsignals]=hdlsub(end_cnt,unsigned_1,cnt_dec2,'Floor',0);
                body=[body,tmpbody];
                signals=[signals,tmpsignals];
                hdlsetparameter('cast_before_sum',oldcbs);

                body=[body,hdlrelop(cnt,end_cnt,outvld_tmp,'=')];

                if Hierarchy=='top'
                    body=[body,comment,'Generate the output valid signal','\n'];
                    body=[body,hdlunitdelay(outvld_tmp,out_vld,['out_vld_proc',sufix],0)];


                    body=[body,comment,'Generate the ready (Status) signal','\n'];
                    body=[body,hdlrelop(cnt,cnt_dec2,rdy_cond,'>=')];
                    body=[body,hdlmux([std_1,rdy_reg],rdy_tmp,rdy_cond,{'='},1,'when-else')];
                    body=[body,hdlmux([std_0,rdy_tmp],nxt_rdy,In1_vld,{'='},1,'when-else')];
                    body=[body,hdlunitdelay(nxt_rdy,rdy_reg,['rdy_proc',sufix],1)];
                    body=[body,hdlbitop(In1_vld,not_in1vld,'NOT')];
                    body=[body,hdlbitop([rdy_reg,not_in1vld],rdy,'AND')];
                end
            end
