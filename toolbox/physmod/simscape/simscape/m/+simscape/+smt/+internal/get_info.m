function infos=get_info(fullPath,extractor,array_initializer)







    lm=simscape.loadModelFromFile(fullPath);


    lmi=simscape.modelInfo(lm);


    if~strcmp(lmi.item_type,'component')
        error(message('physmod:simscape:simscape:smt:DomainNotSupported',lmi.MPath));
    end


    members=lmi.Members;

    fms=fields(members);

    infos=array_initializer();

    for i=1:length(fms)

        curName=fms{i};

        curField=members.(curName);

        info=extractor(curName,curField);

        infos=[infos;info];%#ok

    end

end
