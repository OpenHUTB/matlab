

function mdlRefValue=getMdlRefValue(this)
    if this.coverageSettings.MdlRefCoverage||...
        strcmp(this.ownerType,'Simulink.ModelReference')||...
        strcmp(this.ownerType,'Simulink.BlockDiagram')

        mdlRefValue='on';
    else
        mdlRefValue='off';
    end
end
