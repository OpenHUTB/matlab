function outputVar=writeSignalPrivate(mode,addr,val,h)



    outputVar=val;
    if(mode==1)
        if(~isfloat(val))
            val=uint32(val);
        else
        end









        switch class(val)
        case{'uint32','single','int32'}
            val=typecast(val,'uint32');
        case 'double'

            val=int32(val);
            val=typecast(val,'uint32');

        otherwise
            error(message('dnnfpga:workflow:InvalidDatatype'));
        end

        h.writeMemory(addr,val);
    end
end
