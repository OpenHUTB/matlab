function v=checkhdl(this,varargin)






    v=this.checkAllCoeffsZero;
    if v.Status
        return
    end


    v=this.checkOneBitInput;
    if v.Status
        return
    end





    v=this.checkInvalidProps(varargin{:});

    if v.Status
        return
    end

    ssi=this.getHDLParameter('filter_serialsegment_inputs');
    lpi=this.getHDLParameter('filter_dalutpartition');
    reuse_acc=this.getHDLParameter('filter_reuseaccum');

    arithtype=this.InputSLtype;

    arithisdouble=strcmpi(arithtype,'double');

    radix=this.getHDLParameter('filter_daradix');
    baat=log2(radix);

    hdlsetparameter('filter_target_language',this.getHDLParameter('target_language'));

    polycoeffs=this.polyphasecoefficients;



    v=this.checkComplex;
    if v.Status
        return
    end

    nums=polycoeffs(:);
    firlen=length(nums(nums~=0));


    if firlen==1
        msg='Cannot generate HDL for a zero order FIRDECIM.';
        v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:zero_order');
        return
    end

    [ssi_correct,err_msg]=iscorrectssipartition(this,ssi);
    if~ssi_correct
        v=struct('Status',1,'Message',err_msg,'MessageID',...
        'HDLShared:hdlfilter:wrongSerialPartition');
        return
    end

    [lpi_correct,err_msg]=iscorrectpartition(lpi,polycoeffs);
    if~lpi_correct
        v=struct('Status',1,'Message',err_msg,'MessageID',...
        'HDLShared:hdlfilter:wrongDaLutPartition');
        return
    end
    ipsize=hdlgetsizesfromtype(this.Inputsltype);
    [baat_correct,err_msg]=iscorrectbaat(baat,ipsize,arithisdouble);
    if~baat_correct
        v=struct('Status',1,'Message',err_msg,'MessageID',...
        'HDLShared:hdlfilter:wrongdaradix');
        return
    end




    if reuse_acc
        err_msg=['Property ''ReuseAccum'' is not valid for ',this.FilterStructure,'.'];
        v=struct('Status',1,'Message',err_msg,'MessageID',...
        'HDLShared:hdlfilter:reuseaccumna');
        return
    end

    if~(length(lpi)==1&&lpi==-1)
        if arithisdouble
            err_msg=['Arithmetic ',arithtype,' does not apply to Distributed Arithmetic implementation.'];
            v=struct('Status',1,'Message',err_msg,'MessageID',...
            'HDLShared:hdlfilter:DAnotfordouble');
            return
        end
        if strcmpi(this.getHDLParameter('filter_fir_final_adder'),'pipelined')
            err_msg='Invalid value for ''FIRAdderStyle'' property. Expecting ''Tree''.';
            v=struct('Status',1,'Message',err_msg,'MessageID',...
            'HDLShared:hdlfilter:pipelinednotsupportedwithda');
            return
        end
    else

        if baat~=1
            err_msg='DARadix can''t be set without setting DALutPartition';
            v=struct('Status',1,'Message',err_msg,'MessageID',...
            'HDLShared:hdlfilter:OnlyBaatset');
            return
        end
    end

    v=this.checkPipelineSupport;
    if v.Status
        return
    end


    function[ssi_checked,err_str]=iscorrectssipartition(this,ssi)

        fl=this.getfilterlengths;
        len=fl.polyfirlen;
        cz_len=fl.maxpolylen;
        ipstr='SerialPartition';

        if isscalar(ssi)
            if ssi==cz_len||ssi==-1
                ssi_checked=1;
                err_str='';
            else
                if len~=cz_len
                    ssi_checked=0;
                    err_str=['Incorrect value specified for ',ipstr,', expecting ',num2str(cz_len),'.',newline,...
                    'Values of some filter coefficients are zero or power of 2.'];
                else
                    ssi_checked=0;
                    err_str=['Incorrect value specified for ',ipstr,', expecting ',num2str(cz_len),'.'];
                end
            end
        else

            if size(ssi,1)>1
                ssi_checked=0;
                err_str=['Illegal value specified for ',ipstr,'.',newline,...
                'Expecting scalar or one dimensional vector.'];
                return
            end
            if~all(ssi==floor(ssi))||~isempty(find(ssi<=0))&&~(length(ssi)==1&&ssi==-1)
                ssi_checked=0;
                err_str=['Illegal value specified for ',ipstr,'.',newline,...
                'Expecting positive non-zero integers for vector elements.'];
                return
            end
            if sum(ssi)==cz_len
                ssi_checked=1;
                err_str='';
            else
                if len~=cz_len
                    ssi_checked=0;
                    err_str=['Incorrect value specified for, ',ipstr,'.',newline,...
                    'Expecting a vector with sum of elements = ',num2str(cz_len),'.',newline,...
                    'Values of some filter coefficients are zero or power of 2.'];
                else
                    ssi_checked=0;
                    err_str=['Incorrect value specified for ',ipstr,'.',newline,...
                    'Expecting a vector with sum of elements = ',num2str(cz_len),'.'];
                end
            end
        end


        function[lpi_checked,err_str]=iscorrectpartition(lpi,polyc)


            phases=size(polyc);
            firlen=phases(2);
            phases=phases(1);
            if size(lpi,1)==1
                if sum(lpi)==firlen||(isscalar(lpi)&&lpi==-1)
                    if max(lpi)>12
                        lpi_checked=0;
                        err_str='All elements of vector value for ''DALutPartition'' property must be <= 12.';
                    else
                        lpi_checked=1;
                        err_str='';
                    end
                else
                    lpi_checked=0;
                    err_str=['Incorrect value specified for''DALUTPartition''.',newline,...
                    'Expecting ',num2str(firlen),' or a vector with sum of elements = ',num2str(firlen),'.',newline,];
                end
            else

                if~(size(lpi,1)==phases)
                    lpi_checked=0;
                    err_str=['Incorrect value specified for''DALUTPartition''.',newline,...
                    'Value must be a vector with 1 or ',num2str(phases),' rows.',newline];
                    return
                end
                for n=1:phases
                    len=length(find(polyc(n,:)));
                    if sum(lpi(n,:))==len
                        if max(lpi(n,:))>12
                            lpi_checked=0;
                            err_str='All elements of vector value for ''DALutPartition'' property must be <= 12.';
                            return
                        else
                            lpi_checked=1;
                            err_str='';
                        end
                    else
                        if firlen==len
                            lpi_checked=0;
                            err_str=['Incorrect value specified for ''DalutPartition''','.',newline,...
                            'Expecting a vector with sum of elements = ',num2str(len),' for row ',num2str(n),' (polyphase subfilter #',num2str(n),').'];
                            return
                        else
                            lpi_checked=0;
                            err_str=['Incorrect value specified for''DalutPartition''','.',newline,...
                            'Expecting a vector with sum of elements = ',num2str(len),' for row ',num2str(n),' (polyphase subfilter # ',num2str(n),').',newline,...
                            'Values of some polyphase coefficients for this phase are zero.'];
                            return
                        end
                    end
                end
            end

            function[baatok,err_msg]=iscorrectbaat(baat,ipsize,arithisdouble)

                if arithisdouble
                    baatok=1;
                    err_msg='';
                else
                    if mod(ipsize,baat)==0
                        baatok=1;
                        err_msg='';
                    else
                        if baat==0
                            baatok=1;
                            err_msg='';
                        else
                            baatok=0;
                            err_msg=['Incorrect Value specified for ''DARadix''',newline,...
                            'Value must be such that mod(InputWordLength, value) == 0.'];
                        end
                    end
                end


