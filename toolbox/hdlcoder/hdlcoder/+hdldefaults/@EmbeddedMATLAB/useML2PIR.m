function[val]=useML2PIR(~,hC)



    val=false;
    [~,~,isFullySupported]=slhdlcoder.SimulinkFrontEnd.getInternalLibraryBlockInfo(hC.SimulinkHandle);

    if isFullySupported&&hdlgetparameter('using_ml2pir')==1&&targetcodegen.targetCodeGenerationUtils.isNFPMode


        allPorts=[hC.PirInputSignals;hC.PirOutputSignals];
        for itr=1:numel(allPorts)
            refType=allPorts(itr).Type.getLeafType;
            if refType.isFloatType
                val=true;

                return;
            elseif refType.isRecordType
                memberTypes=refType.MemberTypesFlattened;
                for ii=1:numel(memberTypes)
                    if memberTypes(ii).getLeafType.isFloatType
                        val=true;

                        return;
                    end
                end
            end
        end
    elseif hdlgetparameter('using_ml2pir')==2

        val=true;
    end
