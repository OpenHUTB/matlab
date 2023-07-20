classdef HasMultiword<SimulinkFixedPoint.AutoscalerConstraints.Multiword.Interface






    methods(Access=?SimulinkFixedPoint.AutoscalerConstraints.Multiword.Factory)
        function this=HasMultiword(wordLength)

            this.WordLength=int16(wordLength);
        end
    end
    methods
        function multiwordSum=plus(this,other)


            multiwordSum=this;
            if isLesserThan(other,this.WordLength)
                multiwordSum=other;
            end
        end
        function flag=isLesserThan(this,wordLength)


            flag=this.WordLength<wordLength;
        end
    end
end


