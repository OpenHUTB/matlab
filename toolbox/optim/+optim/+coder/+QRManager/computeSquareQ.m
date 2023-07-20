function obj=computeSquareQ(obj)















%#codegen

    coder.allowpcode('plain');


    obj=optim.coder.QRManager.computeQ_(obj,obj.mrows);
end

