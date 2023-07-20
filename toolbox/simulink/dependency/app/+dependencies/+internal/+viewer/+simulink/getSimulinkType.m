function type=getSimulinkType(node)





    persistent query
    if isempty(query)
        query=Simulink.loadsave.Query('/ModelInformation/Model/OwnerBDName');
        query.Hint=Simulink.loadsave.Hint.BlockDiagram;
    end

    file=node.Location{1};
    [~,~,ext]=fileparts(file);

    try
        switch ext
        case{'.mdl','.slx'}
            type=string(lower(Simulink.MDLInfo(file).BlockDiagramType));
            if type=="model"&&Simulink.loadsave.find(file,query)
                type="harness";
            end
        case{'.mdlp','.slxp'}
            type="protectedModel";
        case '.sldd'
            type="dictionary";
        otherwise
            type="";
        end
    catch
        type="";
    end

end
