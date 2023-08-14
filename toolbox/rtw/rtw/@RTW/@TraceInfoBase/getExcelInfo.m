



















function[excelInfo,sheet]=getExcelInfo(~,pathToFile,colText)
    excelInfo.numCom=0;
    excelInfo.cSum={};
    excelInfo.ssid={};
    warning('off','MATLAB:nonIntegerTruncatedInConversionToChar');

    sheet=DAStudio.message('RTW:traceInfo:tInfoExcelReport');


    if(~strcmp(pathToFile(end-2:end),'xls'))
        pathToFile=[pathToFile,'.xls'];
    end
    if(exist(pathToFile,'file'))

        copyPath=[pathToFile(1:end-4),'_BAK.xls'];
        copyfile(pathToFile,copyPath,'f');
        excelInfo.opened=1;

        [typ,sheets]=xlsfinfo(pathToFile);
        if(isempty(typ))
            ME=MException('RTW:traceInfo:UnableToOpenExcelFile',...
            DAStudio.message('RTW:traceInfo:UnableToOpenExcelFile'));
            throw(ME);
        end
        numSheets=length(sheets);
        inx=1;
        notFound=1;
        while((inx<=numSheets)&&(notFound))
            [~,~,raw]=xlsread(pathToFile,sheets{inx});

            if(iscell(raw))
                strPos=findstr([raw{1,:}],colText{1});
                if(~isempty(strPos))
                    notFound=0;
                    sheet=sheets{inx};
                end
            end
            inx=inx+1;
        end
        if(notFound==1)

            ME=MException('RTW:traceInfo:HeaderNotFound',...
            DAStudio.message('RTW:traceInfo:HeaderNotFound'));
            throw(ME);
        end

        header=raw(1,:);

        for inx=1:length(header)
            if isnan(header{inx})
                header{inx}='';
            end
        end
        excelInfo.header=header;


        for inx=1:size(raw,2)

            if(isempty(strmatch(header(inx),colText)))

                excelInfo.numCom=excelInfo.numCom+1;
                excelInfo.colInx(excelInfo.numCom)=inx;
                excelInfo.comHead{excelInfo.numCom}=header{inx};
                excelInfo=getComments(excelInfo,raw,header,colText);
            end
        end
    else
        excelInfo.opened=0;
    end
    warning('on','MATLAB:nonIntegerTruncatedInConversionToChar');

end




















function[excelInfo]=getComments(excelInfo,raw,header,colText)


    ssidIndx=strmatch(colText{12},header);
    funcIndx=strmatch(colText{6},header);
    fileIndx=strmatch(colText{5},header);
    cSumIndx=strmatch(colText{18},header);
    reqIndx=strmatch(colText{11},header);

    if(isempty(ssidIndx))
        ssidIndx=1;
    end
    if(isempty(funcIndx))
        funcIndx=1;
    end
    if(isempty(fileIndx))
        fileIndx=1;
    end
    if(isempty(cSumIndx))
        cSumIndx=1;
    end
    if(isempty(reqIndx))
        reqIndx=1;
    end


    curCom=excelInfo.numCom;
    curCol=excelInfo.colInx(curCom);
    if(~isfield(excelInfo,'comm'))
        excelInfo.comm={};
        excelInfo.ssid={};
        excelInfo.comNum=[];
        excelInfo.func={};
        excelInfo.file={};
        excelInfo.cSum={};
        excelInfo.req={};
    end

    for inx=2:size(raw,1)
        if(~isnan(raw{inx,curCol}))

            excelInfo.comm{end+1}=raw{inx,curCol};
            excelInfo.comNum(end+1)=curCom;
            excelInfo.ssid{end+1}=raw{inx,ssidIndx};

            if(isnan(raw{inx,fileIndx}))

                excelInfo.file{end+1}='';
            else
                excelInfo.file{end+1}=raw{inx,fileIndx};
            end

            if(isnan(raw{inx,funcIndx}))
                excelInfo.func{end+1}='';
            else
                excelInfo.func{end+1}=raw{inx,funcIndx};
            end

            if(isnan(raw{inx,cSumIndx}))
                excelInfo.cSum{end+1}='';
            else
                excelInfo.cSum{end+1}=raw{inx,cSumIndx};
            end

            if(isnan(raw{inx,reqIndx}))
                excelInfo.req{end+1}='';
            else
                excelInfo.req{end+1}=raw{inx,reqIndx};
            end

        end
    end
end
