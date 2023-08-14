function yesno=hasData(ddPath)

    ddPath=convertStringsToChars(ddPath);

    yesno=~isempty(slreq.data.ReqData.getInstance.getLinkSet(ddPath));
end
