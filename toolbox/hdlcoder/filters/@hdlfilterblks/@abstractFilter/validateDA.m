function v=validateDA(this,hC)







    hF=this.createHDLFilterObj(hC);

    unSupportedProps=hF.getunsupportedprops;
    if any(strncmpi('dalutpartition',unSupportedProps,length('dalutpartition')))
        v=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validateDA:danotsupported'));
    else
        v=hdlvalidatestruct;
        value=this.getImplParams('DALUTPartition');
        if~isempty(value)
            v=[v,checkDALutPartitionValue(value)];
        end
        value=this.getImplParams('DARadix');
        if~isempty(value)
            v=[v,checkDARadixValue(value)];
        end
        ErrInDAvalues=0;
        for n=1:length(v),
            if v(n).Status
                ErrInDAvalues=1;
                break
            end
        end
        if~ErrInDAvalues
            v=[v,checkFullPrecision(hF)];
            v=[v,getdainfo(hF)];
            s=this.applyFilterImplParams(hF,hC);
            hF.setimplementation;
            v=[v,hF.checkhdl];
            this.unApplyParams(s.pcache);

            if hdlgetparameter('generateValidationModel')


                v(end+1)=hdlvalidatestruct(3,message('HDLShared:filters:validate:validationModelAssertions'));
            end
        end

    end

    function v=checkDALutPartitionValue(value)


        v=hdlvalidatestruct;
        if isnumeric(value)&&~isempty(value)
            if isscalar(value)
                if~((floor(value)==value)&&value>=-1)
                    v=hdlvalidatestruct(1,message('hdlcoder:filters:validateDA:illegalscalarparametervalue',value));
                end
            else

            end
        else
            v=hdlvalidatestruct(1,message('hdlcoder:filters:validateDA:illegalparametervalue'));
        end


        function v=checkDARadixValue(value)

            vint=check_integer(value);
            v=vint;
            if~vint.Status
                vsingl=check_singular(value);
                v=[v,vsingl];
            end
            if~vsingl.Status
                vpwr2=check_pwr2(value);
                v=[v,vpwr2];
            end


            function v=check_integer(value)
                v=hdlvalidatestruct;
                if any(rem(value,1)),
                    v=hdlvalidatestruct(1,message('hdlcoder:filters:validateDA:incorrectDARadix'));
                end



                function v=check_pwr2(value)

                    v=hdlvalidatestruct;
                    c=log2(value);
                    if~isreal(c)||any(rem(c,1))||c==0
                        v=hdlvalidatestruct(1,message('hdlcoder:filters:validateDA:incorrectDARadix'));
                    end


                    function v=check_singular(value)

                        v=hdlvalidatestruct;
                        if any(size(value)~=1),
                            v=hdlvalidatestruct(1,message('hdlcoder:filters:validateDA:incorrectDARadix'));
                        end



                        function v=getdainfo(hF)


                            [damatrix,lutmatrix]=getDAPartMatrix(hF);



                            [start_tag,end_tag,start_title_tag,end_title_tag]=hdlgetHtmlonlyTags;
                            errmsg=[start_tag...
                            ,start_title_tag,'Distributed Arithmetic Implementation Information',end_title_tag...
                            ,dispDAPartitionHTML(hF,damatrix,lutmatrix)...
                            ,end_tag];
                            v=hdlvalidatestruct(3,message('hdlcoder:filters:validateDA:serialInfoMsg',errmsg));


