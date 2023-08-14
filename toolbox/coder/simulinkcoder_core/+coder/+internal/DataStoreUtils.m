


classdef DataStoreUtils<handle
    methods(Static,Access=public)
        function dsmInfo=getNeededDSMInfo(ssBlkHdl)
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            try
                blkObj=get_param(ssBlkHdl,'Object');
                dsmInfo=blkObj.getNeededDSMemBlks();
            catch exc %#ok<NASGU>
                dsmInfo=[];
            end
            delete(sess);
        end


        function strPrm=convDSMInfoToPortPrm(dsmInfo)
            strPrm.CompiledPortDataType=dsmInfo.CompiledAliasedThruDataType;
            strPrm.AliasPortDataType=dsmInfo.CompiledDataType;
            strPrm.CompiledPortDimensions=dsmInfo.CompiledDimensions;
            strPrm.CompiledPortComplexSignal=dsmInfo.CompiledComplexSignal;
            strPrm.CompiledPortFrameData=0;
            strPrm.isFixPt=0;
            strPrm.isScaledDouble=0;
            dt=strPrm.CompiledPortDataType;
            if(fixed.internal.type.isNameOfTraditionalFixedPointType(dt))
                [~,isScaledDouble]=fixdt(dt);
                strPrm.isScaledDouble=isScaledDouble;
                strPrm.isFixPt=1;
            end
        end
    end
end
