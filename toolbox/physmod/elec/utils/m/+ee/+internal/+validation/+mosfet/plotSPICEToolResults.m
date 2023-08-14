function[outputStruct,legends,handle]=plotSPICEToolResults(subcircuitName,SPICETool,voltages,currents,time,test,structArrayIndex,nodes,qissValid,qossValid)











































    if(SPICETool=="LTspice")
        outputStruct.SPICEplots(structArrayIndex)=0;
    end
    if(SPICETool=="SIMetrix")
        outputStruct.SIMetrixplots(structArrayIndex)=0;
    end
    legends=string.empty;
    handle=struct.empty;
    if strncmpi(test(structArrayIndex).name,"qiss",4)&&(qissValid==0)
        return
    end
    if strncmpi(test(structArrayIndex).name,"qoss",4)&&(qossValid==0)
        return
    end
    handle=figure("Name",strcat(subcircuitName,"_",test(structArrayIndex).name),"NumberTitle","off");
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
                    if(stepValueIndex==1)
                        subplot(2,2,3);
                        plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),voltages{stepValueIndex}(nodeIndex,:),"-");
                        hold on;
                        plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),voltages{stepValueIndex}(nodeIndex+1,:),"-");
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
                    plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-currents{stepValueIndex}(nodeIndex,:),"-");
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel(getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Case_Heat_Flow")));

                    if(SPICETool=="LTspice")
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex)=(strcat("SPICE V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex)=(strcat("SPICE V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                    end
                    if(SPICETool=="SIMetrix")
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex)=(strcat("SIMetrix V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex)=(strcat("SIMetrix V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                    end
                    legend(legends,"Location","southwest");
                    hold on;
                elseif(nodeIndex==1)
                    subplot(2,2,nodeIndex);
                    plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-currents{stepValueIndex}(nodeIndex,:),"-");
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_D (A)");
                    if(SPICETool=="LTspice")
                        outputStruct.SPICEplots(structArrayIndex)=outputStruct.SPICEplots(structArrayIndex)+1;
                    end
                    if(SPICETool=="SIMetrix")
                        outputStruct.SIMetrixplots(structArrayIndex)=outputStruct.SIMetrixplots(structArrayIndex)+1;
                    end
                    hold on;
                elseif(nodeIndex==2)
                    subplot(2,2,nodeIndex);
                    plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-currents{stepValueIndex}(nodeIndex,:),"-");
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_G (A)");
                    hold on;
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
                    if(stepValueIndex==1)
                        subplot(2,2,3);
                        plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),voltages{stepValueIndex}(nodeIndex,:),"-");
                        hold on;
                        plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),voltages{stepValueIndex}(nodeIndex+1,:),"-");
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
                    plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-currents{stepValueIndex}(nodeIndex,:),"-");
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel(getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Case_Heat_Flow")));

                    if(SPICETool=="LTspice")
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex)=(strcat("SPICE V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex)=(strcat("SPICE V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                    end
                    if(SPICETool=="SIMetrix")
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex)=(strcat("SIMetrix V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex)=(strcat("SIMetrix V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                    end
                    legend(legends,"Location","southwest");
                    hold on;
                elseif(nodeIndex==1)
                    subplot(2,2,nodeIndex);
                    plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-currents{stepValueIndex}(nodeIndex,:),"-");
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_D (A)");
                    if(SPICETool=="LTspice")
                        outputStruct.SPICEplots(structArrayIndex)=outputStruct.SPICEplots(structArrayIndex)+1;
                    end
                    if(SPICETool=="SIMetrix")
                        outputStruct.SIMetrixplots(structArrayIndex)=outputStruct.SIMetrixplots(structArrayIndex)+1;
                    end
                    hold on;
                elseif(nodeIndex==2)
                    subplot(2,2,nodeIndex);
                    plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-currents{stepValueIndex}(nodeIndex,:),"-");
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_G (A)");
                    hold on;
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
                    plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-currents{stepValueIndex}(nodeIndex,:),"-");
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_D (A)");

                    if(SPICETool=="LTspice")
                        outputStruct.SPICEplots(structArrayIndex)=outputStruct.SPICEplots(structArrayIndex)+1;
                    end
                    if(SPICETool=="SIMetrix")
                        outputStruct.SIMetrixplots(structArrayIndex)=outputStruct.SIMetrixplots(structArrayIndex)+1;
                    end
                    hold on;
                end
                if(nodeIndex==2)
                    subplot(1,2,nodeIndex);
                    plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-currents{stepValueIndex}(nodeIndex,:),"-");
                    if(test(structArrayIndex).sweepNodes==2)
                        xlabel("V_{GS} (V)");
                    end
                    if(test(structArrayIndex).sweepNodes==1)
                        xlabel("V_{DS} (V)");
                    end
                    ylabel("I_G (A)");
                    hold on;
                    if(SPICETool=="LTspice")
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex)=(strcat("SPICE V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex)=(strcat("SPICE V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                    end
                    if(SPICETool=="SIMetrix")
                        if(test(structArrayIndex).stepNodes==2)
                            legends(stepValueIndex)=(strcat("SIMetrix V_{GS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                        if(test(structArrayIndex).stepNodes==1)
                            legends(stepValueIndex)=(strcat("SIMetrix V_{DS}= ",num2str(test(structArrayIndex).stepValues(stepValueIndex)),"V"));
                        end
                    end
                    legend(legends,"Location","southwest");
                    hold on;
                end
            end
        elseif(test(structArrayIndex).name=="breakdownt5")||(test(structArrayIndex).name=="breakdownt3")||(test(structArrayIndex).name=="breakdownt4")||(test(structArrayIndex).name=="breakdownt6")
            sgtitle([char(subcircuitName),': ',getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Breakdown"))],"Interpreter","none");
            plot(voltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-currents{stepValueIndex}(1,:),"-");
            xlabel("V_{DS} (V)");
            ylabel("I_D (A)");
            if(SPICETool=="LTspice")
                outputStruct.SPICEplots(structArrayIndex)=outputStruct.SPICEplots(structArrayIndex)+1;
                legends(stepValueIndex)=("SPICE ");
            end
            if(SPICETool=="SIMetrix")
                outputStruct.SIMetrixplots(structArrayIndex)=outputStruct.SIMetrixplots(structArrayIndex)+1;
                legends(stepValueIndex)=("SIMetrix ");
            end
            legend(legends,"Location","southwest");
            hold on;
        elseif(test(structArrayIndex).name=="qosst5")||(test(structArrayIndex).name=="qosst3")||(test(structArrayIndex).name=="qosst6")||(test(structArrayIndex).name=="qosst4")
            sgtitle([char(subcircuitName),': QOSS'],"Interpreter","none");
            plot(time{stepValueIndex},voltages{stepValueIndex}(1,:),"-");
            xlabel(getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Time")),"Interpreter","none");
            ylabel("V_{DS} (V)");
            if(SPICETool=="LTspice")
                outputStruct.SPICEplots(structArrayIndex)=outputStruct.SPICEplots(structArrayIndex)+1;
                xlim([0,time{stepValueIndex}(end)])
                hold on;
                legends(stepValueIndex)=("SPICE ");
            end
            if(SPICETool=="SIMetrix")
                outputStruct.SIMetrixplots(structArrayIndex)=outputStruct.SIMetrixplots(structArrayIndex)+1;
                xlim([0,time{stepValueIndex}(end)])
                hold on;
                legends(stepValueIndex)=("SIMetrix ");
            end
            legend(legends,"Location","southeast");
            hold on;
        elseif(test(structArrayIndex).name=="qisst5")||(test(structArrayIndex).name=="qisst3")||(test(structArrayIndex).name=="qisst6")||(test(structArrayIndex).name=="qisst4")
            sgtitle([char(subcircuitName),': QISS'],"Interpreter","none");
            plot(time{stepValueIndex},voltages{stepValueIndex}(2,:),"-");
            xlabel(getString(message("physmod:ee:library:comments:utils:signal:plotconvertedMosfetValidation:Time")),"Interpreter","none");
            ylabel("V_{GS} (V)");
            if(SPICETool=="LTspice")
                outputStruct.SPICEplots(structArrayIndex)=outputStruct.SPICEplots(structArrayIndex)+1;
                hold on;
                legends(stepValueIndex)=("SPICE ");
            end
            if(SPICETool=="SIMetrix")
                outputStruct.SIMetrixplots(structArrayIndex)=outputStruct.SIMetrixplots(structArrayIndex)+1;
                hold on;
                legends(stepValueIndex)=("SIMetrix ");
            end
            legend(legends,"Location","southeast");
            hold on;
        end
    end
end