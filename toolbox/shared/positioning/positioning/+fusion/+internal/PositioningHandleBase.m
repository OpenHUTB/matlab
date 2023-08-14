classdef(Hidden)PositioningHandleBase<handle




%#codegen 

    methods
        function obj=PositioningHandleBase()
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

    methods(Hidden,Sealed,Static)
        function[navSuccess,sfttSuccess]=checkoutLicense






            [navSuccess,sfttSuccess]=implementCheckoutLogic(@checkoutNav,@checkoutSFTT);
        end
        function[navSuccess,sfttSuccess]=testLicense





            [navSuccess,sfttSuccess]=implementCheckoutLogic(@testNav,@testSFTT);
        end
    end
end

function[navSuccess,sfttSuccess]=implementCheckoutLogic(doNav,doSFTT)





















    navSuccess=false;
    sfttSuccess=false;


    isSFTTUsed=~isempty(builtin('license','inuse',...
    'Sensor_Fusion_and_Tracking'));
    isNavUsed=~isempty(builtin('license','inuse',...
    'Navigation_Toolbox'));





    if(~isNavUsed&&~isSFTTUsed)

        navSuccess=doNav();
        if~navSuccess
            sfttSuccess=doSFTT();
        end

    elseif(~isNavUsed&&isSFTTUsed)

        sfttSuccess=doSFTT();

    else
        navSuccess=doNav();

    end
end














function navSuccess=checkoutNav

    navSuccess=false;
    canUseNav=testNav();
    if canUseNav
        navSuccess=builtin('license','checkout',...
        'Navigation_Toolbox');
    end
end

function sfttSuccess=checkoutSFTT

    sfttSuccess=false;
    canUseSFTT=testSFTT();
    if canUseSFTT
        sfttSuccess=builtin('license','checkout',...
        'Sensor_Fusion_and_Tracking');
    end
end

function canUseNav=testNav()

    canUseNav=builtin('license','test','Navigation_Toolbox');
end

function canUseSFTT=testSFTT()

    canUseSFTT=builtin('license','test','Sensor_Fusion_and_Tracking');
end
