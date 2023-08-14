function hdlcode=hdlcodeconcat(hdlcodein)







    if isempty(hdlcodein)
        hdlcode=[];
    else
        fnames=fieldnames(hdlcodein);

        for n=1:length(fnames)
            fn=fnames{n};
            hdlcode.(fn)=[hdlcodein(:).(fn)];
        end
    end



