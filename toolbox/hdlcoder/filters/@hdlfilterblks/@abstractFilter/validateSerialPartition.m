function v=validateSerialPartition(this,hC)







    hF=this.createHDLFilterObj(hC);

    unSupportedProps=hF.getunsupportedprops;
    if any(strncmpi('serialpartition',unSupportedProps,length('serialpartition')))||...
        any(strncmpi('reuseaccum',unSupportedProps,length('reuseaccum')))
        err=1;
        v=hdlvalidatestruct(err,...
        message('hdlcoder:filters:validateSerialPartition:serialnotsupported'));
    else
        v=hdlvalidatestruct;
        value=this.getImplParams('SerialPartition');
        if~isempty(value)
            v=[v,checkSerialPartitionValue(value)];
        end
        if any([v.Status])
            return;
        end


        this.applySerialPartition(hF);
        v=[v,checkFullPrecision(hF)];

        v=[v,getserialinfo(hF)];
        s=this.applyFilterImplParams(hF,hC);
        hF.setimplementation;
        v1=hF.checkhdl;
        v1.Message=strrep(v1.Message,'\n',' ');
        v=[v,v1];
        this.unApplyParams(s.pcache);

        if hdlgetparameter('generateValidationModel')


            v(end+1)=hdlvalidatestruct(3,message('HDLShared:filters:validate:validationModelAssertions'));
        end

    end

    function v=checkSerialPartitionValue(value)


        v=hdlvalidatestruct;
        if isnumeric(value)&&~isempty(value)
            if isscalar(value)
                if~((floor(value)==value)&&value>=-1)
                    err=1;
                    v=hdlvalidatestruct(err,...
                    message('hdlcoder:filters:validateSerialPartition:illegalscalarparametervalue',value));
                end
            else

            end
        else
            err=1;
            v=hdlvalidatestruct(err,...
            message('hdlcoder:filters:validateSerialPartition:illegalparametervalue'));
        end



        function v=getserialinfo(hF)


            fls=hF.getfilterlengths;
            fl=fls.czero_len;
            spmatrix=getSerialPartMatrix(hF,fl);




            if isa(hF,'hdlfilter.firdecim')||isa(hF,'hdlfilter.firinterp')
                maxpolylen=0;
                for n=1:size(fls.effective_polycoeffs,1)
                    polyfilterlen=fls.effective_polycoeffs(n,:);
                    maxpolylen=max(maxpolylen,length(find(polyfilterlen~=0)));
                end

                spmatrix{1,2}=num2str(maxpolylen);
                spmatrix{1,3}=['ones(1,',num2str(maxpolylen),')'];

            end

            err=3;



            [start_tag,end_tag,start_title_tag,end_title_tag]=hdlgetHtmlonlyTags;
            errmsg=[start_tag...
            ,start_title_tag,'Serial Partition Implementation Information',end_title_tag...
            ,dispSerialPartitionHTML(hF,spmatrix)...
            ,end_tag];
            v=hdlvalidatestruct(err,...
            message('hdlcoder:filters:validateSerialPartition:serialInfoMsg',errmsg));





