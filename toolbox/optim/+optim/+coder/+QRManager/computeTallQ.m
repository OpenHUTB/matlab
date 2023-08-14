function obj=computeTallQ(obj)















%#codegen

    coder.allowpcode('plain');


    obj=optim.coder.QRManager.computeQ_(obj,obj.minRowCol);
end

