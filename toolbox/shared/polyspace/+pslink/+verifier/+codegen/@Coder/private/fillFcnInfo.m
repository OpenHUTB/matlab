function fillFcnInfo(self,execMap,className)

    keys=execMap.keys();
    keys=[keys{:}];
    keys(keys==-inf)=[];
    keys=sort(keys);

    if execMap.isKey(-inf)
        self.fcnInfo.init=pslink.verifier.Coder.createFcnInfoStruct();
        val=execMap(-inf);
        self.fcnInfo.init.fcn=val{1};
        self.fcnInfo.init.var=val{2};
    end

    for ii=1:numel(keys)
        if isempty(self.fcnInfo.step)
            self.fcnInfo.step=pslink.verifier.Coder.createFcnInfoStruct();
        else
            self.fcnInfo.step(end+1)=pslink.verifier.Coder.createFcnInfoStruct();
        end
        val=execMap(keys(ii));
        self.fcnInfo.step(end).fcn=val{1};
        self.fcnInfo.step(end).var=val{2};
    end
    if~isempty(self.codeInfo.TerminateFunctions)
        self.fcnInfo.term=pslink.verifier.Coder.createFcnInfoStruct();
        self.fcnInfo.term.fcn={self.codeInfo.TerminateFunctions(1).Prototype.Name};
    end

    if~isempty(className)
        self.fcnInfo.className={className};
    end

