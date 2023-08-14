function[entries,default]=getAvailableInstructionSetExtensions(currentSel,prodHWDeviceVendor,prodHWDeviceType,isERT)



    inParser=inputParser;
    inParser.addRequired('prodHWDeviceVendor',@(x)ischar(x));
    inParser.addRequired('prodHWDeviceType',@(x)ischar(x));
    inParser.parse(prodHWDeviceVendor,prodHWDeviceType);
    params=inParser.Results;

    try
        fullHWName=[params.prodHWDeviceVendor,'->',params.prodHWDeviceType];
        [~,entries]=RTW.getAvailableInstructionSets(fullHWName,isERT);

        default=RTW.getDefaultInstructionSetExtensions(fullHWName,isERT);
        if isempty(default)
            default='None';
        elseif iscell(default)
            default=default{1};
        end



        if(~ismember(currentSel,entries)&&~isempty(currentSel))
            entries=[entries;{currentSel}];
        end
        if(~ismember(default,entries))
            entries=[{default};entries];
        end
        if(~ismember('None',entries))
            entries=[{'None'};entries];
        end


        default='None';

    catch me %#ok<NASGU>
        entries='None';
        default='None';
    end
end
