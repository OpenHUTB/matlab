function setBlockPriority(harnessH,sutH,setPriorityOnSUT,convSSH)

    DSWs=find_system(harnessH,'SearchDepth',1,'BlockType','DataStoreWrite');
    DSRs=find_system(harnessH,'SearchDepth',1,'BlockType','DataStoreRead');

    if isempty(DSWs)&&isempty(DSRs)
        return;
    end

    priority=0;


    for idx=1:length(DSWs)
        set_param(DSWs(idx),'Priority',num2str(priority));
        priority=priority+1;
    end

    if sutH>0
        lineHs=get_param(sutH,'LineHandles');
        if isempty(lineHs.Trigger)&&setPriorityOnSUT
            set_param(sutH,'Priority',num2str(priority));
            priority=priority+1;
        else
            if convSSH>0

                fcnGenBlks=find_system(convSSH,'SearchDepth',1,'BlockType','S-Function','MaskType','Function-Call Generator');
                for i=1:length(fcnGenBlks)
                    setPriorityOnSUT=false;
                    set_param(fcnGenBlks(i),'Priority',num2str(priority));
                    priority=priority+1;
                end


                fcnGenBlks=find_system(convSSH,'SearchDepth',1,'BlockType','SubSystem','Tag','_SLT_FCN_CALL_GEN_BLK_');
                for i=1:length(fcnGenBlks)
                    setPriorityOnSUT=false;
                    set_param(fcnGenBlks(i),'Priority',num2str(priority));
                    priority=priority+1;
                end


                fcnGenBlks=find_system(convSSH,'SearchDepth',1,'BlockType','SubSystem','Tag','_SLT_FCN_CALL_GEN_SS_');
                for i=1:length(fcnGenBlks)
                    setPriorityOnSUT=false;
                    set_param(fcnGenBlks(i),'TreatAsAtomicUnit','on');
                    set_param(fcnGenBlks(i),'Priority',num2str(priority));
                    priority=priority+1;
                end
            end
            if setPriorityOnSUT
                set_param(sutH,'Priority',num2str(priority));
                priority=priority+1;
            end
        end
    end


    for idx=1:length(DSRs)
        set_param(DSRs(idx),'Priority',num2str(priority));
        priority=priority+1;
    end

end
