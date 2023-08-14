function[element,exciter,ps,fv]=dipoleCrossedLocation(Element)

    ps=0;fv=0;
    element=0;
    exciter=0;
    if isscalar(Element)
        if strcmpi(class(Element),'dipoleCrossed')
            element=1;
            ps=Element.FeedPhase;
            fv=Element.FeedVoltage;
        elseif isprop(Element,'Exciter')&&strcmpi(class(Element.Exciter),...
            'dipoleCrossed')
            exciter=1;
            ps=Element.Exciter.FeedPhase;
            fv=Element.Exciter.FeedVoltage;
        elseif isprop(Element,'Element')
            if any(isprop(Element.Element,'Element'),'all')&&strcmpi(class(Element.Element.Element),...
                'dipoleCrossed')
                element=1;
                ps=Element.Element.Element.FeedPhase;
                fv=Element.Element.Element.FeedVoltage;
            elseif strcmpi(class(Element.Element),'dipoleCrossed')
                element=1;
                ps=Element.Element.FeedPhase;
                fv=Element.Element.FeedVoltage;
                if isa(Element,'em.Array')
                    Size=prod(Element.ArraySize);
                    for i=1:Size
                        PS{1,i}=Element.Element.FeedPhase;%#ok<AGROW>
                        FV{1,i}=Element.Element.FeedVoltage;%#ok<AGROW>
                    end
                    ps=cell2mat(PS);
                    fv=cell2mat(FV);
                end
            end
        end
    else
        elem=zeros(1,numel(Element));
        exci=zeros(1,numel(Element));
        elemSub=zeros(1,numel(Element));
        for m=1:numel(Element)
            if iscell(Element)
                elem(m)=strcmpi(class(Element{m}),'dipoleCrossed');
                if isprop(Element{m},'Exciter')&&...
                    strcmpi(class(Element{m}.Exciter),'dipoleCrossed')
                    exci(m)=1;
                elseif isprop(Element{m},'Element')&&...
                    strcmpi(class(Element{m}.Element),'dipoleCrossed')
                    elemSub(m)=1;
                end
            else
                elem(m)=strcmpi(class(Element(m)),'dipoleCrossed');
                if isprop(Element(m),'Exciter')&&...
                    strcmpi(class(Element(m).Exciter),'dipoleCrossed')
                    exci(m)=1;
                elseif isprop(Element(m),'Element')&&...
                    strcmpi(class(Element(m).Element),'dipoleCrossed')
                    elemSub(m)=1;
                end
            end
        end
        if any(elem)
            element=1;
            ps=Element.FeedPhase;
            fv=Element.FeedVoltage;
        end
        if any(exci)
            exciter=1;
            ps=Element.Exciter.FeedPhase;
            fv=Element.Exciter.FeedVoltage;
        end
        if any(elemSub)
            element=1;









        end
    end
end