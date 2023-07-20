function status=isHTMLViewer()






    isJSDorMO=matlab.desktop.editor.internal.useJavaScriptBackEnd;
    forceHTMLViewer=strcmp(getenv('HTML_VIEWER'),'true')||strcmp(getenv('HTML_VIEWER'),'1');




    status=isJSDorMO||forceHTMLViewer;
end