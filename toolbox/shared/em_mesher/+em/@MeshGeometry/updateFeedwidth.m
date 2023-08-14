function feedwidth=updateFeedwidth(obj,feedwidth)




    if isprop(obj,'Exciter')&&isa(obj.Exciter,'dipoleCrossed')
        return;
    end
    if isprop(obj,'Element')&&strcmpi(class(obj.Element),'dipoleCrossed')
        if isprop(obj.Element,'Exciter')&&...
            strcmpi(class(obj.Element.Exciter),'dipoleCrossed')
            return;
        end
        return;
    end
    if isprop(obj,'Exciter')&&em.internal.checkLRCArray(obj.Exciter)&&...
        strcmpi(class(obj.Exciter.Element),'dipoleCrossed')
        return;
    end

    maxH=inf;
    if isprop(obj,'Height')
        maxH=obj.Height;
    elseif isprop(obj,'Spacing')
        maxH=obj.Spacing;
    elseif isprop(obj,'Element')
        if isprop(obj.Element,'Height')
            maxH=obj.Element.Height;
        elseif isprop(obj.Element,'Spacing')
            maxH=obj.Element.Spacing;
        end
    end

    if isprop(obj,'Exciter')&&isa(obj.Exciter,'helixMultifilar')
        return;
    end

    if isinf(maxH)
        return;
    end

    if numel(feedwidth)==1
        if feedwidth<0.05*obj.MesherStruct.Geometry.MaxFeatureSize
            maxval=getfeedwidth(obj);
            feedwidth=min(maxval,1.2*maxH);
        end
    elseif numel(feedwidth)>1
        if any(strcmpi(class(obj),{'customArrayMesh','helixMultifilar'}))
            maxval=getfeedwidth(obj);
            if any(feedwidth<0.05*maxval)
                index=feedwidth<0.05*maxval;
                feedwidth(index)=min(0.08*maxval,1.2*maxH);
            end
        elseif isprop(obj,'Exciter')&&em.internal.checkLRCArray(obj.Exciter)
            feedwidth=arrayfeedwidth(obj.Exciter,feedwidth,maxH);
        elseif~iscell(obj.Element)
            feedwidth=arrayfeedwidth(obj,feedwidth,maxH);
        else
            for m=1:numel(obj.Element)
                if feedwidth(m)<0.05*obj.Element{m}.MesherStruct.Geometry.MaxFeatureSize
                    maxval=getfeedwidth(obj.Element{m});
                    feedwidth(m)=min(maxval,1.2*maxH);
                end
            end
        end
    end

end

function maxval=getfeedwidth(obj)
    if(isprop(obj,'Exciter'))
        maxval=updateFeedwidth(obj.Exciter,getFeedWidth(obj.Exciter));
    else
        maxval=0.08*obj.MesherStruct.Geometry.MaxFeatureSize;
    end
end

function feedwidth=arrayfeedwidth(obj,feedwidth,maxH)
    if isscalar(obj.Element)
        maxval=getfeedwidth(obj.Element);
        if any(feedwidth<0.05*maxval)
            index=feedwidth<0.05*maxval;
            feedwidth(index)=min(maxval,1.2*maxH);
        end
    else
        for m=1:numel(obj.Element)
            if feedwidth(m)<0.05*obj.Element(m).MesherStruct.Geometry.MaxFeatureSize
                maxval=getfeedwidth(obj.Element(m));
                feedwidth(m)=min(maxval,1.2*maxH);

            end
        end
    end

end
