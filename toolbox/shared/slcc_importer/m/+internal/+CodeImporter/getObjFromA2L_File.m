function asap2Objs=getObjFromA2L_File(asap2File)


    asap2Str=fileread(asap2File);
    asap2Objs=initAsap2Objs(asap2Str);





    function objs=initAsap2Objs(asap2Str)






        objs.header{1}=getHeader(asap2Str);
        objs.par.Names={};
        objs.par.Entries={};
        objs.axis.Names={};
        objs.axis.Entries={};
        objs.sig.Names={};
        objs.sig.Entries={};
        objs.record.Names={};
        objs.record.Entries={};
        objs.compumethod.Names={};
        objs.compumethod.Entries={};
        objs.compuvtab.Names={};
        objs.compuvtab.Entries={};
        objs.group.Names={};
        objs.group.Entries={};
        objs.footer{1}=getFooter(asap2Str);


        objs=getAsap2Objs(objs,asap2Str);
    end

    function outObjs=getAsap2Objs(inObjs,asap2Str)




        inObjs.sig=getObjs(inObjs.sig,asap2Str,'MEASUREMENT',4);
        inObjs.group=getObjs(inObjs.group,asap2Str,'GROUP',4);
        inObjs.compumethod=getObjs(inObjs.compumethod,asap2Str,'COMPU_METHOD',4);
        inObjs.compuvtab=getObjs(inObjs.compuvtab,asap2Str,'COMPU_VTAB',4);
        inObjs.par=getObjs(inObjs.par,asap2Str,'CHARACTERISTIC',4);
        inObjs.axis=getObjs(inObjs.axis,asap2Str,'AXIS_PTS',4);
        inObjs.record=getObjs(inObjs.record,asap2Str,'RECORD_LAYOUT',4);


        outObjs=inObjs;
    end

    function outObjs=getObjs(inObjs,asap2Str,keyword,sOffset)





        sIdx=regexp(asap2Str,['begin\s+',keyword]);
        eIdx=regexp(asap2Str,['end\s+',keyword],'end');


        for cI=1:size(sIdx,2)

            str=asap2Str(sIdx(cI)-sOffset-1:eIdx(cI));

            CommentStart=strfind(str,'/*');
            CommentEnd=strfind(str,'*/');
            idxDeleted=zeros(size(str));
            for idxStart=length(CommentStart):-1:1
                EndComment=CommentEnd(find(CommentEnd>CommentStart(idxStart),1,'first'));
                if~isempty(EndComment)
                    idxDeleted(CommentStart(idxStart):EndComment+1)=1;
                else
                    idxDeleted(CommentStart(idxStart):end)=1;
                end
            end
            str(logical(idxDeleted))=[];

            [tmpS,tmpE]=regexp(str,'"[^"]*"');
            for idx=length(tmpS):-1:1
                str(tmpS(idx)+1:tmpE(idx)-1)=[];
            end

            LineTabsIdx=regexp(str,'[\f\n\r\t\v]');
            deleteLineTabs=ones(size(LineTabsIdx));
            for idxLineTabsIdx=1:length(LineTabsIdx)
                if idxLineTabsIdx==1&&str(1)=='#'
                    deleteLineTabs(idxLineTabsIdx)=0;
                elseif idxLineTabsIdx>1&&str(LineTabsIdx(idxLineTabsIdx-1)+1)=='#'...
                    ||(length(str)>=LineTabsIdx(idxLineTabsIdx)+1...
                    &&str(LineTabsIdx(idxLineTabsIdx)+1)=='#')
                    deleteLineTabs(idxLineTabsIdx)=0;
                end
            end
            str(LineTabsIdx(logical(deleteLineTabs)))=' ';

            strCell=strsplit(strtrim(str),' ');

            cm='';
            Min='';
            Max='';
            DataType='';
            Category='';
            if length(strCell)>3&&strcmp(strCell{1},'/begin')
                switch strCell{2}
                case 'RECORD_LAYOUT'
                    name=strtrim(strCell{3});
                    idxFV=find(strcmp(strCell,'FNC_VALUES'));
                    if~isempty(idxFV)&&length(strCell)>=idxFV(1)+2
                        DataType=strtrim(strCell{idxFV(1)+2});
                    end
                    idxAX=find(strcmp(strCell,'AXIS_PTS_X'));
                    if~isempty(idxAX)&&length(strCell)>=idxAX(1)+2
                        DataType_X=strtrim(strCell{idxAX(1)+2});
                    end
                    idxAY=find(strcmp(strCell,'AXIS_PTS_Y'));
                    if~isempty(idxAY)&&length(strCell)>=idxAY(1)+2
                        DataType_Y=strtrim(strCell{idxAY(1)+2});
                    end
                case 'COMPU_METHOD'
                    name=strtrim(strCell{3});
                case 'COMPU_VTAB'
                    name=strtrim(strCell{3});
                case 'MEASUREMENT'
                    name=strtrim(strCell{3});
                    if length(strCell)>=5
                        DataType=strtrim(strCell{5});
                    end
                    if length(strCell)>=6
                        cm=strtrim(strCell{6});
                    end
                    if length(strCell)>=9
                        Min=str2double(strtrim(strCell{9}));
                    end
                    if length(strCell)>=10
                        Max=str2double(strtrim(strCell{10}));
                    end
                case 'CHARACTERISTIC'
                    name=strtrim(strCell{3});
                    if length(strCell)>=5
                        Category=strtrim(strCell{5});
                    else
                        Category='';
                    end
                    if length(strCell)>=7
                        RecordType=strtrim(strCell{7});
                    end
                    if length(strCell)>=9
                        cm=strtrim(strCell{9});
                    end
                    if length(strCell)>=10
                        Min=str2double(strtrim(strCell{10}));
                    end
                    if length(strCell)>=11
                        Max=str2double(strtrim(strCell{11}));
                    end

                    AxisRefYes=find(strcmp(strCell,'AXIS_PTS_REF'));
                    AxisRef={};
                    for idxAxisRef=1:length(AxisRefYes)
                        AxisRef{end+1}=strCell{AxisRefYes(idxAxisRef)+1};%#ok<AGROW>
                    end

                    AxisDescYes=find(strcmp(strCell,'AXIS_DESCR'));
                    AxisDesc={};
                    for idxAxisDesc=1:2:length(AxisDescYes)
                        AxisDesc{end+1}=struct('Category','','cm','');%#ok<AGROW>
                        AxisDesc{end}.Category=strCell{AxisDescYes(idxAxisDesc)+1};
                        AxisDesc{end}.cm=strCell{AxisDescYes(idxAxisDesc)+3};
                        AxisDesc{end}.Min=strCell{AxisDescYes(idxAxisDesc)+5};
                        AxisDesc{end}.Max=strCell{AxisDescYes(idxAxisDesc)+6};
                        AxisDesc{end}.DataType='';
                        AxisDesc{end}.RecordTypeX=RecordType;
                    end

                case 'AXIS_PTS'
                    name=strtrim(strCell{3});
                    if length(strCell)>=7
                        RecordType=strtrim(strCell{7});
                    end
                    if length(strCell)>=9
                        cm=strtrim(strCell{9});
                    end
                    if length(strCell)>=11
                        Min=str2double(strtrim(strCell{11}));
                    end
                    if length(strCell)>=12
                        Max=str2double(strtrim(strCell{12}));
                    end

                otherwise
                    name=strtrim(strCell{3});
                end
            end


            if~isempty(name)
                if any(strfind(name,'['))
                    name=regexprep(name,'\[\w*\]','');
                end
                if~any(strcmp(inObjs.Names,name))
                    inObjs.Names{end+1}=name;
                    inObjs.Entries{end+1}.name=name;
                    inObjs.Entries{end}.Text=strCell;
                    inObjs.Entries{end}.cm=cm;
                    inObjs.Entries{end}.DataType=DataType;
                    inObjs.Entries{end}.Min=Min;
                    inObjs.Entries{end}.Max=Max;
                    if~isempty(Category)
                        inObjs.Entries{end}.Category=Category;
                    end
                    if exist('AxisRef','var')&&~isempty(AxisRef)
                        inObjs.Entries{end}.AxisRef=AxisRef;
                    end
                    if exist('AxisDesc','var')&&~isempty(AxisDesc)
                        inObjs.Entries{end}.AxisDesc=AxisDesc;
                    end
                    if exist('RecordType','var')&&~isempty(RecordType)
                        inObjs.Entries{end}.RecordType=RecordType;
                    end
                    if exist('DataType_X','var')&&~isempty(DataType_X)
                        inObjs.Entries{end}.DataType_X=DataType_X;
                    end
                    if exist('DataType_Y','var')&&~isempty(DataType_Y)
                        inObjs.Entries{end}.DataType_Y=DataType_Y;
                    end
                end
            end

        end

        outObjs=inObjs;
    end

    function outStr=getHeader(inStr)






        hIdxs=regexp(inStr,'/begin\s+RECORD_LAYOUT','ONCE');
        if isempty(hIdxs)
            disp('Header section information not found');
            outStr='';
        else
            outStr=inStr(1:hIdxs(end)-1);
        end
    end

    function outStr=getFooter(inStr)






        fIdxs=regexp(inStr,'\end\s+MODULE','ONCE');
        if isempty(fIdxs)
            disp('Footer section information not found');
            outStr='';
        else
            outStr=inStr(fIdxs-1:end);
        end
    end

end