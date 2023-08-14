function outputVar=writeSignalForced(mode,ddrbase,v,h,arg0,arg1)



    outputVar=dnnfpga.hwutils.writeSignalPrivate(mode,dnnfpga.hwutils.numTo8Hex(ddrbase),v,h);
    if(strcmpi(dnnfpgafeature('ReadbackToCheckWrite'),'off'))
        return;
    end
    readBack=dnnfpga.hwutils.readSignal(mode,dnnfpga.hwutils.numTo8Hex(ddrbase),length(v),zeros(1,length(v)),h,arg0,arg1);
    idx=find((v-readBack)~=0);
    if(~isempty(idx))
        falseRead=0;
        falseWrite=0;
        for i=1:length(idx)
            idxx=idx(i)-1;
            addr=idxx*4;
            rb1=dnnfpga.hwutils.readSignal(mode,dnnfpga.hwutils.numTo8Hex(ddrbase+addr),1,zeros(1,1),h,arg0,arg1);
            if(isequal(rb1,v(idxx+1)))
                falseRead=falseRead+1;
            else
                falseWrite=falseWrite+1;
                dnnfpga.hwutils.writeSignalPrivate(mode,addr,v(idxx+1),h);
                rb2=dnnfpga.hwutils.readSignal(mode,dnnfpga.hwutils.numTo8Hex(ddrbase+addr),1,zeros(1,1),h,arg0,arg1);
                assert(rb2==v(idxx+1),sprintf('Rewrite DDR failed in "DDR" at %d',addr));
            end
        end
        dnnfpga.disp(message('dnnfpga:workflow:MemTxnCountGood','DDR',string(falseReadHWMemDMA)));
        dnnfpga.disp(message('dnnfpga:workflow:MemTxnCountBad','DDR',string(falseWriteHWMemDMA)));
    else

    end
end
