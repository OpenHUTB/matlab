classdef(Hidden)PositioningSystemBase<matlab.System




%#codegen 

    methods
        function obj=PositioningSystemBase()
            coder.allowpcode('plain');
            if isempty(coder.target)
                try
                    [navSuccess,sfttSuccess]=fusion.internal.PositioningHandleBase.checkoutLicense;
                    success=navSuccess|sfttSuccess;
                    assert(success,message(...
                    'shared_positioning:internal:Common:NoLicense'));
                catch ME
                    throwAsCaller(ME);
                end
            end
        end
    end

end
