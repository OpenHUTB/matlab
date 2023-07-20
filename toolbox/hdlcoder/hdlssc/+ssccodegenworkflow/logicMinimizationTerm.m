classdef(Sealed=true,Hidden=true)logicMinimizationTerm<handle







    properties

        indecies=[];

        dcIndex=[];


        irrBits=[];


        numberOfOnes=[];


        prime=true;
    end

    methods
        function obj=logicMinimizationTerm(indecies_in,dcIndex_in,irrBits_in,numberOfOnes_in)


            if nargin<1
                indecies_in=[];
            end
            if nargin<2
                dcIndex_in=[];
            end
            if nargin<3
                irrBits_in=[];
            end
            if nargin<4
                numberOfOnes_in=[];
            end

            obj.indecies=indecies_in;
            obj.dcIndex=dcIndex_in;
            obj.irrBits=irrBits_in;
            obj.numberOfOnes=numberOfOnes_in;
        end

        function newTerm=combine(obj,termIn,irrBit)

            newIndices=unique([obj.indecies,termIn.indecies]);
            newDcIndices=unique([obj.dcIndex,termIn.dcIndex]);
            irrbits=unique([obj.irrBits,termIn.irrBits,irrBit]);


            newNumberOfOnes=min([obj.numberOfOnes,termIn.numberOfOnes]);

            newTerm=ssccodegenworkflow.logicMinimizationTerm(newIndices,newDcIndices,irrbits,newNumberOfOnes);
        end
        function[ind,dc]=getFirstIndex(obj)
            if isempty(obj.indecies)
                dc=1;
                ind=obj.dcIndex(1);
            else
                dc=0;
                ind=obj.indecies(1);
            end
        end



    end
end

