function seqLC=seqLayerConfigPrivate(lcs,storedType,fieldNames)
%#codegen



    seqLCC=cell(1,length(lcs));
    for i=1:length(lcs)








        if(isequal(storedType,'single'))
            temp=single([]);
        elseif(isequal(storedType,'half'))
            temp=half([]);
        else
            temp=eval([storedType,'([])']);
        end
        lc=lcs(i);
        for j=1:length(fieldNames)
            fd=fieldNames{j};
            vals=lc.(fd);
            for k=1:numel(vals)
                val=vals(k);
                if(isa(val,'uint32'))




                    sval=typecast(val,storedType);
                else
                    sval=typecast(dnnfpga.assembler.ConvtoUint32U(val),storedType);
                end
                temp(end+1)=sval;%#ok<EMGRO>
            end
        end
        seqLCC{i}=flip(temp);
    end
    seqLC=eval([storedType,'(cell2mat(seqLCC))']);
end

