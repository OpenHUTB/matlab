function varargout=plotLatestParameters(psObj)
























    for psIdx=1:numel(psObj)

        parObj(psIdx)=psObj(psIdx).Parameters;%#ok<AGROW>
        Names{psIdx}=psObj(psIdx).MetaData.Name;%#ok<AGROW>

    end



    h=parObj.plot(Names);



    if nargout
        varargout{1}=h;
    end