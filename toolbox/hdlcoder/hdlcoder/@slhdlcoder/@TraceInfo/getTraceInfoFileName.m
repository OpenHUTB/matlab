function out=getTraceInfoFileName(h)




    out=fullfile(h.getRelativeBuildDir,'html',h.Model,'traceInfo.mat');
