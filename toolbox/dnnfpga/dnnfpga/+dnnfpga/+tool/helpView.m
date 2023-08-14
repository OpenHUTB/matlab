function docRoot=helpView(anchorID,spID)

    if nargin<2
        spID='';
    end

    docRoot=dnnfpga.tool.getDocRoot(spID);
    docMap=fullfile(docRoot,'helptargets.map');

    try
        helpview(docMap,anchorID);
    catch
        error(message('dnnfpga:workflow:NoHelpPage',anchorID));
    end
end