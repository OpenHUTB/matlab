classdef abstractRegisterProduct<hdldefaults.abstractReg



    methods
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        this=abstractProduct(block)
        v=validateProductBlock(this,hC)
        v=validateProductTreeCascade(this,hC)
    end
end

