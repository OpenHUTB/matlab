



classdef InstanceDb<sldv.code.internal.InstanceDb

    methods



        function this=InstanceDb()
            this.Analyzers={};
        end




        function[analysis,info]=getAnalysisInfo(this,entryName,entryInfo,analysisMode,varargin)
            if nargin<5
                simMode='SIL';
            else
                simMode=varargin{1};
            end
            info=[];
            analysis=[];

            for ii=1:numel(this.Analyzers)
                currentAnalysis=this.Analyzers{ii};

                currentInfo=currentAnalysis.getDescriptorFor(...
                entryName,entryInfo,analysisMode,simMode);

                if~isempty(currentInfo)
                    info=currentInfo;
                    analysis=currentAnalysis;
                    return
                end
            end
        end
    end
end
