function plotHandle=plotOneFigure(sig,sigName)





    ts=export(sig);
    clr=sig.lineColor;
    ls=sig.lineDashed;
    opts={'Color',clr,'LineStyle',ls};
    if length(ts.Time)<2
        opts=[{'o','MarkerFaceColor',clr},opts];
    end
    if(~isempty(ts.Time)&&~isempty(ts.Data))


        isEventSignal=sltest.testmanager.ReportUtility.isEventSignal(sig);
        if isEventSignal
            isVerifySignal=sltest.testmanager.ReportUtility.isVerifySignal(sig);
            if isVerifySignal
                plotHandle=sltest.testmanager.ReportUtility.plotOneVerifySignal(ts);
            else
                plotHandle=stem(ts.Time,ts.Data,opts{:});
            end
        else
            isComplex=~isreal(ts.Data);
            if isComplex
                plotHandle=plot(ts.Time,real(ts.Data(:)),ts.Time,imag(ts.Data(:)),opts{:});
            else
                plotHandle=plot(ts,opts{:});
            end
        end

        sltest.internal.TestResultReportBase.plotEnum(ts,plotHandle);
    end

    str=sigName;
    if(length(str)>50)
        str=[sigName(1:50),' ...'];
    end
    ylabel(str,'Interpreter','none');
    xlabel(getString(message('stm:ReportContent:Label_Time')));
end