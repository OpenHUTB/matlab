function licType=focsharedtest(block)







    maskObj=get_param(block,'MaskObject');
    maskVars=maskObj.Parameters;
    maskVars=maskVars(strcmp({maskVars.Name},'focMode'));
    if isempty(maskVars)
        licType='1';
    else
        licType=maskVars.Value;
        while strcmp(licType,'focMode')
            block=get_param(block,'Parent');
            if isempty(get_param(block,'Parent'))

                if bdIsLibrary(block)
                    licType='-1';
                    break
                else
                    licType='1';
                    break
                end
            else
                chkMask=get_param(block,'MaskType');
                maskObj=get_param(block,'MaskObject');
                if strcmp(block,bdroot)

                    licType='1';
                    break
                elseif~isempty(chkMask)&&~isempty(maskObj)

                    maskVars=maskObj.Parameters;
                    maskVars=maskVars(strcmp({maskVars.Name},'focMode'));
                    if isempty(maskVars)

                        licType='focMode';
                    else

                        licType=maskVars.Value;
                    end
                else


                    licType='focMode';
                end
            end
        end
    end
end