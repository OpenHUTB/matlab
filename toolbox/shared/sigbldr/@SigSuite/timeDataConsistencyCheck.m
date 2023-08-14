





function timeDataConsistencyCheck(time,data)

    if iscell(data)
        [sigCnt,grpCnt]=size(data);

        if iscell(time)
            if isequal(size(time),size(data))
                for i=1:sigCnt
                    for j=1:grpCnt
                        msg=timeDataPairCheck(time{i,j},data{i,j});
                        if~isempty(msg)
                            DAStudio.error('Sigbldr:sigsuite:GroupTimeDataInconsistentArgument',i,j,i,j,msg);
                        end
                    end
                end
            elseif length(time)==grpCnt
                for i=1:sigCnt
                    for j=1:grpCnt
                        msg=timeDataPairCheck(time{j},data{i,j});
                        if~isempty(msg)
                            DAStudio.error('Sigbldr:sigsuite:GroupTimeDataInconsistentArgumentOneIndex',j,i,j,msg);
                        end
                    end
                end
            elseif length(time)==1
                for i=1:sigCnt
                    for j=1:grpCnt
                        msg=timeDataPairCheck(time{1},data{i,j});
                        if~isempty(msg)
                            DAStudio.error('Sigbldr:sigsuite:GroupTimeDataInconsistentArgumentNoIndex',i,j,msg);
                        end
                    end
                end
            else
                DAStudio.error('Sigbldr:sigsuite:GroupTimeDataMismatchGeneral');
            end

        else
            for i=1:sigCnt
                for j=1:grpCnt
                    msg=timeDataPairCheck(time,data{i,j});
                    if~isempty(msg)
                        DAStudio.error('Sigbldr:sigsuite:GroupTimeDataInconsistentArgumentNoIndex',i,j,msg);
                    end
                end
            end
        end
    else
        if iscell(time)
            DAStudio.error('Sigbldr:sigsuite:GroupTimeDataFormatMatch');
        end
        [msg,id]=timeDataPairCheck(time,data);
        if~isempty(msg)
            ME=MException(id,msg);
            throw(ME);
        end
    end


    function[msg,id]=timeDataPairCheck(time,data)
        msg='';
        id=[];
        if~isreal(time)
            [msg,id]=DAStudio.message('Sigbldr:sigsuite:TimeDataRealValue','TIME');
            return;
        end

        if any(~isfinite(time))
            [msg,id]=DAStudio.message('Sigbldr:sigsuite:TimeDataFiniteNumericValue','TIME');
            return;
        end

        if~isreal(data)
            [msg,id]=DAStudio.message('Sigbldr:sigsuite:TimeDataRealValue','DATA');
            return;
        end

        if any(~isfinite(data))
            [msg,id]=DAStudio.message('Sigbldr:sigsuite:TimeDataFiniteNumericValue','DATA');
            return;
        end

        if any(diff(time)<0)
            [msg,id]=DAStudio.message('Sigbldr:sigsuite:TimeMonotonicallyIncreasing');
            return;
        end

        if length(time(:))~=length(data(:))
            [msg,id]=DAStudio.message('Sigbldr:sigsuite:GroupTimeDataMismatch',...
            length(time(:)),length(data(:)));
            return;
        end
    end
end