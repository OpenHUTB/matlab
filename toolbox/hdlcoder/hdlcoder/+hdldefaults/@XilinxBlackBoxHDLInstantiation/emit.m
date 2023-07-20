function hdlcode=emit(this,hC)


    bfp=hC.SimulinkHandle;
    phan=get_param(bfp,'PortHandles');

    inportOffset=fixPorts(this,hC);
    pstruct=[];

    isport=1;
    xin=find_system(bfp,'SearchDepth',1,'LookUnderMasks','all',...
    'block_type','gatewayin');

    for n=1:length(xin)


        pname=get_param(xin(n),'Name');
        blk=xin(n);
        [pnum,inportblk]=this.findioport(blk,1);

        if isempty(pnum)
            error(message('hdlcoder:validate:xilinxinputporterror',pname));
        end
        pnum=str2int(pnum);
        hC.setInputPortName(inportOffset+pnum-1,this.xilinxhdlname(pname,isport));

        pstruct(end+1).Name=pname;%#ok
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
            [pname,gatewayblk]=this.findioport(blk,0);
        end

        if isempty(pname)
            error(message('hdlcoder:validate:xilinxoutputporterror',pnum));
        end
        hC.setOutputPortName(n-1,this.xilinxhdlname(pname,isport));

        pstruct(end+1).Name=pname;%#ok
        pstruct(end).NameLen=length(pname);
        pstruct(end).SType=getportdatatype(this,blk,1);

        if isempty(gatewayblk)
            pstruct(end).XType='Unknown';
        else
            pstruct(end).XType=getportdatatype(this,gatewayblk,1);
        end
    end


    ionames={};
    for n=1:hC.NumberOfPirInputPorts
        ionames{end+1}=hC.PirInputPorts(n).Name;%#ok
    end
    for n=1:hC.NumberOfPirOutputPorts
        ionames{end+1}=hC.PirOutputPorts(n).Name;%#ok
    end

    [uniqueio,idx1]=unique(ionames);
    if length(uniqueio)<length(ionames)
        a=sort(idx1);
        b=1:length(a);
        c=find(a~=b,1);
        error(message('hdlcoder:validate:duplicatexilinxport',ionames{c}));
    end

    isport=0;
    Name=[this.xilinxhdlname(hC.Name,isport),'_cw'];
    if isempty(this.getImplParams('EntityName'))
        this.addImplParam('EntityName',Name);
        isDefaultName=true;
    else
        isDefaultName=false;
    end

    if isempty(this.getImplParams('VHDLArchitectureName'))
        this.addImplParam('VHDLArchitectureName','structural');
        isDefaultArch=true;
    else
        isDefaultArch=false;
    end

    hdlcode=finishEmit(this,hC);

    addAttr=this.getImplParams('BlackBoxAttributes');
    if isempty(addAttr)||strcmpi(addAttr,'on')


        if hdlgetparameter('isvhdl')
            hdlcode.synthesis_attribute=[...
'  -- blackbox attribute for XST\n'...
            ,'  attribute box_type : string;\n'...
            ,'  attribute box_type of ',hdlcode.entity_name,' : component is "black_box";\n'...
            ,'  -- blackbox attribute for Synplify Pro\n'...
            ,'  attribute syn_black_box : boolean;\n'...
            ,'  attribute syn_black_box of ',hdlcode.entity_name,' : component is true;\n'];
        end
    else

        filename=fullfile(hdlGetCodegendir,'add_sgp.tcl');
        fid=fopen(filename,'w');
        fprintf(fid,['xfile add $xsg_dir/',Name,'.sgp\n']);
        fclose(fid);
    end



    if isDefaultName
        this.removeImplParam('EntityName');
    end

    if isDefaultArch
        this.removeImplParam('VHDLArchitectureName');
    end

    sysname=getfullname(bfp);
    printdatatype(this,sysname,pstruct);

    fprintf('\n### Xilinx System Generator Subsystem instead of Xilinx Black Box is recommended to work with Xilinx System Generator.\n\n')



