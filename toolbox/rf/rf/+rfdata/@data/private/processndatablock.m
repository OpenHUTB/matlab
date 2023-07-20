function[noisefreq,noiseparameters,ndataformat,noiz0]=processndatablock(h,a_section,lcounter)





    option_line=upper(findoptline(h,a_section,lcounter,'NDATA'));

    option_line=debracket(h,option_line);
    [frequnit_token,rem]=strtok(option_line);
    [nettype_token,rem]=strtok(rem);
    [netformat_token,rem]=strtok(rem);
    [R_token,z0_token]=strtok(rem);


    if~strcmp(nettype_token,'S')
        error(message('rf:rfdata:data:processndatablock:ndataonlysparamallowed',lcounter));
    end

    ndataformat=findnetformat(h,netformat_token);
    checkempty(h,ndataformat,lcounter,'NDATA','parameter format');

    noiz0=str2double(z0_token);
    checkscalar(h,noiz0,lcounter,'NDATA','Normalization resistance');

    FScale=findfrequnit(h,frequnit_token);
    checkscalar(h,FScale,lcounter,'NDATA','frequency units');


    [format_line,format_lnum]=findformatline(h,a_section,lcounter,'NDATA');

    try
        datasec=cell2mat(extractdata(h,a_section(format_lnum(1)+1:end-1)));
    catch
        datasec=[];
    end
    if(size(datasec,1)~=5)
        error(message('rf:rfdata:data:processndatablock:errpins21data',lcounter));
    end
    datasec=reorderbykeys(h,datasec,upper(format_line{1}),...
    {'F ','NFMIN','N11X','N11Y','RN'},...
    lcounter+format_lnum(1)-1,'NDATA');
    noisefreq=FScale*datasec(:,1);
    noiseparameters=datasec(:,2:end);