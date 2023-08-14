function aeroLic=aerosharedtest(block)







    maskObj=get_param(block,'MaskObject');
    maskVars=maskObj.Parameters;
    maskVars=maskVars(strcmp({maskVars.Name},'aMode'));
    if isempty(maskVars)
        licType='0';
    else
        licType=maskVars.Value;
        while strcmp(licType,'aMode')
            block=get_param(block,'Parent');
            if isempty(get_param(block,'Parent'))

                if bdIsLibrary(block)
                    licType='-1';
                    break
                else
                    licType='0';
                    break
                end
            else
                chkMask=get_param(block,'MaskType');
                maskObj=get_param(block,'MaskObject');
                if strcmp(block,bdroot)

                    licType='0';
                    break
                elseif~isempty(chkMask)&&~isempty(maskObj)

                    maskVars=maskObj.Parameters;
                    maskVars=maskVars(strcmp({maskVars.Name},'aMode'));
                    if isempty(maskVars)

                        licType='aMode';




                    elseif~isempty(find(contains(getPTBSBlks,get_param(block,'ReferenceBlock')),1))&&strcmp(maskVars.Value,'aMode')
                        licType='1';
                        break
                    else

                        licType=maskVars.Value;
                    end
                else


                    licType='aMode';
                end
            end
        end
    end
    aeroshared(licType);
    if strcmp(licType,'0')||strcmp(licType,'-1')
        aeroLic=true;
    else
        aeroLic=false;
    end
end
function allPTBSBlks=getPTBSBlks(~)
    allPTBSBlks=cell(6,1);
    allPTBSBlks{1,1}='autolibshared/Vehicle Body 1DOF Longitudinal';
    allPTBSBlks{2,1}='autolibshared/Vehicle Body 3DOF Longitudinal';
    allPTBSBlks{3,1}='autolibshared/Vehicle Body Total Road Load';
    allPTBSBlks{4,1}='autolibvehdynlong/Vehicle Body 1DOF Longitudinal';
    allPTBSBlks{5,1}='autolibvehdynlong/Vehicle Body 3DOF Longitudinal';
    allPTBSBlks{6,1}='autolibvehdynlong/Vehicle Body Total Road Load';
end