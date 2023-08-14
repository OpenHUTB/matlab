function close_models(iMdls)





    nMdls=length(iMdls);
    for i=1:nMdls
        close_system(iMdls{i},0);
    end

