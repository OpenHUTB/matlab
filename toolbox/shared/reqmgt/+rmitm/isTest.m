function yesno=isTest(obj)

    obj=convertStringsToChars(obj);

    if ischar(obj)
        prefix=strtok(obj,'|');
        [~,~,ext]=fileparts(prefix);
        switch ext
        case '.mldatx'
            yesno=true;
        case '.m'
            [~,yesno]=rmiml.RmiMUnitData.isMUnitFile(prefix);
        otherwise
            yesno=false;
        end
    else
        yesno=false;
    end
end


