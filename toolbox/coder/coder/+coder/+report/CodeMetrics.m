





classdef CodeMetrics<coder.report.CodeMetricsBase

    methods
        function obj=CodeMetrics(varargin)
            if nargin>0
                if isa(varargin{1},'rtw.codemetrics.C_CodeMetrics')
                    obj.Data=varargin{1};
                else
                    obj.BuildDir=varargin{1};
                end
            end
            if nargin>1
                obj.InReportInfo=varargin{2};
            end
            if nargin>2
                obj.targetisCPP=varargin{3};
            end
            obj.forceGenHyperlinkToSource=true;
        end
        function execute(obj)
            if~isa(obj.Data,'coder.CodeMetrics')
                option=struct('targetisCPP',obj.targetisCPP);
                obj.Data=coder.CodeMetrics(obj.BuildDir,[],option);
            end
            execute@coder.report.CodeMetricsBase(obj);
        end
        function out=getTitle(~)
            out=message('Coder:reportGen:MetricsTitle').getString;
        end
        function out=getShortTitle(~)
            out=message('Coder:reportGen:MetricsLink').getString;
        end
    end
    methods(Hidden=true)
        function initMessages(obj)
            initMessages@coder.report.CodeMetricsBase(obj);
            obj.msgs.intro_msg=obj.getMessage('CodeMetricsIntroduction1');
        end
        function introduction=getHTMLIntroduction(obj)
            rtwcm=obj.Data;
            options=rtwcm.CodeMetricsOption.Target;
            types={'char','short','int','long','float','double','pointer'};
            nbit=[options.CharNumBits,options.ShortNumBits,options.IntNumBits,...
            options.LongNumBits,options.FloatNumBits,options.DoubleNumBits,...
            options.PointerNumBits];
            str='';
            for i=1:length(types)
                str=[str,'<b>',types{i},'</b> ',num2str(nbit(i)),', '];%#ok
            end
            str=[str(1:end-2),' bits'];
            intro_msg=sprintf(obj.msgs.intro_msg,str);
            intro_elem=Advisor.Element;
            intro_elem.setTag('p');
            intro_elem.setContent([intro_msg,' ',obj.msgs.disclaimer_msg]);
            introduction=intro_elem.emitHTML();
        end
    end
end


