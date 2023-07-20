classdef RandGeneratorUtilities





    properties(Constant,Access=public)
        RandomGenerator=RandStream('dsfmt19937','Seed','shuffle');
    end
end