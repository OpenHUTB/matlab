function[outputStruct]=plotSimscapeResults(subcircuitName,SimscapeVoltages,SimscapeCurrents,SimscapeTime,test,structArrayIndex,nodes,Vt,Vds,plotWithSPICE,qissValid,qossValid,legends,handle)
















































    outputStruct.Simscapeplots(structArrayIndex)=0;
    if strncmpi(test(structArrayIndex).name,"qiss",4)&&(qissValid==0)
        return
    end
    if strncmpi(test(structArrayIndex).name,"qoss",4)&&(qossValid==0)
        return
    end
    if(plotWithSPICE==1)
        figure(handle);
    elseif(plotWithSPICE==0)
        figure("Name",strcat(subcircuitName,"_",test(structArrayIndex).name),"NumberTitle","off");
    end
    for stepValueIndex=1:max([1,length(test(structArrayIndex).stepValues)])
        if(test(structArrayIndex).name=="idvgst5tj27")||(test(structArrayIndex).name=="idvgst5tj75")||(test(structArrayIndex).name=="idvdst5")
            for nodeIndex=1:length(nodes)
                if(test(structArrayIndex).name=="idvgst5tj27")||(test(structArrayIndex).name=="idvgst5tj75")
                    sgtitle([char(subcircuitName),': ',getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Gate_Sweep"))],"Interpreter","none");
                end
                if(test(structArrayIndex).name=="idvdst5")
                    sgtitle([char(subcircuitName),': ',getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Drain_Sweep"))],"Interpreter","none");
                end
                if(nodeIndex==4)
                    if(stepValueIndex==1)&&(plotWithSPICE==0)
                        subplot(2,2,3);
                        plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),SimscapeVoltages{stepValueIndex}(nodeIndex,:),"--");
                        hold on;
                        plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),SimscapeVoltages{stepValueIndex}(nodeIndex+1,:),"--");
                        hold on;
                        if(test(structArrayIndex).sweepNodes==2)
                            xlabel("V_{GS} (V)");
                        end
                        if(test(structArrayIndex).sweepNodes==1)
                            xlabel("V_{DS} (V)");
                        end
                        ylabel(getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Temperature")));
                        legen(1)=("Junction Temperature");%#ok<*AGROW>
                        legen(2)=("Case Temperature");
                        legend(legen);
                    end
                elseif(nodeIndex==5)
                    subplot(2,2,4);
                    plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SimscapeCurrents{stepValueIndex}(nodeIndex,:),"--");
                    hold on;
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel(getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Case_Heat_Flow")));
                    if(plotWithSPICE==0)
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex)=(strcat("Simscape V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex)=(strcat("Simscape V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        legend(legends,"Location","southwest");
                    elseif(plotWithSPICE==1)
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex+length(test(structArrayIndex).stepValues))=(strcat("Simscape V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex+length(test(structArrayIndex).stepValues))=(strcat("Simscape V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        legend(legends);
                    end
                elseif(nodeIndex==1)
                    subplot(2,2,nodeIndex);
                    if ismember(nodeIndex,[test(structArrayIndex).dcNodes,test(structArrayIndex).stepNodes,test(structArrayIndex).sweepNodes])
                        plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SimscapeCurrents{stepValueIndex}(nodeIndex,:),"--");
                        outputStruct.Simscapeplots(structArrayIndex)=outputStruct.Simscapeplots(structArrayIndex)+1;
                        hold on;
                    end
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_D (A)");
                elseif(nodeIndex==2)
                    subplot(2,2,nodeIndex);
                    if ismember(nodeIndex,[test(structArrayIndex).dcNodes,test(structArrayIndex).stepNodes,test(structArrayIndex).sweepNodes])
                        plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SimscapeCurrents{stepValueIndex}(nodeIndex,:),"--");
                        hold on;
                    end
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_G (A)");
                end
            end
        elseif(test(structArrayIndex).name=="idvgst6tj27")||(test(structArrayIndex).name=="idvgst6tj75")||(test(structArrayIndex).name=="idvdst6")
            for nodeIndex=1:length(nodes)
                if(test(structArrayIndex).name=="idvgst6tj27")||(test(structArrayIndex).name=="idvgst6tj75")
                    sgtitle([char(subcircuitName),': ',getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Gate_Sweep"))],"Interpreter","none");
                end
                if(test(structArrayIndex).name=="idvdst6")
                    sgtitle([char(subcircuitName),': ',getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Drain_Sweep"))],"Interpreter","none");
                end
                if(nodeIndex==5)
                    if(stepValueIndex==1)&&(plotWithSPICE==0)
                        subplot(2,2,3);
                        plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),SimscapeVoltages{stepValueIndex}(nodeIndex,:),"--");
                        hold on;
                        plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),SimscapeVoltages{stepValueIndex}(nodeIndex+1,:),"--");
                        hold on;
                        if(test(structArrayIndex).sweepNodes==2)
                            xlabel("V_{GS} (V)");
                        end
                        if(test(structArrayIndex).sweepNodes==1)
                            xlabel("V_{DS} (V)");
                        end
                        ylabel(getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Temperature")));
                        legen(1)=("Junction Temperature");%#ok<*AGROW>
                        legen(2)=("Case Temperature");
                        legend(legen);
                    end
                elseif(nodeIndex==6)
                    subplot(2,2,4);
                    plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SimscapeCurrents{stepValueIndex}(nodeIndex,:),"--");
                    hold on;
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel(getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Case_Heat_Flow")));
                    if(plotWithSPICE==0)
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex)=(strcat("Simscape V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex)=(strcat("Simscape V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        legend(legends,"Location","southwest");
                    elseif(plotWithSPICE==1)
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex+length(test(structArrayIndex).stepValues))=(strcat("Simscape V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex+length(test(structArrayIndex).stepValues))=(strcat("Simscape V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        legend(legends);
                    end
                elseif(nodeIndex==1)
                    subplot(2,2,nodeIndex);
                    if ismember(nodeIndex,[test(structArrayIndex).dcNodes,test(structArrayIndex).stepNodes,test(structArrayIndex).sweepNodes])
                        plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SimscapeCurrents{stepValueIndex}(nodeIndex,:),"--");
                        outputStruct.Simscapeplots(structArrayIndex)=outputStruct.Simscapeplots(structArrayIndex)+1;
                        hold on;
                    end
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_D (A)");
                elseif(nodeIndex==2)
                    subplot(2,2,nodeIndex);
                    if ismember(nodeIndex,[test(structArrayIndex).dcNodes,test(structArrayIndex).stepNodes,test(structArrayIndex).sweepNodes])
                        plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SimscapeCurrents{stepValueIndex}(nodeIndex,:),"--");
                        hold on;
                    end
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_G (A)");
                end
            end
        elseif(test(structArrayIndex).name=="idvgst3")||(test(structArrayIndex).name=="idvdst3")||(test(structArrayIndex).name=="idvgst4")||(test(structArrayIndex).name=="idvdst4")
            for nodeIndex=1:length(nodes)
                if(test(structArrayIndex).name=="idvgst3")||(test(structArrayIndex).name=="idvgst4")
                    sgtitle([char(subcircuitName),': ',getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Gate_Sweep"))],"Interpreter","none");
                end
                if(test(structArrayIndex).name=="idvdst3")||(test(structArrayIndex).name=="idvdst4")
                    sgtitle([char(subcircuitName),': ',getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Drain_Sweep"))],"Interpreter","none");
                end
                if(nodeIndex==1)
                    subplot(1,2,nodeIndex);
                    if ismember(nodeIndex,[test(structArrayIndex).dcNodes,test(structArrayIndex).stepNodes,test(structArrayIndex).sweepNodes])
                        plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SimscapeCurrents{stepValueIndex}(nodeIndex,:),"--");
                        outputStruct.Simscapeplots(structArrayIndex)=outputStruct.Simscapeplots(structArrayIndex)+1;
                        hold on;
                    end
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_D (A)");
                end
                if(nodeIndex==2)
                    subplot(1,2,nodeIndex);
                    if ismember(nodeIndex,[test(structArrayIndex).dcNodes,test(structArrayIndex).stepNodes,test(structArrayIndex).sweepNodes])
                        plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SimscapeCurrents{stepValueIndex}(nodeIndex,:),"--");
                        hold on;
                    end
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_G (A)");
                    if(plotWithSPICE==0)
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex)=(strcat("Simscape V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex)=(strcat("Simscape V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        legend(legends,"Location","southwest");
                    elseif(plotWithSPICE==1)
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex+length(test(structArrayIndex).stepValues))=(strcat("Simscape V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex+length(test(structArrayIndex).stepValues))=(strcat("Simscape V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        legend(legends);
                    end
                end
            end
        elseif(test(structArrayIndex).name=="breakdownt5")||(test(structArrayIndex).name=="breakdownt3")||(test(structArrayIndex).name=="breakdownt4")||(test(structArrayIndex).name=="breakdownt6")
            sgtitle([char(subcircuitName),': ',getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Breakdown"))],"Interpreter","none");
            plot(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SimscapeCurrents{stepValueIndex}(1,:),"--");
            outputStruct.Simscapeplots(structArrayIndex)=outputStruct.Simscapeplots(structArrayIndex)+1;
            hold on;
            xlabel("V_{DS} (V)");
            ylabel("I_D (A)");
            if(plotWithSPICE==0)
                legends(stepValueIndex)=("Simscape ");
                legend(legends,"Location","southwest");
            elseif(plotWithSPICE==1)
                legends(stepValueIndex+1)=("Simscape ");
                legend(legends);
            end
        elseif(test(structArrayIndex).name=="qosst5")||(test(structArrayIndex).name=="qosst3")||(test(structArrayIndex).name=="qosst6")||(test(structArrayIndex).name=="qosst4")
            sgtitle([char(subcircuitName),': QOSS'],"Interpreter","none");
            plot(SimscapeTime{stepValueIndex},SimscapeVoltages{stepValueIndex}(1,:),"--");
            outputStruct.Simscapeplots(structArrayIndex)=outputStruct.Simscapeplots(structArrayIndex)+1;
            xlabel(getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Time")),"Interpreter","none");
            ylabel("V_{DS} (V)");
            xlim([0,SimscapeTime{stepValueIndex}(end)])
            hold on;
            if(plotWithSPICE==0)
                legends(stepValueIndex)=("Simscape ");
                legend(legends,"Location","southeast");
            elseif(plotWithSPICE==1)
                legends(stepValueIndex+1)=("Simscape ");
                legend(legends);
            end
            txt={strcat("I_D=",num2str(-test(structArrayIndex).sweepValues(2)),"A")};
            xaxis=get(gca,"XLim");
            yaxis=get(gca,"YLim");
            text(0.4*xaxis(2),(yaxis(1)+yaxis(2))/2,txt);
            if((SimscapeVoltages{stepValueIndex}(1,end))>Vds)
                pm_warning("physmod:ee:SPICE2sscvalidation:CossIsHighWarning");
            end
            if((SimscapeVoltages{stepValueIndex}(1,end))<Vds/2)
                pm_warning("physmod:ee:SPICE2sscvalidation:CossIsLowWarning");
            end
        elseif((test(structArrayIndex).name=="qisst5")||(test(structArrayIndex).name=="qisst3")||(test(structArrayIndex).name=="qisst6")||(test(structArrayIndex).name=="qisst4"))
            sgtitle([char(subcircuitName),': QISS'],"Interpreter","none");
            plot(SimscapeTime{stepValueIndex},SimscapeVoltages{stepValueIndex}(2,:),"--");
            outputStruct.Simscapeplots(structArrayIndex)=outputStruct.Simscapeplots(structArrayIndex)+1;
            xlabel(getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Time")),"Interpreter","none");
            ylabel("V_{GS} (V)");
            hold on;
            if(plotWithSPICE==0)
                legends(stepValueIndex)=("Simscape ");
                legend(legends,"Location","southeast");
            elseif(plotWithSPICE==1)
                legends(stepValueIndex+1)=("Simscape ");
                legend(legends);
            end
            txt={strcat("I_G=",num2str(-test(structArrayIndex).sweepValues(2)),"A")};
            xaxis=get(gca,"XLim");
            yaxis=get(gca,"YLim");
            text(0.4*xaxis(2),(yaxis(1)+yaxis(2))/2,txt);
            if((SimscapeVoltages{stepValueIndex}(2,end))<Vt)
                pm_warning("physmod:ee:SPICE2sscvalidation:CissIsLowWarning");
            end
        end
    end
    hold off;
end