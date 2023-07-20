



function this=Options(arg)

    narginchk(0,1);

    modelH=[];
    systemH=[];
    if nargin<1
        arg='unknown';
    end

    this=pslink.Options;

    if pssharedprivate('checkString',arg)
        arg=char(arg);
    end


    if ischar(arg)&&(ismember(lower(arg),{'unknown','tl','ec','codegen'})...
        ||(pssharedprivate('isPslinkAvailable')&&strcmpi(arg,pslink.verifier.sfcn.Coder.CODER_ID))...
        ||(pssharedprivate('isPslinkAvailable')&&strcmpi(arg,pslink.verifier.slcc.Coder.CODER_ID)))
        this.coderKind=lower(arg);
    else

        [meObj,systemH]=pssharedprivate('checkSystemValidity',arg);
        if~isempty(meObj)
            throwAsCaller(meObj);
        end
        modelH=bdroot(systemH);
    end

    constructObject(this,modelH,systemH);


