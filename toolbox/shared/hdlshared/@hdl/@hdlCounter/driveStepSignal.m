function hdlcode=driveStepSignal(this)





    hdlcode=hdlcodeinit;

    if~isempty(this.cnt_dir)
        if strcmpi(this.CounterType,'Free Running')
            oldsc=hdlsequentialcontext;
            hdlsequentialcontext(false);
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
            [hdlmux([this.negStepSignal,this.posStepSignal],this.StepSignal,this.cnt_dir,...
            {'=='},[],'when-else',[],0:1),hdl.newline(2)]];
            hdlsequentialcontext(oldsc);
        else
            hdlcode=hdlcodeconcat([hdlcode,nextValuePreProcess(this)]);
            oldsc=hdlsequentialcontext;
            hdlsequentialcontext(false);
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
            [hdlmux([this.negStepReg,this.posStepReg],this.StepSignal,this.cnt_dir,...
            {'=='},[],'when-else',[],0:1),hdl.newline(2)]];
            hdlsequentialcontext(oldsc);
        end
    else
        if strcmpi(this.CounterType,'Free Running')
            oldsc=hdlsequentialcontext;
            hdlsequentialcontext(false);
            if~isempty(this.posStepSignal)
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
                [hdlsignalassignment(this.posStepSignal,this.StepSignal),hdl.newline]];
            else
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
                [hdlsignalassignment(this.negStepSignal,this.StepSignal),hdl.newline]];
            end
            hdlsequentialcontext(oldsc);
        else
            hdlcode=hdlcodeconcat([hdlcode,nextValuePreProcess(this)]);
            oldsc=hdlsequentialcontext;
            hdlsequentialcontext(false);
            if~isempty(this.posStepSignal)
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
                [hdlsignalassignment(this.StepReg,this.StepSignal),hdl.newline]];
            else
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
                [hdlsignalassignment(this.StepReg,this.StepSignal),hdl.newline]];
            end
            hdlsequentialcontext(oldsc);
        end

    end



    function hdlcode=nextValuePreProcess(this)

        hdlcode=hdlcodeinit;

        oldsc=hdlsequentialcontext;
        hdlsequentialcontext(true);

        outportType=getoutportType(this);

        slType=hdlsignalsltype(this.outputs);
        outputType=hdlgetallfromsltype(slType);

        type=this.getCounterType(outputType);

        Compl=findComplement(this,type);

        if~isempty(this.cnt_dir)


            next2Last=this.findNext2LastValue(outportType.signed,outportType.size,outportType.bp);
            next2LastValueL=hdlconstantvalue(next2Last(1),outportType.size,outportType.bp,outportType.signed);
            [idxname,next2LastConst(1)]=hdlnewsignal('NEXT2LAST_VALUE_L','block',-1,0,0,outportType.vtype,outportType.sltype);
            makehdlconstantdecl(next2LastConst(1),next2LastValueL);

            next2LastValueH=hdlconstantvalue(next2Last(2),outportType.size,outportType.bp,outportType.signed);
            [idxname,next2LastConst(2)]=hdlnewsignal('NEXT2LAST_VALUE_H','block',-1,0,0,outportType.vtype,outportType.sltype);
            makehdlconstantdecl(next2LastConst(2),next2LastValueH);

            ComplValue=hdlconstantvalue(Compl,type.size,0,type.signed);
            [idxname,ComplConst]=hdlnewsignal('COMPLEMENT_VALUE','block',-1,0,0,type.vtype,type.sltype);
            makehdlconstantdecl(ComplConst,ComplValue);

            this.ComplSignal=ComplConst;

            [idxname,posStepReg]=hdlnewsignal('posStepReg','block',-1,0,0,type.vtype,type.sltype);
            hdlregsignal(posStepReg);
            [idxname,negStepReg]=hdlnewsignal('negStepReg','block',-1,0,0,type.vtype,type.sltype);
            hdlregsignal(negStepReg);

            this.posStepReg=posStepReg;
            this.negStepReg=negStepReg;

            hdlcode=hdlcodeconcat([hdlcode,getCountUpCond(this,next2LastConst)]);


            orgClkEnb=this.clockenable;
            if~isempty(this.cnt_en)
                this.clockenable=[this.clockenable,this.cnt_en];
            end


            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline];

            hdlcode=hdlcodeconcat([hdlcode...
            ,preProcStartExpr(this),...
            this.asyncResetExpr,...
            preProcResetBody(this,'async',posStepReg,negStepReg),...
            this.clockExpr,...
            this.syncResetExpr,...
            preProcResetBody(this,'sync',posStepReg,negStepReg),...
            this.clockEnableExpr,...
            preProcBody(this,next2LastConst,posStepReg,negStepReg),...
            this.endClockEnableExpr,...
            this.endSyncResetExpr,...
            this.endClockExpr,...
            this.endAsyncResetExpr,...
            preProcessEndExpr(this)]);


            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline];

            this.clockenable=orgClkEnb;

        else


            next2Last=this.findNext2LastValue(outportType.signed,outportType.size,outportType.bp);

            next2LastValue=hdlconstantvalue(next2Last,outportType.size,outportType.bp,outportType.signed);
            [idxname,next2LastConst]=hdlnewsignal('NEXT2LAST_VALUE','block',-1,0,0,outportType.vtype,outportType.sltype);
            makehdlconstantdecl(next2LastConst,next2LastValue);

            ComplValue=hdlconstantvalue(Compl,type.size,0,type.signed);
            [idxname,ComplConst]=hdlnewsignal('COMPLEMENT_VALUE','block',-1,0,0,type.vtype,type.sltype);
            makehdlconstantdecl(ComplConst,ComplValue);

            [idxname,StepReg]=hdlnewsignal('stepReg','block',-1,0,0,type.vtype,type.sltype);
            hdlregsignal(StepReg);

            this.ComplSignal=ComplConst;

            this.StepReg=StepReg;


            orgClkEnb=this.clockenable;
            if~isempty(this.cnt_en)
                this.clockenable=[this.clockenable,this.cnt_en];
            end


            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline];
            hdlcode=hdlcodeconcat([hdlcode...
            ,preProcStartExpr(this),...
            this.asyncResetExpr,...
            preProcResetBody(this,'async',StepReg,''),...
            this.clockExpr,...
            this.syncResetExpr,...
            preProcResetBody(this,'sync',StepReg,''),...
            this.clockEnableExpr,...
            preProcBody(this,next2LastConst,StepReg,''),...
            this.endClockEnableExpr,...
            this.endSyncResetExpr,...
            this.endClockExpr,...
            this.endAsyncResetExpr,...
            preProcessEndExpr(this)]);


            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline];


            this.clockenable=orgClkEnb;
        end
        hdlsequentialcontext(oldsc);




        function hdlcode=preProcStartExpr(this)

            hdlcode=hdlcodeinit;

            label=getProcessLabel(this);

            if this.isVHDL
                hdlcode.arch_body_blocks=...
                [hdl.indent(1),label,' : ','PROCESS',' ',this.sensitivityList,hdl.newline,...
                hdl.indent(1),'BEGIN',hdl.newline];

            else
                hdlcode.arch_body_blocks=...
                [hdl.indent(1),'always @ ',this.sensitivityList,hdl.newline,...
                hdl.indent(2),'begin: ',label,hdl.newline];
            end



            function hdlcode=preProcResetBody(this,resetType,posStepReg,negStepReg)

                hdlcode=hdlcodeinit;

                if this.needResetBody(resetType)

                    if this.isVHDL&&this.hasAsyncReset
                        rindent=3;
                    else
                        rindent=4;
                    end

                    if~isempty(this.posStepSignal)&&~isempty(this.negStepSignal)
                        str=[hdl.indent(rindent),hdlsignalname(posStepReg),' <= ',hdlsignalname(this.posStepSignal),';',hdl.newline];
                        str=[str,hdl.indent(rindent),hdlsignalname(negStepReg),' <= ',hdlsignalname(this.negStepSignal),';',hdl.newline];
                    elseif~isempty(this.negStepSignal)
                        str=[hdl.indent(rindent),hdlsignalname(posStepReg),' <= ',hdlsignalname(this.negStepSignal),';',hdl.newline];
                    else
                        str=[hdl.indent(rindent),hdlsignalname(posStepReg),' <= ',hdlsignalname(this.posStepSignal),';',hdl.newline];
                    end





                    hdlcode.arch_body_blocks=str;

                    if strcmpi(resetType,'Sync')
                        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,this.finishSyncResetBody];
                    end

                end


                function hdlcode=preProcessEndExpr(this)


                    hdlcode=hdlcodeinit;

                    label=getProcessLabel(this);

                    if this.isVHDL
                        hdlcode.arch_body_blocks=...
                        [hdl.indent(1),'END PROCESS ',label,';'];
                    else
                        hdlcode.arch_body_blocks=...
                        [hdl.indent(2),'end // ',label];
                    end
                    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline];


                    function hdlcode=preProcBody(this,next2LastConst,posStepReg,negStepReg)

                        hdlcode=hdlcodeinit;
                        nl=hdl.newline;

                        if this.isVHDL
                            rindent=4;
                            str=hdl.indent(rindent);
                            ifStr='IF ';
                            thenStr=[' THEN',nl];
                            condStr=' = ';
                            condVal='''1''';
                            elsStr='ELS';
                            eStr=['E',nl];
                            endStr=['END IF;',nl];
                        else
                            rindent=5;
                            str=hdl.indent(rindent);
                            ifStr='if (';
                            thenStr=[') begin',nl];
                            condStr=' == ';
                            condVal='1''b1';
                            elsStr=['end',nl,hdl.indent(rindent),'else '];
                            eStr=['begin ',nl];
                            endStr=['end',nl];
                        end

                        if isempty(negStepReg)
                            str=[str,ifStr,hdlsignalname(this.CounterSignal),condStr,hdlsignalname(next2LastConst(1)),thenStr];

                            str=[str,hdl.indent(rindent+1),hdlsignalname(posStepReg),' <= ',hdlsignalname(this.ComplSignal),';',nl];

                            str=[str,hdl.indent(rindent),elsStr,eStr];

                            if(this.Stepvalue<0)
                                str=[str,hdl.indent(rindent+1),hdlsignalname(posStepReg),' <= ',hdlsignalname(this.negStepSignal),';',nl];
                            else
                                str=[str,hdl.indent(rindent+1),hdlsignalname(posStepReg),' <= ',hdlsignalname(this.posStepSignal),';',nl];
                            end

                            str=[str,hdl.indent(rindent),endStr];

                        else
                            str=[str,ifStr,hdlsignalname(this.countUpCond),condStr,condVal,thenStr];
                            str=[str,hdl.indent(rindent+1),hdlsignalname(posStepReg),' <= ',hdlsignalname(this.ComplSignal),';',nl];
                            str=[str,hdl.indent(rindent+1),hdlsignalname(negStepReg),' <= ',hdlsignalname(this.ComplSignal),';',nl];

                            str=[str,hdl.indent(rindent),elsStr,eStr];

                            str=[str,hdl.indent(rindent+1),hdlsignalname(posStepReg),' <= ',hdlsignalname(this.posStepSignal),';',nl];
                            str=[str,hdl.indent(rindent+1),hdlsignalname(negStepReg),' <= ',hdlsignalname(this.negStepSignal),';',nl];

                            str=[str,hdl.indent(rindent),endStr];
                        end

                        hdlcode.arch_body_blocks=str;



                        function type=getoutportType(this)

                            if strcmpi(this.Outputdatatype,'unsigned')
                                signed=0;
                            else
                                signed=1;
                            end
                            [vtyep,sltype]=hdlgettypesfromsizes(this.wordlength,this.fractionlength,signed);
                            type=hdlgetallfromsltype(sltype);


                            function hdlcode=getCountUpCond(this,next2LastValue)
                                bdt=hdlgetparameter('base_data_type');

                                hdlcode=hdlcodeinit;
                                str='';

                                [idxname,countUpCond]=hdlnewsignal('countUpCond','block',-1,0,0,bdt,'boolean');
                                [idxname,roll2InitialValue]=hdlnewsignal('roll2InitialValue','block',-1,0,0,bdt,'boolean');
                                this.countUpCond=roll2InitialValue;

                                if this.isVHDL
                                    str=[str,'  ',hdlsignalname(countUpCond),' <= ''1''  WHEN ((',...
                                    hdlsignalname(this.posStepSignal),' > 0 AND ',hdlsignalname(this.cnt_dir),' = ''1'' ) OR (',...
                                    hdlsignalname(this.posStepSignal),' < 0 AND ',hdlsignalname(this.cnt_dir),' = ''0'' )) \n',...
                                    '                      ELSE ''0'';\n'];
                                    str=[str,'  ',hdlsignalname(roll2InitialValue),' <= ''1'' WHEN (((',...
                                    hdlsignalname(this.CounterSignal),' = ',hdlsignalname(next2LastValue(1)),') AND (',hdlsignalname(countUpCond),' = ''1'')) OR ((',...
                                    hdlsignalname(this.CounterSignal),' = ',hdlsignalname(next2LastValue(2)),') AND (',hdlsignalname(countUpCond),' = ''0''))) \n',...
                                    '                      ELSE ''0'';\n\n'];
                                else
                                    str=[str,'  assign ',hdlsignalname(countUpCond),' = ((',...
                                    hdlsignalname(this.posStepSignal),' > 0 && ',hdlsignalname(this.cnt_dir),' == 1''b1 ) || (',...
                                    hdlsignalname(this.posStepSignal),' < 0 && ',hdlsignalname(this.cnt_dir),' == 1''b0 )) ? 1''b1 :\n',...
                                    '                      1''b0;\n'];
                                    str=[str,'  assign ',hdlsignalname(roll2InitialValue),' = (((',...
                                    hdlsignalname(this.CounterSignal),' == ',hdlsignalname(next2LastValue(1)),') && (',hdlsignalname(countUpCond),' == 1''b1)) || ((',...
                                    hdlsignalname(this.CounterSignal),' == ',hdlsignalname(next2LastValue(2)),') && (',hdlsignalname(countUpCond),' == 1''b0))) ? 1''b1 :\n',...
                                    '                      1''b0;\n\n'];
                                end


                                hdlcode.arch_body_blocks=str;


                                function complement=findComplement(this,type)



                                    countToValue=fi(this.CountToValue,type.signed,type.size+type.signed,type.bp,'OverflowMode','wrap');
                                    countToValue=rescale(countToValue,0);
                                    maxValue=fi(countToValue.intmax,0,type.size+type.signed,0,'OverflowMode','wrap');
                                    initialValue=fi(this.resetValue,type.signed,type.size+type.signed,type.bp,'OverflowMode','wrap');
                                    initialValue=rescale(initialValue,0);
                                    comp=fi(maxValue-countToValue+initialValue+1,type.signed,type.size+type.signed,0,'OverflowMode','wrap');
                                    complement=comp.double;


                                    function label=getProcessLabel(this)

                                        label=['pre_',this.processName];

