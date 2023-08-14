function outputVar=readSignal(mode,addr,length,val,h,arg0,arg1)







    if(mode==1)

        assert(isequal(arg0,'OutputDataType'),'Expected ''OutputDataType'' for input ''arg0'' to function.');
        assert(ismember(arg1,{'uint32','single','int32'}),message('dnnfpga:workflow:InvalidDatatype'));

        outputVar=h.readMemory(addr,length,arg0,arg1);
    else
        outputVar=val;
    end
end
