function r=isRunning(this)%#ok<INUSD>





    if~isempty(iatbrowser.Browser().currentVideoinputObject)
        r=isrunning(iatbrowser.Browser().currentVideoinputObject);
    else
        r=false;
    end

end