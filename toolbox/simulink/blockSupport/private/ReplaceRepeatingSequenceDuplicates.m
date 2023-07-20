function ReplaceRepeatingSequenceDuplicates(block,h)


    modelVersion=get_param(bdroot(block),'VersionLoaded');
    SLVersion_R2013b=8.2;
    if(modelVersion>=SLVersion_R2013b)
        return
    end


    if(isParamVariable(block,'rep_seq_t'))
        wks=slResolve(get_param(block,'rep_seq_t'),block,'context');
        if~isempty(regexp(wks,'[^/]/[^/]','ONCE'))
            return;
        end
    end




    t=double(slResolve(get_param(block,'rep_seq_t'),block));
    [~,first,~]=unique(t,'first');
    [~,last,~]=unique(t,'last');
    if isequal(first,last)
        return;
    end


    if askToReplace(h,block)

        old_t=double(slResolve(get_param(block,'rep_seq_t'),block));
        old_y=double(slResolve(get_param(block,'rep_seq_y'),block));
        [new_t_str,new_y_str]=parseRepeatingSequenceBlockDuplicates(old_t,old_y);

        tPrmValueStr=saveParsedData(h,block,'rep_seq_t',new_t_str);
        yPrmValueStr=saveParsedData(h,block,'rep_seq_y',new_y_str);

        funcSet1=uSafeSetParam(h,block,'rep_seq_t',tPrmValueStr,'rep_seq_y',yPrmValueStr);

        reasonStr=DAStudio.message('SimulinkBlocks:upgrade:RepeatingSequenceRemoveDuplicates');
        appendTransaction(h,block,reasonStr,{funcSet1});

    end

    function prmValueStr=saveParsedData(h,block,param,new_v_str)

        prmValueStr=new_v_str;

        if~doUpdate(h)
            return;
        end

        if isParamVariable(block,param)

            tName=get_param(block,param);
            fileGenCfg=Simulink.fileGenControl('getConfig');
            rootBDir=[fileGenCfg.CacheFolder,'/slprj/modeladvisor/'];
            newtName=[tName,'_slupdate_',datestr(now,'yymmddTHHMMFFF')];
            assignin('base',newtName,str2num(new_v_str));
            prmValueStr=newtName;
            fileName=[rootBDir,newtName,'.mat'];
            cmd=['save(''',fileName,''', ''',newtName,''')'];
            evalin('base',cmd);
            origStr=get_param(h.MyModel,'PreLoadFcn');
            newStr=sprintf('%s\n%s %s; \n',origStr,'addpath ',rootBDir);











            newStr=sprintf('%s\ntry',newStr);

            newStr=sprintf('%s\n  %s %s%s;',newStr,'load ',newtName,'.mat');

            newStr=sprintf('%s\ncatch ME\n',newStr);
            condStr='  if strcmp(ME.identifier, ''MATLAB:load:couldNotReadFile'')';

            newStr=sprintf('%s\n%s',newStr,condStr);

            blkName=[get_param(block,'Parent'),'/',get_param(block,'name')];

            returnChar=newline;

            modifiedBlkName=regexprep(blkName,returnChar,' ');

            msgStr=['msg = DAStudio.message(''SimulinkBlocks:upgrade:RepeatingSequenceRemoveDuplicatesLoadFileErr'',''',fileName,''',''',newtName,''',''',modifiedBlkName,''');'];

            newStr=sprintf('%s\n  %s',newStr,msgStr);

            errStr='errMsg = MException(''SimulinkBlocks:upgrade:RepeatingSequenceRemoveDuplicatesLoadFileErr'', msg);';

            newStr=sprintf('%s\n%s \n    throw(errMsg); \n  end \nend',newStr,errStr);

            set_param(h.MyModel,'PreLoadFcn',newStr);

            reasonStr=DAStudio.message('SimulinkBlocks:upgrade:RepeatingSequenceRemoveDuplicatesResult',modifiedBlkName,tName,newtName,fileName);
            disp(reasonStr);
        end



        function isvar=isParamVariable(block,param)

            try
                retVal=slResolve(get_param(block,param),block,'variable');
            catch %#ok<CTCH>
                retVal=[];
            end

            if isempty(retVal)
                isvar=false;
            else
                isvar=true;
            end




            function[X,Y]=parseRepeatingSequenceBlockDuplicates(rep_seq_t,rep_seq_y)

                lastidx=1;
                minVal=min(rep_seq_t);

                if minVal>0
                    minVal=0;
                end

                X='[';
                Y='[';
                for i=2:length(rep_seq_t)
                    if(rep_seq_t(i)==rep_seq_t(lastidx))
                        continue;
                    end
                    if(lastidx==1)
                        X=[X,' ',num2str(rep_seq_t(i-1))];%#ok<AGROW>
                        Y=[Y,' ',num2str(rep_seq_y(i-1))];%#ok<AGROW>
                    else
                        X=[X,' ',num2str(rep_seq_t(lastidx))];%#ok<AGROW>
                        Y=[Y,' ',num2str(rep_seq_y(lastidx))];%#ok<AGROW>
                        if(lastidx<i-1)
                            if(rep_seq_t(i-1)==0)
                                if minVal<0
                                    epsilon=['eps(',num2str(-minVal),')'];
                                else
                                    epsilon='eps(1)';
                                end
                            else
                                epsilon=['eps(',num2str(rep_seq_t(i-1)-minVal),')'];
                            end
                            X=[X,' ',[num2str(rep_seq_t(i-1)),'+',epsilon]];%#ok<AGROW>
                            offset_y=[num2str(((rep_seq_y(i)-rep_seq_y(i-1))/(rep_seq_t(i)-rep_seq_t(i-1)))),'*',epsilon];
                            Y=[Y,' ',[num2str(rep_seq_y(i-1)),'+',offset_y]];%#ok<AGROW>
                        end
                    end
                    lastidx=i;
                end

                X=[X,' ',num2str(rep_seq_t(lastidx)),']'];
                Y=[Y,' ',num2str(rep_seq_y(lastidx)),']'];
