classdef(Sealed)TableBuilderContext<handle




    properties(SetAccess=private)
        DataBase cell
        DescriptionGenerator FunctionApproximation.internal.memoryusagetablebuilder.TableDescriptionGenerator
        Path char
    end

    methods
        function setDataBase(this,database)

            this.DataBase=database;
        end

        function setDescriptionGenerator(this,generator)

            this.DescriptionGenerator=generator;
        end

        function setPath(this,path)

            this.Path=path;
        end
    end
end