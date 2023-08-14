function hdlcode=emit(this,hC)




    bfp=hC.SimulinkHandle;

    blkobj=get_param(bfp,'Object');

    portpaths=get(blkobj,'PortPaths');
    portmodes=this.hdlslResolve('PortModes',bfp);
    clkpaths=get(blkobj,'ClockPaths');
    clkmodes=this.hdlslResolve('ClockModes',bfp);

    phan=get_param(bfp,'PortHandles');

    if length(clkmodes)==1
        [cpath,~]=this.mtidehierarchyname(clkpaths);
    else
        clkpathsep=find(clkpaths==';');
        if isempty(clkpathsep)
            cpath='';

        else
            [cpath,~]=this.mtidehierarchyname(clkpaths(1:(clkpathsep(1)-1)));
        end
    end


    portpathsep=find(portpaths==';');
    if length(portpathsep)+1~=length(portmodes)
        error(message('hdlcoder:validate:portnumbermismatch',[get(blkobj,'Path'),'/',get(blkobj,'Name')]));
    end

    entityportnames={};
    if isempty(portpathsep)
        [notused,entityportnames{end+1}]=this.mtidehierarchyname(portpaths);%#ok
    else
        st=1;
        testpath=cpath;
        for n=1:length(portpathsep)
            [path,entityportnames{end+1}]=this.mtidehierarchyname(portpaths(st:(portpathsep(n)-1)));
            st=portpathsep(n)+1;
            if~isempty(path)&&isempty(testpath)
                testpath=path;
            elseif~isempty(path)&&~isempty(testpath)

                if~strcmp(path,testpath)
                    error(message('hdlcoder:validate:pathmismatch'));
                end
            end
        end
        [path,entityportnames{end+1}]=this.mtidehierarchyname(portpaths(st:end));
        if~isempty(path)&&~isempty(testpath)

            if~strcmp(path,testpath)
                error(message('hdlcoder:validate:pathmismatch'));
            end
        end
    end


    inentityports=entityportnames(portmodes==1);
    outentityports=entityportnames(portmodes==2);



    inportOffset=fixPorts(this,hC);

    for n=1:length(phan.Inport)
        hC.setInputPortName((n+inportOffset)-1,hdllegalnamersvd(inentityports(n)));
    end

    for n=1:length(phan.Outport)
        hC.setOutputPortName(n-1,hdllegalnamersvd(outentityports(n)));
    end

    hdlcode=finishEmit(this,hC);




