function DecouplingLineBlock(nl,sps)





    if sps.PowerguiInfo.Discrete==0
        idx1=nl.filter_type('Decoupling Line');
        idx3=nl.filter_type('Decoupling Line (Three-Phase)');

        if~isempty(idx1)||~isempty(idx3)
            message='Your model contains Decoupling Line blocks that require a discrete solver in Powergui block.';
            Erreur.message=char(message);
            Erreur.identifier='SpecializedPowerSystems:Powergui:IncompatibleBlocks';
            psberror(Erreur);
        end
    end