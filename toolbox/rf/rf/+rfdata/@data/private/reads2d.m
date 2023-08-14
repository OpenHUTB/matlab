function refobj=reads2d(h,filename)




    fid=fopen(filename,'rt');
    if(fid==-1)
        error(message('rf:rfdata:data:reads2d:erropens2dfile',filename))
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
        PFreq=[];
        Pin={};
        Pout={};
        Phase={};
        IP3=[];
        OneDBC=[];
        PS=[];
        GCS=[];
        totnoisec=0;
        totnetsec=0;
        totpowsec=0;
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
            error(message('rf:rfdata:data:reads2d:beginendnotmatch',filename));
        end


        for secIndex=1:numel(pos_begin)
            lcounter=pos_begin(secIndex);
            a_section=refdata(lcounter:pos_end(secIndex));

            a_section{1}=upper(a_section{1});
            temp=strfind(a_section{1},'REM');
            if~isempty(temp)
                a_section{1}=a_section{1}(1:temp(1)-1);
            end

            block_type=findblocktype(h,strtok(a_section{1},'!'),lcounter);

            switch block_type
            case{'GCOMP7'}
                totpowsec=totpowsec+1;

                option_line=upper(findoptline(h,a_section,lcounter,'GCOMP7'));

                option_line=debracket(h,option_line);
                [frequnit_token,rem]=strtok(option_line);
                [nettype_token,rem]=strtok(rem);
                [powerunit_token,rem]=strtok(rem);
                [netformat_token,rem]=strtok(rem);
                [R_token,z0_token]=strtok(rem);


                if~strcmp(nettype_token,'S')
                    error(message('rf:rfdata:data:reads2d:onlysparamallowed',lcounter));
                end

                DataFormat=findnetformat(h,netformat_token);
                checkempty(h,DataFormat,lcounter,'GCOMP7',...
                'network parameter format');

                PZ0=str2double(z0_token);
                checkscalar(h,PZ0,lcounter,'GCOMP7','Reference resistance');

                FScale=findfrequnit(h,frequnit_token);
                checkempty(h,FScale,lcounter,'GCOMP7','frequency units');

                if~strcmp(powerunit_token,'DBM')
                    error(message('rf:rfdata:data:reads2d:onlydbmallowed',lcounter));
                end


                [format_line,format_lnum]=findformatline(h,a_section,lcounter,'GCOMP7',2);

                try
                    datasec=cell2mat(extractdata(h,a_section(format_lnum(1)+1:format_lnum(2)-1)));
                catch
                    datasec=[];
                end

                checkscalar(h,datasec,lcounter,'GCOMP7','Frequency point');
                PFreq(totpowsec,1)=datasec*FScale;



                pinformat_line=upper(format_line{2});

                try
                    powerdata=cell2mat(extractdata(h,a_section(format_lnum(2)+1:end-1)));
                catch
                    powerdata=[];
                end
                if(size(powerdata,1)~=3)
                    error(message('rf:rfdata:data:reads2d:errpins21dataGCOMP7',lcounter));
                end
                powerdata=reorderbykeys(h,powerdata,pinformat_line,...
                {'PIN','N21X','N21Y'},lcounter+format_lnum(2)-1,'GCOMP7');

                Pin{totpowsec,1}=0.001*(10.^(powerdata(:,1)/10));
                [Pout{totpowsec,1},Phase{totpowsec,1}]=...
                s2power(Pin{totpowsec,1},powerdata,DataFormat);

            case{'ACDATA'}

                totnetsec=totnetsec+1;
                if(totnetsec>1)
                    error(message('rf:rfdata:data:reads2d:multipleacdata'));
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

                NetworkType=findnettype(h,nettype_token);
                checkempty(h,NetworkType,lcounter,'ACDATA',...
                'network parameter type');
                DataFormat=findnetformat(h,netformat_token);
                checkempty(h,DataFormat,lcounter,'ACDATA',...
                'network parameter format');

                Z0=str2double(z0_token);
                checkscalar(h,Z0,lcounter,'ACDATA','Reference resistance');

                FScale=findfrequnit(h,frequnit_token);
                checkempty(h,FScale,lcounter,'ACDATA','frequency units');










                [format_line,format_lnum]=findformatline(h,a_section,lcounter,'ACDATA');

                try
                    datasec=cell2mat(extractdata(h,a_section(format_lnum(1)+1:end-1)));
                catch
                    datasec=[];
                end
                if(size(datasec,1)~=9)
                    error(message('rf:rfdata:data:reads2d:errpins21dataACDATA',lcounter));
                end
                datasec=reorderbykeys(h,datasec,upper(format_line{1}),...
                {'F','N11X','N11Y','N21X','N21Y','N12X','N12Y',...
                'N22X','N22Y'},lcounter+format_lnum(1)-1,'ACDATA');
                NetworkParameters=getnetdata(h,datasec(:,2:end),DataFormat);
                Freq=FScale*datasec(:,1);


            case{'NDATA'}

                totnoisec=totnoisec+1;
                if(totnoisec>1)
                    error(message('rf:rfdata:data:reads2d:multiplendata'));
                end
                [NoiseFreq,NoiseParameters,NDataFormat,NoiZ0]=...
                processndatablock(h,a_section,lcounter);

            case{'GCOMP1'}

                [format_line,format_lnum]=findformatline(h,a_section,lcounter,'GCOMP1');
                try
                    datasec=cell2mat(extractdata(h,a_section(format_lnum(1)+1:end-1)));
                catch
                    datasec=[];
                end
                checkscalar(h,datasec,lcounter,'GCOMP1','IP3');
                IP3=0.001*(10.^(datasec/10));

            case{'GCOMP2'}

                [format_line,format_lnum]=findformatline(h,a_section,lcounter,'GCOMP2');
                try
                    datasec=cell2mat(extractdata(h,a_section(format_lnum(1)+1:end-1)));
                catch
                    datasec=[];
                end
                checkscalar(h,datasec,lcounter,'GCOMP2','1DBC');
                OneDBC=0.001*(10.^(datasec/10));

            case{'GCOMP3'}

                [format_line,format_lnum]=findformatline(h,a_section,lcounter,'GCOMP3');
                try
                    datasec=cell2mat(extractdata(h,a_section(format_lnum(1)+1:end-1)));
                catch
                    datasec=[];
                end
                if(numel(datasec)~=2)
                    error(message('rf:rfdata:data:reads2d:gcomp3wrongdatasize',lcounter));
                end
                datasec=reorderbykeys(h,datasec,upper(format_line{1}),...
                {'IP3','1DBC'},lcounter+format_lnum(1)-1,'GCOMP3');
                IP3=0.001*(10.^(datasec(1)/10));
                OneDBC=0.001*(10.^(datasec(2)/10));

            case{'GCOMP4'}

                [format_line,format_lnum]=findformatline(h,a_section,lcounter,'GCOMP4');
                try
                    datasec=cell2mat(extractdata(h,a_section(format_lnum(1)+1:end-1)));
                catch
                    datasec=[];
                end
                if(numel(datasec)~=3)
                    error(message('rf:rfdata:data:reads2d:gcomp4wrongdatasize',lcounter));
                end
                datasec=reorderbykeys(h,datasec,upper(format_line{1}),...
                {'IP3','PS','GCS'},lcounter+format_lnum(1)-1,'GCOMP4');
                IP3=0.001*(10.^(datasec(1)/10));
                PS=0.001*(10.^(datasec(2)/10));
                GCS=10.^(datasec(3)/10);

            case{'GCOMP5'}

                [format_line,format_lnum]=findformatline(h,a_section,lcounter,'GCOMP5');
                try
                    datasec=cell2mat(extractdata(h,a_section(format_lnum(1)+1:end-1)));
                catch
                    datasec=[];
                end
                if(numel(datasec)~=3)
                    error(message('rf:rfdata:data:reads2d:gcomp5wrongdatasize',lcounter));
                end
                datasec=reorderbykeys(h,datasec,upper(format_line{1}),...
                {'1DBC','PS','GCS'},lcounter+format_lnum(1)-1,'GCOMP5');
                OneDBC=0.001*(10.^(datasec(1)/10));
                PS=0.001*(10.^(datasec(2)/10));
                GCS=10.^(datasec(3)/10);

            case{'GCOMP6'}

                [format_line,format_lnum]=findformatline(h,a_section,lcounter,'GCOMP6');
                try
                    datasec=cell2mat(extractdata(h,a_section(format_lnum(1)+1:end-1)));
                catch
                    datasec=[];
                end
                if(numel(datasec)~=4)
                    error(message('rf:rfdata:data:reads2d:gcomp6wrongdatasize',lcounter));
                end
                datasec=reorderbykeys(h,datasec,upper(format_line{1}),...
                {'IP3','1DBC','PS','GCS'},lcounter+format_lnum(1)-1,...
                'GCOMP6');
                IP3=0.001*(10.^(datasec(1)/10));
                OneDBC=0.001*(10.^(datasec(2)/10));
                PS=0.001*(10.^(datasec(3)/10));
                GCS=10.^(datasec(4)/10);

            case{'IMTDATA'}
                totimtsec=totimtsec+1;
                if(totimtsec>1)
                    error(message('rf:rfdata:data:reads2d:multipleimtdata'));
                end
                [IMTTable,MaxOrder,Siglvl,Lolvl]=...
                processimtdatablock(h,a_section,lcounter);

            end

        end

        tempobj=rfdata.reference;
        set(tempobj,'OIP3',IP3,'OneDBC',OneDBC,'PS',PS,'GCS',GCS);
        if~isinf(IP3)
            updateip3(tempobj,'OIP3',[],IP3);
        end
        if totimtsec>0
            updatemixerspur(tempobj,Lolvl,Siglvl,IMTTable);
        end
        [Fmin,Gammaopt,Rn]=getnoisedata(h,NoiseParameters,NDataFormat,1);
        update(tempobj,NetworkType,Freq,NetworkParameters,Z0,NoiseFreq,...
        Fmin,Gammaopt,Rn,PFreq,Pin,Pout,Phase);
        References{refIndex}=tempobj;

    end

    if isempty(IndependentVars)
        refobj=References{1};
    else
        refobj=rfdata.multireference('References',References,...
        'IndependentVars',IndependentVars);
        refobj.Selection=1;
    end


    function[pout,phase]=s2power(pin,s21data,dataformat)


        switch dataformat
        case 'RI'
            temps=(s21data(:,2)+s21data(:,3)*j);
            pout=pin.*(abs(temps).^2);
            phase=180*angle(temps)/pi;
        case 'MA'
            pout=pin.*(s21data(:,2).^2);
            phase=s21data(:,3);
        case 'DB'
            pout=pin.*(10.^(s21data(:,2)/10));
            phase=s21data(:,3);
        end


