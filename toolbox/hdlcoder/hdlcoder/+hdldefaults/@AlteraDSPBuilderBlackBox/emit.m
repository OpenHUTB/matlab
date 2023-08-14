function hdlcode=emit(this,hC)






    bfp=hC.SimulinkHandle;
    phan=get_param(bfp,'PortHandles');

    sysname=getfullname(bfp);
    pname_prefix=[this.alterahdlname(sysname),'_'];

    inportOffset=fixPorts(this,hC);
    pstruct=[];

    ain=find_system(bfp,'SearchDepth',1,'LookUnderMasks','all',...
    'ReferenceBlock','allblocks_alteradspbuilder2/Input');

    for n=1:length(ain)


        pname=get_param(ain(n),'Name');
        blk=ain(n);
        [pnum,inportblk]=this.findioport(blk);

        if isempty(pnum)
            error(message('hdlcoder:validate:alterainputporterror',pname));
        end
        pnum=str2num(pnum);
        hC.setInputPortName(inportOffset+pnum-1,[pname_prefix,this.alterahdlname(pname)]);

        pstruct(end+1).Name=pname;
        pstruct(end).NameLen=length(pname);
        pstruct(end).XType=getportdatatype(this,blk,0);

        if isempty(inportblk)
            pstruct(end).SType='Unknown';
        else
            pstruct(end).SType=getportdatatype(this,inportblk,0);
        end
    end

    for n=1:length(phan.Outport)


        pnum=get_param(phan.Outport(n),'PortNumber');
        blk=find_system(bfp,'SearchDepth',1,'LookUnderMasks','all',...
        'BlockType','Outport','Port',num2str(pnum));

        if isempty(blk)
            pname=['inport',num2str(pnum)];
        else
            [pname,dspboutput]=this.findioport(blk,'allblocks_alteradspbuilder2/Output');
        end

        if isempty(pname)
            error(message('hdlcoder:validate:alteraoutputporterror',pnum));
        end
        hC.setOutputPortName(n-1,[pname_prefix,this.alterahdlname(pname)]);

        pstruct(end+1).Name=pname;
        pstruct(end).NameLen=length(pname);
        pstruct(end).SType=getportdatatype(this,blk,1);

        if isempty(dspboutput)
            pstruct(end).XType='Unknown';
        else
            pstruct(end).XType=getportdatatype(this,dspboutput,1);
        end
    end


    ionames={};
    for n=1:hC.NumberOfPirInputPorts
        ionames{end+1}=hC.PirInputPorts(n).Name;
    end
    for n=1:hC.NumberOfPirOutputPorts
        ionames{end+1}=hC.PirOutputPorts(n).Name;
    end

    [uniqueio,idx1]=unique(lower(ionames));
    if length(uniqueio)<length(ionames)
        a=sort(idx1);
        b=1:length(a);
        c=find(a~=b,1);
        error(message('hdlcoder:validate:duplicatealteraport',ionames{c}));
    end

    if isempty(this.getImplParams('EntityName'))
        Name=hdlgettoplevel(bfp);
        this.addImplParam('EntityName',Name);
        isDefaultName=true;
    else
        isDefaultName=false;
    end

    if isempty(this.getImplParams('VHDLArchitectureName'))
        globalDefault=hdlgetparameter('vhdl_architecture_name');
        this.addImplParam('VHDLArchitectureName',globalDefault);
        isDefaultArch=true;
    else
        isDefaultArch=false;
    end

    hdlcode=finishEmit(this,hC);



    if isDefaultName
        this.removeImplParam('EntityName');
    end

    if isDefaultArch
        this.removeImplParam('VHDLArchitectureName');
    end

    thirdpname.blk='DSP Builder I/O Port';
    thirdpname.dt='DSP Builder Data Type';
    printdatatype(this,sysname,pstruct,thirdpname);




