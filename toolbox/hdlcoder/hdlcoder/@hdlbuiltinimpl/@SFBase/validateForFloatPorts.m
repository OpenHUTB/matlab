function[msgObj]=validateForFloatPorts(~,hC)



    msgObj=[];
    if targetcodegen.targetCodeGenerationUtils.isNFPMode
        allPorts=[hC.PirInputSignals;hC.PirOutputSignals];
        for itr=1:numel(allPorts)
            refType=allPorts(itr).Type.getLeafType;
            if refType.isFloatType
                msgObj=message('hdlcommon:nativefloatingpoint:Nfp_unsupported_block',getfullname(hC.SimulinkHandle));


                return;
            elseif refType.isRecordType
                memberTypes=refType.MemberTypesFlattened;
                for ii=1:numel(memberTypes)
                    if memberTypes(ii).getLeafType.isFloatType
                        msgObj=message('hdlcommon:nativefloatingpoint:Nfp_unsupported_block',getfullname(hC.SimulinkHandle));


                        return;
                    end
                end
            end
        end
    end