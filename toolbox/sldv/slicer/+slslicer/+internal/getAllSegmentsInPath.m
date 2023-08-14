function[allSrc,allDst,handles,vBlks]=getAllSegmentsInPath(srcP,dstP)








    modelname=bdroot(srcP);
    status=get_param(modelname,'SimulationStatus');

    if iscell(status)
        status=cell2mat(unique(status));
    end
    if strcmpi(status,'stopped')
        error('ModelSlicer:Internal:NotInCompiledMode','getAllSegmentInPath should be called for compiled model.')
    end

    utils=SystemsEngineering.SEUtil;

    [handles,vBlks,gSrc,gDst]=utils.getAllSegmentsInPath(srcP,dstP);%#ok<ASGLU>

    allSrc=[];
    allDst=[];

    for index=1:length(handles)
        currenthandle=handles(index);
        currentSrc=get(currenthandle,'SrcPortHandle');
        assert(length(currentSrc)==1);







        if isempty(get(currenthandle,'LineChildren'))

            currentDst=get(currenthandle,'DstPortHandle');
            currentSrc=repmat(currentSrc,size(currentDst));
            allSrc=[allSrc;currentSrc];%#ok<AGROW>
            allDst=[allDst;currentDst];%#ok<AGROW>
        end
    end
end
