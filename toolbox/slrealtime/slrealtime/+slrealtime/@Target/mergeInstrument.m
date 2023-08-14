function mergeInstrument(this,hInst)






    instList=[this.instrumentList;hInst];
    hInstCount=length(instList);

    if isempty(this.streamingAcquireList)


        acquireList=hInst.AcquireList.duplicate();



        map=cell(hInst.AcquireList.AcquireListModel.nAcquireGroups,hInst.AcquireList.AcquireListModel.MaxGroupLength);
        map(:)={-1};
        ref=-1*ones(hInst.AcquireList.AcquireListModel.nAcquireGroups,hInst.AcquireList.AcquireListModel.MaxGroupLength);



        for agi=1:hInst.AcquireList.AcquireListModel.nAcquireGroups
            for si=1:hInst.AcquireList.AcquireListModel.AcquireGroups(agi).nSignals
                map{agi,si}=[1,agi,si];
                ref(agi,si)=1;
            end
        end
    else


        acquireList=this.streamingAcquireList;



        map=this.mapStreamingALToInstList;
        ref=this.streamingAcquireListRefrenceCount;



        for agi=1:hInst.AcquireList.AcquireListModel.nAcquireGroups
            for si=1:hInst.AcquireList.AcquireListModel.AcquireGroups(agi).nSignals
                xcpSignal=hInst.AcquireList.AcquireListModel.AcquireGroups(agi).xcpSignals(si);








                newSignalStruct=struct(...
                'blockpath',xcpSignal.SimulationDataBlockPath,...
                'portindex',xcpSignal.portNumber+1,...
                'signame','',...
                'statename','',...
                'decimation',hInst.AcquireList.AcquireListModel.AcquireGroups(agi).decimation);

                output=acquireList.AcquireListModel.getAcquireSignalIndex(newSignalStruct,'first',hInst.UUID);
                if output.signalindex==-1







                    signalStruct=hInst.AcquireList.AcquireListModel.AcquireGroups(agi).signalStructs(si);
                    xcpSignal=hInst.AcquireList.AcquireListModel.AcquireGroups(agi).xcpSignals(si);
                    output=acquireList.AcquireListModel.addSignalFromXcpSignalInfo(signalStruct,xcpSignal,newSignalStruct.decimation);
                    globagi=output.acquiregroupindex;
                    globsi=output.signalindex;



                    if hInst.AcquireList.AcquireListModel.AcquireGroups(agi).xcpSignals(si).attachMatlabObs
                        metadata=struct(...
                        'matlabObsFcn',hInst.AcquireList.AcquireListModel.AcquireGroups(agi).xcpSignals(si).matlabObsFcn,...
                        'matlabObsParam',num2str(globsi),...
                        'matlabObsCallbackGroup',uint32(globagi),...
                        'matlabObsFuncHandle',hInst.AcquireList.AcquireListModel.AcquireGroups(agi).xcpSignals(si).matlabObsFuncHandle,...
                        'matlabObsDropIfBusy',hInst.AcquireList.AcquireListModel.AcquireGroups(agi).xcpSignals(si).matlabObsDropIfBusy...
                        );
                        acquireList.AcquireListModel.AcquireGroups(globagi).xcpSignals(globsi).fillMATLABObserverInfo(metadata);
                    end



                    map{globagi,globsi}=[hInstCount,agi,si];
                    ref(globagi,globsi)=1;
                else



                    globagi=output.acquiregroupindex;
                    globsi=output.signalindex;



                    map{globagi,globsi}=[map{globagi,globsi};[hInstCount,agi,si]];
                    ref(globagi,globsi)=ref(globagi,globsi)+1;
                end
            end
        end
    end

    this.instrumentList=instList;
    this.streamingAcquireList=acquireList;
    this.mapStreamingALToInstList=map;
    this.streamingAcquireListRefrenceCount=ref;
end