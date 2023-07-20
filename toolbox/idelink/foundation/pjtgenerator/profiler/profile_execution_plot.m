function[profData]=profile_execution_plot(profData,incompleteDataFlg)









    fig_objs=findobj('Type','Figure','Name','Profiling Time Diagram');
    if isempty(fig_objs)
        prof_plot=figure('Name','Profiling Time Diagram');
    else
        prof_plot=fig_objs(1);
    end

    clf(prof_plot);
    curr_axes=axes();
    set(prof_plot,'CurrentAxes',curr_axes);

    profData.recordedTaskIdx=i_task_plot(profData.taskActivity,...
    profData.taskIdList,profData.taskTs,incompleteDataFlg,curr_axes);
    i_task_ylabels(curr_axes,profData.taskNameList);
grid
    duration=num2str((profData.taskTs(end)-profData.taskTs(1)));
    title(['Plot of recorded profiling data over ',duration,' seconds'])
    xlabel('Time in seconds')

    figure(prof_plot);


    set(prof_plot,'Renderer','zbuffer');


    function i_task_ylabels(curr_axes,taskNameList)
        nLabels=2*length(taskNameList);
        [labels{1:nLabels}]=deal(' ');
        [labels{1:2:(2*length(taskNameList))}]=deal(taskNameList{:});
        set(curr_axes,'ytick',(1:0.5:length(taskNameList))+0.5);
        set(curr_axes,'yticklabel',char(labels));
        set(curr_axes,'TickLength',[0,0]);
        set(curr_axes,'ylim',[0.9,(length(taskNameList)+1)]);

        function recordedTaskIdx=i_task_plot(taskActivity,taskIdList,...
            taskTs,incompleteDataFlg,curr_axes)

            recordedTaskIdx=[];

            for i=1:length(taskIdList)
                [xExecData,yExecData,xPreemptData,yPreemptData]=...
                i_get_patch_data(taskActivity(:,i),taskTs,incompleteDataFlg);


                if((~isempty(xExecData))&&(~isempty(yExecData)))

                    recordedTaskIdx((length(recordedTaskIdx)+1))=i;%#ok<AGROW>
                end

                execution_colour=[1,0.3,0.3];
                preemtion_colour=[1,0.85,0.85];
                h=patch(xExecData,yExecData+i,execution_colour);
                set(h,'EdgeColor',execution_colour);
                set(h,'FaceColor',execution_colour);

                h=patch(xPreemptData,yPreemptData+i,preemtion_colour);
                set(h,'EdgeColor','none');
                set(h,'FaceColor',preemtion_colour);



                xStart=i_get_task_start_data(taskActivity(:,i),taskTs);
                h=line(xStart,ones(size(xStart))*i+0.05);
                set(h,'marker','^');
                set(h,'linestyle','none');

            end


            set(curr_axes,'YLim',get(curr_axes,'YLim')+[-0.1,0.1]);


            function[xExecData,yExecData,xPreemptData,yPreemptData]...
                =i_get_patch_data(tActivity,taskTs,incompleteDataFlg)


                event_idx=find(tActivity(:)~='u');


                e_idx=find(tActivity(event_idx)=='e');




                appendIncompleteEventFlg=0;
                if~isempty(e_idx)

                    if e_idx(end)==length(event_idx)
                        if incompleteDataFlg==1


                            incomplete_activationT=taskTs(event_idx(e_idx(end)));
                            incomplete_stopT=1.25*taskTs(end);




                            appendIncompleteEventFlg=1;
                        end
                        e_idx=e_idx(1:end-1);
                    end
                end


                activationT=taskTs(event_idx(e_idx));
                stopT=taskTs(event_idx(e_idx+1));


                if appendIncompleteEventFlg==1
                    activationT=[activationT;incomplete_activationT];
                    stopT=[stopT;incomplete_stopT];
                end


                xExecData=[activationT,stopT,stopT,activationT]';
                yExecData=diag([0.1;0.1;0.9;0.9])*ones(4,length(activationT));



                preempted_idx=find(tActivity(event_idx)=='p');

                if~isempty(preempted_idx)
                    if preempted_idx(end)==length(event_idx)
                        preempted_idx=preempted_idx(1:end-1);
                    end

                    activationT=taskTs(event_idx(preempted_idx));
                    stopT=taskTs(event_idx(preempted_idx+1));

                    xPreemptData=[activationT,stopT,stopT,activationT]';
                    yPreemptData=diag([0.1;0.1;0.9;0.9])*ones(4,length(activationT));
                else
                    xPreemptData=[];
                    yPreemptData=[];
                end


                function startT=i_get_task_start_data(tActivity,taskTs)


                    s_idx=2;
                    event_idx=s_idx:length(tActivity)-1;
                    e_idx=find(tActivity(event_idx)=='e')+(s_idx-1);


                    start_idx=e_idx(find(tActivity(e_idx-1)=='i'));


                    startT=taskTs(start_idx);

