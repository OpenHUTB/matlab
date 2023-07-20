function dnnfpgaLRNRenderRamBusVal(gcb,opSize,lrnCompWindowSize,OpRatio,threadNum)
    if(isempty(opSize))
        return;
    end

    if(isempty(lrnCompWindowSize))
        return;
    end

    if(isempty(OpRatio))
        return;
    end

    outPortPosOrig=[840,558,870,572];
    ssName='ssValbus';
    ssPath=[gcb,'/',ssName];
    pos=get_param(ssPath,'Position');
    try
        lh=get_param(ssPath,'LineHandles');
        delete_block(ssPath)
        delete_line(lh.Inport)
        delete_line(lh.Outport)

        InPortName1='ASel';
        InPortName2='InVal';
        InPortName3='DataIn';
        OutPortName1='OutData';
        OutPortName2='OutVal';
        redrawValConnect(gcb,[gcb,'/',ssName],pos,opSize,lrnCompWindowSize,OpRatio,threadNum);
        add_line(gcb,[InPortName1,'/1'],[ssName,'/1'],'autorouting','on');
        add_line(gcb,[InPortName2,'/1'],[ssName,'/2'],'autorouting','on');
        add_line(gcb,[InPortName3,'/1'],[ssName,'/3'],'autorouting','on');
        add_line(gcb,[ssName,'/1'],[OutPortName1,'/1'],'autorouting','on');
        add_line(gcb,[ssName,'/2'],[OutPortName2,'/1'],'autorouting','on');

    catch
    end

end

function redrawValConnect(gcb,curGcbPath,pos,opSize,lrnCompWindowSize,OpRatio,threadNum)
    root=fileparts(curGcbPath);


    h=add_block('built-in/SubSystem',curGcbPath,'MakeNameUnique','on','Position',pos,'TreatAsAtomicUnit','off');
    ssBlockName=get_param(h,'name');
    curGcb=[root,'/',ssBlockName];
    In1PortPos=[20,120,50,133];
    In2PortPos=[20,220,50,243];
    Out1PortPos=[1005,155,1025,195];
    ConstantPos=[20,423,50,437];
    SelectorPos=[820,120,900,520];
    MuxPos=[50,133,90,190];

    add_block('built-in/InPort',[curGcb,'/ASel'],'Position',In1PortPos);
    add_block('built-in/InPort',[curGcb,'/Val'],'Position',In2PortPos);
    add_block('built-in/InPort',[curGcb,'/DataIn'],'Position',In2PortPos+50);
    add_block('built-in/OutPort',[curGcb,'/OutData'],'Position',Out1PortPos);
    add_block('built-in/OutPort',[curGcb,'/OutVal'],'Position',Out1PortPos+100);

    if(OpRatio==1)
        add_block('dnnfpgaSharedGenericlib/Scalar Replicator',[curGcb,'/Scalar Replicator'],'Position',ConstantPos+50);
        add_block('built-in/Terminator',[curGcb,'/Terminator'],'Position',ConstantPos+100);



        set_param([curGcb,'/Scalar Replicator'],'width','opSize');
        add_line(curGcb,'Val/1','Scalar Replicator/1','autorouting','on');
        add_line(curGcb,'Scalar Replicator/1','OutVal/1','autorouting','on');
        add_line(curGcb,'ASel/1','Terminator/1','autorouting','on');
        add_line(curGcb,'DataIn/1','OutData/1','autorouting','on');


    else
        add_block('built-in/Constant',[curGcb,'/Constant'],'Position',ConstantPos);
        set_param([curGcb,'/Constant'],'OutDataTypeStr','Inherit: Inherit via back propagation');
        set_param([curGcb,'/Constant'],'SampleTime','-1');
        set_param([curGcb,'/Constant'],'Value','0');
        add_block('simulink/Signal Routing/Multiport Switch',[curGcb,'/Selector'],'Position',SelectorPos);
        set_param([curGcb,'/Selector'],'Inputs',num2str(opSize/lrnCompWindowSize));
        set_param([curGcb,'/Selector'],'DataPortForDefault','Additional data port');
        set_param([curGcb,'/Selector'],'DataPortOrder','Zero-based contiguous');
        add_line(curGcb,'ASel/1','Selector/1','autorouting','on');
        add_block('dnnfpgaSharedGenericlib/Scalar Replicator',[curGcb,'/Scalar Replicator'],'Position',ConstantPos+50);
        set_param([curGcb,'/Scalar Replicator'],'width',num2str(opSize/lrnCompWindowSize));

        for i=1:opSize/lrnCompWindowSize
            newpos=i*50+50;
            add_block('simulink/Signal Routing/Bus Creator',[curGcb,'/Mux',num2str(i)],'Position',MuxPos+newpos);
            set_param([curGcb,'/Mux',num2str(i)],'Inputs',num2str(opSize/lrnCompWindowSize));
            if(lrnCompWindowSize==1)
                add_line(curGcb,'Val/1',['Mux',num2str(i),'/',num2str(i)],'autorouting','on');
                for j=1:opSize
                    if(j~=i)
                        add_line(curGcb,'Constant/1',['Mux',num2str(i),'/',num2str(j)],'autorouting','on');
                    end
                end
            else
                add_block('dnnfpgaSharedGenericlib/Scalar Replicator',[curGcb,'/Scalar Replicator',num2str(i)],'Position',ConstantPos+100);
                set_param([curGcb,'/Scalar Replicator',num2str(i)],'width',num2str(lrnCompWindowSize));
                add_line(curGcb,'Val/1',['Scalar Replicator',num2str(i),'/1'],'autorouting','on');
                add_line(curGcb,['Scalar Replicator',num2str(i),'/1'],['Mux',num2str(i),'/',num2str(i)],'autorouting','on');

                for j=1:opSize/lrnCompWindowSize

                    if(j~=i)
                        add_block('dnnfpgaSharedGenericlib/Scalar Replicator',[curGcb,'/Scalar Replicator',num2str(i*lrnCompWindowSize+j)],'Position',ConstantPos+100);
                        set_param([curGcb,'/Scalar Replicator',num2str(i*lrnCompWindowSize+j)],'width',num2str(lrnCompWindowSize));
                        add_line(curGcb,'Constant/1',['Scalar Replicator',num2str(i*lrnCompWindowSize+j),'/1'],'autorouting','on');
                        add_line(curGcb,['Scalar Replicator',num2str(i*lrnCompWindowSize+j),'/1'],['Mux',num2str(i),'/',num2str(j)],'autorouting','on');
                    end

                end
            end
            add_line(curGcb,['Mux',num2str(i),'/1'],['Selector/',num2str(i+1)],'autorouting','on');
        end


        add_block('simulink/Signal Routing/Bus Creator',[curGcb,'/MuxLast'],'Position',MuxPos+newpos+50);
        set_param([curGcb,'/MuxLast'],'Inputs',num2str(opSize/lrnCompWindowSize));
        for j=1:opSize/lrnCompWindowSize
            add_block('dnnfpgaSharedGenericlib/Scalar Replicator',[curGcb,'/Scalar Replicator',num2str(i*lrnCompWindowSize+j*lrnCompWindowSize+j)],'Position',ConstantPos+100);
            set_param([curGcb,'/Scalar Replicator',num2str(i*lrnCompWindowSize+j*lrnCompWindowSize+j)],'width',num2str(lrnCompWindowSize));
            add_line(curGcb,'Constant/1',['Scalar Replicator',num2str(i*lrnCompWindowSize+j*lrnCompWindowSize+j),'/1'],'autorouting','on');
            add_line(curGcb,['Scalar Replicator',num2str(i*lrnCompWindowSize+j*lrnCompWindowSize+j),'/1'],['MuxLast/',num2str(j)],'autorouting','on');
        end
        add_line(curGcb,'MuxLast/1',['Selector/',num2str(OpRatio+2)],'autorouting','on');


        add_line(curGcb,'Selector/1','OutVal/1','autorouting','on');
        add_line(curGcb,'DataIn/1','Scalar Replicator/1','autorouting','on');
        add_line(curGcb,'Scalar Replicator/1','OutData/1','autorouting','on');

    end

end