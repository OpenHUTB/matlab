function[hasRD,rdInfo]=getReferenceDesignInfo(fpgaModel)







    hasRD=false;
    rdInfo=[];

    if~isempty(fpgaModel)&&dig.isProductInstalled('HDL Coder')
        workFlow=hdlget_param(fpgaModel,'WorkFlow');
        if~strcmpi(workFlow,'IP Core Generation')
            return;
        end
        ipBoardObj=hdlturnkey.plugin.IPBoardList;
        rdInfo.RDBoardName=hdlget_param(fpgaModel,'TargetPlatform');
        [isIn,hP]=isInList(ipBoardObj,rdInfo.RDBoardName);
        if isIn
            pluginFile=[hP.PluginPackage,'.hdlcoder_ref_design_customization'];
            if~isempty(which(pluginFile))
                rdInfo.RDName=hdlget_param(fpgaModel,'ReferenceDesign');
                mws=get_param(fpgaModel,'ModelWorkspace');
                if hasVariable(mws,'ReferenceDesignInfo')
                    ReferenceDesignInfo=getVariable(mws,'ReferenceDesignInfo');
                    if isfield(ReferenceDesignInfo,'VivadoVersion')
                        VivadoVersion=ReferenceDesignInfo.VivadoVersion;
                    else
                        VivadoVersion='';
                    end
                else
                    VivadoVersion='';
                end
                allPlugins=eval(pluginFile);
                allRDObjs=cellfun(@(x)eval(x),allPlugins,'UniformOutput',false);
                if isempty(VivadoVersion)
                    rdObj=findobj([allRDObjs{:}],'ReferenceDesignName',rdInfo.RDName);
                    if numel(rdObj)>1

                        rdObj=rdObj(1);
                    end
                else
                    indx=cellfun(@(x)strcmp(x.ReferenceDesignName,rdInfo.RDName)&&...
                    any(strcmp(x.SupportedToolVersion,VivadoVersion)),allRDObjs);
                    rdObj=allRDObjs{indx};
                end
                if~isempty(rdObj)
                    hasRD=true;
                    if isempty(VivadoVersion)
                        rdInfo.SupportedToolVersion=rdObj.SupportedToolVersion;
                    else
                        rdInfo.SupportedToolVersion={VivadoVersion};
                    end
                    rdInfo.HasProcessingSystem=rdObj.HasProcessingSystem;
                    if any(strcmpi(rdObj.getInterfaceIDList,'AXI4-Lite'))
                        rdInfo.DUTBaseAddress=rdObj.getInterface('AXI4-Lite').BaseAddress;
                        rdInfo.RegisterInterface='AXI4-Lite';


                        if iscell(rdInfo.DUTBaseAddress)
                            rdInfo.DUTBaseAddress=rdInfo.DUTBaseAddress{1};
                        end
                    elseif any(strcmpi(rdObj.getInterfaceIDList,'AXI4'))
                        rdInfo.DUTBaseAddress=rdObj.getInterface('AXI4').BaseAddress;
                        rdInfo.RegisterInterface='AXI4';


                        if iscell(rdInfo.DUTBaseAddress)
                            rdInfo.DUTBaseAddress=rdInfo.DUTBaseAddress{1};
                        end
                    end
                end
            end
        end
    end

end