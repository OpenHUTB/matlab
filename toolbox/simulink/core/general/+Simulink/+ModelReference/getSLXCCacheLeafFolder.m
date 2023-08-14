function[leafFolder]=getSLXCCacheLeafFolder()











    leafFolder='';

    if sfpref('UseLCC64ForSimulink')





        if ispc


            leafFolder=loc_addArchPrefix('LCC64');
        end
    else






        selectedCfg=mex.getCompilerConfigurations('C','Selected');




        if loc_configurationIsSupported(selectedCfg)









            if loc_mexSetupDoesNotErrorForSelectedConfig(selectedCfg)

                leafFolder=loc_addArchPrefix(selectedCfg.ShortName);
            end
        end
    end
end





function[leafFolder]=loc_addArchPrefix(compilerFolderName)


    platformFolderName=computer('arch');



    assert(~isempty(platformFolderName));
    assert(~isempty(compilerFolderName));



    leafFolder=fullfile(platformFolderName,compilerFolderName);
end









function[configurationIsSupported]=loc_configurationIsSupported(selectedCfg)



    configurationIsSupported=false;

    if~isempty(selectedCfg)
        supportedCfgs=mex.getCompilerConfigurations('C','Supported');
        numSupportedCfgs=numel(supportedCfgs);



        if isequal(class(selectedCfg),class(supportedCfgs))&&(numSupportedCfgs>0)









            propertyNames=properties(class(selectedCfg));
            propertyNamesToCheck=setxor(propertyNames,{'MexOpt','Priority','Details'});



            for supportedCfgIndex=1:numSupportedCfgs

                thisConfig=supportedCfgs(supportedCfgIndex);

                thisConfigMatches=true;



                for propertyNameIndex=1:numel(propertyNamesToCheck)


                    aPropName=propertyNamesToCheck{propertyNameIndex};




                    if~isequal(thisConfig.(aPropName),selectedCfg.(aPropName))
                        thisConfigMatches=false;

                        break;
                    end
                end

                if thisConfigMatches



                    configurationIsSupported=true;

                    break;
                end
            end
        end
    end
end











function[cfgDoesNotError]=loc_mexSetupDoesNotErrorForSelectedConfig(selectedCfg)

    if~isempty(selectedCfg)
        try



            evalc(['mex -setup:',selectedCfg.ShortName]);

            cfgDoesNotError=true;
        catch


            cfgDoesNotError=false;
        end
    end
end
