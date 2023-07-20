function dataAvailableFromObserver(this,cbg,varargin)





    try


        instList=this.instrumentList;
        nInsts=length(instList);

        map=this.mapStreamingALToInstList;
        if isempty(map),return;end


        acquireSignalDatas=cell(nInsts,1);
        for iI=1:nInsts
            if instList(iI).AcquireList.AcquireListModel.nAcquireGroups==0
                asd=[];
            else
                asd(instList(iI).AcquireList.AcquireListModel.nAcquireGroups,instList(iI).AcquireList.AcquireListModel.MaxGroupLength)=struct('Time',[],'Data',[]);%#ok
            end
            acquireSignalDatas{iI}=asd;
            clear asd
        end


        for icbg=1:length(cbg)

            globalagi=double(cbg(icbg).groupNum);
            globalsi=str2double(cbg(icbg).cbParam);

            veclocalhIi=map{globalagi,globalsi}(:,1);
            veclocalagi=map{globalagi,globalsi}(:,2);
            veclocalsi=map{globalagi,globalsi}(:,3);

            for isig=1:length(veclocalhIi)
                localhIi=veclocalhIi(isig);
                localagi=veclocalagi(isig);
                localsi=veclocalsi(isig);

                if localhIi==-1
                    continue
                end

                if isempty(acquireSignalDatas{localhIi}(localagi,localsi).Time)

                    acquireSignalDatas{localhIi}(localagi,localsi).Time=cbg(icbg).time;
                    acquireSignalDatas{localhIi}(localagi,localsi).Data=cbg(icbg).data;
                else

                    acquireSignalDatas{localhIi}(localagi,localsi).Time=[acquireSignalDatas{localhIi}(localagi,localsi).Time;cbg(icbg).time];
                    acquireSignalDatas{localhIi}(localagi,localsi).Data=[acquireSignalDatas{localhIi}(localagi,localsi).Data;cbg(icbg).data];

                end

            end

        end


        for iI=1:nInsts
            hInst=instList(iI);

            hInst.dataAvailableFromObserverViaTarget(acquireSignalDatas{iI});
        end

    catch ME
        if~strcmp(ME.identifier,'MATLAB:badsubscript')






            rethrow(ME);
        end
    end
end
