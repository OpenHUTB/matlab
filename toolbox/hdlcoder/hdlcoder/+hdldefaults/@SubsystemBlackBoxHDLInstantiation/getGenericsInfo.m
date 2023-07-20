function genericsList=getGenericsInfo(this)




    genericsListStr=this.getImplParams('GenericList');


    if isempty(genericsListStr)
        genericsList={};
        return;
    end

    try

        genericsList=evalin('base',genericsListStr);
    catch ME
        rethrow(ME);
    end



