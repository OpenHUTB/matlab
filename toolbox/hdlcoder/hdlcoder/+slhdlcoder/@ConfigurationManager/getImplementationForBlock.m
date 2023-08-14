function[impl,implInfo]=getImplementationForBlock(this,slBlockPath)



















    impl=[];
    implInfo=[];


    try
        blockType=get_param(slBlockPath,'BlockType');
    catch me %#ok<NASGU>


        return;
    end
    blockLibPath=hdlgetblocklibpath(slBlockPath);


    if strcmpi(blockType,'SubSystem')
        [impl,implInfo]=this.localGetImplementation(...
        this.FrontEndStopTable,'built-in/SubSystem',slBlockPath);
        if isempty(impl)
            [impl,implInfo]=this.localGetImplementation(...
            this.FrontEndStopTable,blockLibPath,slBlockPath);
        end
        if~isempty(impl)||~isempty(implInfo)
            return;
        end
    end

    if~isempty(blockLibPath)



        [impl,implInfo]=this.localGetImplementation(...
        this.HereOnlyComponentTable,blockLibPath,slBlockPath);
        if~isempty(impl)
            return;
        end



        [impl,implInfo]=this.localGetImplementation(...
        this.DefaultTable,blockLibPath,this.ModelName);
        if~isempty(impl)
            return;
        end






        if strcmpi(blockType,'MATLABSystem')
            blockLibPath='built-in/MATLABSystem';
            [impl,implInfo]=this.localGetImplementation(...
            this.DefaultTable,blockLibPath,this.ModelName);
        end
    end
end



