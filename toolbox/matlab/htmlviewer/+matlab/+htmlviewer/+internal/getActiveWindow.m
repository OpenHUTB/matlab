function window=getActiveWindow()






    if matlab.htmlviewer.internal.isHTMLViewer



        window=matlab.htmlviewer.internal.HTMLViewerManager.getInstance().getLastActiveViewer();
    else





        window=com.mathworks.mde.webbrowser.WebBrowser.getActiveBrowser;
    end
end