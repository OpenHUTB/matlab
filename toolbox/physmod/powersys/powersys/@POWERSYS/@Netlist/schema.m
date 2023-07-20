function schema





    pkg=findpackage('POWERSYS');
    cls=schema.class(pkg,'Netlist');

    pElements=schema.prop(cls,'elements','MATLAB array');
    pElements.AccessFlags.PublicSet='off';

    pNodes=schema.prop(cls,'nodes','MATLAB array');
    pNodes.AccessFlags.PublicSet='off';

    pPorts=schema.prop(cls,'ports','MATLAB array');
    pPorts.AccessFlags.PublicSet='off';
    pPorts.AccessFlags.PublicGet='off';

    pPortToNode=schema.prop(cls,'portToNode','MATLAB array');
    pPortToNode.AccessFlags.PublicSet='off';
    pPortToNode.AccessFlags.PublicGet='off';


    pReservedNode=schema.prop(cls,'reservednode','MATLAB array');
    pReservedNode.AccessFlags.PublicSet='off';


