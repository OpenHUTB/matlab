


function sdiPlot(signamep)



    runids=Simulink.sdi.getAllRunIDs;
    if~isempty(runids)
        runid=runids(end);
        mdlrun=Simulink.sdi.getRun(runid);

        ntoplot=numel(signamep);


        Simulink.sdi.clearPreferences;
        ntoplotcolumn=fix(ntoplot/8)+1;
        if ntoplotcolumn>8
            ntoplotcolumn=8;
        end
        if ntoplotcolumn==1
            ntoplotrow=ntoplot;
        else
            ntoplotrow=8;
        end
        Simulink.sdi.setSubPlotLayout(ntoplotrow,ntoplotcolumn);
        Simulink.sdi.clearAllSubPlots;


        for i=1:ntoplot
            row=mod(i-1,8)+1;
            col=ceil(i/8);

            try
                signameIndex=strfind(signamep{i},'.');
                signame=['<',signamep{i}(signameIndex(end)+1:end),'>'];
                sigid=getSignalIDsByName(mdlrun,signame);

                sigtoplot=Simulink.sdi.getSignal(sigid);
                if isempty(sigtoplot.Children)
                    plotOnSubPlot(sigtoplot,row,col,true);
                else
                    for j=1:numel(sigtoplot.Children)
                        plotOnSubPlot(sigtoplot.Children(j),row,col,true);
                    end
                end
            catch
                continue;
            end
        end


        Simulink.sdi.view

    else

        warndlg('No simulation results avaiable.','Run warning.');
    end
end
