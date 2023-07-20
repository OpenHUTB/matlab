function SwitchedReluctanceMotorPlot(block,PlotCurves,MachineModel,SM)







    if strcmp(PlotCurves,'on')
figure
        switch MachineModel
        case 1
            plot(SM.IX,SM.psix(1:10:91,:))
grid
            title('Generic model - Magnetization characteristics')
        case 2
            plot(SM.II,SM.flux(1:10:91,:))
grid
            title('Specific model - Magnetization characteristics')
        end
        xlabel('Current , A')
        ylabel('Flux linkage , Wb')
        set_param(block,'PlotCurves','off');
    end
