function result=feature_SimulinkTestObserver()


    result=isObserverFeaturedOn()&&isObserverToolStripFeaturedOn();

end

function result=isObserverFeaturedOn()

    result=slfeature('SimHarnessObserver')>0;

end

function result=isObserverToolStripFeaturedOn()

    result=slfeature('ObserverToolStrip')>0;

end
