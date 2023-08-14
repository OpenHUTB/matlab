function newVal=convertSampleTimeInfo(val)




    newVal=[];
    errmsg='';

    if isempty(val)
        return;
    end

    try
        if isstruct(val)
            newVal='';
            for i=1:length(val)
                newVal=sprintf('%s[%s,%s,%d];',newVal,val(i).SampleTime,...
                val(i).Offset,val(i).Priority);
            end
            newVal=['[',newVal,']'];

        elseif isstr(val)

            i=1;


            val=deblank(val);


            while~isempty(val)&&isequal(val(end),';')
                val(end)=' ';
                val=deblank(val);
            end


            if~isequal(val(end),']')||length(val)<2
                errmsg=DAStudio.message('RTW:configSet:convertSampleTimeInfoMsgInvalidArray');
                error(errmsg);
            end
            val=val(1:end-1);


            val=deblank(val);


            val=fliplr(deblank(fliplr(val)));

            if~isequal(val(1),'[')||length(val)<2
                errmsg=DAStudio.message('RTW:configSet:convertSampleTimeInfoMsgInvalidArray');
                error(errmsg);
            end

            val=val(2:end);
            i=0;

            while~isempty(val)
                i=i+1;
                [T,R]=strtok(val,';');


                if isempty(T)
                    errmsg=DAStudio.message('RTW:configSet:convertSampleTimeInfoMsgExtraSemiColon');
                    error(errmsg);
                end


                T=fliplr(deblank(fliplr(T)));


                if isequal(T(1),'[')
                    if length(T)<2
                        errmsg=DAStudio.message('RTW:configSet:convertSampleTimeInfoMsgInvalidArray');
                        error('Simulink:ConfigSet:SampleTimeProperty',errmsg);
                    end
                    T=T(2:end);
                end

                T=strrep(T,',',' ');

                errmsg=DAStudio.message('RTW:configSet:convertSampleTimeInfoMsgNotNX3Array');

                [TT,TR]=strtok(T,' ');
                if isempty(TT)||isempty(TR)
                    error(errmsg);
                end
                newVal(i).SampleTime=TT;

                [TT,TR]=strtok(TR,' ');
                if isempty(TT)||isempty(TR)
                    error(errmsg);
                end
                newVal(i).Offset=TT;

                TR=strrep(TR,']',' ');
                [TT,TR]=strtok(TR,' ');
                TR=strtok(TR,' ');
                if isempty(TT)||~isempty(TR)
                    error(errmsg);
                end
                iTT=sscanf(TT,'%d');
                if isempty(iTT)||~isequal(sprintf('%d',iTT),TT)
                    errmsg=DAStudio.message('RTW:configSet:convertSampleTimeInfoMsgPriorityInteger');
                    error(errmsg);
                end
                newVal(i).Priority=iTT;

                if length(R)>2
                    val=R(2:end);
                else
                    val='';
                end
            end

        else
            errmsg=DAStudio.message('RTW:configSet:convertSampleTimeInfoMsgUnknownInput');
            error(errmsg);
        end
    catch
        prevErr=lasterr;
        [stack,prevErr]=strtok(lasterr,sprintf('\n'));
        if isempty(prevErr)
            prevErr=lasterr;
        end
        errmsg=[DAStudio.message('RTW:configSet:IncorrectSampleTimeFormat'),sprintf('\n'),prevErr];
        error('Simulink:ConfigSet:SampleTimePropertyChecking',errmsg);
    end

