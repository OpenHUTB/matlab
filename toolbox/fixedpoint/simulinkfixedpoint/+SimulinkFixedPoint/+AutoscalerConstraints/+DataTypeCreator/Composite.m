classdef Composite<SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.Interface





    methods
        function this=Composite(dataTypeCreator1,dataTypeCreator2)
            dataType1=dataTypeCreator1.DataType;
            dataType2=dataTypeCreator2.DataType;



            fiObject=fi([],dataType1)+fi([],dataType2);
            dataType=fiObject.numerictype;
            dataType.WordLength=dataType.WordLength-1;
            this.DataType=dataType;


            this.Values=[dataTypeCreator1.Values,dataTypeCreator2.Values];
        end
    end
end


