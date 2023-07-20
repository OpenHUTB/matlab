%#codegen
function dout=hdleml_lookupnd(table_data,powerof2,...
    oType_ex,fType_ex,interpVal,varargin)













    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(table_data);
    eml_prefer_const(powerof2);
    eml_prefer_const(oType_ex);
    eml_prefer_const(fType_ex);
    eml_prefer_const(interpVal);

    float_data=isfloat(table_data);

    if float_data
        nt_o=[];
        fm_o=[];
        diff_ex=[];
        nt_os_ex=[];
    else
        nt_o=numerictype(oType_ex);
        fm_o=fimath(oType_ex);


        nt_table=numerictype(table_data);
        nt_diff=numerictype(1,nt_table.WordLength+1,nt_table.FractionLength);
        diff_ex=fi(0,nt_diff,fm_o);


        nt_os=numerictype(1,nt_o.WordLength+~nt_o.SignednessBool,nt_o.FractionLength);
        nt_os_ex=fi(0,nt_os,fm_o);
    end


    nt_k=numerictype(0,nextpow2(length(table_data)),0);

    fm_k=hdlfimath;


    tabledims=length(powerof2);
    k=fi(zeros(1,tabledims),nt_k,fm_k);
    f=cast(zeros(1,tabledims),'like',fType_ex);
    for i=1:tabledims



        [k(i),f(i)]=hdleml_prelookup(varargin{i},varargin{i+tabledims},fi(0,nt_k,fm_k),...
        fType_ex,0,powerof2(i),varargin{i+2*tabledims});
    end

    if tabledims==1

        dout_low=hdleml_directlookup(table_data,false,false,k(1));
        if interpVal==0

            if float_data
                dout=dout_low;
            else
                dout=fi(dout_low,nt_o,fm_o);
            end
        else

            if k(1)==length(varargin{1})-1
                high_idx=fi(k(1),nt_k,fm_k);
            else
                high_idx=fi(k(1)+1,nt_k,fm_k);
            end
            dout_high=hdleml_directlookup(table_data,false,false,high_idx);
            lut_diff=hdleml_sub_withcast(dout_high,dout_low,diff_ex,diff_ex,1);

            fraction=hdleml_product(f(1),lut_diff,oType_ex,1);
            dout=hdleml_add(dout_low,fraction,oType_ex);
        end
    else



        dout_low=hdleml_directlookup(table_data,false,false,k(1),k(2));
        if interpVal==0

            if float_data
                dout=dout_low;
            else
                dout=fi(dout_low,nt_o,fm_o);
            end
        else



















            if k(1)==length(varargin{1})-1
                k1inc=fi(k(1),nt_k,fm_k);
            else
                k1inc=fi(k(1)+1,nt_k,fm_k);
            end
            if k(2)==length(varargin{2})-1
                k2inc=fi(k(2),nt_k,fm_k);
            else
                k2inc=fi(k(2)+1,nt_k,fm_k);
            end




            dout_down=hdleml_directlookup(table_data,false,false,k1inc,k(2));
            dout_right=hdleml_directlookup(table_data,false,false,k(1),k2inc);
            dout_high=hdleml_directlookup(table_data,false,false,k1inc,k2inc);


            ptdiff1=hdleml_sub_withcast(dout_down,dout_low,diff_ex,diff_ex,1);
            ptdiff2=hdleml_sub_withcast(dout_high,dout_right,diff_ex,diff_ex,1);



            fr1=hdleml_product(f(1),ptdiff1,nt_os_ex,1);
            fr2=hdleml_product(f(1),ptdiff2,nt_os_ex,1);


            delta1=hdleml_add(dout_low,fr1,oType_ex);
            delta2=hdleml_add(dout_right,fr2,oType_ex);



            ptdiff3=hdleml_sub_withcast(delta2,delta1,nt_os_ex,nt_os_ex,1);


            fr3=hdleml_product(f(2),ptdiff3,nt_os_ex,1);

            dout=hdleml_add(delta1,fr3,oType_ex);
        end
    end
end


