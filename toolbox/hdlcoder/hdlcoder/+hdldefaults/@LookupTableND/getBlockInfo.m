function[table_data_typed,bpType_ex,oType_ex,fType_ex,powerof2,interpVal,...
    bp_data,dims,rndMode,satMode,diagnostics,extrap,spacing]=getBlockInfo(~,hC)





    slbh=hC.SimulinkHandle;
    rndMode=get_param(slbh,'RndMeth');
    sat=strcmp(get_param(slbh,'SaturateOnIntegerOverflow'),'on');
    if strcmp(sat,'on')
        satMode='Saturate';
    else
        satMode='Wrap';
    end


    outType=hC.PirOutputSignals(1).Type;
    oType_ex=pirelab.getTypeInfoAsFi(outType,rndMode);

    if~outType.getLeafType.isEnumType
        if isfloat(oType_ex)

            fType_ex=oType_ex;
            tType_ex=oType_ex;
        else
            fType_ex=fi(0,0,32,32,fimath(oType_ex));
            tTypeStr=get_param(slbh,'TableDataTypeName');
            if strcmp(tTypeStr,'double')



                tType_ex=oType_ex;
            else
                [tableWordSize,tableBits,tableSign]=hdlwordsize(tTypeStr);
                tType_ex=fi(0,tableSign,tableWordSize,tableBits,fimath(oType_ex));
            end
        end
    end


    rto=get_param(slbh,'RuntimeObject');
    table_data=rto.RuntimePrm(1).Data;



    if~strcmp(get_param(slbh,'TableSource'),'Dialog')
        table_data_typed=cast([],'like',table_data);
    elseif isfloat(oType_ex)

        table_data_typed=table_data;
    else


        table_fimath=pirelab.getFimathFromProps('Saturate','Nearest');
        table_data_rounded=fi(table_data,numerictype(tType_ex),table_fimath);
        table_data_typed=fi(table_data_rounded,numerictype(oType_ex),fimath(oType_ex));
    end


    dims=slResolve(get_param(slbh,'NumberOfTableDimensions'),getfullname(slbh));

    bp_data=cell(1,dims);
    bpType_ex=cell(1,dims);
    powerof2=zeros(1,dims);
    slobj=get_param(slbh,'Object');
    isEvenSpacing=strcmpi(slobj.BreakpointsSpecification,'Even spacing');
    spacing=zeros(1,dims);
    for ii=1:dims


        sigIdx=min(numel(hC.PirInputSignals),ii);
        inType=hC.PirInputSignals(sigIdx).Type;
        bpType=pirelab.getTypeInfoAsFi(inType,rndMode);

        if~inType.getLeafType.isEnumType
            rto=get_param(slbh,'RuntimeObject');
            bp_val=rto.RuntimePrm(ii+1).Data;
            if isinteger(bp_val)
                bp_val=fi(bp_val);
            end
            if isfi(bp_val)
                bpType_nt=numerictype(bp_val);
                if~isfloat(bpType_nt)
                    bpType=fi(bpType,bpType_nt);
                end
            end

            if~isfloat(bpType)&&bpType.WordLength==128
                bpType.SumMode='SpecifyPrecision';
                bpType.SumWordLength=bpType.WordLength;
                bpType.SumFractionLength=bpType.FractionLength;
                bpType.ProductMode='SpecifyPrecision';
                bpType.ProductWordLength=bpType.WordLength;
                bpType.ProductFractionLength=bpType.FractionLength;
            end



            evenly_spaced_fixpt=false;
            if~isfloat(bpType)
                bp_fimath=fimath(bpType);
                bp_fimath.RoundMode='Nearest';
                bp_fimath.OverflowMode='Saturate';
                evenly_spaced_fixpt=false;
            end

            if ii>3
                isDialogBP=true;
            else
                propName=sprintf('BreakpointsForDimension%dSource',ii);
                isDialogBP=strcmp(get_param(slbh,propName),'Dialog');
            end

            propName=sprintf('BreakpointsForDimension%dSpacing',ii);
            bp_spacing=slResolve(slobj.(propName),getfullname(slbh));

            if~isDialogBP

                bp_res=[];
            elseif isEvenSpacing

                if dims==1
                    N_dim=length(table_data);
                else
                    N_dim=size(table_data,ii);
                end

                if isfi(bpType)

                    bp_spacing=fi(bp_spacing,numerictype(bpType));
                    bp_val=fi(bp_val,numerictype(bpType));

                    bp_end_pt=fi(bp_val+(N_dim-1)*bp_spacing,numerictype(bpType));
                    if bpType.Signed
                        bp_res_reint_type=numerictype(1,bpType.WordLength,0);
                    else
                        bp_res_reint_type=numerictype(0,bpType.WordLength,0);
                    end



                    if bp_spacing==0
                        bp_res=fi(zeros(1,N_dim),...
                        bp_res_reint_type);
                    else
                        bp_res=fi(convertToInteger(bp_val):convertToInteger(bp_spacing):convertToInteger(bp_end_pt),...
                        bp_res_reint_type);
                    end
                    evenly_spaced_fixpt=true;
                else
                    bp_end_pt=bp_val+(N_dim-1)*bp_spacing;
                    bp_res=bp_val:bp_spacing:bp_end_pt;
                    evenly_spaced_fixpt=false;
                end

                spacing(ii)=bp_spacing;
            else

                propName=sprintf('bp%d',ii);
                bp_rawdata=get_param(slbh,propName);

                bp_res=slResolve(bp_rawdata,getfullname(slbh));
            end




            if~isDialogBP
                bp_data{ii}=bp_res;
                stride=[];
            elseif evenly_spaced_fixpt
                bp_round=reinterpretcast(bp_res,numerictype(bpType));

                bp_data{ii}=fi(bp_round,numerictype(bpType),fimath(bpType));

                stride=reinterpretcast(fi(convertToInteger(bp_res(2))-convertToInteger(bp_res(1)),...
                bpType.Signed,bpType.WordLength,0),numerictype(bpType));
                stride=double(stride);
            elseif~isfloat(bpType)

                bp_data{ii}=fi(bp_res,numerictype(bpType),bp_fimath);

                stride=double(bp_res(2)-bp_res(1));


            else
                bp_data{ii}=bp_res;
                stride=[];
            end



            if isempty(stride)
                powerof2(ii)=-9999;
            else
                powerof2(ii)=nextpow2(stride);
                if~isempty(stride)&&stride~=2^powerof2(ii)
                    powerof2(ii)=-9999;
                end
            end
        end
        bpType_ex{ii}=bpType;
    end


    interpMethods=slobj.getPropAllowedValues('interpMethod');
    interp=get_param(slbh,'interpMethod');
    if strcmp(interp,interpMethods{1})
        interpVal=0;
    else

        interpVal=1;
    end
    extrapMethods=slobj.getPropAllowedValues('ExtrapMethod');
    if any(strcmp(interp,interpMethods(1:2)))

        extrap=extrapMethods{1};
    else
        extrap=get_param(slbh,'ExtrapMethod');
    end
    diagnostics=get_param(slbh,'DiagnosticForOutOfRangeInput');
end

function y=convertToInteger(bp_val)
    y=reinterpretcast(bp_val,numerictype(bp_val.Signed,bp_val.WordLength,0));
end


