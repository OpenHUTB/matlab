function subsys=getParentBlks(blockhandles,mdlToBlkMap)





    seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    subsys=zeros(1,length(blockhandles));
    if~isempty(blockhandles)
        for index=1:length(blockhandles)
            bh=blockhandles(index);
            currentsubsys=get_param(get(bh,'Parent'),'Handle');

            if mdlToBlkMap.isKey(currentsubsys)
                currentsubsys=mdlToBlkMap(currentsubsys);

                subsyso=get(currentsubsys,'Object');
                if subsyso.isSynthesized
                    currentsubsys=subsyso.getCompiledParent;
                    syso=get(currentsubsys,'Object');
                    if syso.isSynthesized
                        currentsubsys=syso.getOriginalBlock;
                    end
                end
            end
            subsys(index)=currentsubsys;
        end

    end
end

