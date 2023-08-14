function refobj=readamp(h,filename)






    nPort=2;
    NetworkType='';
    Freq=[];
    NetworkParameters=[];
    NoiseFreq=[];
    NoiseParameters=[];
    Z0=50;
    PoutFreq=[];
    Pin={};
    Pout={};
    Phase={};
    IP3Power=[];
    IP3Freq=[];
    IP3Type='';
    NFdB=[];
    NFFreq=[];
    MAXORDER=[];
    IMTTable=[];
    FLO=Inf;
    PLO=Inf;

    fid=fopen(filename,'rt');
    if fid==-1
        error(message('rf:rfdata:data:readamp:cannotopenfile',filename))
    end

    totnoisec=0;
    totnetsec=0;
    totpowsec=0;
    totip3sec=0;
    totmixersec=0;
    totnfsec=0;

    lcounter=0;
    cline='';


    while isempty(strtok(cline))
        cline=fgetl(fid);
        lcounter=lcounter+1;
    end
    if~ischar(cline)
        fclose(fid);
        error(message('rf:rfdata:data:readamp:emptyfile',filename))
    end

    cline=strtrim(cline);
    headersec=strtok(cline,';');



    while ischar(cline)||isempty(cline)


        datasec={};
        ds_idx=1;
        cline=strtok(fgetl(fid),';');
        lcounter=lcounter+1;
        while ischar(cline)||isempty(cline)

            cline=strtrim(cline);
            token=strtok(cline);

            if~isempty(token)&&~isempty(strfind('+-.0123456789',token(1)))
                datasec{ds_idx}=cline;
                ds_idx=ds_idx+1;
                break;

            elseif~isempty(token)&&~strcmp(token(1),'*')
                headersec=strvcat(headersec,cline);
            end
            cline=strtok(fgetl(fid),';');
            lcounter=lcounter+1;
        end


        if~ischar(cline)&&cline==-1
            warning(message('rf:rfdata:data:read:DataNotFound'))
            break;
        end

        headersec=upper(headersec);
        if~isempty(strmatch('POUT',headersec))
            sectype='PowerData';
        elseif(~isempty(strmatch('S',headersec))||...
            ~isempty(strmatch('Y',headersec))||...
            ~isempty(strmatch('H',headersec))||...
            ~isempty(strmatch('Z',headersec)))&&...
            ~isempty(strmatch('F',headersec))
            sectype='NetParam';
        elseif~isempty(strmatch('NOI',headersec))
            sectype='NoiParam';
        elseif~isempty(strmatch('OIP3',headersec))||...
            ~isempty(strmatch('IIP3',headersec))
            sectype='IP3';
        elseif~isempty(strmatch('MIXERSPURS',headersec))
            sectype='MixerData';
        elseif~isempty(strmatch('NF',headersec))
            sectype='NF';
        else
            fclose(fid);
            error(message('rf:rfdata:data:readamp:noidentifier'))
        end



        switch sectype

        case 'PowerData'

            pinunit='';
            poutunit='';

            newfreq=[];
            pfscale=1;



            pout_lnum=strmatch('POUT',headersec);
            if~isempty(pout_lnum)
                [token,rem]=strtok(headersec(pout_lnum(end),:));

                pout_line=strtok(rem);
                poutunit=findpowerunit(h,pout_line);
            end


            pin_lnum=cat(1,strmatch('P1',headersec),...
            strmatch('PIN',headersec));
            if~isempty(pin_lnum)
                [token,rem]=strtok(headersec(pin_lnum(end),:));
                pin_line=strtok(rem);
                pinunit=findpowerunit(h,pin_line);
            end

            if~isempty(poutunit)&&isempty(pinunit)
                pinunit=poutunit;
            elseif~isempty(pinunit)&&isempty(poutunit)
                poutunit=pinunit;
            elseif isempty(poutunit)&&isempty(pinunit)
                pinunit='W';
                poutunit='W';
            end
            pinunit_default=pinunit;
            poutunit_default=poutunit;



            freq_line='';
            for k=size(headersec,1):-1:1
                if~isempty(strfind(headersec(k,:),'F'))
                    freq_line=headersec(k,:);
                    break;
                end
            end
            if~isempty(freq_line)

                pfscale=findfrequnit(h,freq_line,1);


                start_of_freq=strfind(freq_line,'F');





                nfreq_line=numel(freq_line);
                for ii=start_of_freq(end)+1:nfreq_line
                    if~isempty(strfind('+-.0123456789',freq_line(ii)))


                        if ii==nfreq_line
                            newfreq=str2double(freq_line(ii));
                        else
                            for p=ii+1:nfreq_line
                                if isempty(strfind('+-.0123456789E',...
                                    freq_line(p)))
                                    newfreq=str2double(freq_line(ii:p-1));
                                    break;
                                end
                            end
                        end
                        break;
                    end
                end
            end
            if~isempty(newfreq)
                newfreq=newfreq*pfscale;
            end


            cline=strtok(fgetl(fid),';');
            lcounter=lcounter+1;
            while ischar(cline)||isempty(cline)
                first_char=sscanf(cline,'%s');


                if~isempty(first_char)&&...
                    ~isempty(strfind('+-.0123456789',first_char(1)))
                    datasec{ds_idx}=cline;
                    ds_idx=ds_idx+1;
                elseif~isempty(first_char)&&...
                    isempty(strfind('+-.0123456789',first_char(1)))&&...
                    ~strcmp(first_char(1),'*')

                    cline=strtrim(cline);
                    headersec=cline;
                    break;
                end
                cline=strtok(fgetl(fid),';');
                lcounter=lcounter+1;
            end

            totpowsec=totpowsec+1;





            datasec=upper(datasec);
            ndatasec=numel(datasec);
            for k=1:ndatasec
                [token,rem]=strtok(datasec{k});
                if~isempty(strfind(token,'DBM'))
                    pinunit='DBM';
                    datasec{k}=strrep(datasec{k},'DBM',blanks(3));
                elseif~isempty(strfind(token,'DBW'))
                    pinunit='DBW';
                    datasec{k}=strrep(datasec{k},'DBW',blanks(3));
                elseif~isempty(strfind(token,'MW'))
                    pinunit='MW';
                    datasec{k}=strrep(datasec{k},'MW',blanks(2));
                elseif~isempty(strfind(token,'W'))
                    pinunit='W';
                    datasec{k}=strrep(datasec{k},'W',blanks(1));
                else
                    pinunit='';
                end

                second_token=strtok(rem);
                if~isempty(strfind(second_token,'DBM'))
                    poutunit='DBM';
                    datasec{k}=strrep(datasec{k},'DBM',blanks(3));
                elseif~isempty(strfind(second_token,'DBW'))
                    poutunit='DBW';
                    datasec{k}=strrep(datasec{k},'DBW',blanks(3));

                    datasec{k}=strrep(datasec{k},'DB',blanks(2));
                elseif~isempty(strfind(second_token,'MW'))
                    poutunit='MW';
                    datasec{k}=strrep(datasec{k},'MW',blanks(2));

                    datasec{k}=strrep(datasec{k},'M',blanks(1));
                elseif~isempty(strfind(second_token,'W'))
                    poutunit='W';
                    datasec{k}=strrep(datasec{k},'W',blanks(1));
                else
                    poutunit='';
                end


                tempA=str2num(datasec{k});
                if(numel(tempA)~=2&&numel(tempA)~=3)
                    fclose(fid);
                    error(message('rf:rfdata:data:readamp:errinpowerdata'))
                end
                if k==1

                    powerdata=zeros(numel(datasec),numel(tempA));
                    powerdata(1,:)=tempA;
                else
                    powerdata(k,:)=tempA;
                end


                powerdata(k,1)=convert2w(powerdata(k,1),pinunit,...
                pinunit_default);
                powerdata(k,2)=convert2w(powerdata(k,2),poutunit,...
                poutunit_default);
            end





            if totpowsec>1&&isempty(PoutFreq)
                fclose(fid);
                error(message('rf:rfdata:data:readamp:emptypowerfreq'))
            end
            if~isempty(newfreq)
                PoutFreq(totpowsec,1)=newfreq;
            end

            Pin{totpowsec,1}=powerdata(:,1)';
            Pout{totpowsec,1}=powerdata(:,2)';
            if size(powerdata,2)==3
                Phase{totpowsec,1}=powerdata(:,3)';
            else
                Phase{totpowsec,1}=zeros(1,size(powerdata,1));
            end


        case 'NetParam'

            type_lnum=cat(1,strmatch('S',headersec),...
            strmatch('Y',headersec),strmatch('Z',headersec),...
            strmatch('H',headersec));

            type_line=headersec(type_lnum(end),:);


            NetworkType=findnettype(h,type_line(1));


            DataFormat=findnetformat(h,type_line);
            if isempty(DataFormat)
                switch NetworkType(1)
                case 'S'
                    DataFormat='MA';
                otherwise
                    DataFormat='RI';
                end
            end


            RREFpos=strfind(type_line,'RREF');
            if~isempty(RREFpos)
                RREFpos=RREFpos(end);
            end
            Rpos=strfind(type_line,'R');
            if~isempty(Rpos)
                Rpos=Rpos(end);
            end

            if(isempty(Rpos)&&isempty(RREFpos))||...
                (~isempty(Rpos)&&Rpos==numel(type_line))||...
                (~isempty(RREFpos)&&RREFpos==numel(type_line)-3)
                warning(message('rf:rfdata:data:read:Z0NotFound'));

            elseif~isempty(RREFpos)
                Z0=findz0(h,type_line(RREFpos+4:end));
                if isempty(Z0)||~isscalar(Z0)
                    Z0=50;
                    warning(message('rf:rfdata:data:read:Z0NotFound'));
                end

            else
                Z0=findz0(h,type_line(Rpos+1:end));
                if isempty(Z0)||~isscalar(Z0)
                    Z0=50;
                    warning(message('rf:rfdata:data:read:Z0NotFound'));
                end
            end

            freq_lnum=strmatch('F',headersec);
            freq_line=headersec(freq_lnum(end),:);


            FScale=findfrequnit(h,freq_line);



            noifscale_default=FScale;
            FScale_default=FScale;


            cline=strtok(fgetl(fid),';');
            lcounter=lcounter+1;
            while ischar(cline)||isempty(cline)
                first_char=sscanf(cline,'%s');


                if~isempty(first_char)&&...
                    ~isempty(strfind('+-.0123456789',first_char(1)))
                    datasec{ds_idx}=cline;
                    ds_idx=ds_idx+1;
                elseif~isempty(first_char)&&...
                    isempty(strfind('+-.0123456789',first_char(1)))&&...
                    ~strcmp(first_char(1),'*')

                    cline=strtrim(cline);
                    headersec=cline;
                    break;
                end
                cline=strtok(fgetl(fid),';');
                lcounter=lcounter+1;
            end

            totnetsec=totnetsec+1;
            if totnetsec>1
                fclose(fid);
                error(message('rf:rfdata:data:readamp:multiplenetdata'))
            end




            datasec=upper(datasec);

            pcounter=0;

            Col=2*nPort*nPort+1;

            netline=[];

            netdata=[];
            ndatasec=numel(datasec);
            for k=1:ndatasec
                if pcounter==0
                    token=sscanf(datasec{k},'%s');
                    if~isempty(strfind(token,'GHZ'))
                        FScale=1e9;
                        datasec{k}=strrep(datasec{k},'GHZ',blanks(3));
                    elseif~isempty(strfind(token,'MHZ'))
                        FScale=1e6;
                        datasec{k}=strrep(datasec{k},'MHZ',blanks(3));
                    elseif~isempty(strfind(token,'KHZ'))
                        FScale=1e3;
                        datasec{k}=strrep(datasec{k},'KHZ',blanks(3));
                    elseif~isempty(strfind(token,'HZ'))
                        FScale=1;
                        datasec{k}=strrep(datasec{k},'HZ',blanks(2));
                    else
                        FScale=[];
                    end
                    if isempty(FScale)&&isempty(FScale_default)
                        fclose(fid);
                        error(message('rf:rfdata:data:readamp:nofrequnits'))
                    end
                end

                tempL=str2num(datasec{k});
                if isempty(tempL)
                    fclose(fid);
                    error(message('rf:rfdata:data:readamp:errinnetdata'))
                end
                pcounter=pcounter+numel(tempL);

                if pcounter>Col
                    fclose(fid);
                    error(message('rf:rfdata:data:readamp:paramnotmatchport'))

                elseif pcounter==Col
                    pcounter=0;
                    netline=cat(2,netline,tempL);
                    if isempty(FScale)

                        netline(1)=netline(1)*FScale_default;
                    else
                        netline(1)=netline(1)*FScale;
                    end
                    netdata=cat(1,netdata,netline);

                    netline=[];
                else
                    netline=cat(2,netline,tempL);
                end
            end



            if pcounter~=0
                fclose(fid);
                error(message('rf:rfdata:data:readamp:incompletenetparam'))
            end

            Freq=netdata(:,1);

            netdata=netdata(:,2:end);
            NetworkParameters=getnetdata(h,netdata,DataFormat);

        case 'NoiParam'

            freq_lnum=strmatch('F',headersec);
            if~isempty(freq_lnum)
                freq_line=headersec(freq_lnum(end),:);


                noifscale_default=findfrequnit(h,freq_line);
            end

            cline=strtok(fgetl(fid),';');
            lcounter=lcounter+1;
            while ischar(cline)||isempty(cline)
                first_char=sscanf(cline,'%s');


                if~isempty(first_char)&&...
                    ~isempty(strfind('+-.0123456789',first_char(1)))
                    datasec{ds_idx}=cline;
                    ds_idx=ds_idx+1;
                elseif~isempty(first_char)&&...
                    isempty(strfind('+-.0123456789',first_char(1)))&&...
                    ~strcmp(first_char(1),'*')

                    cline=strtrim(cline);
                    headersec=cline;
                    break;
                end
                cline=strtok(fgetl(fid),';');
                lcounter=lcounter+1;
            end

            totnoisec=totnoisec+1;
            if totnoisec>1
                fclose(fid);
                error(message('rf:rfdata:data:readamp:multiplenoidata'))
            end




            datasec=upper(datasec);
            noidata=zeros(numel(datasec),5);
            ndatasec=numel(datasec);
            for k=1:ndatasec
                if~isempty(strfind(datasec{k},'GHZ'))
                    noifscale=1e9;
                    datasec{k}=strrep(datasec{k},'GHZ',blanks(3));
                elseif~isempty(strfind(datasec{k},'MHZ'))
                    noifscale=1e6;
                    datasec{k}=strrep(datasec{k},'MHZ',blanks(3));
                elseif~isempty(strfind(datasec{k},'KHZ'))
                    noifscale=1e3;
                    datasec{k}=strrep(datasec{k},'KHZ',blanks(3));
                elseif~isempty(strfind(datasec{k},'HZ'))
                    noifscale=1;
                    datasec{k}=strrep(datasec{k},'HZ',blanks(2));
                else
                    noifscale=[];
                end

                if isempty(noifscale)&&isempty(noifscale_default)
                    fclose(fid);
                    error(message('rf:rfdata:data:readamp:nonoifrequnits'))
                end


                tempA=str2num(datasec{k});
                if numel(tempA)~=5
                    fclose(fid);
                    error(message('rf:rfdata:data:readamp:errinnoidata'))
                end

                if~isempty(noifscale)
                    tempA(1)=noifscale*tempA(1);
                else
                    tempA(1)=noifscale_default*tempA(1);
                end
                noidata(k,:)=tempA;
            end


            NoiseFreq=noidata(:,1);
            NoiseParameters=noidata(:,2:end);

        case 'IP3'



            if~isempty(strmatch('OIP3',headersec))
                ip3_lnum=strmatch('OIP3',headersec);
                IP3Type='OIP3';
            else
                ip3_lnum=strmatch('IIP3',headersec);
                IP3Type='IIP3';
            end
            ip3_line=headersec(ip3_lnum(end),:);
            ip3unit=findpowerunit(h,ip3_line);
            if isempty(ip3unit)
                ip3unit='W';
            end

            freq_lnum=strmatch('F',headersec);
            if~isempty(freq_lnum)
                freq_line=headersec(freq_lnum(end),:);


                ip3fscale=findfrequnit(h,freq_line,1);
            else
                ip3fscale=1;
            end


            cline=strtok(fgetl(fid),';');
            lcounter=lcounter+1;
            while ischar(cline)||isempty(cline)
                first_char=sscanf(cline,'%s');


                if~isempty(first_char)&&...
                    ~isempty(strfind('+-.0123456789',first_char(1)))
                    datasec{ds_idx}=cline;
                    ds_idx=ds_idx+1;
                elseif~isempty(first_char)&&...
                    isempty(strfind('+-.0123456789',first_char(1)))&&...
                    ~strcmp(first_char(1),'*')

                    cline=strtrim(cline);
                    headersec=cline;
                    break;
                end
                cline=strtok(fgetl(fid),';');
                lcounter=lcounter+1;
            end

            totip3sec=totip3sec+1;
            if totip3sec>1
                fclose(fid);
                error(message('rf:rfdata:data:readamp:multipleip3data'))
            end




















            ip3data=str2num(char(datasec));
            if size(ip3data,2)==2;
                IP3Freq=ip3fscale*ip3data(:,1);
                IP3Power=ip3data(:,2);
            elseif size(ip3data,2)==1&&...
                size(ip3data,1)==1
                IP3Freq=1;
                IP3Power=ip3data(1,1);
            else
                fclose(fid);
                error(message('rf:rfdata:data:readamp:errinip3data'))
            end

            IP3Power=convert2w(IP3Power,ip3unit,'W');

        case 'NF'
            freq_lnum=strmatch('F',headersec);
            if~isempty(freq_lnum)
                freq_line=headersec(freq_lnum(end),:);


                nffscale=findfrequnit(h,freq_line,1);
            else
                nffscale=1;
            end


            cline=strtok(fgetl(fid),';');
            lcounter=lcounter+1;
            while ischar(cline)||isempty(cline)
                first_char=sscanf(cline,'%s');


                if~isempty(first_char)&&...
                    ~isempty(strfind('+-.0123456789',first_char(1)))
                    datasec{ds_idx}=cline;
                    ds_idx=ds_idx+1;
                elseif~isempty(first_char)&&...
                    isempty(strfind('+-.0123456789',first_char(1)))&&...
                    ~strcmp(first_char(1),'*')

                    cline=strtrim(cline);
                    headersec=cline;
                    break;
                end
                cline=strtok(fgetl(fid),';');
                lcounter=lcounter+1;
            end

            totnfsec=totnfsec+1;
            if totnfsec>1
                fclose(fid);
                error(message('rf:rfdata:data:readamp:multiplenfdata'))
            end


            nfdata=str2num(char(datasec));
            if size(nfdata,2)==2;
                NFFreq=nffscale*nfdata(:,1);
                NFdB=nfdata(:,2);
            elseif size(nfdata,2)==1&&...
                size(nfdata,1)==1
                NFFreq=1;
                NFdB=nfdata(1,1);
            else
                fclose(fid);
                error(message('rf:rfdata:data:readamp:errinnfdata'))
            end

        case 'MixerData'


            maxorder_line='';
            for k=size(headersec,1):-1:1
                if~isempty(strfind(headersec(k,:),'MAXORDER'))
                    maxorder_line=headersec(k,:);
                    break;
                end
            end
            if isempty(maxorder_line)
                fclose(fid);
                error(message('rf:rfdata:data:readamp:nomaxorderkeyword'))
            end

            start_of_maxorder=strfind(maxorder_line,'MAXORDER');
            nmaxorder_line=numel(maxorder_line);
            for ii=start_of_maxorder(end)+7:nmaxorder_line
                if~isempty(strfind('+-.0123456789',maxorder_line(ii)))

                    if ii==nmaxorder_line
                        MAXORDER=str2num(maxorder_line(ii));
                    else
                        for p=ii+1:nmaxorder_line
                            if isempty(strfind('+-.0123456789E',...
                                maxorder_line(p)))
                                MAXORDER=str2num(maxorder_line(ii:p-1));
                                break;
                            end
                        end
                    end
                    break;
                end
            end
            if isempty(MAXORDER)
                fclose(fid);
                error(message('rf:rfdata:data:readamp:nomaxorder'))
            end
            IMTTable=nan(MAXORDER+1,MAXORDER+1);


            flo_line='';
            for k=size(headersec,1):-1:1
                if~isempty(strfind(headersec(k,:),'FLO'))
                    flo_line=headersec(k,:);
                    break;
                end
            end
            if~isempty(flo_line)
                start_of_flo=strfind(flo_line,'FLO');
                nflo_line=numel(flo_line);
                for ii=start_of_flo(end)+2:nflo_line
                    if~isempty(strfind('+-.0123456789',flo_line(ii)))

                        if ii==nflo_line
                            FLO=str2num(flo_line(ii));
                        else
                            for p=ii+1:nflo_line
                                if isempty(strfind('.0123456789E',...
                                    flo_line(p)))
                                    FLO=str2num(flo_line(ii:p-1));
                                    break;
                                end
                            end
                        end
                        break;
                    end
                end


                FLO=FLO*findfrequnit(h,flo_line,1);
            end


            plo_line='';
            for k=size(headersec,1):-1:1
                if~isempty(strfind(headersec(k,:),'PLO'))
                    plo_line=headersec(k,:);
                    break;
                end
            end
            if~isempty(plo_line)
                start_of_plo=strfind(plo_line,'PLO');
                nplo_line=numel(plo_line);
                for ii=start_of_plo(end)+2:nplo_line
                    if~isempty(strfind('+-.0123456789',plo_line(ii)))

                        if ii==nplo_line
                            PLO=str2num(plo_line(ii));
                        else
                            for p=ii+1:nplo_line
                                if isempty(strfind('.0123456789E',...
                                    plo_line(p)))
                                    PLO=str2num(plo_line(ii:p-1));
                                    break;
                                end
                            end
                        end
                        break;
                    end
                end


                PLO=convert2w(PLO,findpowerunit(h,plo_line),'W');
            end


            cline=strtok(fgetl(fid),';');
            lcounter=lcounter+1;
            while ischar(cline)||isempty(cline)
                first_char=sscanf(cline,'%s');


                if~isempty(first_char)&&...
                    ~isempty(strfind('+-.0123456789',first_char(1)))
                    datasec{ds_idx}=cline;
                    ds_idx=ds_idx+1;
                elseif~isempty(first_char)&&...
                    isempty(strfind('+-.0123456789',first_char(1)))&&...
                    ~strcmp(first_char(1),'*')

                    cline=strtrim(cline);
                    headersec=cline;
                    break;
                end
                cline=strtok(fgetl(fid),';');
                lcounter=lcounter+1;
            end


            totmixersec=totmixersec+1;
            if totmixersec>1
                fclose(fid);
                error(message('rf:rfdata:data:readamp:multipleimttable'))
            end


            datasec=upper(datasec);
            for ii=1:MAXORDER+1
                tempA=str2num(datasec{ii});
                if isempty(tempA)||(numel(tempA)~=MAXORDER+2-ii)
                    fclose(fid);
                    error(message('rf:rfdata:data:readamp:errinimttable'))
                end
                IMTTable(ii,1:MAXORDER+2-ii)=tempA;
            end
        end
    end


    if totnetsec==0&&totpowsec>0
        warning(message('rf:rfdata:data:readamp:SNotFound'));
    end


    refobj=get(h,'Reference');
    if~isa(refobj,'rfdata.reference')
        refobj=rfdata.reference('CopyPropertyObj',false);
    end
    [Fmin,Gammaopt,Rn]=getnoisedata(h,NoiseParameters,'MA',1);
    update(refobj,NetworkType,Freq,NetworkParameters,Z0,NoiseFreq,Fmin,...
    Gammaopt,Rn,PoutFreq,Pin,Pout,Phase);

    if~isempty(IMTTable)&&~isempty(MAXORDER)
        MixerSpurData=rfdata.mixerspur('Data',IMTTable);
        set(refobj,'MixerSpurData',MixerSpurData);
    else
        set(refobj,'MixerSpurData',[]);
    end

    if~isempty(IP3Power)&&~isempty(IP3Freq)
        IP3Data=rfdata.ip3('Freq',IP3Freq,'Data',IP3Power,'Type',IP3Type);
        set(refobj,'IP3Data',IP3Data);
    else
        set(refobj,'IP3Data',[]);
    end

    if~isempty(NFdB)&&~isempty(NFFreq)
        NFData=rfdata.nf('Freq',NFFreq,'Data',NFdB);
        set(refobj,'NFData',NFData);
    else
        set(refobj,'NFData',[]);
    end

    fclose(fid);


    function power=convert2w(power,unit,default_unit)


        if(nargin<3)
            default_unit='W';
        end
        switch unit
        case 'DBM'
            power=0.001*10.^(power/10);
        case 'DBW'
            power=10.^(power/10);
        case 'MW'
            power=0.001*power;

        case ''
            switch default_unit
            case 'DBM'
                power=0.001*10.^(power/10);
            case 'DBW'
                power=10.^(power/10);
            case 'MW'
                power=0.001*power;
            end
        end