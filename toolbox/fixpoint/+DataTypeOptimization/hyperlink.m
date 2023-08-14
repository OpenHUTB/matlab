function hyperlink(obj)






    try

        if obj.isvalid

            objClass=class(obj);
            switch(objClass)
            case 'DataTypeOptimization.OptimizationResult'
                explore(obj);
            case 'fxpOptimizationOptions'
                showTolerances(obj);

            end

        end
    catch errDiag %#ok<NASGU>


    end
end