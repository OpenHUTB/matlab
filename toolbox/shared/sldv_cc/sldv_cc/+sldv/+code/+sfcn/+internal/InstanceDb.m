



classdef InstanceDb<sldv.code.internal.InstanceDb

    methods



        function obj=InstanceDb()

        end




        function[analysis,info]=getAnalysisInfo(this,entryName,entryInfo,analysisMode,varargin)
            info=[];
            analysis=[];

            valuatedParameterCount=-1;
            for ii=1:numel(this.Analyzers)
                currentAnalysis=this.Analyzers{ii};

                [currentInfo,currentParamCount]=currentAnalysis.getDescriptorFor(entryName,entryInfo,analysisMode);

                if~isempty(currentInfo)
                    if strcmp(entryInfo.SID,currentInfo.SID)

                        info=currentInfo;
                        analysis=currentAnalysis;
                        return
                    elseif isempty(currentInfo.SID)

                        if currentParamCount>valuatedParameterCount

                            info=currentInfo;
                            analysis=currentAnalysis;
                            valuatedParameterCount=currentParamCount;
                        end
                    end
                end
            end
        end
    end


end


