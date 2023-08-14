function dnnfpgaBfpScalingInt32Bias(gcb,KdataType,threadNumLimit)

    if(isempty(KdataType))
        return;
    end

    if(isempty(threadNumLimit))
        return;
    end

    ssName='ssb1';
    ssPath=[gcb,'/',ssName];
    pos=get_param(ssPath,'Position');
    posDTC=[-150,70,-100,120];
    posBC=[300,150,350,200];
    posint32=[600,150,650,200];

    try
        blocks=find_system(gcb,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1);
        for i=1:length(blocks)
            if(strcmp(get_param(blocks{i},'Name'),get_param(gcb,'Name')))||...
                strcmp(get_param(blocks{i},'BlockType'),'Inport')||...
                strcmp(get_param(blocks{i},'BlockType'),'Outport')
                continue;
            end
            delete_block(blocks{i});
        end
        lines=find_system(gcb,'LookUnderMasks','all','FindAll','on','FollowLinks','on','SearchDepth',1,'type','line');
        delete_line(lines);
        InPortName='InData';
        OutPortName='BiasData';
        OutPortName1='ExpData';

        if(strcmp(KdataType,'single'))
            add_block('hdlsllib/Commonly Used Blocks/Delay',[gcb,'/ssb1'],'position',[100,150,170,200]);
            set_param([gcb,'/ssb1'],'DelayLength','0');
            add_line(gcb,[InPortName,'/1'],'ssb1/1','autorouting','on');
            add_line(gcb,'ssb1/1',[OutPortName,'/1'],'autorouting','on');
            add_line(gcb,'ssb1/1',[OutPortName1,'/1'],'autorouting','on');
        else











            numofBlocks=ceil((threadNumLimit*2*4*8)/64);
            add_block('hdlsllib/Commonly Used Blocks/Data Type Conversion',[gcb,'/DTC'],'position',posDTC);
            set_param([gcb,'/DTC'],'OutDataTypeStr','dnnfpgaDataTypeChange( KdataType, 2)');
            add_block('hdlsllib/Signal Routing/Bus Creator',[gcb,'/BC'],'position',posBC);
            set_param([gcb,'/BC'],'Inputs',num2str(numofBlocks));
            for i=1:numofBlocks

                add_block('dnnfpgaBfpScalinglib/selData',[gcb,'/ssb',num2str(i)],'position',[100,150+100*(i-1),170,200+100*(i-1)]);
                set_param([gcb,'/ssb',num2str(i)],'startIdx',num2str((i-1)*8+1));
                set_param([gcb,'/ssb',num2str(i)],'endIdx',num2str(i*8));
                set_param([gcb,'/ssb',num2str(i)],'inputLength',num2str(threadNumLimit*2*4));
                add_line(gcb,'DTC/1',['ssb',num2str(i),'/1'],'autorouting','on');
                add_line(gcb,['ssb',num2str(i),'/1'],['BC/',num2str(i)],'autorouting','on');
            end
            add_line(gcb,[InPortName,'/1'],'DTC/1','autorouting','on');
            add_block('hdlsllib/Commonly Used Blocks/Data Type Conversion',[gcb,'/int32DTC'],'position',posint32);
            set_param([gcb,'/int32DTC'],'OutDataTypeStr','dnnfpgaDataTypeChange( KdataType, 0)');
            add_line(gcb,'BC/1','int32DTC/1','autorouting','on');

            add_block('hdlsllib/Signal Routing/Selector',[gcb,'/sel1'],'position',[800,80,850,130]);
            add_block('hdlsllib/Signal Routing/Selector',[gcb,'/sel2'],'position',[800,255,850,305]);
            set_param([gcb,'/sel1'],'InputPortWidth',num2str(threadNumLimit*2));
            set_param([gcb,'/sel1'],'Indices',['[',num2str(1:2:threadNumLimit*2),']']);
            set_param([gcb,'/sel2'],'InputPortWidth',num2str(threadNumLimit*2));
            set_param([gcb,'/sel2'],'Indices',['[',num2str(2:2:threadNumLimit*2),']']);
            add_line(gcb,'int32DTC/1','sel1/1','autorouting','on');
            add_line(gcb,'int32DTC/1','sel2/1','autorouting','on');
            add_line(gcb,'sel1/1',[OutPortName,'/1'],'autorouting','on');
            add_line(gcb,'sel2/1',[OutPortName1,'/1'],'autorouting','on');

        end

    catch
        error('Bias rendering failed!');
    end
end
