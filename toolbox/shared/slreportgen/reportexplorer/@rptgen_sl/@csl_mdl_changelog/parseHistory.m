function hInfo=parseHistory(this,hString)




    if this.isLimitRevisions
        numRevisions=this.NumRevisions;
    else
        numRevisions=inf;
    end

    hInfo=cell(0,4);
    currEntry=0;

    dashStr=' -- ';
    dashLen=length(dashStr);

    verStr='Version ';
    verLen=length(verStr);

    sinceDate=[];

    if this.isLimitDate
        sinceDate=rptgen.parseExpressionText(this.DateLimit);

        if(~isempty(sinceDate)&&ischar(sinceDate))
            try
                sinceDate=datenum(sinceDate);
            catch ex
                sinceDate=[];
                this.status(...
                sprintf(getString(message('RptgenSL:rsl_csl_mdl_changelog:ignoringShowSinceLabel')),ex.message),...
                6);
            end
        end
    end

    continueDate=true;

    while~isempty(hString)&&...
        currEntry<=numRevisions&&...
continueDate

        [currChunk,hString]=strtok(hString,char(10));%#ok<STTOK> - There are several 




        dashLoc=findstr(currChunk,dashStr);
        numDashes=length(dashLoc);
        if(numDashes>0&&numDashes<=2)



            currEntry=currEntry+1;

            if currEntry<=numRevisions
                authorString=currChunk(1:dashLoc);

                if numDashes==2
                    dateString=currChunk(dashLoc(1)+dashLen:dashLoc(2)-1);
                    verString=currChunk(dashLoc(2)+dashLen+verLen:end);
                else
                    dateString=currChunk(dashLoc(1)+dashLen:end);
                    verString='';
                end

                try
                    thisDateNumeric=datenum(dateString(4:end),...
                    'mmm dd HH:MM:SS yyyy');




                catch ex
                    thisDateNumeric=[];
                    this.status(sprintf(getString(message('RptgenSL:rsl_csl_mdl_changelog:badDateLabel')),...
                    ex.message),6);
                end

                if(~isempty(thisDateNumeric))
                    if~(isempty(this.DateFormat)||strcmpi(this.DateFormat,'inherit'))
                        dateString=datestr(thisDateNumeric,this.DateFormat,'local');
                    end

                    if(~isempty(sinceDate))
                        continueDate=thisDateNumeric>=sinceDate;
                    end
                end

                if(continueDate)
                    hInfo(currEntry,:)={verString,authorString,dateString,''};
                end
            end
        elseif currEntry>0
            hInfo{currEntry,4}=[hInfo{currEntry,4},' ',currChunk];
        end
    end



    if~isempty(hInfo)&&strcmp(this.SortOrder,'chronological')
        hInfo=hInfo(end:-1:1,:);
    end
