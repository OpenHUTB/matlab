function checkProbeFeedStatusForForHeterogeneousElement(obj,propVal)

    tempElement=propVal;
    isaBackingStructureAntenna=all(arrayfun(@(x)isa(x,'em.BackingStructure'),tempElement));
    isProbeFeedEnabledProp=any(arrayfun(@(x)isprop(x,'EnableProbeFeed')&&~isempty(x.EnableProbeFeed),tempElement));

    if all(isaBackingStructureAntenna)&&any(isProbeFeedEnabledProp)
        isProbeFeedEnabled=arrayfun(@(x)x.('EnableProbeFeed'),tempElement);

        tf1=all(all(isProbeFeedEnabled));
        tf2=all(all(~isProbeFeedEnabled));
        if~tf1&&~tf2
            objtype=strjoin({'in',class(obj)});
            error(message('antenna:antennaerrors:Disallowed','Elements with and without Probe feed enabled',objtype));
        end
    end