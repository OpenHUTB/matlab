function signalLabelerImpl()


    if~signal.labeler.Instance.isSignalLabelerRunning()
        signal.labeler.Instance.open();
    else

        hApp=signal.labeler.Instance.getMainGUI;


        hApp.bringToFront;
    end
end