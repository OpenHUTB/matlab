




function addterms(self)


    addterms(self.slSystemName);


    ports=self.PostAddtermsResetOutDataTypeStrMap.keys();
    for ii=1:length(ports)
        port=ports{ii};
        set_param(port,'OutDataTypeStr',...
        self.PostAddtermsResetOutDataTypeStrMap(port));
        set_param(port,'PortDimensions','-1');
    end
end
