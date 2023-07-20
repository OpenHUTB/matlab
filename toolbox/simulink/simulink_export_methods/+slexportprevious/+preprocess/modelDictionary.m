function modelDictionary(obj)




    if isR2021bOrEarlier(obj.ver)



        if slfeature('BreakpointsAsModelArguments')>=1



            dictBd=get_param(obj.modelName,'DictionarySystem');
            paramsArray=dictBd.Parameter.toArray;
            for param=paramsArray
                if isa(param,'slid.Breakpoint')&&...
                    param.Argument
                    param.Argument=false;
                end
            end
        end
    end
end
