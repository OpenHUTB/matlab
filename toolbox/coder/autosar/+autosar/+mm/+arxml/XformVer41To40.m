classdef XformVer41To40<autosar.mm.arxml.XformVer42To41




    methods
        function self=XformVer41To40(varargin)

            self@autosar.mm.arxml.XformVer42To41(varargin{:});

            self.registerPreTransform('LOWER-LIMIT',@self.preProcessLowerUpperLimit);
            self.registerPreTransform('UPPER-LIMIT',@self.preProcessLowerUpperLimit);
        end

        function retSeq=preProcessLowerUpperLimit(~,inputCtx)


            retSeq=M3I.ContextSequence;
            context=inputCtx;

            if strcmp(inputCtx.getValue,'-INF')||strcmp(inputCtx.getValue,'INF')
                for ii=1:inputCtx.getAttributeCount
                    if strcmp(inputCtx.getAttributeLocalName(ii),'INTERVAL-TYPE')

                        context.setAttribute(ii,inputCtx.getAttributeNamespace(ii),...
                        'INTERVAL-TYPE','INFINITE');
                        context.setValueElement('');
                    end

                end
            end

            retSeq.addContext(context);
        end


    end
end


