classdef(Abstract)ServerInterface<handle





    methods(Abstract)
        [output1,output2]=getEvolution(h,input1);
        [output1,output2]=createEvolution(h,input1);
        [output1,output2]=updateEvolution(h);
        output=deleteEvolutions(h,input1);
        output=deleteSingleEvolution(h,input1);
        output=compareFiles(h,input1);

    end
end

