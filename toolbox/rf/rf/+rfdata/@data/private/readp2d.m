function refobj=readp2d(h,filename)




    fid=fopen(filename,'rt');
    if fid==-1
        error(message('rf:rfdata:data:read:erropenp2dfile',filename));
    end


    tempdata=textscan(fid,'%s','delimiter','\n','whitespace','');
    fclose(fid);
    tempdata=strtrim(tempdata{1});



    idx=strcmp(tempdata,'');
    tempdata=tempdata(~idx);


    IndependentVars={};
    var_pos=strmatch('VAR',tempdata);
    if~isempty(var_pos)
        idx=find(diff(var_pos)>1)+1;
        start_lines=var_pos([1;idx]);
        IndependentVars=cell(1,numel(start_lines));
    else
        start_lines=1;
    end
    References=cell(1,numel(start_lines));

    nstart_lines=numel(start_lines);
    for refIndex=1:nstart_lines


        NetworkType='';
        Freq=[];
        NetworkParameters=[];
        NoiseFreq=[];
        NoiseParameters=[];
        NDataFormat='';
        Z0=50;
        totnoisec=0;
        totnetsec=0;
        totpowersec=0;
        totimtsec=0;


        if refIndex~=nstart_lines
            refdata=tempdata(start_lines(refIndex):start_lines(refIndex+1)-1);
        else
            refdata=tempdata(start_lines(refIndex):end);
        end


        if~isempty(IndependentVars)
            IndependentVars{refIndex}=getindependentvars(h,refdata);
        end


        pos_begin=strmatch('BEGIN',refdata);
        pos_end=strmatch('END',refdata);
        if(numel(pos_begin)~=numel(pos_end)||any(pos_begin>pos_end))
            error(message('rf:rfdata:data:read:readp2d:beginendnotmatch',filename));
        end


        npos_begin=numel(pos_begin);
        for secIndex=1:npos_begin
            lcounter=pos_begin(secIndex);
            a_section=refdata(lcounter:pos_end(secIndex));

            a_section{1}=upper(a_section{1});
            temp=strfind(a_section{1},'REM');
            if~isempty(temp)
                a_section{1}=a_section{1}(1:temp(1)-1);
            end

            block_type=findblocktype(h,strtok(a_section{1},'!'),lcounter);

            switch block_type
            case{'ACDATA'}


                totnetsec=totnetsec+1;
                if(totnetsec>1)
                    error(message('rf:rfdata:data:readp2d:multipleacdata'));
                end

                option_line=upper(findoptline(h,a_section,lcounter,'ACDATA'));

                option_line=debracket(h,option_line);
                [frequnit_token,rem]=strtok(option_line);
                [nettype_token,rem]=strtok(rem);
                [netformat_token,rem]=strtok(rem);
                [R_token,rem]=strtok(rem);
                [z0_token,rem]=strtok(rem);
                [FC_token,rem]=strtok(rem);
                [freq_m_token,freq_b_token]=strtok(rem);

                if~strcmp(nettype_token,'S')
                    error(message('rf:rfdata:data:read:readp2d:onlysparamallowed',lcounter));
                end
                NetworkType='S_Parameters';
                DataFormat=findnetformat(h,netformat_token);
                checkempty(h,DataFormat,lcounter,'ACDATA',...
                'network parameter format');

                Z0=str2double(z0_token);
                checkscalar(h,Z0,lcounter,'ACDATA','Reference resistance');

                FScale=findfrequnit(h,frequnit_token);
                checkempty(h,FScale,lcounter,'ACDATA','frequency units');









                [format_line,format_lnum]=findformatline(h,a_section,lcounter,'ACDATA',inf);
                totpowersec=(numel(format_line)-1)/2;

                if(totpowersec~=floor(totpowersec))
                    error(message('rf:rfdata:data:read:readp2d:totpowersecnotinteger',lcounter));
                end

                try
                    if(numel(format_lnum)>1)
                        datasec=cell2mat(extractdata(h,a_section(format_lnum(1)+1:format_lnum(2)-1)));
                    else
                        datasec=cell2mat(extractdata(h,a_section(format_lnum(1)+1:end-1)));
                    end
                catch
                    datasec=[];
                end
                if(size(datasec,1)~=9)
                    error(message('rf:rfdata:data:read:readp2d:errpins21data',lcounter));
                end
                datasec=reorderbykeys(h,datasec,upper(format_line{1}),...
                {'F','N11X','N11Y','N21X','N21Y','N12X','N12Y',...
                'N22X','N22Y'},lcounter+format_lnum(1)-1,'ACDATA');
                NetworkParameters=getnetdata(h,datasec(:,2:end),DataFormat);
                Freq=FScale*datasec(:,1);





                LargesigFreq=zeros(totpowersec,1);
                LargesigSparam=cell(totpowersec,1);
                LargesigP1=cell(totpowersec,1);
                LargesigP2=cell(totpowersec,1);

                for ii=1:totpowersec

                    try
                        datasec=cell2mat(extractdata(h,a_section(format_lnum(2*ii)+1:format_lnum(2*ii+1)-1)));
                    catch
                        datasec=[];
                    end
                    checkscalar(h,datasec,format_lnum(2*ii)+1,'ACDATA',...
                    'Large signal frequency point');
                    LargesigFreq(ii)=datasec;


                    try
                        if(ii<totpowersec)
                            datasec=cell2mat(extractdata(h,a_section(format_lnum(2*ii+1)+1:...
                            format_lnum(2*ii+2)-1)));
                        else
                            datasec=cell2mat(extractdata(h,a_section(format_lnum(2*ii+1)+1:end-1)));
                        end
                    catch
                        datasec=[];
                    end
                    if(size(datasec,1)~=10)
                        error(message('rf:rfdata:data:read:readp2d:errinlargesigdata',num2str(format_lnum(2*ii+1)+lcounter-1)));
                    end
                    datasec=reorderbykeys(h,datasec,upper(format_line{2*ii+1}),...
                    {'P1','P2','N11X','N11Y','N21X','N21Y','N12X',...
                    'N12Y','N22X','N22Y'},...
                    format_lnum(2*ii+1)+lcounter-1,'ACDATA');
                    LargesigSparam{ii}=getnetdata(h,datasec(:,3:end),DataFormat);
                    LargesigP1{ii}=0.001*(10.^(datasec(:,1)/10));
                    LargesigP2{ii}=0.001*(10.^(datasec(:,2)/10));
                end
                LargesigFreq=FScale*LargesigFreq;


            case{'NDATA'}

                totnoisec=totnoisec+1;
                if(totnoisec>1)
                    error(message('rf:rfdata:data:readp2d:multiplendata'));

                end
                [NoiseFreq,NoiseParameters,NDataFormat,NoiZ0]=...
                processndatablock(h,a_section,lcounter);

            case{'IMTDATA'}
                totimtsec=totimtsec+1;
                if(totimtsec>1)
                    error(message('rf:rfdata:data:readp2d:multipleimtdata'));
                end
                [IMTTable,MaxOrder,Siglvl,Lolvl]=...
                processimtdatablock(h,a_section,lcounter);

            end

        end

        tempobj=rfdata.reference;
        [Fmin,Gammaopt,Rn]=getnoisedata(h,NoiseParameters,NDataFormat,1);
        update(tempobj,NetworkType,Freq,NetworkParameters,Z0,...
        NoiseFreq,Fmin,Gammaopt,Rn,[],{},{},{});
        References{refIndex}=tempobj;
        if totpowersec>0
            updatep2d(tempobj,LargesigFreq,LargesigP1,LargesigP2,LargesigSparam);
        end
        if totimtsec>0
            updatemixerspur(tempobj,Lolvl,Siglvl,IMTTable);
        end

    end

    if isempty(IndependentVars)
        refobj=References{1};
    else
        refobj=rfdata.multireference('References',References,...
        'IndependentVars',IndependentVars);
        refobj.Selection=1;
    end

