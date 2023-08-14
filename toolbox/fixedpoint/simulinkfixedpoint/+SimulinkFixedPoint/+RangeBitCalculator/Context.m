classdef Context<handle






    properties(Access=private)
        Signed;
        WordLengths;
        FractionLengths;
    end
    methods
        function this=Context(signed,wordLengths,fractionLengths)
            this.Signed=signed;
            this.WordLengths=wordLengths;
            this.FractionLengths=fractionLengths;
        end
        function signed=getSigned(this)


            signed=this.Signed;
        end
        function wordLengths=getWordLengths(this)


            wordLengths=this.WordLengths;
        end
        function fractionLengths=getFractionLengths(this)


            fractionLengths=this.FractionLengths;
        end
    end
end
