function varargout=plotting_generatePlots(modelName)



    localDataSet=ee.internal.mask.getSimscapeBlockDatasetFromModel(modelName);

    terminals=localDataSet.getTabulatedDataFromSymbol('term');
    referenceTerminal=localDataSet.getTabulatedDataFromSymbol('ref');

    if~isempty(localDataSet.characteristicData)
        numberOfPlots=length(localDataSet.characteristicData);
        plotsPerRow=ceil(sqrt(numberOfPlots));
        plotsPerColumn=ceil(numberOfPlots/plotsPerRow);
        figure(1);
        clf;
        h=cell(length(localDataSet.characteristicData),1);
        l=zeros(length(localDataSet.characteristicData),1);
        for ii=1:length(localDataSet.characteristicData)
            subplot(plotsPerColumn,plotsPerRow,ii);
            leg=cell(1,length(localDataSet.characteristicData(ii).curves));
            h{ii}=zeros(1,length(localDataSet.characteristicData(ii).curves));
            for jj=1:length(localDataSet.characteristicData(ii).curves)
                if jj==length(localDataSet.characteristicData(ii).curves)&&ii==length(localDataSet.characteristicData)
                    result=localDataSet.characteristicData(ii).curves{jj}.getData;
                else
                    result=localDataSet.characteristicData(ii).curves{jj}.getData('holdFastRestart');
                end
                if isa(localDataSet.characteristicData(ii).curves{jj},'simscapeTargetCurve')
                    h{ii}(jj)=plot(result.x,result.y,'--');
                else
                    h{ii}(jj)=plot(result.x,result.y,'-');
                end
                leg{jj}=ee.internal.mask.getCurveType(localDataSet.characteristicData(ii).curves{jj},true);
                hold on;
            end
            legendString=ee.internal.mask.convertLegendStringToUseTerminalNames(leg,terminals,referenceTerminal);
            l(ii)=legend(legendString,'Location','Best');
            hold off;
        end
    else
        warning(getString(message('physmod:ee:library:comments:utils:mask:plotting_generatePlots:warning_NeitherTargetNorSimulatedDataHasBeenConfigured')));
    end
    if nargout>=1
        varargout{1}=h;
        if nargout>=2
            varargout{2}=l;
        end
    end
end