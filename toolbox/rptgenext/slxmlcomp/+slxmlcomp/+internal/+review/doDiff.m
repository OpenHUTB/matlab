function jsonDiff=doDiff(filePath1,filePath2)

    import com.mathworks.comparisons.review.DoDiffAndReturnWaiter

    pollingInterval=0.05;

    waiter=DoDiffAndReturnWaiter(filePath1,filePath2);
    waiter.startComparison();

    while~waiter.isFinished()
        feature('qewait',-1);
        pause(pollingInterval);
    end

    jsonDiff=char(waiter.getComparisonResult());

end
