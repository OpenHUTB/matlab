function lib(libInfo)
    libInfo.Name='SPICE MOSFETs';
    pinfo=ver('toolbox/physmod/elec/spice/mosfets/m');
    libInfo.Annotation=sprintf('These blocks are imported from device manufacturer SPICE subcircuits.\nOpen the originating NETLIST for further information pertaining to specific components.');
end