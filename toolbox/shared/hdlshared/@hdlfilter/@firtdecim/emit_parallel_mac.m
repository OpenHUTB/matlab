function[hdl_arch,prodlist]=emit_parallel_mac(this,coeffs_data,reginput)




    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    hdlsetparameter('filter_excess_latency',...
    hdlgetparameter('filter_excess_latency')+...
    hdlgetparameter('multiplier_input_pipeline')+...
    hdlgetparameter('multiplier_output_pipeline'));

    phases=this.decimationfactor;
    polycoeffs=this.polyphasecoefficients;


    productall=hdlgetallfromsltype(this.productSLtype);
    productvtype=productall.vtype;
    productsltype=productall.sltype;


    polysumall=hdlgetallfromsltype(this.PolyAccumSLType);
    polysumvtype=polysumall.vtype;
    polysumsltype=polysumall.sltype;


    rmode=this.Roundmode;
    [productrounding,sumrounding,...
    ]=deal(rmode);


    omode=this.Overflowmode;
    [productsaturation,sumsaturation,...
    ]=deal(omode);



    polymap=zeros(size(polycoeffs));
    pu={};
    fidx={};

    for n=1:size(polycoeffs,1)
        [pu{n},fidx{n},polymap(n,:)]=unique(polycoeffs(n,:),'legacy');
        polycoeffs(n,setdiff(1:size(polycoeffs,2),fidx{n},'legacy'))=0;
    end

    prodlist=zeros(size(coeffs_data.idx));
    total_typedefs={};

    for n=1:size(coeffs_data.idx,1)
        for m=1:size(coeffs_data.idx,2)
            coeffn=coeffs_data.idx(n,m);
            [prodlist(n,m),prodbody,prodsignals,prodtempsignals,prodtypedefs]=hdlcoeffmultiply(reginput(n),...
            polycoeffs(n,m),coeffn,...
            ['product_phase',num2str(n),'_',num2str(m)],...
            productvtype,productsltype,...
            productrounding,productsaturation,polysumsltype);
            if strcmpi(hdlgetparameter('target_language'),'vhdl')
                total_typedefs=[total_typedefs,prodtypedefs];
            end
            hdl_arch.signals=[hdl_arch.signals,prodsignals,prodtempsignals];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,prodbody];
        end
    end



    for n=1:phases
        tmp=prodlist(n,fidx{n});
        prodlist(n,:)=tmp(polymap(n,:));
    end




    polyadd=zeros(1,size(prodlist,2));
    for m=1:size(prodlist,2)

        last=0;
        lastn=0;
        for n=1:size(prodlist,1)
            if prodlist(n,m)~=0
                last=prodlist(n,m);
                lastn=n;
                break;
            end
        end
        if last~=0
            for n=lastn+1:size(prodlist,1)
                if prodlist(n,m)~=0
                    prodcomplexity=hdlsignaliscomplex(last)||hdlsignaliscomplex(prodlist(n,m));
                    [uname,polyadd(m)]=hdlnewsignal(['polyadd_',num2str(m)],...
                    'filter',-1,prodcomplexity,0,polysumvtype,polysumsltype);
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(polyadd(m))];
                    [tempbody,tempsignals]=hdlfilteradd(last,prodlist(n,m),polyadd(m),...
                    sumrounding,sumsaturation);
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                    hdl_arch.signals=[hdl_arch.signals,tempsignals];
                    last=polyadd(m);
                end
            end
            if last~=polyadd(m)
                if last==prodlist(lastn,m)
                    dtccomplexity=hdlsignaliscomplex(last);
                    [uname,polyadd(m)]=hdlnewsignal(['polyadd_',num2str(m)],...
                    'filter',-1,dtccomplexity,0,polysumvtype,polysumsltype);
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(polyadd(m))];
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,...
                    hdldatatypeassignment(last,polyadd(m),sumrounding,sumsaturation)];
                else
                    polyadd(m)=last;
                end
            end
        end
    end

    prodlist=polyadd;

    total_typedefs=unique(total_typedefs,'legacy');
    hdl_arch.typedefs=[hdl_arch.typedefs,total_typedefs{:}];



