function[imttable,maxorder,siglvl,lolvl]=processimtdatablock(h,a_section,lcounter)





    option_line=upper(findoptline(h,a_section,lcounter,'IMTDATA'));
    option_line=debracket(h,option_line);


    if(strcmp(option_line(1),'#'))
        temp=sscanf(option_line(2:end),'%f');
    else
        temp=sscanf(option_line,'%f');
    end

    if(numel(temp)~=2)
        error(message('rf:rfdata:data:processimtdatablock:misssigorlolvl',lcounter));
    end
    siglvl=temp(1);
    lolvl=temp(2);


    datasec=extractdata(h,a_section(2:end-1));
    maxorder=numel(datasec{1})-1;
    imttable=99*ones(maxorder+1,maxorder+1);
    for ii=1:maxorder+1
        temp=numel(datasec{ii});
        if(temp~=maxorder+2-ii&&temp~=maxorder+1)
            error(message('rf:rfdata:data:processimtdatablock:errinimtdata',lcounter));
        end
        imttable(ii,1:temp)=datasec{ii};
    end