function systemName=generateCosimBlock(this,openLinksSystem)



    if(nargin<2)
        openLinksSystem=true;
    end
    systemName=generateCosimBlockLocal(this,openLinksSystem);
end

function systemName=generateCosimBlockLocal(this,openLinksSystem)
    systemName='';
    [top,blksize]=CosimBlkAttributes(this);

    libraries={};
    libpostfix={};
    [ms,in,~,~,~]=hdlcoderui.isedasimlinksinstalled;

    if ms
        load_system('modelsimlib');
        libraries{end+1}='modelsimlib';
        libpostfix{end+1}='_mq';
    end
    if in
        load_system('lfilinklib');
        libraries{end+1}='lfilinklib';
        libpostfix{end+1}='_in';
    end

    if~isempty(libraries)
        blockName=top;
        h=new_system;
        if(openLinksSystem)
            open_system(h);
        end
        systemName=getfullname(h);

        PortPaths='';
        PortModes='';
        PortTimes='';
        PortSigns='';
        PortFracLengths='';

        for m=1:length(this.InPortSrc)
            port=this.InPortSrc(m);
            portName=port.HDLPortName;
            for ii=1:length(portName)
                name=portName{ii};
                if~iscell(name)
                    name={name};
                end
                for jj=1:length(name)
                    PortPaths=[PortPaths,'/',top,'/',name{jj},';'];%#ok<AGROW>
                    PortModes=[PortModes,'1 '];%#ok<AGROW> % input == 1
                    PortTimes=[PortTimes,'-1 '];%#ok<AGROW> % all inputs inherit
                    PortSigns=[PortSigns,'-1 '];%#ok<AGROW>
                    PortFracLengths=[PortFracLengths,'0,'];%#ok<AGROW> % inherit
                end
            end
        end

        for m=1:length(this.OutPortSnk)
            port=this.OutPortSnk(m);
            [~,bp,sign]=hdlgetsizesfromtype(port.PortSLType);
            portName=port.HDLPortName;
            for ii=1:length(portName)
                name=portName{ii};
                if~iscell(name)
                    name={name};
                end
                for jj=1:length(name)
                    PortPaths=[PortPaths,'/',top,'/',name{jj},';'];%#ok<AGROW>
                    PortModes=[PortModes,'2 '];%#ok<AGROW> % output == 2
                    PortTimes=[PortTimes,sprintf('%16.15g ',port.SLSampleTime)];%#ok<AGROW>
                    PortSigns=[PortSigns,sprintf('%d ',sign)];%#ok<AGROW>
                    PortFracLengths=[PortFracLengths,sprintf('%d,',bp)];%#ok<AGROW>
                end
            end
        end


        PortPaths=PortPaths(1:end-1);

        PortModes=['[',PortModes,']'];
        PortTimes=['[',PortTimes,']'];
        PortSigns=['[',PortSigns,']'];
        PortFracLengths=['[',PortFracLengths(1:end-1),']'];

        sizeX=blksize(1);
        sizeY=blksize(2);
        whitespace=100;
        baseX=whitespace;
        baseY=whitespace;

        for ii=1:length(libraries)
            blk_path=[systemName,'/',blockName,libpostfix{ii}];
            add_block([libraries{ii},'/HDL Cosimulation'],...
            blk_path,...
            'Position',[baseX,baseY,...
            baseX+sizeX,...
            baseY+sizeY]);%#ok<I18N_Concatenated_Msg>
            set_param(blk_path,...
            'PortPaths',PortPaths,...
            'PortModes',PortModes,...
            'PortTimes',PortTimes,...
            'PortSigns',PortSigns,...
            'PortFracLengths',PortFracLengths);
            baseX=baseX+floor(whitespace/2)+sizeX;
        end

        set_param(systemName,'Location',[10,10,baseX+sizeX,baseY+whitespace+sizeY]);
    end
end
