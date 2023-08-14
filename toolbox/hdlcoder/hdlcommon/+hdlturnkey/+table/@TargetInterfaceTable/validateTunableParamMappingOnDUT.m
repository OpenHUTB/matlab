function success=validateTunableParamMappingOnDUT(~,tunableParamMappingOnDUT)



    success=false;

    if iscell(tunableParamMappingOnDUT)&&isrow(tunableParamMappingOnDUT)
        success=true;
        for ii=1:length(tunableParamMappingOnDUT)


            tunableParamInfo=tunableParamMappingOnDUT{ii};
            if~iscellstr(tunableParamInfo)||~isrow(tunableParamInfo)||~(length(tunableParamInfo)==3)
                success=false;
                break;
            end
        end
    end

end