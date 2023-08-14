function initialize(h,modelName)




    if nargin>1
        modelName=convertStringsToChars(modelName);
    end

    h.modelName=modelName;

    if~isempty(h.testComp)

        h.browserparam1(1)=0;
        h.browserparam1(2)=0;
        h.browserparam1(3)=0;
        h.browserparam1(4)=0;
        h.browserparam1(5)=0;
        h.browserparam1(6)=0;
        h.browserparam1(7)=0;
        if Sldv.utils.isPathBasedTestGeneration(h.testComp.activeSettings)
            h.browserparam1(8)=0;
            h.browserparam1(9)=0;
            h.browserparam1(10)=0;
            h.browserparam1(11)=0;
        end
        h.browserparam1(12)=0;
        h.browserparam1(13)=0;
        h.browserparam2=0;


        h.abortSignal=false;


        h.mode=h.testComp.activeSettings.Mode;




        h.progressHTML;

        h.lastRefresh=clock;
    end
