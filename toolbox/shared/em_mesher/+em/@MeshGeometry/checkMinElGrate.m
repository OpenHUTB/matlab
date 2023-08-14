function checkMinElGrate(obj,minEL,grate)









    minel=any(minEL);
    grate=any(grate);
    if minel==1&&grate==1
        flag='MinEdgeLength and GrowthRate';
    elseif grate==1
        flag='GrowthRate';
    elseif minel==1
        flag='MinEdgeLength';
    end

    list={'dipoleCylindrical','birdcage','cloverleaf','hornRidge'};
    arg=[];

    if(minel||grate)&&isempty(getParent(obj))
        if any(strcmpi(list,class(obj)))
            arg=class(obj);
        elseif isa(obj,'conformalArray')&&~isscalar(obj.Element)
            for i=1:numel(obj.Element)
                if iscell(obj.Element)&&any(strcmpi(list,class(obj.Element{i})))
                    warning(message('antenna:antennaerrors:NoEffectOfMinElGrate',flag,class(obj.Element{i})));
                    return;
                elseif any(strcmpi(list,class(obj.Element(i))))
                    warning(message('antenna:antennaerrors:NoEffectOfMinElGrate',flag,class(obj.Element(i))));
                    return;
                end
            end
        elseif isa(obj,'installedAntenna')&&~isscalar(obj.Element)
            for i=1:numel(obj.Element)
                if iscell(obj.Element)&&any(strcmpi(list,class(obj.Element{i})))
                    warning(message('antenna:antennaerrors:NoEffectOfMinElGrate',flag,class(obj.Element{i})));
                    return;
                elseif any(strcmpi(list,class(obj.Element(i))))
                    warning(message('antenna:antennaerrors:NoEffectOfMinElGrate',flag,class(obj.Element(i))));
                    return;
                end
            end
        else

            objtemp=obj;
            child=[];
            while~isempty(objtemp.MesherStruct.Child)
                child=objtemp.MesherStruct.Child;
                objtemp=child;
            end
            if~isempty(child)&&any(strcmpi(list,class(objtemp)))
                arg=class(child);
            end
        end
        if~isempty(arg)
            warning(message('antenna:antennaerrors:NoEffectOfMinElGrate',flag,arg));
        end
    end
end