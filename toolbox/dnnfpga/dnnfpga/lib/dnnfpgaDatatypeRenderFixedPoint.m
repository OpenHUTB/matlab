function dnnfpgaDatatypeRenderFixedPoint(gcb,MadLatency,RemapLatency,IsFixedPt)



    if(isempty(IsFixedPt))
        return;
    end
    rmName='Remap';
    rmPath=[gcb,'/',rmName];
    pos=get_param(rmPath,'Position');
    try
        lh=get_param(rmPath,'LineHandles');
        delete_block(rmPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);
        redrawRemapper([gcb,'/',rmName],pos,MadLatency,RemapLatency,IsFixedPt);
        add_line(gcb,'WeightIn/1',[rmName,'/1'],'autorouting','on');
        add_line(gcb,'RemapWeightDiffFraction/1',[rmName,'/2'],'autorouting','on');
        add_line(gcb,'RemapMinweightMultiplyConstant/1',[rmName,'/3'],'autorouting','on');
        add_line(gcb,'Remap/1','SingleWeights/1','autorouting','on');
    catch me
    end
end

function curGcb=redrawRemapper(curGcbOrig,pos,MadLatency,RemapLatency,IsFixedPt)
    root=fileparts(curGcbOrig);




    inPortPos=[20,23,50,37];
    in1PortPos=[20,163,50,177];
    in2PortPos=[20,233,50,247];

    outputRegPos1=[100,23,160,45];
    outputRegPos2=[190,23,230,45];




    outPortPos=[330,23,360,45];
    out1PortPos=[330,163,360,177];
    out2PortPos=[330,233,360,247];



    if(IsFixedPt)
        h=add_block('dnnfpgadatatypelib/Remap',curGcbOrig,'MakeNameUnique','on','Position',pos);
        subBlockName=get_param(h,'name');
        curGcb=[root,'/',subBlockName];







    else

        h=add_block('built-in/SubSystem',curGcbOrig,'MakeNameUnique','on','Position',pos,'TreatAsAtomicUnit','off');
        subBlockName=get_param(h,'name');
        curGcb=[root,'/',subBlockName];

        add_block('built-in/InPort',[curGcb,'/In'],'Position',inPortPos);
        add_block('built-in/InPort',[curGcb,'/RemapWeightDiffFraction'],'Position',in1PortPos);
        add_block('built-in/InPort',[curGcb,'/RemapMinweightMultiplyConstant'],'Position',in2PortPos);
        add_block('built-in/OutPort',[curGcb,'/Out'],'Position',outPortPos);

        add_block('built-in/Terminator',[curGcb,'/Terminator1'],'Position',out1PortPos);
        add_block('built-in/Terminator',[curGcb,'/Terminator2'],'Position',out2PortPos);
        add_line(curGcb,'RemapWeightDiffFraction/1','Terminator1/1','autorouting','on');
        add_line(curGcb,'RemapMinweightMultiplyConstant/1','Terminator2/1','autorouting','on');
        RegName1='DataTypeWire';


        add_block('hdlsllib/Commonly Used Blocks/Data Type Conversion',[curGcb,'/DTC'],'Position',outputRegPos2);




        set_param([curGcb,'/DTC'],'OutDataTypeStr','dnnfpgaDataTypeChange( kernelDataType, 0)');
        set_param([curGcb,'/DTC'],'RndMeth','Nearest');

        add_line(curGcb,'In/1','DTC/1','autorouting','on');
        add_line(curGcb,'DTC/1','Out/1','autorouting','on');
    end

end
