


classdef InterfaceManager<handle

    methods(Static)
        function r=getInterfaceInstance(Name)
            switch(Name)
            case eda.internal.boardmanager.ClockInterface.Name
                r=eda.internal.boardmanager.ClockInterface;
            case eda.internal.boardmanager.ResetInterface.Name
                r=eda.internal.boardmanager.ResetInterface;
            case eda.internal.boardmanager.RGMII.Name
                r=eda.internal.boardmanager.RGMII;
            case eda.internal.boardmanager.GMII.Name
                r=eda.internal.boardmanager.GMII;
            case eda.internal.boardmanager.MII.Name
                r=eda.internal.boardmanager.MII;
            case eda.internal.boardmanager.MIIwith25MHzOut.Name
                r=eda.internal.boardmanager.MIIwith25MHzOut;
            case eda.internal.boardmanager.SGMII.Name
                r=eda.internal.boardmanager.SGMII;
            case eda.internal.boardmanager.XlnxSGMII625MhzRef.Name
                r=eda.internal.boardmanager.XlnxSGMII625MhzRef;
            case eda.internal.boardmanager.XlnxSGMII.Name
                r=eda.internal.boardmanager.XlnxSGMII;
            case eda.internal.boardmanager.RMII.Name
                r=eda.internal.boardmanager.RMII;
            case eda.internal.boardmanager.UserdefinedInterface.Name
                r=eda.internal.boardmanager.UserdefinedInterface;
            case eda.internal.boardmanager.AltJTAG.Name
                r=eda.internal.boardmanager.AltJTAG;
            case eda.internal.boardmanager.Arria10SGMII.Name
                r=eda.internal.boardmanager.Arria10SGMII;
            case{eda.internal.boardmanager.DigilentJTAG.Name,'JTAG (via Digilent cable)'}
                r=eda.internal.boardmanager.DigilentJTAG;
            otherwise
                error(message('EDALink:boardmanager:UnknownInterface',Name));
            end
        end
        function r=isTurnkeyInterfaceSupported(~,FPGAFamily)
            switch FPGAFamily
            case{'Kintex7','Virtex7'}
                r=true;
            case eda.internal.fpgadevice.getXilinxVivadoFPGAFamilies
                r=false;
            otherwise
                r=true;
            end
        end
        function r=getSupportedFILInterfaces(FPGAVendor,FPGAFamily)
            r={};



            if isempty(FPGAVendor)||isempty(FPGAFamily)
                r{end+1}=eda.internal.boardmanager.MII;
                return;
            end


            if any(strcmpi(FPGAFamily,{'Spartan3','Spartan3A and Spartan3AN','Spartan3E','Spartan-3A DSP'}))
                return;
            end

            if strcmpi(FPGAVendor,'Altera')

                r{end+1}=eda.internal.boardmanager.AltJTAG;

                if any(strcmpi(FPGAFamily,{'Stratix IV','Stratix V'}))
                    r{end+1}=eda.internal.boardmanager.SGMII;
                elseif strcmpi(FPGAFamily,'Arria 10')
                    r{end+1}=eda.internal.boardmanager.Arria10SGMII;
                end
                r{end+1}=eda.internal.boardmanager.GMII;
                r{end+1}=eda.internal.boardmanager.RGMII;
                r{end+1}=eda.internal.boardmanager.MII;
            elseif strcmpi(FPGAVendor,'Xilinx')
                if any(strcmpi(FPGAFamily,eda.internal.fpgadevice.getXilinxVivadoFPGAFamilies))

                    r{end+1}=eda.internal.boardmanager.DigilentJTAG;

                    if~startsWith(FPGAFamily,'zynq','IgnoreCase',true)
                        r{end+1}=eda.internal.boardmanager.GMII;
                        r{end+1}=eda.internal.boardmanager.RGMII;
                        r{end+1}=eda.internal.boardmanager.XlnxSGMII;
                        r{end+1}=eda.internal.boardmanager.XlnxSGMII625MhzRef;
                        r{end+1}=eda.internal.boardmanager.RMII;
                        r{end+1}=eda.internal.boardmanager.MII;
                        r{end+1}=eda.internal.boardmanager.MIIwith25MHzOut;
                    end
                else


                    r{end+1}=eda.internal.boardmanager.GMII;
                    r{end+1}=eda.internal.boardmanager.RGMII;
                    r{end+1}=eda.internal.boardmanager.MII;
                end
            end
        end
    end
end

