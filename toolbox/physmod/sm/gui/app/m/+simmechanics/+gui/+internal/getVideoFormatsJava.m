function formatInfo=getVideoFormatsJava()








    [formatNameArray,formatExtArray]=simmechanics.gui.internal.getVideoFormats();
    formatNames=strjoin(formatNameArray,',');
    formatExtensions=strjoin(formatExtArray,',');

    formatInfo=[formatNames,'%',formatExtensions];

end