
















function FlaggedPorts=getPortsUnderspecBO(system,hBusObjports)

    FlaggedPorts=cell(0,4);

    if~isempty(hBusObjports)

        for n=1:size(hBusObjports,1)

            UsedVars=Simulink.findVars(hBusObjports(n,1),'SearchMethod','cached');


            TempParagraph=ModelAdvisor.Paragraph;
            TempParagraph.CollapsibleMode='all';
            TempParagraph.setDefaultCollapsibleState('collapsed');

            NumViolatingBusElements=0;

            for ni=1:size(UsedVars,1)



                if existsInGlobalScope(system,UsedVars(ni,1).Name)

                    Bus=evalinGlobalScope(system,UsedVars(ni,1).Name);

                    if isa(Bus,'Simulink.Bus')
                        for nii=1:size(Bus.Elements,1)



                            dataTypeStr=Bus.Elements(nii).DataType;

                            if~(loc_isBusType(bdroot(system),dataTypeStr)||...
                                Advisor.Utils.Simulink.isEnumOutDataTypeStr(system,dataTypeStr))&&...
                                (isempty(Bus.Elements(nii).Min)||isempty(Bus.Elements(nii).Max))

                                TempParagraph.addItem([ModelAdvisor.Text([UsedVars(ni,1).Name,'.',Bus.Elements(nii).Name]),...
                                ModelAdvisor.LineBreak]);
                                NumViolatingBusElements=NumViolatingBusElements+1;
                            end
                        end
                    end
                end
            end

            if NumViolatingBusElements>0

                TempParagraph.setHiddenContent(sprintf('%i bus element(s)',NumViolatingBusElements));


                FlaggedPorts{end+1,1}=str2double(get_param(hBusObjports(n,1),'Port'));%#ok<AGROW>
                FlaggedPorts{end,2}=ModelAdvisor.Text(hBusObjports{n,1});
                FlaggedPorts{end,3}=[ModelAdvisor.Text(get_param(hBusObjports{n,1},'OutDataTypeStr')),...
                ModelAdvisor.LineBreak,TempParagraph.copy];
                FlaggedPorts{end,4}=4;
            end
        end
    end
end

function s=loc_isBusType(model,dataTypeStr)
    s=false;

    if strncmp(dataTypeStr,'Bus',3)
        s=true;
    else




        if isvarname(dataTypeStr)&&existsInGlobalScope(model,dataTypeStr)
            s=evalinGlobalScope(model,['isa(',dataTypeStr,',''Simulink.Bus'')']);
        end
    end
end