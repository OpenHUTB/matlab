function out=isReservedReqSetName(~,name)






    [~,shortName]=fileparts(name);

    out=any(strcmpi(shortName,{'default','clipboard','scratch','slinternal_scratchpad'}));

end
