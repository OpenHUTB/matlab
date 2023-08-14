function[entries,default]=getAvailableTFLEntries(currentSel,isERTTarget,tgtLang,tgtLangStd,prodHWDeviceVendor,prodHWDeviceType)



    inParser=inputParser;
    inParser.addRequired('IsERTTarget',@(x)islogical(x));
    inParser.addRequired('TargetLang',@(x)ischar(x));
    inParser.addRequired('TargetLangStandard',@(x)ischar(x));
    inParser.addRequired('ProdHWDeviceVendor',@(x)ischar(x));
    inParser.addRequired('ProdHWDeviceType',@(x)ischar(x));
    inParser.parse(isERTTarget,tgtLang,tgtLangStd,prodHWDeviceVendor,prodHWDeviceType);


    params=inParser.Results;
    switch(params.TargetLang)
    case 'option.TargetLang.C'
        params.TargetLang='C';
    case 'option.TargetLang.CPP'
        params.TargetLang='C++';
    otherwise
        error('Unknown TargetLang!');
    end

    if(params.IsERTTarget)
        params.IsERTTarget='on';
    else
        params.IsERTTarget='off';
    end




    if isempty(params.TargetLangStandard)
        params.TargetLangStandard='Auto';
    end



    crlConfig=coder.config('lib','ecoder',isERTTarget);
    crlConfig.TargetLang=params.TargetLang;
    crlConfig.TargetLangStandard=params.TargetLangStandard;
    params.TargetLangStandard=emlcprivate('getActualTargetLangStandard',crlConfig);

    try
        tr=emcGetTargetRegistry();
        entries=[{'None'};coder.internal.getTflList4Target(tr,params.ProdHWDeviceVendor,params.ProdHWDeviceType,params)];
        if(~ismember(currentSel,entries))
            entries=[entries;{currentSel}];
        end
    catch me
        entries={me.message};
    end

    default=entries{1};
end
