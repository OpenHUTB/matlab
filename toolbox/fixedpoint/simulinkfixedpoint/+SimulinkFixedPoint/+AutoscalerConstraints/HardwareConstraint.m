classdef(Abstract)HardwareConstraint<SimulinkFixedPoint.AutoscalerConstraints.CompositeFixedPointConstraint











    properties(SetAccess=protected)

        Multiword=[];
    end

    properties(SetAccess=protected)
        ModelName={};
    end

    methods(Abstract,Access=protected)

        wordLengths=getWordLengthsToDisplay(this);
    end

    methods
        function this=HardwareConstraint(modelNamesCell)



            this.ModelName=modelNamesCell;


            this.Object={};
            for ii=1:numel(this.ModelName)

                modelObject=get_param(this.ModelName{ii},'Object');


                this.Object=[this.Object,{modelObject}];
            end


            this.ElementOfObject=getString(message('SimulinkFixedPoint:autoscaling:HardwareSettings'));
        end
    end

    methods
        function comments=getComments(this)


            wordlengths=getWordLengthsToDisplay(this);
            comments={getString(message('SimulinkFixedPoint:autoscaling:GetHardwareConstraint',...
            this.ElementOfObject,getFullName(this),wordlengths))};
        end

        function fullName=getFullName(this)

            fullName='';
            if numel(this.Object)==1

                fullName=this.Object{1}.getFullName;
            else



                for ii=1:numel(this.Object)-1
                    fullName=[fullName,this.Object{ii}.getFullName,', '];%#ok<AGROW>
                end
                fullName(end-1:end)=[];

                fullName=[fullName,' and ',this.Object{end}.getFullName];
            end
        end

        function dataType=snapDataType(this,dataType)

            dataType=snapDataType(this.ChildConstraint,dataType);
        end

        function flag=hasConflict(this)

            flag=hasConflict(this.ChildConstraint);
        end

        function comments=getConflictComments(this)

            comments=getConflictComments(this.ChildConstraint);
        end
    end

    methods(Hidden)
        function setMultiword(this,multiword)


            this.Multiword=multiword;
        end
    end
end



