function desc=getCodeFilterDescription(prop)




    desc='';
    if prop.isCode

        [codeInfo,ssid]=SlCov.FilterEditor.decodeCodeFilterInfo(prop.value);



        msgIdPart1='Slvnv:simcoverage:covFilter';
        if~isempty(ssid)
            msgIdPart1=[msgIdPart1,'SFun'];
        end
        msgIdPart1=[msgIdPart1,'Code'];
        if prop.mode==0
            msgIdPart2='Excluded';
        else
            msgIdPart2='Justified';
        end
        msgIdPart3='Desc';


        if SlCov.FilterEditor.isCodeFilterFileInfo(codeInfo)
            msgId=[msgIdPart1,'File',msgIdPart2,msgIdPart3];
            if~isempty(ssid)
                desc=getString(message(msgId,codeInfo{1},...
                generatePrettyName(ssid,prop.valueDesc)));
            else
                desc=getString(message(msgId,codeInfo{1}));
            end
        elseif SlCov.FilterEditor.isCodeFilterFunInfo(codeInfo)
            msgId=[msgIdPart1,'Fun',msgIdPart2,msgIdPart3];
            if~isempty(ssid)
                desc=getString(message(msgId,codeInfo{2},codeInfo{1},...
                generatePrettyName(ssid,prop.valueDesc)));
            else
                desc=getString(message(msgId,codeInfo{2},codeInfo{1}));
            end
        elseif SlCov.FilterEditor.isCodeFilterDecInfo(codeInfo)

            args={codeInfo{3},codeInfo{1},codeInfo{2}};
            if~isempty(ssid)
                args=[args,{generatePrettyName(ssid,prop.valueDesc)}];
            end
            if numel(codeInfo{4})==2

                args=[args,{codeInfo{4}(2)}];
                msgId=[msgIdPart1,'DecOutcome','Justified',msgIdPart3];
            else
                msgId=[msgIdPart1,'Dec',msgIdPart2,msgIdPart3];
            end
            desc=getString(message(msgId,args{:}));
        elseif SlCov.FilterEditor.isCodeFilterCondInfo(codeInfo)

            args={codeInfo{3},codeInfo{1},codeInfo{2}};
            if~isempty(ssid)
                args=[args,{generatePrettyName(ssid,prop.valueDesc)}];
            end
            if numel(codeInfo{4})>=2

                if codeInfo{4}(2)==2
                    arg='T';
                else
                    arg='F';
                end
                args=[args,{arg}];
                if numel(codeInfo{4})==3


                    args=[args,{codeInfo{4}(1)}];
                    msgId=[msgIdPart1,'DecCondOutcome','Justified',msgIdPart3];
                else
                    msgId=[msgIdPart1,'CondOutcome','Justified',msgIdPart3];
                end
            else
                msgId=[msgIdPart1,'Cond',msgIdPart2,msgIdPart3];
            end
            desc=getString(message(msgId,args{:}));
        elseif SlCov.FilterEditor.isCodeFilterMCDCInfo(codeInfo)

            args={codeInfo{3},codeInfo{1},codeInfo{2}};
            if~isempty(ssid)
                args=[args,{generatePrettyName(ssid,prop.valueDesc)}];
            end
            args=[args,{codeInfo{4}(2)}];
            msgId=[msgIdPart1,'MCDCOutcome','Justified',msgIdPart3];
            desc=getString(message(msgId,args{:}));
        elseif SlCov.FilterEditor.isCodeFilterRelBoundInfo(codeInfo)

            args={codeInfo{3},codeInfo{1},codeInfo{2}};
            if~isempty(ssid)
                args=[args,{generatePrettyName(ssid,prop.valueDesc)}];
            end

            if codeInfo{4}(2)==1
                arg='"LT"';
            elseif codeInfo{4}(2)==2
                arg='"GT"';
            else
                arg='"EQ"';
            end
            args=[args,{arg}];
            if numel(codeInfo{4})==3


                args=[args,{codeInfo{4}(3)}];
                msgId=[msgIdPart1,'CondRelBoundOutcome','Justified',msgIdPart3];
            else
                msgId=[msgIdPart1,'RelBoundOutcome','Justified',msgIdPart3];
            end
            desc=getString(message(msgId,args{:}));
        end
    end


    function out=generatePrettyName(ssid,valueDesc)

        try
            modelObject=SlCov.FilterEditor.getObject(ssid);
        catch
            modelObject=[];
        end

        if~isempty(modelObject)
            [~,out]=strtok(modelObject.getFullName,'/');
            out=regexprep(out(2:end),'\n',' ');
        else
            out=valueDesc;
        end
