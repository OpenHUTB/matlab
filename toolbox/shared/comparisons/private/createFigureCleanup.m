function figureCleanup=createFigureCleanup()




    beforeFigures=findall(groot,'Type','figure');

    figureCleanup=onCleanup(...
    @()closeNewFigures(beforeFigures)...
    );

    function closeNewFigures(beforeFigures)
        afterFigures=findall(groot,'Type','figure');
        figs=setdiff(afterFigures,beforeFigures);
        close(figs);
    end

end
