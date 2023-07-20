function setElementForConformalArray(obj,propVal)




    if~iscell(propVal)
        if~isscalar(propVal)
            excludeClass={'conformalArray','infiniteArray','pifa',...
            'dipoleCrossed','customArrayGeometry','helixMultifilar','eggCrate'};
            excludeClass1={'monopoleTopHat','helix','dipoleHelix'};
            for i=1:numel(propVal)
                if isprop(propVal(i),'Element')&&any(strcmpi(class(propVal(i).Element),{'reflectorCorner',...
                    'reflectorGrid','reflectorSpherical','reflectorCylindrical','draRectangular','draCylindrical'}))
                    error(message('antenna:antennaerrors:Unsupported',...
                    strcat(class(propVal(i).Element),' as Element'),'subArrays'));
                elseif isprop(propVal(i),'Exciter')&&(isa(propVal(i).Exciter,'dipoleCrossed')...
                    ||em.internal.checkLRCArray(propVal(i).Exciter))
                    error(message('antenna:antennaerrors:Unsupported',...
                    [class(propVal(i)),' with ',(class(propVal(i).Exciter)),...
                    ' as Exciter'],'conformalArray'));
                elseif isprop(propVal(i),'Element')&&any(strcmpi(class(propVal(i).Element),...
                    excludeClass1))&&(any((propVal(i).Element.Substrate.EpsilonR)~=1))
                    error(message('antenna:antennaerrors:Unsupported',...
                    [class(propVal(i)),' of ',(class(propVal(i).Element)),...
                    ' with dielectric as Element'],'subArrays'));
                end
            end
            setElementAsHandleArray(obj,propVal,excludeClass);
        else
            excludeClass1={'conformalArray','infiniteArray','slot',...
            'cavity','pifa','customArrayGeometry',...
            'dipoleCrossed','helixMultifilar','eggCrate'};
            excludeClass2={'helix','slot','cavity','pifa'};
            excludeClass3={'monopoleTopHat','helix','dipoleHelix'};
            for i=1:numel(propVal)
                if isprop(propVal(i),'Element')&&any(strcmpi(class(propVal(i).Element),{'reflectorCorner',...
                    'reflectorGrid','reflectorSpherical','reflectorCylindrical','draRectangular','draCylindrical'}))
                    error(message('antenna:antennaerrors:Unsupported',...
                    strcat(class(propVal(i).Element),' as Element'),'subArrays'));
                elseif isprop(propVal(i),'Exciter')&&strcmpi(class(propVal(i).Exciter),'dipoleCrossed')
                    error(message('antenna:antennaerrors:Unsupported',...
                    [class(propVal(i)),' with ',(class(propVal(i).Exciter)),...
                    ' as Exciter'],'conformalArray'));
                elseif isprop(propVal(i),'Element')&&any(strcmpi(class(propVal(i).Element),...
                    excludeClass3))&&(any((propVal(i).Element.Substrate.EpsilonR)~=1))
                    error(message('antenna:antennaerrors:Unsupported',...
                    [class(propVal(i)),' of ',(class(propVal(i).Element)),...
                    ' with dielectric as Element'],'subArrays'));
                end
            end
            setElementAsScalarHandle(obj,propVal,excludeClass1,excludeClass2);
        end
    else
        excludeClass={'conformalArray','infiniteArray',...
        'helixMultifilar','dipoleCrossed','eggCrate'};
        excludeClass1={'monopoleTopHat','helix','dipoleHelix'};
        for i=1:numel(propVal)
            if isprop(propVal{i},'Element')&&any(strcmpi(class(propVal{i}.Element),{'reflectorCorner',...
                'reflectorGrid','reflectorSpherical','reflectorCylindrical','draRectangular','draCylindrical'}))
                error(message('antenna:antennaerrors:Unsupported',...
                strcat(class(propVal{i}.Element),' as Element'),'subArrays'));
            elseif isprop(propVal{i},'Exciter')&&(strcmpi(class(propVal{i}.Exciter),...
                'dipoleCrossed')||em.internal.checkLRCArray(propVal{i}.Exciter))
                error(message('antenna:antennaerrors:Unsupported',...
                [class(propVal{i}),' with ',(class(propVal{i}.Exciter)),...
                ' as Exciter'],'conformalArray'));
            elseif isprop(propVal{i},'Element')&&any(strcmpi(class(propVal{i}.Element),...
                excludeClass1))&&(any((propVal{i}.Element.Substrate.EpsilonR)~=1))
                error(message('antenna:antennaerrors:Unsupported',...
                [class(propVal{i}),' of ',(class(propVal{i}.Element)),...
                ' with dielectric as Element'],'subArrays'));
            end

        end
        setElementAsCellArray(obj,propVal,excludeClass);
    end


    resetPrivateSubstrate(obj);


    setGroundPlaneFlags(obj,propVal)


    obj.FeedLocation=calculateFeedLocation(obj);


    setHasStructureChanged(obj);

end
