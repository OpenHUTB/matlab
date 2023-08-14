function dnnfpgaFCDTCRender(gcb,convKdataType,fcKdataType,dataPath,inSignal)



































    if(isempty(convKdataType)||isempty(fcKdataType))
        return;
    end

    ssName='ConversionBlock';
    ssPath=[gcb,'/',ssName];
    pos=get_param(ssPath,'Position');
    try

        lh=get_param(ssPath,'LineHandles');
        delete_block([gcb,'/ConversionBlock'])
        delete_line(lh.Inport);
        delete_line(lh.Outport);

        InPortName='InData';
        InPortName1='Exp';
        OutPortName='OutData';

        redrawSubSystem([gcb,'/',ssName],pos,convKdataType,fcKdataType,dataPath,inSignal);

        add_line(gcb,'ConversionBlock/1','OutData/1','autorouting','on');
        add_line(gcb,'InData/1','ConversionBlock/1','autorouting','on');
        add_line(gcb,'Exp/1','ConversionBlock/2','autorouting','on');
    catch me
        disp(me)
    end
end


function redrawSubSystem(curGcbOrig,pos,convKdataType,fcKdataType,dataPath,inSignal)
    root=fileparts(curGcbOrig);

    h=add_block('built-in/SubSystem',curGcbOrig,'Position',pos);

    subBlockName=get_param(h,'name');
    curGcb=[root,'/',subBlockName];

    InDataPortPos=[110,103,140,117];
    IdxPortPos=[110,148,140,162];
    outputRegPos=[360,128,390,142];

    add_block('built-in/InPort',[curGcb,'/InData'],'Position',InDataPortPos);
    add_block('built-in/InPort',[curGcb,'/Exp'],'Position',IdxPortPos);
    add_block('built-in/OutPort',[curGcb,'/OutData'],'Position',outputRegPos);



    if(inSignal==1)

        if(strcmp(convKdataType,fcKdataType))


            add_block('built-in/Terminator',[curGcb,'/Terminate'],'position',IdxPortPos+100);
            add_line(curGcb,'InData/1','OutData/1','autorouting','on');
            add_line(curGcb,'Exp/1','Terminate/1','autorouting','on');

        elseif(strcmp(convKdataType,'single'))


            if(dataPath==0)

                add_block('built-in/Terminator',[curGcb,'/Terminate'],'position',IdxPortPos+100);
                add_block('built-in/Delay',[curGcb,'/Delay'],'position',pos);
                set_param([curGcb,'/Delay'],'DelayLength','Fixdt_0_16_0_To_SingleLatency');
                add_line(curGcb,'InData/1','Delay/1','autorouting','on');
                add_line(curGcb,'Delay/1','OutData/1','autorouting','on');
                add_line(curGcb,'Exp/1','Terminate/1','autorouting','on');
            else

                add_block('dnnfpgaBfpScalinglib/single2int8',[curGcb,'/DTC'],'position',pos);
                set_param([curGcb,'/DTC'],'Fixdt_0_16_0_To_SingleLatency','Fixdt_0_16_0_To_SingleLatency');
                add_line(curGcb,'InData/1','DTC/1','autorouting','on');
                add_line(curGcb,'DTC/1','OutData/1','autorouting','on');
                add_line(curGcb,'Exp/1','DTC/2','autorouting','on');
            end

        elseif(strcmp(fcKdataType,'single'))


            if(dataPath==0)

                add_block('built-in/Delay',[curGcb,'/Delay'],'position',pos);
                add_block('built-in/Terminator',[curGcb,'/Terminate'],'position',IdxPortPos+100);
                set_param([curGcb,'/Delay'],'DelayLength','Fixdt_0_16_0_To_SingleLatency');
                add_line(curGcb,'InData/1','Delay/1','autorouting','on');
                add_line(curGcb,'Delay/1','OutData/1','autorouting','on');
                add_line(curGcb,'Exp/1','Terminate/1','autorouting','on');
            else

                add_block('dnnfpgaBfpScalinglib/int8toSingle',[curGcb,'/DTC'],'position',pos);
                set_param([curGcb,'/DTC'],'Fixdt_0_16_0_To_SingleLatency','Fixdt_0_16_0_To_SingleLatency');
                add_line(curGcb,'InData/1','DTC/1','autorouting','on');
                add_line(curGcb,'DTC/1','OutData/1','autorouting','on');
                add_line(curGcb,'Exp/1','DTC/2','autorouting','on');
            end

        else
            error('Wrong input')

        end
    else
        if(strcmp(convKdataType,fcKdataType))


            add_block('built-in/Terminator',[curGcb,'/Terminate'],'position',IdxPortPos+100);
            add_line(curGcb,'InData/1','OutData/1','autorouting','on');
            add_line(curGcb,'Exp/1','Terminate/1','autorouting','on');

        elseif(strcmp(convKdataType,'single'))


            if(dataPath==0)

                add_block('built-in/Terminator',[curGcb,'/Terminate'],'position',IdxPortPos+100);
                add_block('built-in/Delay',[curGcb,'/Delay'],'position',pos);
                set_param([curGcb,'/Delay'],'DelayLength','Fixdt_0_16_0_To_SingleLatency');
                add_line(curGcb,'InData/1','Delay/1','autorouting','on');
                add_line(curGcb,'Delay/1','OutData/1','autorouting','on');
                add_line(curGcb,'Exp/1','Terminate/1','autorouting','on');
            else

                add_block('dnnfpgaBfpScalinglib/int8toSingle',[curGcb,'/DTC'],'position',pos);
                set_param([curGcb,'/DTC'],'Fixdt_0_16_0_To_SingleLatency','Fixdt_0_16_0_To_SingleLatency');
                add_line(curGcb,'InData/1','DTC/1','autorouting','on');
                add_line(curGcb,'DTC/1','OutData/1','autorouting','on');
                add_line(curGcb,'Exp/1','DTC/2','autorouting','on');
            end

        elseif(strcmp(fcKdataType,'single'))


            if(dataPath==0)

                add_block('built-in/Delay',[curGcb,'/Delay'],'position',pos);
                add_block('built-in/Terminator',[curGcb,'/Terminate'],'position',IdxPortPos+100);
                set_param([curGcb,'/Delay'],'DelayLength','Fixdt_0_16_0_To_SingleLatency');
                add_line(curGcb,'InData/1','Delay/1','autorouting','on');
                add_line(curGcb,'Delay/1','OutData/1','autorouting','on');
                add_line(curGcb,'Exp/1','Terminate/1','autorouting','on');
            else

                add_block('dnnfpgaBfpScalinglib/single2int8',[curGcb,'/DTC'],'position',pos);
                set_param([curGcb,'/DTC'],'Fixdt_0_16_0_To_SingleLatency','Fixdt_0_16_0_To_SingleLatency');
                add_line(curGcb,'InData/1','DTC/1','autorouting','on');
                add_line(curGcb,'DTC/1','OutData/1','autorouting','on');
                add_line(curGcb,'Exp/1','DTC/2','autorouting','on');
            end

        else
            error('Wrong input')

        end
    end


end









