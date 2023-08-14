function varargout=rfsystemsdomain(arg)







    persistent NETLIST;

    if(nargin==0)
        varargout{1}=NETLIST;
        return
    end

    switch(class(arg))
    case 'Simulink.SlDomainInfo'
        internal_RegisterRFSystems(arg);
    case 'struct'
        internal_CompileRFSystems(arg);
    case 'string'
        internal_StopRFSystems(arg);
    end

    function internal_RegisterRFSystems(domaininfo)

        domaininfo.name='rfsystemsdomain';
        domaininfo.version='0';
        domaininfo.lineBranching='off';
        domaininfo.compileFcn='rfsystemsdomain';
        domaininfo.stopFcn='rfsystemsdomain';
        domaininfo.key='63685da87db170d2f4b109715b0004aec2bc5aabba30adcb828458b3f8b21259';
        port=domaininfo.addPortType('p1');
        port.icon=domaininfo.getDomainImage('rfport.jpg');
        port.setConnectivity(port);

        domaininfo.locked='on';

        function internal_CompileRFSystems(netlist)












            nc=netlist.ConnectivityMatrix;
            nbh=netlist.BlockHandles;


            ubh=unique(netlist.BlockHandles);
            nblocks=length(ubh);
            types=zeros(nblocks,1);
            sourceblock=[];
            sinkblock=[];

            for idx1=1:nblocks,
                classname=get_param(ubh(idx1),'SubClassName');
                switch classname
                case 'source'
                    types(idx1)=1;
                    sourceblock=[get_param(ubh(idx1),'parent'),'/','Goto'];
                case 'sink'
                    types(idx1)=2;
                    sinkblock=[get_param(ubh(idx1),'parent'),'/','From'];
                case 's-params-passive-network'
                    types(idx1)=3;
                case 'y-params-passive-network'
                    types(idx1)=4;
                case 'z-params-passive-network'
                    types(idx1)=5;
                case 'general-passive-network'
                    types(idx1)=6;
                case 'general-circuit-element'
                    types(idx1)=7;
                case 's-params-amplifier'
                    types(idx1)=10;
                case 'y-params-amplifier'
                    types(idx1)=11;
                case 'z-params-amplifier'
                    types(idx1)=12;
                case 'general-amplifier'
                    types(idx1)=13;
                case 's-params-mixer'
                    types(idx1)=14;
                case 'y-params-mixer'
                    types(idx1)=15;
                case 'z-params-mixer'
                    types(idx1)=16;
                case 'general-mixer'
                    types(idx1)=17;
                case 'general-network'
                    types(idx1)=18;
                case 'txline'
                    types(idx1)=30;
                case 'twowire'
                    types(idx1)=31;
                case 'coaxial'
                    types(idx1)=32;
                case 'parallelplate'
                    types(idx1)=33;
                case 'microstrip'
                    types(idx1)=34;
                case 'cpw'
                    types(idx1)=35;
                case 'rlcgline'
                    types(idx1)=36;
                case 'lclowpasstee'
                    types(idx1)=40;
                case 'lclowpasspi'
                    types(idx1)=41;
                case 'lchighpasstee'
                    types(idx1)=42;
                case 'lchighpasspi'
                    types(idx1)=43;
                case 'lcbandpasstee'
                    types(idx1)=44;
                case 'lcbandpasspi'
                    types(idx1)=45;
                case 'lcbandstoptee'
                    types(idx1)=46;
                case 'lcbandstoppi'
                    types(idx1)=47;
                case 'seriesrlc'
                    types(idx1)=48;
                case 'shuntrlc'
                    types(idx1)=49;
                otherwise
                    error(message('rfblks:rfsystemsdomain:UnrecognizedComponent',classname));
                end
            end
            if isempty(sourceblock)||isempty(sinkblock)
                error(message('rfblks:rfsystemsdomain:NoInputOrOutputBlock'));
            end



            dbsb=double(sourceblock);
            sumchar=sum(dbsb(:).*[1:length(dbsb)]');
            prmod=primes(83);
            tag=zeros(1,length(prmod));
            for nchar=1:length(prmod),
                tag(nchar)=mod(mod(sumchar,prmod(nchar)),26)+65;
            end
            strtag=char(tag);


            if nblocks>2


                cascadeh=ubh;

                cascadeh(1)=ubh(find(types==1));


                [ix,jx]=find(nc);
                links=nbh([ix(ix~=jx),jx(ix~=jx)]);

                rowVisited=zeros(size(links,1),1);
                [currRow,currCol]=find(links==cascadeh(1));
                blkCount=2;
                while any(rowVisited==0),

                    rowVisited(currRow)=1;

                    cascadeh(blkCount)=links(currRow,3-currCol);

                    [currRows,currCols]=find(links==cascadeh(blkCount));


                    currRow=currRows(min(find(rowVisited(currRows)==0)));
                    currCol=currCols(currRows==currRow);

                    blkCount=blkCount+1;
                end


                ckts=cell(nblocks-2,1);
                for iblk=2:nblocks-1,
                    currh=cascadeh(iblk);
                    blktype=types(find(ubh==currh));
                    switch blktype
                    case{3,4,5,6,7,10,11,12,13,14,15,16,17,18,30,31,32,33,34,35,36,40,41,42,43,44,45,46,47,48,49}
                        ckts{iblk-1}=getckt(currh);
                    otherwise
                        error(message('rfblks:rfsystemsdomain:CktHasUnrecognizedComponent'));
                    end
                    saveoutputblock(currh,sinkblock(1:end-5))
                end
            else

                cascadeh=ubh;

                cascadeh(1)=ubh(find(types==1));

                cascadeh(2)=ubh(find(types==2));
                ckts={};
            end
            set_param(sourceblock(1:end-5),'GoToTag',strtag);
            udata=get_param(sourceblock(1:end-5),'UserData');
            sys=udata.System;
            set(sys,'ZL',getoutputportparameters(sinkblock(1:end-5)));


            lastwarn('');
            oldsys=copy(sys);
            try
                buildsys(sys,ckts);
                analyze(sys);
            catch buildSYSException
                udata.System=oldsys;
                set_param(sourceblock(1:end-5),'UserData',udata);
                set_param(sinkblock(1:end-5),'UserData',udata);
                rethrow(buildSYSException);
            end
            if~isempty(lastwarn)
                warndlg(lastwarn,'RF Blockset Warning','on');
            end


            udata.Plot=true;
            set_param(sinkblock(1:end-5),'UserData',udata);
            if strncmp(get_param(sinkblock(1:end-5),'Flag'),'0',1)
                set_param(sinkblock(1:end-5),'GoToTag',strtag,'Flag','1');
            else
                set_param(sinkblock(1:end-5),'GoToTag',strtag,'Flag','0');
            end


            function internal_StopRFSystems(blockdiagram);
                disp(['Stopping ',blockdiagram])


                function zl=getoutputportparameters(block)
                    zl=slResolve(get_param(block,'Zl'),block);


                    function ckt=getckt(block)
                        udata=get_param(block,'UserData');
                        ckt=udata.Ckt;
                        if~isa(ckt,'rfckt.rfckt')
                            ckt=createrfcktfromblk(block);
                        end

                        function saveoutputblock(block,outputblock)
                            udata=get_param(block,'UserData');
                            udata.OutputPortBlock=outputblock;
                            set_param(block,'UserData',udata)
