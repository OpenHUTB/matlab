function v=checkhdl(this,varargin)






    v=this.checkOneBitInput;
    if v.Status
        return
    end



    v=this.checkInvalidProps(varargin{:});

    if v.Status
        return
    end


    v=this.checkAllCoeffsZero;
    if v.Status
        return
    end

    coeffs=this.Coefficients;
    firlen=length(coeffs);
    szfirlen=size(firlen);
    structure=this.filterstructure;






    reuse_acc=this.getHDLParameter('filter_reuseaccum');

    ssi=this.getHDLParameter('filter_serialsegment_inputs');
    lpi=this.getHDLParameter('filter_dalutpartition');

    arithtype=this.InputSLtype;
    if strcmpi(arithtype,'double')
        arithisdouble=true;
    else
        arithisdouble=false;
    end





    if szfirlen(1)~=1||szfirlen(2)~=1
        msg=['HDL code generation is not supported for multisection ',upper(structure),' filters.'];
        v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:multisectionfir');
        return
    end

    v=this.checkComplex;
    if v.Status
        return
    end







    radix=this.getHDLParameter('filter_daradix');
    baat=log2(radix);

    filterlengths=this.getfilterlengths;

    czero_len=filterlengths.czero_len;


    [ssi_correct,err_msg]=checkCoeffPartition(this,ssi,'SerialPartition');
    if~ssi_correct
        v=struct('Status',1,'Message',err_msg,'MessageID','HDLShared:hdlfilter:wrongSerialSectionInputs');
        return
    end
    [lpi_correct,err_msg]=checkCoeffPartition(this,lpi,'DALutPartition');

    if~lpi_correct
        v=struct('Status',1,'Message',err_msg,'MessageID','HDLShared:hdlfilter:wrongDaLutPartition');
        return
    end
    ipsize=hdlgetsizesfromtype(this.Inputsltype);
    [baat_correct,err_msg]=iscorrectbaat(baat,ipsize,arithisdouble);
    if~baat_correct
        v=struct('Status',1,'Message',err_msg,'MessageID','HDLShared:hdlfilter:wrongDARadix');
        return
    end


    if isscalar(ssi)
        if ssi==-1
            if reuse_acc









            else

            end
        else





        end
    else
        if reuse_acc
            ssi=[ssi(1:end-1)+1,ssi(end)];
            [okforcascade,err_msg]=isrightforcascade(ssi,czero_len);
            if~okforcascade
                v=struct('Status',1,'Message',err_msg,'MessageID','HDLShared:hdlfilter:wrongserialsectioninputs');
                return
            else




            end
        else
            if isequal(ones(1,length(ssi)),ssi)

            else











            end
        end
    end

    impl=this.implementation;
    if~(length(lpi)==1&&lpi==-1)


        if strcmpi(impl,'serial')||strcmpi(impl,'serialcascade')
            msg='Only one of the two properties ''Distributed Arithmetic'' and ''SerialPartition'' can be set.';
            v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:wrongcombinationofinputs');
            return
        else


            if arithisdouble
                msg=['Arithmetic ',arithtype,' doesnot apply to Distributed Arithmetic implementation.'];
                v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:DAnotfordouble');
                return
            end
            if max(lpi)>12
                msg=['All elements of vector value for ''DALutPartition'' property must be <= 12.'];
                v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:lutparttoomuch');
                return
            end

        end
    else

        if~(strcmpi(impl,'serial')&&strcmpi(impl,'serialcascade'))
            if baat~=1
                msg='DARadix can''t be set without setting DALutPartition.';
                v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:OnlyBaatset');
                return
            end
        end
    end



    v=this.checkPipelineSupport;
    if v.Status
        return
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
                    err_msg=['Incorrect Value specified for ''DARadix',newline,...
                    'Value must be such that mod(InputWordLength, log2(value)) == 0.'];
                end
            end
        end


        function[cascadeok,err_msg]=isrightforcascade(ssi,cz_len)

            if(isequal(ssi,sort(ssi,'descend'))&&(sum(ssi)==cz_len+length(ssi)-1)&&isequal(sort(ssi),unique(ssi)))
                cascadeok=1;
                err_msg='';
            else
                cascadeok=0;
                err_msg=['Incorrect value specified for SerialPartition.',newline,...
'For accumulator reuse, values must be in descending order'...
                ,newline...
                ,'except for the last two values which can be the same.'];
            end

