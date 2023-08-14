classdef FirstPointAndSpacingTypeModifier<handle
















    properties
        FirstPoint;
        Spacing;
    end
    methods
        function this=FirstPointAndSpacingTypeModifier(firstPoint,spacing)


            firstPoint=this.castToDoubleIfSingleOrInteger(firstPoint);
            spacing=this.castToDoubleIfSingleOrInteger(spacing);








            if isfi(firstPoint)&&~isfi(spacing)
                [firstPoint,spacing]=this.fiValue1NonFiValue2(firstPoint,spacing);
            elseif~isfi(firstPoint)&&isfi(spacing)
                [spacing,firstPoint]=this.fiValue1NonFiValue2(spacing,firstPoint);
            end

            this.FirstPoint=firstPoint;
            this.Spacing=spacing;
        end
    end
    methods(Static,Access=private)



        function[value1,value2]=fiValue1NonFiValue2(value1,value2)
            if value1.isscalingslopebias

                if value1.WordLength>54


                    value1=fi(value1,1,value1.WordLength+1);
                    value2=fi(value2,1,value1.WordLength+1);
                else

                    value1=double(value1);
                end
            else



                value2=fi(value2,1,54);
            end
        end
        function value=castToDoubleIfSingleOrInteger(value)

            if isinteger(value)||isa(value,'single')
                value=double(value);
            end
        end
    end
end


