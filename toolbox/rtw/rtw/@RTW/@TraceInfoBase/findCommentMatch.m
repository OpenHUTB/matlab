function[comm]=findCommentMatch(~,comm,eView,cnt,excelInfo)


    indx=find(strcmp(eView.ssid{end},excelInfo.ssid));



    if((length(indx)>=1)&&(~isempty(eView.file{end})))
        jndx=find(strcmp(eView.file{end},excelInfo.file(indx)));
        indx=indx(jndx);%#ok<FNDSB> : note I need the single entry later!
    end

    if((length(indx)>=1)&&(~isempty(eView.func{end})))
        jndx=find(strcmp(eView.func{end},excelInfo.func(indx)));
        indx=indx(jndx);%#ok<FNDSB> : note I need the single entry later!
    end

    if((length(indx)>=1)&&(~isempty(eView.comSum{end})))

        jndx=find(strcmp(eView.comSum{end},excelInfo.cSum(indx)));
        indx=indx(jndx);%#ok<FNDSB> : note I need the single entry later!
    end

    if((length(indx)>=1)&&(~isempty(eView.req{end})))


        jndx=find(strcmp([eView.req{end}.description,':',eView.req{end}.id],excelInfo.req(indx)));

        indx=indx(jndx);%#ok<FNDSB> : note I need the single entry later!
    end

    if(~isempty(indx))
        if(length(indx)>1)
            if(length(indx)==excelInfo.numCom)

                preText='';
            else
                preText=DAStudio.message('RTW:traceInfo:tInfoExcelNotUnique');
            end

            for jnx=1:length(indx)
                comNum=excelInfo.comNum(indx(jnx));
                comm(comNum).text{cnt}=[preText,excelInfo.comm{indx(jnx)}];
                comm(comNum).row(cnt)=excelInfo.colInx(comNum);
            end
        else
            comNum=excelInfo.comNum(indx);
            comm(comNum).text{cnt}=excelInfo.comm{indx};
            comm(comNum).row(cnt)=excelInfo.colInx(comNum);
        end
    end

end
