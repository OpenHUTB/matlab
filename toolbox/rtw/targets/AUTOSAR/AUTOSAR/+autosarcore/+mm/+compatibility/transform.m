



function obj=transform()







    obj=autosarcore.mm.compatibility.TransformerChain;





    obj.addNewVersion(8.2000,...
    @autosarcore.mm.compatibility.internal.exportR14aToR13b,...
    @autosarcore.mm.compatibility.internal.importR14aFromR13b);

    obj.addNewVersion(8.3000,...
    @autosarcore.mm.compatibility.internal.exportR14bToR14a,...
    @autosarcore.mm.compatibility.internal.importR14bFromR14a);

    obj.addNewVersion(8.4000,...
    @autosarcore.mm.compatibility.internal.exportR15aToR14b,...
    @autosarcore.mm.compatibility.internal.importR15aFromR14b);

    obj.addNewVersion(8.5000,...
    @autosarcore.mm.compatibility.internal.exportR15bToR15a,...
    @autosarcore.mm.compatibility.internal.importR15bFromR15a);

    obj.addNewVersion(8.6000,...
    @autosarcore.mm.compatibility.internal.exportR16aToR15b,...
    @autosarcore.mm.compatibility.internal.importR16aFromR15b);
    obj.addNewVersion(8.7000,...
    @autosarcore.mm.compatibility.internal.exportR16bToR16a,...
    @autosarcore.mm.compatibility.internal.importR16bFromR16a);
    obj.addNewVersion(8.9000,...
    @autosarcore.mm.compatibility.internal.exportR17bToR17a,...
    @autosarcore.mm.compatibility.internal.importR17bFromR17a);
    obj.addNewVersion(9.0000,...
    @autosarcore.mm.compatibility.internal.exportR18aToR17b,...
    @autosarcore.mm.compatibility.internal.importR18aFromR17b);
    obj.addNewVersion(9.1000,...
    @autosarcore.mm.compatibility.internal.exportR18bToR18a,...
    @autosarcore.mm.compatibility.internal.importR18bFromR18a);
    obj.addNewVersion(9.2000,...
    @autosarcore.mm.compatibility.internal.exportR19aToR18b,...
    @autosarcore.mm.compatibility.internal.importR19aFromR18b);
    obj.addNewVersion(9.3000,...
    @autosarcore.mm.compatibility.internal.exportR19bToR19a,...
    @autosarcore.mm.compatibility.internal.importR19bFromR19a);
    obj.addNewVersion(10.000,...
    @autosarcore.mm.compatibility.internal.exportR20aToR19b,...
    @autosarcore.mm.compatibility.internal.importR20aFromR19b);
    obj.addNewVersion(10.100,...
    @autosarcore.mm.compatibility.internal.exportR20bToR20a,...
    @autosarcore.mm.compatibility.internal.importR20bFromR20a);
    obj.addNewVersion(10.200,...
    @autosarcore.mm.compatibility.internal.exportR21aToR20b,...
    @autosarcore.mm.compatibility.internal.importR21aFromR20b);
    obj.addNewVersion(10.300,...
    @autosarcore.mm.compatibility.internal.exportR21bToR21a,...
    @autosarcore.mm.compatibility.internal.importR21bFromR21a);
    obj.addNewVersion(10.400,...
    @autosarcore.mm.compatibility.internal.exportR22aToR21b,...
    @autosarcore.mm.compatibility.internal.importR22aFromR21b);
    obj.addNewVersion(10.500,...
    @autosarcore.mm.compatibility.internal.exportR22bToR22a,...
    @autosarcore.mm.compatibility.internal.importR22bFromR22a);
end


