function v=validateBlock(~,hC)




    v=hdlvalidatestruct;

    slbh=hC.SimulinkHandle;
    if~strcmp(get_param(slbh,'outDims'),'Element')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:outputdims'));
    end

    blockname='Direct Lookup Table (n-D)';

    if strcmp(get_param(slbh,'tabIsInput'),'on')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:tableasinput'));
    else
        table_rawdata=get_param(slbh,'mxTable');
        table_data=slResolve(table_rawdata,getfullname(slbh));
        dims=size(table_data);

        for i=1:length(dims)-1




            if dims(i)~=2^nextpow2(dims(i))
                v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:notpoweroftwo',int2str(i)));%#ok<*AGROW> % warning
            end
        end
    end

    cpdt=get_param(slbh,'CompiledPortDataTypes');
    incpdt=cpdt.Inport;

    if~isempty(incpdt)
        inDT=incpdt{1};
        for i=2:length(incpdt)
            if~strcmp(inDT,incpdt{i})
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:porttypemismatch',blockname,int2str(i)));%#ok<*AGROW> % error
            end
        end
    end


