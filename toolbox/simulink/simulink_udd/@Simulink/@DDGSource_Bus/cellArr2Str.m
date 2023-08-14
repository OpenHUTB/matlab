function[str]=cellArr2Str(~,signalArray)






    str='';
    if~isempty(signalArray)
        sep='';
        for i=1:length(signalArray)
            sig=char(signalArray{i});
            str=[str,sep,sig];%#ok
            sep=',';
        end
    end
end

