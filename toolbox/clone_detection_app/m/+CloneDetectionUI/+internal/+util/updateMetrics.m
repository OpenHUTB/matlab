function metrics=updateMetrics(metrics,include,numBlk,isExact)


    if(isExact)
        if(include)
            metrics.overAllPotentialReuse=metrics.overAllPotentialReuse+numBlk;
            metrics.exactPotentialReuse=metrics.exactPotentialReuse+numBlk;
        else
            metrics.overAllPotentialReuse=metrics.overAllPotentialReuse-numBlk;
            metrics.exactPotentialReuse=metrics.exactPotentialReuse-numBlk;
        end
    else
        if(include)
            metrics.overAllPotentialReuse=metrics.overAllPotentialReuse+numBlk;
            metrics.similarPotentialReuse=metrics.similarPotentialReuse+numBlk;
        else
            metrics.overAllPotentialReuse=metrics.overAllPotentialReuse-numBlk;
            metrics.similarPotentialReuse=metrics.similarPotentialReuse-numBlk;
        end

    end


end

